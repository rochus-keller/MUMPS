DDPLNK  ;27-Feb-85 ;UTILITY ;DDP ;DDP LINK STATUS AND CONTROL UTILITY ;JHM
        D:$D(^UTILITY("MENU",$J,"MENU")) PUSH^%MENU S ^UTILITY("MENU",$J,"MENU")="^%MENU(""SYS"",""DDP"",""LINK MANAGEMENT"")" D %STT^%MENU
        S %NOPAUSE=1 Q
STA     W !,"DDP Link Status" D CHKDDP G:%A EXIT
        W ?50,"Total Out-of-Buffer: ",$V(ST+456),!
        D S2 S DDB=$V(ST+422) F LNK=0:1 D S3 S DDB=$V(DDB+2) Q:'DDB
        W !! G EXINOP
S2      W !?30,"Device",?38,"Receive",?46,"Transmit",?55,"Buffer",?66,"Ethernet"
        W !,"Link",?8,"Device",?18,"State",?30,"Errors",?38,"Errors",?46,"Errors",?55,"Errors",?66,"Address",! Q
S3      D GETLNK W !?2,LNK,?6,TYP," (",DEV,")",?18,LNKSTA,?30,$J(ERR,6),?38,$J(DISC,6),?46,$J(XMTO,6),?54,$J(NRBUF,6),?63,ADDR,!?18,LNKSRV Q
ENAB    W !,"Enable DDP Link",! D CHKDDP G:%A EXIT
E1      D LINK G:%A EXIT W ! I LNK'="*" D LNKON G E1
        D STRLNKS G E1
DISAB   W !,"Disable DDP Link",! D CHKDDP G:%A EXIT
D1      D LINK G:%A EXIT W ! I LNK'="*" D LNKOFF G D1
        D STPLNKS G D1
SERV    W !,"Set Link Service",! D CHKDDP G:%A EXIT
A1      D LINK G:%A EXIT I LNK="*" D IV G A1
        D GETLNK W !,"DDP Link #",LNK," is currently ",LNKSRV,!!
A2      S STU="",QUES="SERVQ",DEF="" X ^%Q("EN") I ANS=$E(LNKSRV)!(ANS="")!%A G A1
        I "IO"'[ANS D IV G A2
        I ANS="I",$V(DDB+4)\8#2 V DDB+4::$V(DDB+4)-8 D LNKON
        I ANS="O",'($V(DDB+4)\8#2) D LNKOFF V DDB+4::$V(DDB+4)+8
        S ^SYS(ID,"DDP","LINES",LNK,"SERVICE")=$S(ANS="O":"Out of",1:"In")_" Service"
        W !,"Permanent database modified",! G A1
LINK    S ST=$V(44),DEF="",QUES="LNK" X ^%Q("EN") Q:%A  I ANS="" S %A=1 Q
        I ANS="*" S LNK=ANS Q:$V(ST+422)  W !,"There are no DDP links in this configuration",! G LINK
        I ANS'?1N D IV G LINK
        S DDB=$V(ST+422)+4 F I=0:1:ANS-1 S DDB=$V(DDB+2) Q:'DDB
        I 'DDB W !,"Link #",ANS," is not in this configuration",! G LINK
        S LNK=ANS Q
