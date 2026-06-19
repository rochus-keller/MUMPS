AUPAT0  ;YZH;10-JUN-81;PATCHING MEMORY SYSTEM IMAGE (CALLED BY ^AUPAT)
        W !,*7,"This subroutine should be run using the autopatch utility ^AUPAT.",!,*7 Q
NEXT    S PATNO=$N(^SYS(0,"PATCH",PATNO)) G:PATNO<0 DONE
        I $N(^SYS(0,"PATCH",PATNO,0))<0 G NEXT
        G:$D(HTU) OPT I OPT=4 S SUBS=0 G:'$D(%ALL) INCL G VER
        G:'$D(%ALL) INCL
OPT     I +^(0)=2 W !?3,"Patch # ",PATNO," on hold." G NEXT
        D:MDB="D"!(MDB="B") START^AUPAT2 G:MDB="D" NEXT S SUBS=0
CHK     S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS)) I SUBS<0 S SUBS=0 G PATCH
        D GET G:ERROR NEXT I OLDCO?1"X"."X" G CHK
        S MEMCO=$V(ADDR,MODE) I MEMCO'=OLDCO G:$D(HTU) NEXT S SUBS=0,TPATDA=PATDA D C1 G NEXT
        G CHK
C1      S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS))
        I SUBS<0 W !,"*** Patch #",PATNO," already ",$S(OPT=2:"applied to",1:"removed from")," memory",! Q
        D GET Q:ERROR  S MEM=$V(ADDR,MODE) I MEM=NEWCO G C1
        W !!,"*** Patch #",PATNO," did not verify" W:MDB'="M" " (memory patch)"
        W !,?4,"at module: ",$P(TPATDA,"/",1) W ",  offset = ",$P(TPATDA,"/",2)
        S %DO=MEMCO D ^%DO W !,?4,"contents found:  ",%DO
        W ",  contents expected:  ",$P(TPATDA,"/",$S(OPT=2:3,1:4)),! Q
PATCH   S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS))
        I SUBS<0 S PATCT1=PATCT1+1 W:$D(HTU) !,?3,"Patch #",PATNO," applied to memory" G NEXT
        D GET V ADDR:MODE:NEWCO G PATCH
VER     S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS))
        I SUBS<0 W !,?10,PATNO,?26,"Yes" D START^AUPAT2 G NEXT
        D GET I ERROR D HEAD G NEXT
        S MEM=$V(ADDR,MODE) G:MEM=NEWCO VER S SUBS=0
V1      S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS))
        I SUBS<0 W !,?10,PATNO,?26,"No" D START^AUPAT2 G NEXT
        D GET I ERROR D HEAD G NEXT
        G:OLDCO?1"X"."X" V1 S MEM=$V(ADDR,MODE) I MEM=OLDCO G V1
        W !!,?10,"*** Both the old contents and new contents of patch #",PATNO,!,?14,"did not match current system image",! D HEAD W ?10,PATNO D START^AUPAT2 G NEXT
GET     S ERROR=0,PATDA=^SYS(0,"PATCH",PATNO,SUBS),MODUL=$P(PATDA,"/",1)
        I '$D(MEM(MODUL)) S ERROR=1 W ! W:OPT=4 !?10 W "*** Invalid module name: ",MODUL,", Patch #",PATNO," skipped" W:OPT'=4 " from memory patches" W ! Q
        S MODE=$P(MEM(MODUL),",",3),BADDR=$P(MEM(MODUL),",",2) I 'MODE,'BADDR G E1
        S %OD=$P(PATDA,"/",2) D ^%OD G:%OD="B" E2 S ADDR=BADDR+%OD
        S %OD=$P(PATDA,"/",$S(OPT=3:3,1:4)) I %OD["+" D G3 Q:ERROR  S NEWCO=BADDR+%OD G G2
        G:OPT=3&(%OD?1"X"."X") E3 D ^%OD G:%OD="B" E2 S NEWCO=%OD
G2      S %OD=$P(PATDA,"/",$S(OPT=3:4,1:3)) I %OD?1"X"."X" S OLDCO=%OD Q
        I %OD["+" D G3 Q:ERROR  S OLDCO=BADDR+%OD Q
        D ^%OD G:%OD="B" E2 S OLDCO=%OD Q
G3      S MODUL=$P(%OD,"+",1),%OD=$P(%OD,"+",2) D ^%OD G:%OD="B" E2
        G:'$D(MEM(MODUL)) E2 S BADDR=+MEM(MODUL)
        Q
E1      S ERROR=1 W ! W:OPT=4 ?10 W "*** Module ",MODUL," not in system, patch #",PATNO," skipped" W:OPT'=4 " from memory patches" W ! Q
E2      S ERROR=1 W ! W:OPT=4 ?10 W "*** Bad patch data in patch #",PATNO,", line #",SUBS
        W !,?4,"Patch #",PATNO," skipped" W:OPT'=4 " from memory patches" W ! Q
E3      S ERROR=1 W !,"*** Old contents not specified at line #",SUBS," (old contents = ",%OD,")"
        W !,?4,"Patch #",PATNO," cannot be reversed in memory",! Q
E4      I OPT=4 W !,?10,PATNO,?26,"--" D START^AUPAT2 W !!,?10,"*** Note:  Patch #",PATNO," can only be applied to disk.",! S ERROR=1 Q
        S ERROR=1 W !,"*** Patch #",PATNO," can not be ",$S(OPT=2:"applied to",1:"removed from")," memory",! Q
INCL    I '$D(%L1("*"))&('$D(%L1(PATNO))) G NEXT
        G:$D(%L2(PATNO)) NEXT G:OPT'=4 OPT G VER
DONE    K DISK,MEM,%L1,%L2 C 63 B 1 G:$D(HTU) D1 I OPT=4 W !! Q
        W:MDB'="D" !!,"** Total number of patches ",$S(OPT=2:"applied to",1:"removed from")," the memory image: ",PATCT1," **"
        W:MDB'="M" !,"** Total number of patches ",$S(OPT=2:"applied to",1:"removed from")," the disk image: ",PATCT2," **"
D1      W !!,"** ",$S(OPT=2:"Patching",1:"Removing patches")," completed **",! Q
HEAD    Q:$N(^SYS(0,"PATCH",PATNO))<0  I '$D(%ALL) Q:'$D(%L1("*"))&($N(%L1(PATNO))<0)
        W !!,?10,"Patch #",?22,"Applied to",?37,"Applied to",!,?24,"memory",?40,"disk",! Q
Z       P AUPAT0 ZS AUPAT0 Q
