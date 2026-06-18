%GLO1   ;25-Feb-84 ;UTILITIES ;GLOBAL ;GLOBAL CHARACTERISTICS AND PLACEMENT EDITOR ;JHM
GETDIR  S ST=$V(44),STRTAB=$V(ST+12),STRSIZ=$V(ST+34)#256
        S UCIMM=$V(STRSIZ*$E(STRNO,2)+2+STRTAB)
        S UCB=UCINUM-1*20,UCGBL=UCB+2
        S %GDIR=$V(UCGBL+2,UCIMM)#256*65536+$V(UCGBL,UCIMM)
        D GETDF
FNDGLO  U 63:(::"CPT") V %GDIR:STRNO S %A=$ZA\64#2 U 0 I %A D  G FDON
        .W !!,"Error reading global directory block: ",%GDIR,":",STRNO
        .W !,"Unable to proceed",!
        S END=$V(1022,0),%N="",%PTR=0 G F3:END'>%PTR
F1      F %PTR=%PTR:1 S %C=$V(%PTR,0)#256,%N=%N_$C(%C\2) Q:'(%C#2)
        S %PTR=%PTR+1 I %N=GLON S %PTR=%PTR-$L(%N) G F2
        S %PTR=%PTR+8,%N="" G F1:%PTR<END
F3      S %GDIR=$V(1016,0)#256*65536+$V(1014,0)
        I %GDIR G FNDGLO
        S DF=0 G FDON
F2      S %B=$V(%PTR+$L(GLON),0)#256
        S DF("COL")=%B#2,DF("BIT")=%B\2#2,DF("JRN")=%B\4#2
        S DF("PRO")=$V(%PTR+$L(GLON)+1,0)#256
        S %B=%PTR+$L(GLON)+2 D BLPTR S DF("GDGA")=%BN1
        S %B=%PTR+$L(GLON)+5 D BLPTR S DF("FGPB")=%BN1
FDON    K %B,%BN,%BN1,STRVOL U 63:(::"C"),0 Q
FGDB    S %BN1=DF("FGPB") D MAPNUM U 63:(::"CP"),0
FG1     V %BN:STRNO
        I $V(1021,0)#128=8 S DF("FGDB")=%BN1 G FDON
        S %B=$V(0,0)#256+$V(1,0)+2 D BLPTR G FG1
SETDIR  S %BN1=DF("DGD") D MAPNUM S DGD=%BN
        S %BN1=DF("DGP") D MAPNUM S DGP=%BN
        S %BN1=DF("NGD") D MAPNUM S NGD=%BN
        S %BN1=DF("NGP") D MAPNUM S NGP=%BN
        S $ZT="NOSET",%A=0 B 0 V ST+74::$J*2*256+($V(ST+74)#256)
        V UCB+10:UCIMM:NGD\400
        V UCB+12:UCIMM:NGP\400
        S @("^[%UCI,%SYS]"_GLON)="" H 2
RESET   V UCB+10:UCIMM:DGD\400,UCB+12:UCIMM:DGP\400
        V ST+74::$V(ST+74)#256 B 1 K DGD,DGP,NGD,NGP Q
NOSET   W !,"Error while creating global: ",$ZE,! D RESET
        K @("^[%UCI,%SYS]"_GLON) S %A=1 Q
UPDIR   U 63:(::"CPTV") V %GDIR:STRNO S %A=$ZA\64#2 U 0
        I %A W !,"Global directory modified during last access" G UPFAIL
        S %CC=$V(%PTR+$L(GLON),0)\2#2'=DF("BIT")
        S BYT=DF("JRN")*4+(DF("BIT")*2)+DF("COL")
        S %P=%PTR+$L(GLON)-1 D VBYT S BYT=DF("PRO") D VBYT
        S %BN1=DF("GDGA") D MAPNUM S DIV=1
        F %I=1:1:3 S BYT=%BN\DIV#256,DIV=DIV*256 D VBYT
        U 63:(::"CPT") V -%GDIR:STRNO S %A=$ZA\64#2 U 0
        I %A W !,"Error writing global directory block" G UPFAIL
        I '%CC G U4
        S %BN1=DF("FGPB") D MAPNUM
U2      U 63:(::"PT") V %BN:STRNO S %A=$ZA\64#2 U 0 G:%A U3
        V 1020:0:$V(1021,0)#128+(128*DF("BIT"))*256+($V(1020,0)#256)
        U 63 V -%BN:STRNO S %A=$ZA\64#2 U 0 G:%A U3
        I $V(1021,0)#128=8 G U4
        S %B=$V(0,0)#256+$V(1,0)+2 D BLPTR G U2
U3      W !,"Error upgrading encoding value in block: ",%BN,! G UPFAIL
U4      W " - Characteristics updated",! G UPDON
UPFAIL  W !,"^",GLON," not modified",!
UPDON   U 63:(::"C"),0 K BYT,DIV,%P,%CC D ZGLAST^%SYSROU Q
VBYT    S %P=%P+1 I %P#2 V %P-1:0:BYT*256+($V(%P-1,0)#256)
        E  V %P:0:$V(%P+1,0)*256+BYT
        Q
BLPTR   S %BN=$V(%B+2,0)#256*256+($V(%B+1,0)#256)*256+($V(%B,0)#256)
BLNUM   S K=1,STRNR=$E(STRNO,2),%BN1=%BN
CON     S STRVOL=STR(STRNR,K),MAPS=$P(STRVOL,":",2)
        I %BN1'<(400*MAPS) S K=K+1,%BN1=%BN1-(400*MAPS) G CON
        S %BN1=$P(STRVOL,":",1)_":"_(%BN1\400)_":"_(%BN1#400) Q
MAPCHK  S %A=1 I %BN1'?2U1N1":"1N.N.":".N D IV Q
        I $P(%BN1,":",3)'="",$P(%BN1,":",3)'=0 D IV Q
        I $P(%BN1,":",3)="" S %BN1=%BN1_":0"
MAPNUM  S VOL="",%BN=0,STRNR=$E(STRNO,2)
M1      S VOL=$O(STR(STRNR,VOL))
        I VOL="" W !,$P(%BN1,":")," is not part of the ",%SYS," volume set",! Q
        S DK=STR(STRNR,VOL)
        I $P(DK,":")'=$P(%BN1,":") S %BN=$P(DK,":",2)*400+%BN G M1
        I $P(DK,":",2)-1<$P(%BN1,":",2) W !,$P(DK,":")," has only ",$P(DK,":",2)," maps, numbered 0 thru ",$P(DK,":",2)-1,! Q
        S %BN=$P(%BN1,":",2)*400+$P(%BN1,":",3)+%BN,%A=0 Q
CHKSYS  S $ZT="NOSU",%A=0,UCN=$ZU(%UCI,%SYS) Q
NOSU    S %A=1 W ! I $ZE["NOUCI" W %UCI," is not a defined UCI",! Q
        I $ZE["NOSYS" W %SYS," is not a defined VOLUME SET",! Q
        ZQ
GETDF   S $ZT="GETERR",DF=$D(@("^[%UCI,%SYS]"_GLON)) S:DF>1 DF=-1 Q
GETERR  I $ZE["PROT" S DF=-1 Q
        ZQ
IV      W !,"Invalid response - Type ? for help",! Q
