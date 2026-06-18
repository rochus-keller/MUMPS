IC0     ;INTEGRITY CHECKER, BACKGROUND JOB @SMB@
        *
JOB     B 2
        L ^IC S UCICT=0,STRNO=^IC("STRUCTURE #") G NEXUCI
        -
UCI     S MESS="CHECKING UCI #"_UCI_" (UCI NAME: "_^IC(UCICT,"UCI NAME")_", STRUCTURE: "_STRNO_")"
        D MESS G GLOBALS:^IC(UCICT,"ROU")'="Y"
        S P=^IC(UCICT,"RD")
        S MESS="CHECKING ROUTINES" D MESS,^IC3 S $ZE="TRAP^IC0"
GLOBALS ;
        S %GLOB=^IC(UCICT,"GLOB") K ^IC(0,"GD")
        I %GLOB'="*" F I=1:1 S %GB=$P(%GLOB,";",I) G:%GB="" ONEGLOB S ^IC(0,"GD",$P(%GB,"^",2))=+%GB
        S P=^IC(UCICT,"GD")
        K ^IC(0,"GDB") S $ZE="TRAP^IC0" C 63 O 63
B       V P:STRNO S O=$V(1022,0),C=0 I $D(^IC(0,"GDB",P)) S MESS="Loop in global directory blocks at block "_P D ER G ONEGLOB
N       I C>O S MESS="Bad offset in global direcctory block "_P D ER
        I C'<O S P=$V(1016,0)#256*65536+$V(1014,0) G B:P,ONEGLOB
        S N="" F C=C:1 S N=N_$C($V(C,0)#256\2) Q:$V(C,0)#2=0
        S ^IC(0,"GD",N)=$V(C+8,0)#256*256+($V(C+7,0)#256)*256+($V(C+6,0)#256)
        S C=C+9 G N
ONEGLOB ;
        S G=$ZS(^IC(0,"GD","")) G NEXUCI:G="" S P=^(G) K ^(G)
        I G="IC",UCI=1 G ONEGLOB
        S MESS="CHECKING ^"_G D MESS,^IC1 S $ZE="TRAP^IC0" G ONEGLOB
        -
NEXUCI  S UCICT=UCICT+1 G:UCICT>^IC(0) DONE S UCI=^IC(UCICT,"UCI #") G UCI
        -
MESS    S %DT=$H,%TM=$P(%DT,",",2),%DT=+%DT D %CDS^%H,%CTS^%H
        S MESS=%DAT1_"  "_%TIM_"  "_MESS,^IC=^IC+1,^IC(^IC)=MESS K MESS Q
        -
ER      S ^IC=^IC+1,^IC(^IC)=MESS K MESS Q
        -
TRAP    S X=$ZE G T1:$P(X,">",2)'["B^IC0" S X=$P(X,">",1)
        G T1:X'="<DKHER"&(X'="DKSER") S MESS=X_"> trying to view block "_P
        S MESS=MESS_" (global directory block)" D ER G ONEGLOB
        -
T1      S MESS="Unexpected error "_$ZE G ER
        -
LIST    W !!,"Selected UCIs for Structure ",STRNO,! F I=1:1:^IC(0) D L1
        Q
L1      W !?3,"UCI #",^IC(I,"UCI #")," (",^IC(I,"UCI NAME")
        W ")" I ^IC(I,"GLOB")="*" W !?3,"All Globals" G L2
        W !?3 F L=1:1 S GCT=$P(^IC(I,"GLOB"),";",L) Q:GCT=""  W:L>1 "," W "^",$P(GCT,"^",2) W:$X>75 !?3
L2      I ^IC(I,"ROU")="Y" W !?3,"Routines"
        Q
DONE    C 63 S MESS="FINISHED" D MESS
        Q:'$D(^IC("OUTPUT DEVICE"))  S OUTDEV=^IC("OUTPUT DEVICE")
        O OUTDEV::300 I $T U OUTDEV D REPORT C OUTDEV Q
        ZU OUTDEV
REPORT  W #,!!,"---  INTEGRITY CHECKER REPORT ---",!
        F I=1:1:^IC W !,^IC(I) W:$Y>60 #
        W ! S ^IC("PRINTED")=1 Q
