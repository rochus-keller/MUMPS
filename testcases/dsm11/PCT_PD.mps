%PD     ;23-Oct-81 ;UTILITY ;EDITOR ;PRODUCES A PROGRAM DIRECTORY ;JHM
        U 0 W !,"PROGRAM DIRECTORY "
        S %QTY=2,%DEF=0 D ^%IOS G %DN:'$D(%IOD)
        U 0 W !
        U %IOD W !!,?19,"PROGRAM DIRECTORY " D INT^%D,INT^%T W %DAT
        D ^%GUCI S DIR=%UCI
        U %IOD W !,?19,"OF ",DIR,!
        S EXT=-1,FN=-1,VR=-1
        I $N(^PRG(-1))=-1 U 0 W !!,"No programs in this directory",! G %CLOSE
DSM     S EXT=$N(^PRG(EXT)) G %CLOSE:EXT=-1
        D HDR
D1      S FN=$N(^PRG(EXT,FN)) G DSM:FN=-1
D2      S VR=$N(^PRG(EXT,FN,VR)) G D1:VR=-1
        S F=FN_"."_EXT_";"_VR D WRTLN G D2
WRTLN   W:'(%CT#4) ! W ?(%CT#4*20),F S %CT=%CT+1 Q
HDR     U %IOD W !!,$S(EXT="SOU":"SOURCE",1:EXT)," Library" S X=$X,%CT=0
        W ! F I=1:1:X W "-"
        W ! Q
%CLOSE  U 0 I %IOD'=$I C %IOD
%DN     U 0 K %CT,%DAT,%TIM,%GO,%UTILITY,I Q
