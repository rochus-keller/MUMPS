CREATPQ ;
REST    S ^%Q("ER",40)="S ^(44)=""^%ER(""_DAT_"",""_NUM_"",""""REF"""",-1)"",^%Q(""ER"",48)=^%ER(DAT,NUM),^(46)=$P($P($P(^(48),""\""
,2),""^"",2),"":"",1),^(49)=$S($V(149,$J)=$P(^(48),""\"",7):1,1:0) K  ZR  ZL:^(46)'=""""&^(49) @^(46) S ^(47)=$S"
        S ^%Q("ER",40)=^%Q("ER",40)_" X ^(42),^%Q(""ER"",41),^(43)"
        S ^%Q("ER",41)="K %XQZUBKF W !!,""$ZE = "",$P(^(48),""\"",2) S ^(47)=$S(^(47)'>$S:1,1:0) W:'^(47) !!,""No Room to Load Routi
ne "",^(46),"" !!!"" W:'^(49) !!,""Cannot access routine, must be in UCI #"",$P(^(48),""\"",7)"
        S ^%Q("ER",42)="ZR  S ^(47)=$S-^(47),%XQZUBKF=^(44) F %XQZUBKF(1)=0:0 S %XQZUBKF=$ZN(@%XQZUBKF) Q:%XQZUBKF'[""REF""  S @(""@
""_%XQZUBKF)=@($P(%XQZUBKF,""REF"",1)_""DAT""_$P(%XQZUBKF,""REF"",2))"
        S ^%Q("ER",43)="ZL:^(46)'=""""&^(47)&^(49) @^(46) W:^(46)'=""""&^(47)&^(49) !!,""Line in Error:"" S ^(47)=$P($P($P($P(^(48),
""\"",2),"":"",1),""^"",1),"">"",2) P:^(47)'="""" @^(47) W:$X ! S $ZT="""" Entering Programmer Mode via <CMMND> Error."
CREATPQ ;
        S ^%Q="U 0 W !!,""TO LEARN HOW TO USE GLOBAL ^%Q, LIST ROUTINE 'CREATPQ'"",!"
        F I=1:1 S LINE=$T(DEFGLOB+I) Q:LINE=""  S SUB=$P(LINE," ",1) I SUB'="" S ^%Q(SUB)=$P(LINE,"*",2,255)
        K LINE,I,SUB
        U 0 W !,"CREATION OF GLOBAL ^%Q IS COMPLETE.",!
        Q
DEFGLOB ;
EN      *S %QMK="",%YN="" X ^(1)
ASKYN   *S %QMK=" ?",%YN=" [Y OR N]" X ^(1)
ASKY    *S %QMK=" ?",%YN=" [Y OR N]",DEF="Y" X ^(1)
ASKN    *S %QMK=" ?",%YN=" [Y OR N]",DEF="N" X ^(1)
ASK     *S %QMK=" ?",%YN="" X ^(1)
1       *F %A2=0:1 D @QUES W %YN,%QMK,"   " W:DEF'="" "<",DEF W ">   " R ANS,! X:ANS="?" ^(2) I ANS'="?" S %A=ANS="^" Q:%A  S:ANS=""
 ANS=DEF Q:%YN=""  S ANS=$E(ANS,1) Q:"YN"[ANS  D VALID^%SYSROU
2       *ZL:QUES["^" @$P(QUES,"^",2) D:$L($T(@($P(QUES,"^")_"H"))) @($P(QUES,"^")_"H")
SGEN    *S %QMK="",%YN="" X ^%Q("SG1")
SGASKYN *S %QMK=" ?",%YN=" [Y OR N]" X ^%Q("SG1")
SGASKY  *S %QMK=" ?",%YN=" [Y OR N]",DEF="Y" X ^%Q("SG1")
SGASKN  *S %QMK=" ?",%YN=" [Y OR N]",DEF="N" X ^%Q("SG1")
SGASK   *S %QMK=" ?",%YN="" X ^%Q("SG1")
SG1     *F %A2=0:1 X ^%Q("QUERY") W %YN,%QMK,"   " W:DEF'="" "<",DEF W ">   " R ANS,! X ^%Q("SGCNV") X:ANS="?"&$L($T(@(QUES_"H"))) ^
%Q("QUERYH") I ANS'="?" S %A=ANS="^" Q:%A  S:ANS="" ANS=DEF Q:%YN=""  S ANS=$E(ANS,1) Q:"YN"[ANS  D VALID^%SYSROU
QUERY   *X:EXTH ^%Q("EXTH") S %NO=$T(@QUES),%NUM=$P(%NO,";;",3),%LF=$P(%NO,";;",4),%NO=$P(%NO,";;",2) X:%LF-1 ^%Q("LF") G:'%NO @QUES
 I %NO F %I=1:1:%NO W ! W:%NUM'="" %NUM W ?6,$P($T(@QUES+%I),";;",2,255) S %NUM=""
QUERYH  *S %NO=$P($T(@(QUES_"H")),";;",2) G:'%NO @(QUES_"H") F %I=1:1:%NO W !,$P($T(@(QUES_"H")+%I),";;",2,255)
LF      *F %I=1:1:%LF-1 W !
EXTH    *I '$D(HLP(QUES)) S HLP(QUES)="" X ^%Q("QUERYH")
SGCNV   *S %A=ANS,ANS="" F %I=1:1:$L(%A) S ANS=ANS_$E(%A,%I) I $A(%A,%I)>96,$A(%A,%I)<123 S ANS=$E(ANS,1,$L(ANS)-1)_$C($A(%A,%I)-32)
