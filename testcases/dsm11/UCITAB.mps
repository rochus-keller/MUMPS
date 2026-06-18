UCITAB  ;DISPLAY CONTENTS OF UCI TABLE; JHM
        K %DEF S %QTY=2 D ^%IOS I '$D(%IOD) G EXIT
        D INT^%D,INT^%T
        U %IOD W #!,?5,"UCI Table",?50,%DAT1,"  ",%TIM,! S LINE=1
        S ST=$V(44),STBL=$V(ST+12),LOOP=0
        D START^%STRTAB
        F STR=0:1:3 I $D(STR(STR))#10,STR(STR)'="" D
        .W !!,"UCI Table for Volume Set ",STR(STR)," (S",STR,")"
        .W !,"----------------------------------",!
        .S UT=$V($V(ST+34)#256*STR+2+STBL),OFF=0
LOOP    .G NEXT:$V(OFF,UT)=65535 S UCI=$V(OFF,UT)\2
        .S A=UCI#32+64,B=UCI\32#32+64,C=UCI\1024#32+64
        .S UCNAM=$C(C)_$C(B)_$C(A)
        .S UCGBL=$V(OFF+2,UT)+($V(OFF+4,UT)#256*65536)
        .S UCROU=$V(OFF+5,UT)*65536+$V(OFF+6,UT)
        .U %IOD
        .W !!,"UCI Code",?50,UCNAM
        .W !,"Pointer to Global Directory",?50,UCGBL
        .W !,"Pointer to Routine Directory",?50,UCROU
        .W !,"Map Number for Start of Routine Growth",?50,$V(OFF+8,UT)
        .W !,"Map Number for Start of Global Data Growth",?50,$V(OFF+10,UT)
        .W !,"Map Number for Start of Global Pointer Growth",?50,$V(OFF+12,UT)
        .W !,"Highest Map Number allowed for this UCI",?50,$V(OFF+14,UT)
        .W !,"UCI Number of this UCI's  Library UCI",?50,$V(OFF+19,UT),!
        .D PAGE:$Y>55
NEXT    .S OFF=OFF+20 G LOOP:$V(OFF,UT)
EXIT    W !# U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %DAT,%DAT1,%DTY,%IOD,%NOPAUSE,%TIM,%UCI,%UCN,A,B,C,LINE,LOOP,NGDG,NGG,NRG,PGD,PRD,ST,UCI,UCIOUT,UT Q
PAGE    U %IOD W #,!! S LINE=2 Q
