%PSE    ;3-Dec-81 ;UTILITY ;PROGRAM MAINTENANCE ;PROGRAM SEARCH AND REPLACE ;JHM
        W !,"PROGRAM SEARCH and EDIT"
STA     S %PD=$I,%QTY=2,%DEF=0 D ^%IOS I '$D(%IOD) G EXIT
%PSEL   D ^%PSEL I '%GO G STA
STRT    S N=0 K %Z U 0
Q1      W !,"SEARCH OR REPLACE (S or R) ? > " R C
        I C="" G BEG:$D(%Z),%PSEL
        I C="^" G %PSEL
        I C'="S",C'="R" D ASKHLP G Q1
        S REP=(C="R")
NXT     S N=1+N
Q2      W !,$S(REP:"Replace",1:"Search for")," string ",N," > " R C
        I C="^"!(C="") S N=N-1 G Q1
        I C="?" D Q2HLP G Q2
        I C="^L" D SELL G Q2
FIG     I 'REP S %Z("SS",C)="" G NXT
WITH    W !,"With ? > " R A G Q2:A="^"
        S %Z("RS",C)=A G NXT
BEG     I $D(%Z("SS")) S A=-1 W !!,"Searching for: ",! F I=1:1 S A=$N(%Z("SS",A)) Q:A=-1  W !,A
        I $D(%Z("RS")) S A=-1 W !!,"Replacing: ",! F I=1:1 S A=$N(%Z("RS",A)) Q:A=-1  W !,A,?30,"with",?36,%Z("RS",A)
        R !!,"Press RETURN to continue ",A,!!
%SS     U %IOD W #,!,?35,"PROGRAM SEARCH and EDIT"
        W !,?35 D ^%D W "  " D ^%T W !!
        S NAM=""
NNAM    S NAM=$O(^UTILITY($J,NAM)),%FN="SRC$:"_NAM G:NAM="" EXIT
        U 0 I %IOD'=$I W:$X>65 ! W:$X ?$X\16*16+16 W NAM
        E  U %IOD W !!,NAM
        S TL=NAM,LC=0 D OPEN G NNAM:BD
        D SEARCH G NNAM
SEARCH  K NEW S $ZT="ENDERR"
NXTLN   D GETLN Q:EOF
        S LC=LC+1
        I $A(L,1)'=9,$E(L,1)'=";" S TAG=$P(L,$C(9),1),OFF=0
        E  S OFF=OFF+1
        S SRCH=-1
SRCH    S SRCH=$N(%Z("SS",SRCH)) G REPLC:SRCH=-1
        S F=0
        S F=$F(L,SRCH,F) G SRCH:F'>0 D DISP G SRCH
REPLC   S SRCH=$N(%Z("RS",SRCH)) G NXTLN:SRCH=-1
        S F=0
LOOK    S F=$F(L,SRCH,F) G REPLC:F'>0 D DISP
        S NS=$E(L,1,F-1-$L(SRCH))_%Z("RS",SRCH)_$E(L,F,255)
        S F=F+($L(%Z("RS",SRCH))-$L(SRCH))
        W !,"  >>>>",?10,NS
        S L=NS
        S ^PRG(EXT,PNAM,VR,LNUM)=$P(^PRG(EXT,PNAM,VR,LNUM),"^",1,2)_"^"_L
        G LOOK
DISP    U %IOD W !,NAM,?15,TAG,"+",OFF,?32,L Q
GETLN   ;
        S LNUM=$P(^PRG(EXT,PNAM,VR,LNUM),"^",1),L=^PRG(EXT,PNAM,VR,LNUM),L=$P(L,"^",3,999)
        S EOF='LNUM Q
RECOPY  S $ZT="COPERR",%NEW=$P(%FN,";",1)_";"_($P(%FN,";",2)+1) U %FN:DISCONNECT O %NEW
        F LC=1:1 U %FN R A Q:A=$C(26)  U %NEW W:$D(NEW(LC)) NEW(LC),! I '$D(NEW(LC)) W A,!
        U %NEW W *26,! C %NEW
        Q
COPERR  I $ZE["ENDOFILE" S $ZE="" U %NEW W *26,! C %NEW Q
        ZQ
SELL    S %SE=-1
SELM    S %SE=$N(%Z("SS",%SE)) I %SE<0 Q
        W !,%SE G SELM
OPEN    ;
        S VR=$P(NAM,";",2),PNAM=$P(NAM,".",1),EXT=$P($P(NAM,".",2),";",1)
        S BD='$D(^PRG(EXT,PNAM,VR,0)) Q:BD
        S LNUM=0,L=^(0) Q
ASKHLP  W !,"Enter R to replace every occurrence of a string with another string"
        W !,"Enter S to search for and display every occurrence of a string"
        W !,"Type <CR> when finished entering all search and/or replace strings desired"
        W !,"Type ^ to go back to the last question" Q
Q2HLP   W !,"Enter the string you wish to search for or replace."
        W !,"Type ^ to go back to the last quetion." Q
EXIT    U 0 K %A,%DTY,%GO,%SE,%SF,C,NAM,TYP,NAM,VER,LIN,IT,TC,TL,CC,IU,NS
        I $D(%IOD),%IOD'=%PD C %IOD
        K %PD Q
        Q
