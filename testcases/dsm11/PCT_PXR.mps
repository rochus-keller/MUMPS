%PXR    ;24-JUN-1981;UTILITY;Cross reference for macros, globals, and routines; TFM
        K  U 0 W !!,"Program Cross Reference Utility",!
DEV     S %QTY=2 D ^%IOS Q:'$D(%IOD)  W !
SEL     D ^%PSEL G DEV:'%GO S ROU=-1,WRITE=0,TRUTH=0
        K ^A($J)
ROU     S ROU=$N(^UTILITY($J,ROU)) G PRNT:ROU=-1 U 0 W !,ROU D SCAN G ROU
PRNT    S ROU=-1,X=0
        U %IOD:100
        W #!!?10,"Cross reference listing for following MUMPS programs as of " D ^%D W "  " D ^%T W !!
PRNT1   S ROU=$N(^UTILITY($J,ROU)),X=X+1 G PRNTG:ROU=-1 W ROU,?(X*12) I X=8 W ! S X=0
        G PRNT1
PRNTG   S GLOBAL=-1 U %IOD W #!!,"Global cross reference listing     " D ^%D W !!
PG1     S GLOBAL=$N(^A($J,"GLOBAL",GLOBAL)) G PRNTM:GLOBAL=-1 S REF=-1,X=0 W !?4,"^",GLOBAL,?12
PG2     S REF=$N(^A($J,"GLOBAL",GLOBAL,REF)),X=X+1 G PG1:REF=-1 W ?(X+1*8),REF
        I X=10 S X=1 W !?10
        G PG2
PRNTM   S MACRO=-1 U %IOD W #!!,"Macro cross reference listing       " D ^%D W !!
PM1     S MACRO=$N(^A($J,"MACRO",MACRO)) G PRNTS:MACRO=-1 S REF=-1,X=0 W !?4,MACRO,?12
PM2     S REF=$N(^A($J,"MACRO",MACRO,REF)),X=X+1 G PM1:REF=-1 W ?(X+1*8),REF
        I X=10 S X=1 W !?10
        G PM2
PRNTS   S SYM=-1 U %IOD W #!!,"Symbol cross reference listing     " D ^%D W !!
PS1     S SYM=$N(^A($J,"SYMBOL",SYM)) G PRNTR:SYM=-1 S REF=-1,X=0 W !?4,SYM,?12
PS2     S REF=$N(^A($J,"SYMBOL",SYM,REF)),X=X+1 G PS1:REF=-1 W ?(X*8+30),REF G PS2
        I X=10 S X=1 W !?30
        G PS2
PRNTR   S ROU=-1 U %IOD W #!!,"Routine cross reference listing     " D ^%D W !!
PR1     S ROU=$N(^A($J,"ROUTINE",ROU)) G END:ROU=-1 S REF=-1,X=0 W !?4,ROU,?12
PR2     S REF=$N(^A($J,"ROUTINE",ROU,REF)),X=X+1 G PR1:REF=-1 W ?(X+1*8),REF
        I X=10 S X=1 W !?10
        G PR2
END     U 0 I %IOD'=$I C %IOD
        G SEL
SCAN    ;
        S EXT=$P($P(ROU,".",2),";",1),NAM=$P(ROU,".",1),VER=$P(ROU,";",2)
        S FP=$P(^PRG(EXT,NAM,VER,0),"^",1)
        F I=1:1 Q:'FP  S FP=$P(^PRG(EXT,NAM,VER,FP),"^",1),%L=$P(^(FP),"^",3,9999) D PARS
        Q
PARS    Q:$E(%L,1)=";"  S %L=$P(%L,$C(9),2,999),L=$L(%L)+1
        I %L'[";:" D GLOBAL,SYMBOL Q
MACRO   S MAC=$P(%L,";:",2) F I=1:1 I $E(MAC,I)'?1NU S MAC=$E(MAC,1,I-1) Q
        I MAC'?1U.NUP Q
        S ^A($J,"MACRO",MAC,$P(ROU,".",1))=""
        Q
GLOBAL  I %L'["^" Q
        S P=1
COM     S COM=$E(%L,P),P=P+1 I COM="Z" S COM=COM_$E(%L,P),P=P+1
        I P>L!(COM'?.U) Q
        F P=P:1 Q:$E(%L,P)'?1U
COMEND  I $E(%L,P)=":" S P=P+1 D TRUTH
        S P=P+1
        I COM="S"!(COM="K") D WRITEXP G COM
        I COM="D"!(COM="G") D ROUREF G COM
        D READEXP G COM
WRITEXP S WRITE=1
TRUTH   S TRUTH=1
READEXP ;
        S C=$E(%L,P),P=P+1 I P>L G EXPEND
        I C="""" D QUOT G READEXP
        I C=" "!(C=$C(9))!(C=";") G EXPEND
        I TRUTH,C="," G EXPEND
        I C="^" D GETNAM S ^A($J,"GLOBAL",NAME,$P(ROU,".",1))=WRITE G READEXP
        I C="=" S WRITE=0 G READEXP
        I C=",",COM="S" S WRITE=1 G READEXP
        G READEXP
EXPEND  S (WRITE,TRUTH)=0
        Q
ROUREF  ;
        S C=$E(%L,P),P=P+1 I P>L Q
        I C=" "!(C=$C(9))!(C=";") Q
        I C=":" D TRUTH Q:C=" "!(C=$C(9))!(C=";")  G ROUREF
        I C'="^" G ROUREF
        D GETNAM S ^A($J,"ROUTINE",NAME,$P(ROU,".",1))=""
        I C=" "!(C=$C(9))!(C=";") Q
        I C=":" D TRUTH Q:C=" "!(C=$C(9))!(C=";")
        G ROUREF
GETNAM  ;
        S NAME=""
GETNAM1 S C=$E(%L,P),P=P+1
        I P'>L,C?1NU!(C="%") S NAME=NAME_C G GETNAM1
        I NAME="" S NAME="*Naked*"
        Q
QUOT    ;
QUOT1   S C=$E(%L,P),P=P+1 Q:P>L
        I C'="""" G QUOT1
        I $E(%L,P)="""" S P=P+1 G QUOT1
        Q
SYMBOL  S F=0
SYM1    S F=$F(%L,"/*",F) Q:F=0  S SYM=$E(%L,F,999)
        I SYM'["*/" Q
        S SYM=$P(SYM,"*/",1) I SYM["/*" Q
        I SYM'?1U.NUP Q
        S ^A($J,"SYMBOL",SYM,$P(ROU,".",1))=""
        G SYM1
