%SUM    ;Create summary for a set of routines : JEC ; 16-OCT-80  5:24 AM
        W !!!,"Cross reference/Summary options",!!,"  1.  Print routine(s) with cross reference (symbol table)"
        W !,"  2.  Create and print summary for a set of routines"
        W !,"  3.  Reprint summary which was created earlier"
        W !,"  4.  Reprint routine(s) with cross reference from a summary"
        W !,"  5.  Lookup where routines/globals are used in a summary"
        W !,"  6.  Print a structure diagram for a set of routines"
        R !!,"Cross reference/Summary option: ",X Q:X=""!(X?1"^".E)  G %SUM:X?1"?".E
        I X'?1N.N W *7,"  must be a number between 1 and 6" G %SUM
        I X<1!(X>6) W *7,"  choose from options 1 thru 6" G %SUM
        K ^UTILITY($J) G ^%CRF:X=1,^%SUM4:X=3,^%SUM5:X=4,^%WU:X=5,^%OVR:X=6
        K  W !!,"Create/print symbol table summary for a set of routines" D ^%RSEL G KIL:$N(^UTILITY($J,0))<0
A1      R !!,"Summary name: ",%JB G END:%JB=""!(%JB?1"^".E),A4:%JB?1"*".E I %JB?1"?".E W "  Enter up to an 8 character summary name
or",!?18,"a '*' to list current summaries on file." G A1
        I %JB'?.AN W *7,"  bad character" G A1
        I $L(%JB)>8 W *7,"  Limit of 8 characters" G A1
A2      I $D(^UTILITY("SUM1",%JB,0,0)) S %SUM=^(0) W *7,"  Recreate existing summary (",%SUM,")" R "  Ok? ",X G A6:X?1"Y".E,A1:X'?1"?".E W !!,"  Enter Yes to recreate this summary or No to try another name",!! G A2
A3      R !,"Summary description: ",%SUM G A1:%SUM=""!(%SUM?1"^".E)
        I %SUM?1"?".E W "  Enter up to a 22 character description of this summary" G A3
        I $L(%SUM)>22 W *7,?40,"   up to a 22 character name" G A3
        G A6
A4      S (I,J)=0 W !
A5      S I=$N(^UTILITY("SUM1",I)) I I<0 G A1:J W *7,!,"   No documentation on file" G A1
        I $D(^UTILITY("SUM1",I,0,0)) W !,I,?10,^(0) S J=1
        G A5
A6      R !!,"Do you want to print the summary? <Y> ",PRS G A1:PRS?1"^".E S:PRS="" PRS="Y" I PRS?1"?".E W !,"  Enter either Yes or No" G A6
A7      R !,"Do you want to print the routines? <Y> ",PRR G A6:PRR?1"^".E S:PRR="" PRR="Y" S %SYM=1 I PRR?1"?".E W !,"  Enter either Yes or No" G A7
        S:PRS'?1"Y".E PRS="N" S:PRR'?1"Y".E PRR="N" I PRS="N",PRR="N" S IOO=$I,%IO=$I,ARF="" G D1
IOD     S $ZE="",IOO=$I,%DEF=$I D ^%IOS G KIL:'$D(%IOD) S %IO=%IOD G DET:IOO=%IO
USR     O 0 U 0 R !,"User name: ",ARF G IOD:ARF?1"^".E I ARF?1"?".E W "  Enter a name to put on the report header" G USR
HDR     R !,"Do you want a single line (S), full block (F) or no header (N) on listing: <F> ",%HEADER,! I "S,F,N"'[%HEADER W *7,!?4,"  Please enter either an S, F, N or <CR> for the default",! G HDR
DET     I IOO=%IO W !!,"Please wait..." G INIT
D1      S STR=%JB_" SUMMARY FOR  "_ARF W !!,"Exit",!! C $I,%IO S %DV=%IO B 1
INIT    K ^UTILITY("SUM",%JB),^UTILITY("SUM1",%JB),(%JB,%SUM,IOO,%IO,%DTY,STR,ARF,%OP,%DV,%BLK,%HEADER,PRR,PRS,%SYM) S A=0,^UTILITY("SUM",%JB)=$H,^UTILITY("SUM1",%JB,0,0)=%SUM
        X "F I=1:1 S A=$N(^UTILITY($J,A)),T=0 Q:A<0  ZL @A F J=1:1 S ^UTILITY(""SUM"",%JB,A,J)=$T(+J),T=T+$L($T(+J)) I $T(+J+1)="""" S ^UTILITY(""SUM1"",%JB,A,0)=T ZL %SUM Q"
        S %I=0 F %II=1:1 S %I=$N(^UTILITY("SUM1",%JB,%I)) Q:%I<0  D ^%SUM1
        I PRS="Y" O:%IO<59!(%IO>63) %IO O:%IO>58&(%IO<63) %IO:(0:%BLK) U %IO D ^%SUM2
        I PRR="Y" S:IOO'=%IO STR=%JB_" ROUTINES FOR "_ARF D START^%SUM5
KIL     K ^UTILITY($J),%A,%DT,%DAT,%DAT1,%DAT2,%SUM,%TIM,%TIM1,A,H,I,X,ARF,CRE,E,ERA,FIG,IN,INC,IND,IOM,K,L1,L2,LC,M,P,PGM,PRR,PRS,PRT,R,STR,SW,SWT,TIM,TN,TYP,%BLK,%CH,%CP,%DTY,%DV,%FS,%HED,%II,%I9,%L9,%MS,%N,%NX,%OP,%PF,%ST,%SYM,%T,%T8,%TM,%TR
        K %UCN,%UCI
        S $ZE="" I $D(%IO),%IO,IOO'=%IO U %IO W:%IO>58&(%IO<63) !,"@@@",! H
        K IOO,%IO
END     Q
Z       P %SUM ZS %SUM
