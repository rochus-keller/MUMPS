SYSWAIT ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
        Q
QUIET   D WAIT I %FAIL Q
        S %JO="",%ST=$V(44)
        S %PT=$V(%ST+6),%JT=$V(%ST+4),%JM=$V(%PT+1)\2
        F %I=%JT+2:2:%JT+126 S %JT(%I-%JT\2)=$V(%I+1)
        F %I=%JT-128:2:%JT-128+(2*(%JM-63)) S %JT(%I-(%JT-128)/2+64)=$V(%I+1)
        F %I=1:1:%JM I $D(%JT(%I)),%I'=$J,%JT(%I)'=244,%JT(%I)'=0 S %JO=%JO_%I_"," I $L(%JO)>250 Q
        K %JT,%JM,%I
WAIT    B 0 V $V(44)+74::$J*2*256+($V($V(44)+74)#256)
        S %STSAV=$V($V(44))
        S %GARTRA=$V(44)+364
        S %SHRTQ=$V($V(44)+4)-$V($V(44)+72)
        S %FAIL=0
GWAT    F %I=1:1:6 G SHRTQ:$V(%GARTRA)=0 H 1
        W !,"Garbage collector is still running",! S %FAIL=1 G FAIL
SHRTQ   F %I=1:1:5 G DEMWAT:$V(%SHRTQ)#256=0 H 1
        S %FAIL=2 G FAIL
DEMWAT  S %DK=$V($V(44)+24)
        F %I=1:1:10 H:%I>1 1 F %J=1:1 Q:$V(%DK+4)  S %DK=$V(%DK) G:'%DK DEMOF
        S %FAIL=3 G FAIL
DEMOF   I $V(%GARTRA)+($V(%SHRTQ)#256) G GWAT
        G DONE
FAIL    D RELSYS
DONE    K %GARTRA,%SHRTQ,%J,%DK,%I
        Q
RELSYS  V $V(44)+74::$V($V(44)+74)#256 B 1
        Q
