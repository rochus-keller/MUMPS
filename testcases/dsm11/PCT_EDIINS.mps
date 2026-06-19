%EDIINS ;9-Dec-81 ;UTILITY ;EDITOR ;INSERT/DELETE FUNCTIONS ;JEB
DEL     D NUM Q:%E]""  D DELIT
        I '%P S %P=$P(%L,"^",2),%L=^(%P)
        W:%C="DP" !,$P(%L,"^",3,999) Q
DELIT   S %U="" I %A<0 S %X=$P(%L,"^",2) F %A=1:1:-%A D TOF:'%X Q:'%X  S:$L(%U)<100 %U=%X_","_%U S %Y=%X,%X=$P(^(%Y),"^",2) K ^(%Y)
        E  S:'%P %A=%A-1,%P=+%L,%L=^(%P) S %X=$P(%L,"^",2) F %A=1:1:%A D EOF:'%P Q:'%P  S:$L(%U)<100 %U=%P_","_%U S %Y=%P,%P=+%L,%L=^(%P) K ^(%Y)
        I %X=%P D INIT
        E  S ^(%X)=%P_"^"_$P(^(%X),"^",2,999),(^(%P),%L)=+%L_"^"_%X_"^"_$P(%L,"^",3,999) S:($L(^(1)_%U)<256) ^(1)=%U_^(1)
        Q
OVER    D NUM S:%A<0 %E="ARG" Q:%E]""  D DELIT
        S %P=$P(%L,"^",2),%L=^(%P),%A=""
INS     S:%A?1" ".E %A=$E(%A,2,999) I %A'="" D INS1 Q
        W !,"Input"
        U $I:(::::64)
        F %I=0:0 R !,%A D ESC:($ZB#256=27) Q:%A=""  D INS1
        U $I:(:::::64)
        Q
ESC     S MAR=$S($ZB=4379:72,$ZB=4635:64,$ZB=5147:56,1:0) G STM:MAR
        S MAR=$S($ZB=8219:72,$ZB=8475:64,$ZB=8731:56,1:0) I 'MAR W !,"Invalid escape sequence" Q
        F I=0:0 W "*" S %A=%A_"*" Q:$X>MAR
        Q
STM     F I=0:0 Q:$X'<MAR  W $C(9) S %A=%A_$C(9)
        S %A=%A_"*" W "*" Q
LOAD    D STRIP I %A="" R !,"Routine: ",%A Q:%A=""
        W *13
        S $ZT="LOADER" K ^A($J) X "ZL @%A F %I=1:1 Q:$T(+%I)=""""  S ^A($J,%I)=$T(+%I)"
        F %J=1:1:%I-1 S %A=^A($J,%J) S %A=$P(%A," ",1)_$C(9)_$E(%A,$F(%A," "),9999) D INS1:$D(@(%GL_"0)"))
        S $ZT=""
        Q
LOADER  W !,"Error loading routine : ",%A,!,$ZE S $ZE="",$ZT="" G ^%EDI
INS1    D GET S ^(%P)=%X_"^"_$P(%L,"^",2,999),%Y=^(+%L),^(+%L)=+%Y_"^"_%X_"^"_$P(%Y,"^",3,999)
        S (^(%X),%L)=+%L_"^"_%P_"^"_%A,%P=%X Q
RETYP   S:%A?1" ".E %A=$E(%A,2,999) I %A="" S %A=1 G DEL
        S (^(%P),%L)=$P(%L,"^",1,2)_"^"_%A Q
KILL    W !,"Are you sure you want to kill file ",%FN,"? <Y> " R %X:30 S:'$T %X="N" S:%X="" %X="Y"
        S %X=$E(%X,1),%X=$C($A(%X)-(%X?1L*32))
        I "YN"'[%X W " enter Yes or No" G KILL
        D INIT:%X="Y" Q
SAV     D STRIP S %I=$P(%A," ",1),%A=$P(%A," ",2,999)
        S:%I="" %I=1 S:%I="*" %I=99999 I %I'?.N S %E="NUM" Q
        D STRIP S:%A="" %A="SAVE."_$J D NEWFIL Q:%E]""
        S:'%P %I=%I-1,%P=+%L,%L=^(%P) D INIT^%EDIFIL
        S %S=0,%U=@(%GL_"0)")
        I %P F %I=%I:-1:1 S %A=$P(%L,"^",3,999),%W=%P,%Z=%L,%P=%S,%L=%U D INS1:$D(@(%GL_"1)")) S %S=%P,%U=%L,%P=%W,%L=%Z Q:%I=1  D EOF:'%L Q:'%L  S %P=+%L,%L=@(%G_"%P)")
        D RES Q
UNS     D STRIP S:%A="" %A="SAVE."_$J D NEWFIL Q:%E]""
        I '$D(@(%GL_"0)")) S %E="NOFIL" D RES Q
        S %S=0,%U=^(0)
        F %I=0:1 Q:'%U  S %S=+%U,%U=@(%GL_"%S)"),%A=$P(%U,"^",3,999) D INS1:$D(@(%G_"1)"))
        D RES W !,"[",%I," line",$E("s",%I'=1)," restored]" Q
INIT    S %P=^(2) D INIT^%EDIFIL S ^(2)=%P,%P=0,%L=^(0) Q
GET     S %X=^(1) I '%X S %Y=$P(%X,"^",2),%X="^"_(%Y+10) F %Y=%Y+9:-1:%Y S %X=%Y_","_%X
        S ^(1)=$P(%X,",",2,999),%X=+%X Q
STRIP   F %X=1:1 I $E(%A,%X)'=" " S %A=$E(%A,%X,999) Q
        Q
NUM     D STRIP S:%A="" %A=1 S:%A="*" %A=99999
        I %A'?1N.N,%A'?1"-"1N.N S %E="NUM"
        Q
NEWFIL  S %H=%FN,%G=%GL,%FN=%A D CK^%EDIFIL Q:%GL]""
        S %E="FLN"
RES     S %FN=%H,%GL=%G I '$D(@(%GL_"0)")) S %E="BDFIL",%C="EX"
        Q
TOF     W !,"[TOF]" S %E="1" Q
EOF     W !,"[EOF]" S %E="1" Q
