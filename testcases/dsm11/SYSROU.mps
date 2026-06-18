SYSROU  ;DSM11 V2 UTILITIES; COPYRIGHT 1980 DEC
        Q
TYPES   S TYPES="DK,DM,DR,DB,DL,DU"
        Q
DEF     S SYV="^SYS",DEF=$P(SUB,"/",2,255),SUB=$P(SUB,"/",1),SV0=1,COM="("
        S:$E(DEF,1)="'" DEF=@$E(DEF,2,255)
DEF2    S SV1=$P(SUB,",",SV0) I $E(SV1,1)="'" S SV1=$E(SV1,2,255) G DEF3
        I SV1="" S SYV=SYV_")" S DFI=$D(@SYV)#10 S:DFI DEF=@SYV Q
        S SV1=""""_SV1_""""
DEF3    S SYV=SYV_COM_SV1,COM=",",SV0=SV0+1 G DEF2
VALID   W !,"Valid answers are:"
        W !,"  Y",?8,"- yes",!,"  N",?8,"- no",!
        W "  ?",?8,"- get help",!,"  ^",?8
        W "- go back to previous question",!," <CR>",?8
        W "- accept default value",!! Q
SETPRV  V:'($V(2,$J)\2#2) 2:$J:$V(2,$J)+2
        Q
RSTPRV  V:$V(2,$J)\2#2 2:$J:$V(2,$J)-2
        Q
EN      S QMK="",%YN="" G SAYQ
ASKY    S DEF="Y" G ASKYN
ASKN    S DEF="N"
ASKYN   S QMK=" ?",%YN=" [Y OR N]" G SAYQ
ASK     S QMK=" ?",%YN=""
SAYQ    D @QUES W %YN,QMK,"  " W:DEF'="" "<",DEF W ">   " R ANS,!
        I ANS="?" D:$L($T(@(QUES_"H"))) @(QUES_"H") G SAYQ
        S %A=0 I ANS="^" S %A=1 Q
        S:ANS="" ANS=DEF Q:%YN=""
        S ANS=$E(ANS,1) Q:"YN^"[ANS  D VALID^SYSROU G SAYQ
ID      S DEF=^SYS(0,"DEFAULT"),ST=$V(44),SGN=0
        W !,"Enter the name of the configuration you wish to alter <",DEF R "> ",ID
        S:ID="" ID=DEF I ID="^" K DDPFL Q
        I ID["?" D HLP1 G ID
        I '$D(^SYS(ID))!(ID=0) D IV G ID
        I $D(DDPFL) I ^SYS(ID,"OPTIONS","DDP")'="Y" W !,"This configuration does not have DDP",! G ID
        D CHKVER I '%A G ID
        I '$D(^SYS(0,"RUNNING")) S DMB="D" Q
        I ^SYS(0,"RUNNING")'=ID S DMB="D" Q
        I $ZU("")'="1,0" S DMB="D" Q
CHK     W !!,"Configuration """,ID,""" is running now. If you continue,"
        W !,"both memory and disk will be modified."
        R !,"Are you sure you want to proceed ? <NO> ",ANS
        I ANS["?" D HLP2 G CHK
        I ANS=""!(ANS="^")!($E("NO",1,$L(ANS))=ANS) W ! G ID
        I $E("YES",1,$L(ANS))=ANS S DMB="B" Q
        D IV G CHK
CHKVER  I $D(^SYS(ID,"SYSTEM")) S %A=1+($E(^("SYSTEM"),1,18)=$E($ZV,1,18)) Q
        W !,"The ",ID," configuration is not a ",$ZV," compatible"
        W !,"configuration.  You must create a new configuration.",! S %A=0 Q
CHKSYS  S %A=$ZU("")'="1,0"
        I %A W !,"This utility may only be run from the ",$ZU(1,0)," UCI",!
        Q
HLP1    W !!,"You must enter the name of the configuration you want to modify."
        W !,"The name you enter must be a currently defined configuration."
        W !,"Enter <CR> to accept the default specified in <> or '^' to abort.",!
        W !,"Note:  configuration ID '0' is reserved and may not be altered.",! Q
HLP2    W !!,"Enter Y(ES) to continue or  <CR> or N(O) to abort.",! Q
IV      W !!,"Incorrect response - enter '?' for more information.",! Q
