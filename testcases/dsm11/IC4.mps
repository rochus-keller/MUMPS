IC4     ;ERRORS FROM IC3 @SMB@
        -
TRAP    S X=$ZE,ER=$P(X,">",1),TAG=$P(X,">",2)
        I $P(TAG,"^",2)'["IC3" G UNXPCT
        S TAG=$P(TAG,"^",1) I ER'="<DKSER",ER'="<DKHER" G UNXPCT
        I TAG'="B",TAG'="INIT1",TAG'="P1",TAG'="M" G UNXPCT
        S ER=ER_"> attempting to view block# " G @TAG
        -
B       S ER=ER_B_" (chasing right pointer of "_OLD_")" D ER
        S LEV=LEV-1 D:LEV LEV^IC3 G END
        -
INIT1   I 'T S ER=ER_P_" (root of tree)" D ER G END
        S ER=ER_P_" (left edge down pointer from "_T(T-1)_")" D ER G END
        -
P1      S ER=ER_P_" (a down pointer from "_B_")" D ER,M1^IC3 G END
        -
M       S ER=ER_P_" (the map block for "_P_")" D ER,M1^IC3 G END
        -
UNXPCT  S ER="Unexpected error: "_X D ER G END
        -
ER      S ^IC=^IC+1,^IC(^IC)=ER,$ZE="TRAP^IC4" Q
        -
END     G GLOBALS^IC0
