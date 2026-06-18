%PFL    ;26-OCT-81 ;UTILITY ;PROGRAM MAINTENANCE ;PROGRAM FIRST LINE LIST ;TFM
        U 0 W !,"PROGRAM FIRST LINE LIST"
ASK     S %PD=$I,%QTY=2,%DEF=0 D ^%IOS I '$D(%IOD) K %PD D %DONE Q
        D ^%GUCI S DIR=%UCI
        U %IOD W #,!,"First Line List of ",DIR,"   on    "
        D ^%D W ?18 D ^%T W !! S I=-1
        U 0 I $I'=%IOD W !,"Listing being made",!
        U %IOD
DSM     S EXT=-1,FN=-1
D2      S EXT=$N(^PRG(EXT)) G %DONE:EXT=-1
        D HDR
D3      S FN=$N(^PRG(EXT,FN)) G D2:FN=-1
        S VR=^(FN),FIL=FN_"."_EXT_";"_VR
        I '$D(^PRG(EXT,FN,VR,0)) S L="Corrupted file" D WRTLN G D3
        S L=^PRG(EXT,FN,VR,0)
        S L1=$P(L,"^",1),L=$P(^(L1),"^",3,999) D WRTLN G D3
HDR     U %IOD W !!,$S(EXT="SOU":"SOURCE",1:EXT)," Library" S X=$X,%CT=0
        W ! F I=1:1:X W "-"
        W ! Q
WRTLN   U %IOD W !,FIL,?15,$P(L,$C(9),1),?27,$P(L,$C(9),2,999) Q
%DONE   U 0 K I,%DTY,%GO I $D(%IOD) C:(%IOD'=%PD) %IOD
        Q
