AUPAT2  ;YZH;10-JUNE-81;PATCHING DISK SYSTEM IMAGE (CALLED BY ^AUPAT)
        W !,*7,"This subroutine should be run using the autopatch utility ^AUPAT.",!,*7 Q
START   S SUBS=0
ROU     K TBLK,PATCH G:OPT=4 VER
CHK     S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS)) I SUBS<0 K TBLK S SUBS=0,PATCH="" G PATCH
        D GET Q:ERROR  I OLDCO?1"X"."X" G CHK
        S DSKCO=$V(BLOFF,0) I DSKCO'=OLDCO S SUBS=0,TPATDA=PATDA G C1
        G CHK
C1      S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS))
        I SUBS<0 W !,"*** Patch #",PATNO," already ",$S(OPT=2:"applied to",1:"removed from")," disk",! Q
        D GET Q:ERROR  S DSK=$V(BLOFF,0) I DSK=NEWCO G C1
        W !!,"*** Patch #",PATNO," did not verify (disk patch)"
        W !,?4,"at module: ",$P(TPATDA,"/",1) W ",  offset = ",$P(TPATDA,"/",2)
        S %DO=DSKCO D ^%DO W !,?4,"contents found:  ",%DO
        W ",  contents expected:  ",$P(TPATDA,"/",$S(OPT=2:3,1:4)),! Q
PATCH   S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS))
        I SUBS<0 S BL=$S(BLK>91:BLK-92+ANSTRT,1:BLK) V -BL:"S0" G DONE
        D GET V BLOFF:0:NEWCO G PATCH
VER     S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS))
        I SUBS<0 W ?41,"Yes" Q
        D GET S DSK=$V(BLOFF,0) G:DSK=NEWCO VER S SUBS=0
V1      S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS))
        I SUBS<0 W ?41,"No" Q
        D GET G:OLDCO?1"X"."X" V1 S DSK=$V(BLOFF,0) I DSK=OLDCO G V1
        W !!,?10,"*** Both the old contents and new contents of patch #",PATNO,!,?14,"did not match current disk image",! D HEAD Q
GET     S ERROR=0,PATDA=^SYS(0,"PATCH",PATNO,SUBS),MODUL=$P(PATDA,"/",1)
        I '$D(DISK(MODUL)) S ERROR=1 W !,"*** Invalid module name: ",MODUL,", Patch #",PATNO," skipped from disk patches",! Q
        S PHYS=$P(DISK(MODUL),",",2)
        S %OD=$P(PATDA,"/",2) D ^%OD G:%OD="B" E2 S ADDR=PHYS+%OD
        S %OD=$P(PATDA,"/",$S(OPT=3:3,1:4)) I %OD["+" D G4 Q:ERROR  S NEWCO=BADDR+%OD G G2
        G:OPT=3&(%OD?1"X"."X") E3 D ^%OD G:%OD="B" E2 S NEWCO=%OD
G2      S %OD=$P(PATDA,"/",$S(OPT=3:4,1:3)) I %OD?1"X"."X" S OLDCO=%OD G G3
        I %OD["+" D G4 Q:ERROR  S OLDCO=BADDR+%OD G G3
        D ^%OD G:%OD="B" E2 S OLDCO=%OD
G3      S BLK=ADDR\1024+2,BLOFF=ADDR#1024
VIEW    I '$D(TBLK) S BL=$S(BLK>91:BLK-92+ANSTRT,1:BLK) V BL:"S0" S TBLK=BLK Q
        I TBLK'=BLK D
        .I $D(PATCH) S BL=$S(TBLK>91:TBLK-92+ANSTRT,1:TBLK) V -BL:"S0"
        .S BL=$S(BLK>91:BLK-92+ANSTRT,1:BLK) V BL:"S0" S TBLK=BLK
        Q
G4      S MODUL=$P(%OD,"+",1),%OD=$P(%OD,"+",2) D ^%OD G:%OD="B" E2
        G:'$D(DISK(MODUL)) E1 S BADDR=+DISK(MODUL) Q
E1      S ERROR=1 W ! W:OPT=4 ?10 W "*** Module ",MODUL," not in system, patch #",PATNO," skipped from disk patches",! Q
E2      S ERROR=1 W ! W:OPT=4 ?10 W "*** Bad patch data in patch #",PATNO,", line #",SUBS
        W !,?4,"Patch #",PATNO," skipped from disk patches",! Q
E3      S ERROR=1 W !,"*** Old contents not specified at line #",SUBS," (old contents = ",%OD,")"
        W !,?4,"Patch #",PATNO," cannot be reversed in disk image",! Q
DONE    S ^SYS(0,"PATCH",PATNO,0)=$S(OPT=2:"1/",1:"0/")_$P(^SYS(0,"PATCH",PATNO,0),"/",2,255),PATCT2=PATCT2+1 Q
HEAD    W:$N(^SYS(0,"PATCH",PATNO))'<0 !!,?10,"Patch #",?22,"Applied to",?37,"Applied to",!,?24,"memory",?40,"disk",! Q
