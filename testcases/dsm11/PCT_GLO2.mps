%GLO2   ;27-Feb-84 ;UTILITIES ;GLOBAL MANAGEMENT ;PART 2 OF GLOBAL PLACE AND CHANGE CHARACTERISTICS ;JHM
START   D SHOW
MENU    S OPTN=$P($T(OPTAB),";;",2) S:DF<0 OPTN=OPTN-2
        F %I=1:1:OPTN W !?2,%I,". ",$P($T(OPTAB+%I),";;",2)
ASK     W !!,"Enter option > " R ANS,! G EXIT:ANS=""!(ANS="^")
        I ANS="?" W !,"Enter an option number from 1 to ",OPTN,! G ASK
        I ANS'?1N.N!(ANS>OPTN) D IV G ASK
        D @$P($T(OPTAB+ANS),";;",3) G MENU
SHOW    W !!!,"Global Characteristics for:  ^" W:$ZU(0)'=(%UCI_","_%SYS) "[",%UCI,",",%SYS,"]" W GLON,!!
        D GETDIR^%GLO1 G:%A EXIT D FGDB^%GLO1
        W !,"Collating: ",$S(DF("COL"):"String",1:"Numeric")
        W ?22,"Journalling: ",$S(DF("JRN"):"Enabled",1:"Disabled")
        W ?48,"Encoding: ",DF("BIT")+7," - bit",!!
        W !,"New Data               1st Data           1st Pointer"
        W !,"Growth Area             Block                Block"
        W !,"-----------            --------           -----------"
        W ! W:$P(STR(STRNR,1),":")_":0:0"=DF("GDGA") "*"
        W ?1,DF("GDGA"),?23,DF("FGDB"),?42,DF("FGPB"),!
        I $P(STR(STRNR,1),":")_":0:0"=DF("GDGA") W !,"* = Current UCI default for DATA GROWTH AREA will be used.",!
        W !,"Global Access Privileges:",!
        W ! S DIV=256 F %I=1:1:4 S DIV=DIV\4 W ?(%I-1*15+5),$P("System,World,Group,User",",",%I)," = ",$P("None,R,RW,RWD",",",DF("PRO")\DIV#4+1)
        W ! Q
ENC     S DEF=DF("BIT")+7,QUES="BIT" X ^%Q("EN") Q:%A
        I ANS'=7,ANS'=8 D IV G ENC
        D GETDIR^%GLO1 Q:%A  S ANS=ANS-7 Q:ANS=DF("BIT")
        S DF("BIT")=ANS D UPDIR^%GLO1 Q
COL     S DEF=$S(DF("COL"):"S",1:"N"),QUES="SN" X ^%Q("EN") Q:%A
        I ANS'="N",ANS'="S" D IV G COL
        D GETDIR^%GLO1 Q:%A  S ANS=ANS="S" Q:DF("COL")=ANS
        S DF("COL")=ANS D UPDIR^%GLO1 Q
JRN     S DEF=$S(DF("JRN"):"E",1:"D"),QUES="DE" X ^%Q("EN") Q:%A
        I ANS'="E",ANS'="D" D IV G JRN
        D GETDIR^%GLO1 Q:%A  S ANS=ANS="E" Q:DF("JRN")=ANS
        S DF("JRN")=ANS D UPDIR^%GLO1 Q
DGA     S DEF=DF("GDGA"),QUES="DATA" X ^%Q("EN") Q:%A
        S %BN1=ANS D MAPCHK^%GLO1 G:%A DGA
        S ANS=%BN1 D GETDIR^%GLO1 Q:%A  Q:ANS=DF("GDGA")
        S DF("GDGA")=ANS D UPDIR^%GLO1 Q
PRO     W !,"Enter Access Privileges",!! S DIV=256,PRO=DF("PRO")
        F %IN=1:1:4 S DIV=DIV\4 D  I %A W ! G PROE
PA      .W ?%IN-1*18 S QUES="PRO"_%IN,DEF=$P("NONE,R,RW,RWD",",",PRO\DIV#4+1)
        .D @QUES W " <",DEF,"> " R ANS S %A=ANS="^" Q:%A  S:ANS="" ANS=DEF I ANS="?" D @(QUES_"H") G PB
        .I ANS'="R",ANS'="RW",ANS'="RWD",ANS'?1"N"0.1"ONE" D IV G PB
        .S PRO1=PRO,PRO=PRO\DIV\4*4+$S(ANS="R":1,ANS="RW":2,ANS="RWD":3,1:0)*DIV+(PRO1#DIV) Q
PB      .G PA:%IN=1 S %D=256 F %I=1:1:%IN-1 S %D=%D\4 W ?%I-1*18,$P("System,World,Group,User",",",%I)," <",$P("NONE,R,RW,RWD,",",",PRO\%D#4+1),">"
        .G PA
        D GETDIR^%GLO1 Q:%A  Q:PRO=DF("PRO")
        S DF("PRO")=PRO W !! D UPDIR^%GLO1
PROE    Q
EXIT    Q
OPTAB   ;;6
        ;;Show GLOBAL Characteristics;;SHOW
        ;;Change Access Privileges;;PRO
        ;;Change Journalling Capability;;JRN
        ;;Change DATA GROWTH AREA;;DGA
        ;;Change Collating Sequence;;COL
        ;;Change GLOBAL Encoding;;ENC
BIT     W !,"Encoding [7=7-bit/8=8-bit]" Q
BITH    W !,"Enter 7 to cause the global database to be encoded using"
        W !,"the 7-bit sequence (DSM-11 V2 compatible)."
        W !!,"Enter 8 to cause the global database to be encoded using"
        W !,"the 8-bit sequence which allows 8 bit characters within"
        W !,"the global subscripts.",!
        Q
SN      W !,"Collating [S=string/N=Numeric]" Q
SNH     W !,"Enter ""S"" to force string collating of global subscripts."
        W !,"Enter ""N"" to force numeric collating of global subscripts.",! Q
DE      W !,"Journalling [E=Enabled/D=Disabled]" Q
DEH     W !,"Enter ""E"" to enable journalling for this global."
        W !,"Enter ""D"" to disable journalling for this global.",! Q
DATA    W !,"Global DATA GROWTH AREA" Q
DATAH   W !,"Enter the DISK and MAP number for the GLOBAL DATA GROWTH"
        W !,"AREA for block allocations.  Subsequent allocations of data blocks"
        W !,"will be made beyond this address.",! D DATFRM
        W !,"Enter ",$P(STR(STRNR,1),":"),":0 to force allocation of data blocks to utilize"
        W !,"the UCI's default NEW GLOBAL DATA GROWTH AREA",! Q
DATFRM  W !,"Use the form: DDU:MAP:BLK where:",!
        W !?3,"DDU is the disk and Unit (ex. DK0, DU1)"
        W !?3,"MAP is the map number on DDU"
        W !?3,"BLOCK within map must always be 0",!
        Q
PROFRM  W !,"Use the codes:",!
        W !?3,"R    = Read access"
        W !?3,"RW   = Read and Write access"
        W !?3,"RWD  = Read, Write Delete access"
        W !?3,"NONE = No access",!! Q
PRO1    W "System" Q
PRO1H   W !!,"Enter the ACCESS PRIVILEGES for the SYSTEM class"
        W !,"This class includes all users who operate in the manager's"
        W !,"UCI (MGR in volume set 0).",! D PROFRM Q
PRO4    W "User" Q
PRO4H   W !!,"Enter the ACCESS PRIVILEGES for the USER class."
        W !,"This class includes all users who are operating in the ",%UCI," UCI.",!
        D PROFRM Q
PRO3    W "Group" Q
PRO3H   W !!,"Enter the ACCESS PRIVILEGES for the GROUP class."
        W !,"This class includes all users who are operating in the ",%SYS
        W !,"Volume Set.",! D PROFRM Q
PRO2    W "World" Q
PRO2H   W !!,"Enter the ACCESS PRIVILEGES for the WORLD class."
        W !,"This class includes all users operating on a non-local DSM-11 "
        W !,"System which is connected to this system via DDP.",! D PROFRM Q
IV      W !,"Invalid response - Type ? for Help",! Q
