%EDILST ;9-Dec-81 ;UTILITY ;EDITOR ;LISTING COMMANDS ;JEB
LIST    I '%P S %P=+%L,%L=^(%P)
        F %X=%X:0 Q:'%P  W !,$P(%L,"^",3,999) S %P=+%L,%L=^(%P)
        Q
NEXT    D NUM Q:%E]""  I %A<0 F %X=1:1:-%A D TOF:'%P Q:'%P  S %P=$P(%L,"^",2),%L=^(%P)
        E  F %X=1:1:%A D EOF:'%L Q:'%L  S %P=+%L,%L=^(%P)
        W:%C="NP" !,$P(%L,"^",3,999) Q
PRINT   D NUM S:%A<0 %E="ARG" Q:%E]""
        F %X=%A:-1:1 W !,$P(%L,"^",3,999) Q:%X=1  D EOF:'%L Q:'%L  S %P=+%L,%L=^(%P)
        Q
TYPE    S %Y=%P D PRINT S:%Y'=%P %P=%Y,%L=^(%P) Q
NUM     D STRIP S:%A="" %A=1 S:%A="*" %A=99999
        I %A'?1N.N,%A'?1"-"1N.N S %E="NUM"
        Q
STRIP   F %X=1:1 I $E(%A,%X)'=" " S %A=$E(%A,%X,999) Q
        Q
TOF     W !,"[TOF]" S %E="1" Q
EOF     W !,"[EOF]" S %E="1" Q
