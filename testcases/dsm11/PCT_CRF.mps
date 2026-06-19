%CRF    ;Print routines with symbol table : JEC ; 16-Nov-80  8:48 AM
        K  W !!,"Print routines/symbol tables" K ^UTILITY($J) D ^%RSEL G A2:$N(^UTILITY($J,0))<0
SYM     R !,"Symbol table? <Yes> ",%SYM S:%SYM="" %SYM="Y" G %CRF:%SYM?1"^".E I %SYM?1"?".E W "  Enter either Yes, No or <CR> for default" G SYM
IOD     W ! S $ZT="",%SYM=%SYM?1"Y".E,IOO=$I,%DEF=$I D ^%IOS G A2:'$D(%IOD) S %IO=%IOD G DET:IOO=%IO
USR     O 0 U 0 R !,"User name: ",ARF G IOD:ARF?1"^".E I ARF?1"?".E W "  Enter a name to put on the report header" G USR
HDR     R !,"Do you want a single line (S), full block (F) or no header (N) on listing: <F> ",%HEADER,! I "S,F,N"'[%HEADER W *7,!?4,"  Please enter either an S, F, N or <CR> for the default",! G HDR
DET     I IOO=%IO W !!,"Please wait..."
        E  S STR="ROUTINES  "_ARF W !!,"Exit",!! C $I,%IO S %DV=%IO
        S %JB=$J
A1      I $D(^UTILITY("CRF",%JB))!$D(^UTILITY("CRF1",%JB)) S %JB=%JB+100 G A1
        K ^UTILITY("CRF",%JB),^UTILITY("CRF1",%JB),(%JB,%SYM,IOO,%IO,%DTY,STR,ARF,%DV,%BLK,%HEADER) S (A,%R)=0
        X "F I=1:1 S A=$N(^UTILITY($J,A)),T=0 Q:A<0  ZL @A S %R=%R+1 F J=1:1 S ^UTILITY(""CRF"",%JB,I,J)=$T(+J),T=T+$L($T(+J)) I $T(+J+1)="""" S ^UTILITY(""CRF1"",%JB,I,0)=A_""^""_T ZL %CRF Q"
        I %SYM F %I=1:1:%R D ^%CRF1
        S:'$D(%DTY) %DTY="TRM" W:IOO=%IO # O:%IO<59!(%IO>63) %IO O:%IO>58&(%IO<63) %IO:(0:%BLK) D PRT
A2      S $ZT="" K ^UTILITY($J),%DT,%DAT,%DAT1,%DAT2,%R,%SYM,%TIM,%TIM1,A,I,IOM,X,%I9,%L9,%MS,%NX,%PF,%ST,%T8,%TM,%TR,%UCI,%UCN,ARF,ERA,FIG,LC,STR,%BLK,%CH,%CP,%DTY,%DV,%FS
        I $D(%IO),%IO,IOO'=%IO U %IO W:%IO>58&(%IO<63) !,"@@@",! H
        K IOO,%IO
        Q
PRT     B 1 O %IO U %IO D:IOO'=%IO ^%HDR D INT^%D,INT^%T S HEAD=%DAT1_" "_%TIM,TRM=%DTY="TRM",IOM='TRM*52+71
        F %I=1:1 Q:'$D(^UTILITY("CRF1",%JB,%I,0))  D SB1
        K ^UTILITY("CRF",%JB),^UTILITY("CRF1",%JB),%JB,%I,HEAD,I,J,N,NAM,S,SIZ,T,TRM,V,W,X,Y,Z
END     Q
SB1     S Y=^(0),NAM=$P(Y,"^",1),SIZ=$P(Y,"^",2) W !,NAM,?9,SIZ,?18,"   ",HEAD,!!
        F I=1:1 Q:'$D(^UTILITY("CRF",%JB,%I,I))  S X=^(I),T=$P(X," ",1),X=$P(X," ",2,99) W !,T,?9,$E(X,1,IOM) F J=IOM+1:IOM-3:255 I
$E(X,J,J+IOM-4)'="" W !,?7,".",?12,$E(X,J,J+IOM-4)
        G S1:'%SYM H:TRM 1 W #,!,NAM,?9,SIZ,?18,"   ",HEAD,!!
        F X=1:1:4 S V=999,Y=$P("V,A,G,P",",",X),W=Y_"S" D SB2 W:X=3&$D(^UTILITY("CRF1",%JB,%I,0,"NAKED")) !!?2,"NAKED REFERENCES" W:X=1&$D(^("$VIEW")) !!?2,"$VIEW FUNCTION USED" W:X=1&$D(^("VIEW")) !!?2,"VIEW COMMAND USED" W !!
S1      H:TRM 1 W # Q
SB2     S N=$P("VARIABLES,ARRAYS,GLOBALS,ROUTINES",",",X) W !,N,!
        F I=1:1:$L(N) W "-"
        W ! G S2:X>1&(X<4),S2:'$D(^UTILITY("CRF1",%JB,%I,X))
        S IND=-1 W ?5,"INDIRECTION" F I=0:1 S IND=$N(^UTILITY("CRF1",%JB,%I,X,IND)) Q:IND<0  W !?7,IND
        W !!
S2      S V=$N(^UTILITY("CRF1",%JB,%I,V)) Q:V<0  S T=^UTILITY("CRF1",%JB,%I,V) G S2:T'[Y I $X>67 W !
        S Z=X\4+1,S=1 W:Z=1 $E("        ",1,8-$L(V)) W V I X<4,T[W W "*" S S=0
        I Z=1 W:S " " W "  "
        E  W ?12,"( "
        G S2:X<4 F I=1:1:5 W:T[$P("C,O,L,F,J",",",I) $P("CALL,OVERLAY,LOAD,FIL,START",",",I),"ED [",$P("DO,GOTO,ZL,ZS,ZJ",",",I),"]
 "
        W ")",! G S2
Z       P %CRF ZS %CRF
