%RML    ;17-Jan-86 ;UTILITIES ;LIBRARY ;LOAD MAPPED ROUTINE INTO PARTITION ;SMB
1       D ROUNAM^%RM1 Q:"^"[R
        D INT^%RM1 I ROUSTR<1 W " ",ROUSTA G 1
        W !,"Loading . . ." D GETGLO
        S $ZT="" W !,"This will end with a <NOPGM>"
        S ZL="F I=1:1:^UTILITY($J,""XX"",0) ZI ^(I)"
        X "ZR  X ZL K ^UTILITY($J,""XX"") ZL %S9M8B7"
        -
GETGLO  K ^UTILITY($J,"XX") S LN=0,I=0
D       S L="",X=$V(I,ROUSTR)#256 I X=255 S ^UTILITY($J,"XX",0)=LN Q
        F J=1:1:X S L=L_$C($V(I+J,ROUSTR)#256)
        S L=L_" " F I=I+2+X:1 S X=$V(I,ROUSTR)#256 Q:X=255  S L=L_$C(X)
        S LN=LN+1,^UTILITY($J,"XX",LN)=L
        S I=I+1 G D
