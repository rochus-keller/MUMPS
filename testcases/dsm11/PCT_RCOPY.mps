%RCOPY  ; GEF ; DSM UTILITIES ; ROUTINE COPIER : UPDATED 6-JUN-80 ; FDN
        S $ZE="ER^%RCOPY"
A       S %FL=0 R !,"Copy from routine > ",PGM G HELP:PGM="?" I PGM=""!(PGM="^") S $ZE="" K ^UTILITY($J) G EXIT
        I '(PGM?1U.UN!(PGM?1"%".UN)) D IV G A
        I $L(PGM)>8 D IV1 G A
        S PRG="PGM"
        X "ZL @PGM"
B       R !,"Copy from line > ",FL G:FL=""!(FL="^") A G:FL="?" HELP1
        S OFF=0 I FL["+" S OFF=$P(FL,"+",2),FL=$P(FL,"+",1)
        I OFF'?1N.N D IV G B
        I '(FL?1U.UN!(FL?1"%".UN)!(FL?1N.N)) D IV G B
        I $L(FL)>8 D IV2 G B
        X "ZL @PGM S T=$T(@FL)"
        I T="" W !!,"No such line in routine IN ROUTINE ",PGM,! G B
        S SP=" " X "ZL @PGM F FP=1:1 Q:$P($T(+FP),SP,1)=FL"
        S FP=FP+OFF
C       R !,"Copy through line > ",TL G:TL=""!(TL="^") B G:TL="?" HELP2
        S OFF=0 I TL["+" S OFF=$P(TL,"+",2),TL=$P(TL,"+",1)
        I OFF'?1N.N D IV G C
        I '(TL?1U.UN!(TL?1"%".UN)!(TL?1N.N)) D IV G C
        I $L(TL)>8 D IV2 G C
        X "ZL @PGM S T=$T(@TL)"
        I T="" W !!,"No such line in routine ",PGM,! G C
        S SP=" " X "ZL @PGM F TP=1:1 Q:$P($T(+TP),SP,1)=TL"
        S TP=TP+OFF
        I TP<FP W !,"Invalid" G C
D       S %FL=1 R !,"Copy into routine > ",TPG G:TPG=""!(TPG="^") C G:TPG="?" HELP3
        I '(TPG?1U.UN!(TPG?1"%".UN)) D IV G D
        I $L(TPG)>8 D IV1 G D
        S PRG="TPG"
        X "ZL @TPG"
E       R !,"Copy after line > ",AL G:AL=""!(AL="^") D G:AL="?" HELP4
        S OFF=0 I AL["+" S OFF=$P(AL,"+",2),AL=$P(AL,"+",1)
        I OFF'?1N.N D IV G E
        I '(AL?1U.UN!(AL?1"%".UN)!(AL?1N.N)) D IV G E
        I $L(AL)>8 D IV2 G E
        X "ZL @TPG S T=$T(@AL)"
        I T="" W !!,"     No such line in routine ",TPG,! G E
        S SP=" " X "ZL @TPG F AP=1:1 S:$P($T(+AP),SP,1)=AL LP=AP I $T(+AP)="""" S EP=AP-1 Q"
        S AP=LP+OFF I AP>EP S AP=EP
        S NUL="" K ^UTILITY($J)
        X "ZL @PGM S J=0 F I=TP:-1:FP S T=$T(+I) I T'=NUL S ^UTILITY($J,J)=T,J=J+1"
        X "ZL @TPG F I=$N(^UTILITY($J,-1)):0 Q:I<0  S ND=^(I),I=$N(^(I)) ZI ND:+AP I I<0 ZS @TPG Q"
        W !!,"     Copy is complete",!! S $ZE="" G %RCOPY
ER      I $ZE?1"<NOPGM>".E W !!,"Routine name  '",@PRG,"'  does not exist",! S $ZE="ER^%RCOPY" G:%FL D G A
        W !!,"ERROR - ",$ZE S $ZE="" G EXIT
IV      W !!,"Incorrect response" D QUES Q
IV1     W !!,"Routine name exceeds maximum length" D QUES Q
IV2     W !!,"Line label exceeds maximum length" D QUES Q
QUES    W " - Enter '?' for more information",! Q
HELP    W !!,"Enter the routine name from which you wish to copy lines"
        W !,"Enter <CR> or ^ to exit." D HELPA G A
HELPA   W !!,"Note: Format of a routine name",!
        W !,"The initial character of a routine name must be either a '%' or"
        W !,"an upper-case alpha character.  A routine name must not exceed"
        W !,"8 characters in length.  Special characters are not allowed.",! Q
HELP1   W !!,"Enter first line label or label+offset which you wish to copy"
        D HELPQ,HELPB G B
HELPB   W !!,"Note:  Format of a line label",!
        W !,"The initial character of a line label must be either a '%' or",!,"an upper-case alpha character, followed by one or more alphanumeric"
        W !,"characters.  A line label may also be an integer.  Special characters"
        W !,"are not allowed.  A line label must not exceed 8 characters in length.",! Q
HELP2   W !!,"Enter the last label or label+offset that you wish to be copied"
        D HELPQ,HELPB G C
HELP3   W !!,"Enter the name of the routine into which you wish to copy"
        D HELPQ,HELPA G D
HELP4   W !!,"Enter the line label + offset;"
        W !,"Code segment delimited by 'from line' to 'through line' prompts "
        W !,"will be copied into the specified routine immediately following"
        W !,"this line reference."
        D HELPQ,HELPB G E
HELPQ   W !,"Enter <CR> or ^ to return to previous question." Q
EXIT    K %FL,%PGM,AL,AP,EP,FL,FP,I,J,LP,ND,NUL,OFF,PGM,PRG,SP,T,TL,TP,TPG Q
