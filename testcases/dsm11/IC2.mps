IC2     ;ERRORS FROM IC1 @SMB@
        -
TRAP    S X=$ZE,ER=$P(X,">",1),TAG=$P(X,">",2)
        I $P(TAG,"^",2)'["IC1" G UNXPCT
        S TAG=$P(TAG,"^",1) I ER'="<DKSER",ER'="<DKHER" G UNXPCT
        I TAG'="B",TAG'="INIT1",TAG'="P1",TAG'="M" G UNXPCT
        S ER=ER_"> attempting to view block# " G @TAG
        -
B       S ER=ER_B_" (chasing right pointer of "_OLD_")" D ER
        S LEV=LEV-1 D:LEV LEV^IC1 G END
        -
INIT1   I 'T S ER=ER_P_" (root of tree)" D ER G END
        S ER=ER_P_" (left edge down pointer from "_T(T-1)_")" D ER G END
        -
P1      S ER=ER_P_" (a down pointer from "_B_")" D ER,M1^IC1 G END
        -
M       S ER=ER_P_" (the map block for "_P_")" D ER,M1^IC1 G END
        -
UNXPCT  S ER="Unexpected error: "_X D ER G END
        -
ER      S ^IC=^IC+1,^IC(^IC)=ER,$ZE="TRAP^IC2" Q
        -
END     G ONEGLOB^IC0
STARTED L ^ICS H 2 D U,LIST^IC0 W !!,"Integrity checker running in background"
        W !,"A report will be compiled into ^IC"
        I $D(^IC("OUTPUT DEVICE")) W " and printed on device #",^IC("OUTPUT DEVICE")
        Q
        -
SET     S UCD=$V(UTAB,0)\2,DISK(STRNO,I)=$C(UCD\1024#32+64)_$C(UCD\32#32+64)_$C(UCD#32+64)
        F K=2:2:6 S DISK(STRNO,I,K)=$V(UTAB+K,0)
        Q
STO     I UCI'="*" D ST Q
        S UCI="" F I=1:1 S UCI=$ZS(DISK(STRNO,UCI)) Q:UCI=""  S CC=CC+1,^IC(CC,"GLOB")="*" D ST
        Q
ST      S ^IC(CC,"UCI NAME")=DISK(STRNO,UCI),^("UCI #")=UCI,^("ROU")=ROU
        S ^("GD")=DISK(STRNO,UCI,4)#256*65536+DISK(STRNO,UCI,2)
        S ^("RD")=DISK(STRNO,UCI,4)\256*65536+DISK(STRNO,UCI,6) Q
HLP1    W !!,"Enter '1' if you want a listing of previous integrity checker report"
        W !,"Enter '2' if you want to run integrity checker in background and"
        W !,?10,"compile the results into ^IC",! Q
HLP2    W !!,"Enter a valid UCI # or UCI name",!?3,"Or '*' for all UCI's",! Q
U       C 63 L  Q
