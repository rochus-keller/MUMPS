%EDIMAC ;9-Dec-81 ;UTILITY ;EDITOR ;MACRO AND SAVE/UNSAVE FUNCTIONS ;JEB
IM      S %S=1 I $E(%A,$L(%A))'=">" S %E="SYN" Q
        S %A=$E(%A,2,$L(%A)-1) D MSET S %A="" G MXEC
MX      S %S=$P(%A," ",1),%A=$P(%A," ",2,999) I %S'?1N!(123'[%S) S %E="NUM" Q
MXEC    I '$D(%M(%S)) S %E="NUMAC" Q
        D STRIP S %I=%I-1
        I %I S:$L(%M(%S))+$L(%NC)+$L(%A)+$L(%I)>249 %E="LEN" Q:%E]""
        I  S %NC=%I_"M"_%S_" "_%A_%CC_%NC
        S %X=%M(%S) F %Y=0:0 S %Z=$F(%X,"%") Q:'%Z  D REP1 Q:%E]""
        Q:%E]""  S:$L(%X)+$L(%NC)>254 %E="LEN" Q:%E]""
        S %NC=%X_%CC_%NC Q
REP1    I $L(%X)+$L(%A)>256 S %E="LEN" Q
        I %A="" S %E="MACARG" Q
        S %X=$E(%X,1,%Z-2)_%A_$E(%X,%Z,999) Q
MAC     D STRIP S %S=$P(%A," ",1),%A=$P(%A," ",2,999) I %S'?1N!(123'[%S) S %E="NUM" Q
        D STRIP I %A="" S %E="SYN" Q
MSET    W:$D(%M(%S)) !,"[overlaying macro ",%S,"]" S %M(%S)=%A Q
MS      D STRIP S:%A="" %A="MCALL" D NEWFIL Q:%E]""
        F %S=1:1:3 I $D(%M(%S)) S @(%GL_"%S)")=%M(%S) W !,"[macro ",%S," saved]"
        D RES Q
MC      D STRIP S:%A="" %A="MCALL" D NEWFIL Q:%E]""
        F %S=1:1:3 I $D(@(%GL_"%S)")) S %M(%S)=^(%S) W !,"[macro ",%S," restored]"
        D RES Q
STRIP   F %X=1:1 I $E(%A,%X)'=" " S %A=$E(%A,%X,999) Q
        Q
NEWFIL  S %H=%FN,%G=%GL,%FN=%A D CK^%EDIFIL Q:%GL]""
        S %E="FLN"
RES     S %FN=%H,%GL=%G I '$D(@(%GL_"0)")) S %E="BDFIL",%C="EX"
        Q