GETLNK  S DDB=$V(ST+422)+4 F I=0:1:LNK-1 S DDB=$V(DDB+2)
        S DEV=$C($V(DDB+16)#256,$V(DDB+17))_($V(DDB+14)#256)
        S TYP=$S($V(DDB+8)=0:"DMC11",$V(DDB+8)=4:"DEQNA",1:"DEUNA")
        S LNKSTA=$S($V(DDB+4)\128#2:"Enabled",1:"Disabled")
        S LNKSRV=$S($V(DDB+4)\8#2:"Out of",1:"In")_" Service"
        S ADDR="" F R=30:1:35 S %DH=$V(DDB+R)#256 D ^%DH S:$L(%DH)=1 %DH=0_%DH S ADDR=ADDR_"-"_%DH
        S ADDR=$E(ADDR,2,255),VER=$S($V(DDB+7):"3.0",1:"3.1"),ERR=$V(DDB+26),DISC=$V(DDB+36),NRBUF=$V(DDB+38),XMTO=$V(DDB+40)
        I ADDR="00-00-00-00-00-00" S ADDR=""
        Q
CHKDDP  S ID=^SYS(0,"RUNNING"),ST=$V(44),%A=1 I ID=""!$V(ST+35) W !,"DDP is not available in the baseline system",! Q
        S %A=$V(ST+144)=0 I %A W !,"DDP is not available in this configuration" Q
        D CHKSYS^SYSROU Q
STPDDP  S ST=$V(44),STU="" Q:'$V(ST+144)  W !,*6,*6,"DDP shutting down ..."
        S SCM="MID" D ALINKS^DDPSRV
        S N=$V(ST+459) I N W " DDP servers stopping ..." V ST+458::129 F I=1:1:N ZY -2,0
        D STPCIR^DDPCIR,STPLNKS
        W " DDP shutdown complete",! Q
STU     H 5 S ID=^SYS(0,"RUNNING"),DDP=^SYS(ID,"DDP","SERVERS"),ST=$V(44)
STRDDP  S ST=$V(44),STU="" Q:'$V(ST+144)  W !,"DDP startup ..."
        W " ",DDP," server" W:DDP'=1 "s" W " started ..." D STRSRV,STRCIR^DDPCIR,STRLNKS
        H 5 S SCM="SWI" D ALINKS^DDPSRV
        W " DDP startup complete" Q
STRSRV  V ST+458::DDP*256 F I=1:1:DDP J START^DDPSRV
        Q
STRLNKS S DDB=$V(ST+422) Q:'DDB  S DDB=DDB+4 F LNK=0:1 D LNKON S DDB=$V(DDB+2) Q:'DDB
        Q
LNKON   ZY -6,LNK V DDB+28::$V(DDB+28)#256 W:'$D(STU) "Link #",LNK," - enabled",! Q
STPLNKS S DDB=$V(ST+422) Q:'DDB  S DDB=DDB+4 F LNK=0:1 D LNKOFF S DDB=$V(DDB+2) Q:'DDB
        Q
LNKOFF  ZY -4,LNK W:'$D(STU) "Link #",LNK," - disabled",! Q
EXINOP  D EXIT K %NOPAUSE Q
EXIT    K LNK,ADDR,LNKSTA,TYP,DEV,%DH,ERR,STA,DDB,STU
        S %NOPAUSE=1 Q
SETRN   V $V(44)+458::2+$V(458+$V(44)) Q
CLRTRN  V $V(44)+458::$V(458+$V(44))-2 Q
IV      W !,"Invalid response, Type ? for help",! Q
LNK     W !,"Link #" Q
LNKH    W !,"Enter the DDP Link # which you wish to reference.  The following"
        W !,"Link assignments exist:",!
        F I=0:1:^SYS(ID,"DDP","LINES")-1 W !?5,"Link #",I,?20,^SYS(ID,"DDP","LINES",I,"CONTROLLER"),"-",^("CONTROLLER NUMBER")
        W !!,"Enter * if you wish to refer to ALL configured links",! Q
SERVQ   W "Set In Service or Out of Service [I or O]" Q
SERVQH  W !,"The service state allows you to declare a DDP link as broken or"
        W !,"unusable, thereby preventing any attempts to enable and use the link."
        W !!,"In configurations which have multiple links to the same nodes, it"
        W !,"is desireable to set one of the links OUT OF SERVICE, to force "
        W !,"circuit table updates through a single link",!
        W !,"Enter ""I"" to set this DDP link's service state to IN SERVICE"
        W !,"Enter ""O"" to set this DDP link's service state to OUT OF SERVICE",!
        W !,"The permanent database in ^SYS will be modified to reflect this"
        W !,"selected service state, so that the link will be initialized"
        W !,"in this state at system startup time.",!! Q
