%SUM3   ;PRINT ROUTINES : JEC ; 22-SEP-80  1:48 PM
        B 1 D INT^%D,INT^%T S HEAD=%DAT1_" "_%TIM,TRM=%DTY="TRM",IOM='TRM*52+71,W="S",NAM=-1
        F %I=0:%SUM S NAM=$N(^UTILITY("SUM1",%JB,NAM)) Q:NAM<0  D SB1 Q:'%SUM
        K %JB,%I,%SUM,HEAD,I,J,N,NAM,SIZ,SWT,T,TRM,V,W,X,Y,Z
END     Q
SB1     S SIZ=^UTILITY("SUM1",%JB,NAM,0)
        W !,NAM,?9,SIZ,?18,"   ",HEAD,!!
        F X=1:1:4 S V=-1,Y=$E("VAGP",X) D SB2 W:X=3&$D(^UTILITY("SUM1",%JB,NAM,0,"NAKED")) !!?2,"NAKED REFERENCES" W:X=1&$D(^("$VIEW")) !!?2,"$VIEW FUNCTION USED" W:X=1&$D(^("VIEW")) !!?2,"VIEW COMMAND USED" W !!
        H:TRM 1 W # Q
SB2     S N=$P("VARIABLES,ARRAYS,GLOBALS,ROUTINES",",",X) W !,N,!
        F I=1:1:$L(N) W "-"
        W ! G S1:X>1&(X<4),S1:'$D(^UTILITY("SUM1",%JB,NAM,X)),S1:X'=1&(X'=4)
        S IND=-1 W ?5,"INDIRECTION" F I=0:1 S IND=$N(^UTILITY("SUM1",%JB,NAM,X,IND)) Q:IND<0  W !?7,^(IND)
        W !!
S1      S V=$N(^UTILITY("SUM1",%JB,NAM,Y,V)) Q:V<0  S T=^UTILITY("SUM1",%JB,NAM,Y,V) I $X>67 W !
        S Z=X\4+1,SWT=1 W:Z=1 $E("        ",1,8-$L(V)) W V I X<4,T[W W "*" S SWT=0
        I Z=1 W:SWT " " W "  "
        E  W ?12,"( "
        G S1:X<4 F I=1:1:5 I T[$P("C,O,L,F,J",",",I) W $P("CALL,OVERLAY,LOAD,FIL,START",",",I),"ED [",$P("DO,GOTO,ZL,ZS,ZJ",",",I),"]  "
        W ")",! G S1
Z       P %SUM3 ZS %SUM3
