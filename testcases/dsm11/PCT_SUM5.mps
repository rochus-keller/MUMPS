%SUM5   ;PRINT ROUTINES FROM ^UTILITY("SUM1") : JEC ; 12-JUN-79  9:12 AM
        W !!!,"Reprint routines from the summary file",!
A1      R !!,"Summary name: ",%JB G END:%JB=""!(%JB?1"^".E) I %JB?1"*".E D HELP G A1
        I %JB?1"?".E W !!,"  Enter either a summary name or a '*' to list current summaries on file" G A1
        I %JB'?.AN W *7,"  bad character" G A1
        I $L(%JB)>8 W *7,"  Limit of 8 characters" G A1
A2      I $D(^UTILITY("SUM1",%JB,0,0)) S %SUM=^(0) W *7,"  Use existing summary (",%SUM,")" R "  Ok? ",X G ROU:X?1"Y".E,A1:X'?1"?".E W !!,"  Enter Yes to use this summary to reprint routines or No to try another name",!! G A2
ROU     D ^%SUMSEL Q:$N(^UTILITY($J,0))<0
SYM     R !,"Symbol table? <Yes> ",%SYM S:%SYM="" %SYM="Y" G %SUM5:%SYM?1"^".E I %SYM?1"?".E W "  Enter either Yes, No or <CR> for default" G SYM
IOD     S $ZE="",%SYM=%SYM?1"Y".E,IOO=$I,%DEF=$I D ^%IOS G END:'$D(%IOD) S %IO=%IOD G DET:IOO=%IO
USR     O 0 U 0 R !,"User name: ",ARF G IOD:ARF?1"^".E I ARF?1"?".E W "  Enter a name to put on the report header" G USR
HDR     R !,"Do you want a single line (S), full block (F) or no header (N) on listing: <F> ",%HEADER,! I "S,F,N"'[%HEADER W *7,!?4,"  Please enter either an S, F, N or <CR> for the default",! G HDR
DET     I IOO=%IO W !!,"Please wait..."
        E  S STR=%JB_" ROUTINES  "_ARF W !!,"Exit",!! C $I,%IO S %DV=%IO
START   ;
        B 1 O %IO U %IO D:IOO'=%IO ^%HDR S CRE=^UTILITY("SUM",%JB),%DT=+CRE D %CDS^%H S %T=$P(CRE,",",2),CRE=%DAT1 D TIM D INT^%D,INT^%T S HEAD=" created on "_CRE_" at "_TIM_"     printed on "_%DAT1_" at "_%TIM1,TRM=%DTY="TRM",IOM='TRM*52+71
        S PGM=0 F %I=1:1 S PGM=$N(^UTILITY($J,PGM)) Q:PGM<0  D SB1
        K %JB,%I,HEAD,I,J,N,NAM,S,SIZ,T,TRM,V,W,X,Y,Z
END     Q
HELP    S (I,J)=0 W !
H1      S I=$N(^UTILITY("SUM1",I)) I I<0 Q:J  W *7,!?4,"No documentation on file" Q
        I $D(^UTILITY("SUM1",I,0,0)) W !,I,?10,^(0) S J=1
        G H1
SB1     Q:'$D(^UTILITY("SUM1",%JB,PGM,0))  S NAM=PGM,SIZ=^(0) W !,NAM,?9,SIZ,?18,"   ",HEAD,!!
        F I=1:1 Q:'$D(^UTILITY("SUM",%JB,PGM,I))  S X=^(I),T=$P(X," ",1),X=$P(X," ",2,99) W !,T,?9,$E(X,1,IOM) F J=IOM+1:IOM-3:255 I $E(X,J,J+IOM-4)'="" W !,?7,".",?12,$E(X,J,J+IOM-4)
        G S1:'%SYM H:TRM 1 W #,!,NAM,?9,SIZ,?18,"   ",HEAD,!!
        F TYP="V","A","G","P" S V=-1 D SB2 W:TYP="G"&$D(^UTILITY("SUM1",%JB,PGM,0,"NAKED")) !!?2,"NAKED REFERENCES" W:TYP="V"&$D(^("$VIEW")) !!?2,"$VIEW FUNCTION USED" W:TYP="V"&$D(^("VIEW")) !!?2,"VIEW COMMAND USED" W !!
S1      H:TRM 1 W # Q
SB2     S N=$S(TYP="V":"VARIABLES",TYP="A":"ARRAYS",TYP="G":"GLOBALS",TYP="P":"ROUTINES",1:""),X=0 S:TYP="V" X=1 S:TYP="P" X=4 W !,N,!
        F I=1:1:$L(N) W "-"
        W ! G S2:'X,S2:'$D(^UTILITY("SUM1",%JB,PGM,X)),S2:X'=1&(X'=4)
        S IND=-1 W ?5,"INDIRECTION" F I=0:1 S IND=$N(^UTILITY("SUM1",%JB,PGM,X,IND)) Q:IND<0  W !?7,^(IND)
        W !!
S2      S V=$N(^UTILITY("SUM1",%JB,PGM,TYP,V)) Q:V<0  S T=^UTILITY("SUM1",%JB,PGM,TYP,V),S=1
        W:TYP'="P" $E("        ",1,8-$L(V)) W V I TYP'="P",T="S" W "*" S S=0
        I TYP'="P" W:S " " W "  "
        E  W ?12,"( "
        G S2:TYP'="P" F I=1:1:5 W:T[$P("C,O,L,F,J",",",I) $P("CALL,OVERLAY,LOAD,FIL,START",",",I),"ED [",$P("DO,GOTO,ZL,ZS,ZJ",",",I),"]  "
        W ")",! G S2
TIM     S %M=%T\60,%N=$E("AP",%M\720+1)_"M",%M=-%M\720*720+%M,%H=%M\60,%M=-%H*60+%M
        S:'%H %H=12 S:%H<10 %H=" "_%H S:%M<10 %M=0_%M S TIM=%H_":"_%M_" "_%N Q
Z       P %SUM5 ZS %SUM5
