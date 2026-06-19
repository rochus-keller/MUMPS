DDPCIR  ;27-Feb-85 ;UTILITIES ;DDP ;GET CIRCUIT INFORMATION ;JHM
        D CHKSYS^SYSROU Q:%A  D:$D(^UTILITY("MENU",$J,"MENU")) PUSH^%MENU S ^UTILITY("MENU",$J,"MENU")="^%MENU(""SYS"",""DDP"",""CIRCUIT MANAGEMENT"")" D %STT^%MENU
        S %NOPAUSE=1 Q
ENAB    W !,"Enable Circuit",! D CHKDDP G:%A EXIT
E1      D GETNOD G:%A EXIT G:'RV E1 I RV>0 W ! D CIRON G E1
        D CHKRV G:'RV E1 D STRCIR G E1
DISAB   W !,"Disable Circuit",! D CHKDDP G:%A EXIT
D1      D GETNOD G:%A EXIT G:'RV D1 I NODE'="*" W ! D CIROFF G D1
        D CHKRV G:'RV D1 D STPCIR G D1
STA     W !,"Circuit Status",! D CHKDDP G:%A EXIT
        S RV=-1 D CIRSTA G EXINOP
COUNT   W !,"Circuit Activity Counters",! D CHKDDP G:%A EXIT
N1      D GETNOD G:%A EXIT G:'RV N1
        W !,"         Requests       Requests      Requests       Requests Recieved"
        W !,"Node     Received         Sent        Retried           Out-of-Sync",!!
        I RV>0 D N2 W ! G N1
        D CHKRV G:'RV N1
        F ND=1:1 S RV=$V(0,RV) Q:'RV  I $V(10,RV)  D N2
        G N1
N2      D GETCIR W NODE,?7,$J(RCV,10),?22,$J(SNT,10),?40,$J(RTY,6),?60,$J(OOS,6),! Q
RESET   W !,"Reset Circuit Counters",! D CHKDDP G:%A EXIT
R1      D GETNOD G:%A EXIT G:'RV R1
        I RV>0 D R2 G R1
        D CHKRV G:'RV R1
        F ND=1:1 S RV=$V(0,RV) Q:'RV  D R2
        W ! G R1
R2      D GETCIR F R=50:2:60 V R:RV:0
        W !,NODE," - reset" Q
GETNOD  S DEF="",QUES="NOD",RV=0 X ^%Q("EN") Q:%A  I ANS="" S %A=1 Q
        I ANS'?3U,ANS'="*" D IV G GETNOD
        S NODE=ANS,RV=-1 Q:ANS="*"  D GETRV I 'RV W !,"There is no DDP circuit to node ",NODE,! Q
        Q
GETCIR  S N=$V(10,RV) D PKASC S NODE=N
        S VOL=NODE F R=12:2:24 S N=$V(R,RV) D PKASC S:N'="@@@" VOL=VOL_","_N
        S SNT=$V(52,RV)*65536+$V(50,RV),RCV=$V(56,RV)*65536+$V(54,RV)
        S RTY=$V(58,RV),OOS=$V(60,RV)
        S ADDR="" F R=4:1:9 S %N=$V(R,RV)#256,%A="" D   S ADDR=ADDR_"-"_%A
L       .I %N'=0 S %D=%N#16,%N=%N\16 S:%D>9 %D=$C($A("A")+%D-10) S %A=%D_%A G L
        .F I=$L(%A):1:1 S %A=0_%A
        S ADDR=$E(ADDR,2,255),DDB=$V(2,RV),LNK=$V(DDB+6)#256,VER=$S($V(DDB+7):"3.0",1:"3.1")
        I ADDR="00-00-00-00-00-00" S ADDR=""
        S LNKSTA=$S($V(DDB+4)\128#2:"Enabled",1:"Disabled")
        S LNKSRV=$S($V(DDB+4)\8#2:"Out of",1:"In")_" Service"
        S STA=$S($V(26,RV)\128#2:"Dis",1:"En")_"abled"
        S STA=STA_","_$S($V(26,RV)\4#2:"Unreachable",1:"Reachable")
        I $V(26,RV)#2 S STA=STA_",Read Locked"
        I $V(26,RV)\2#2 S STA=STA_",Write Locked"
        I $V(26,RV)\8#2 S STA=STA_",Error condition"
        S DEV=$C($V(DDB+16)#256,$V(DDB+17))_($V(DDB+14)#256)
        K DDB,N,R,I
        Q
CHKDDP  S ID=^SYS(0,"RUNNING"),ST=$V(44),%A=1 I ID=""!$V(ST+35) W !,"DDP is not available in the baseline system",! Q
        S %A=$V(ST+144)=0 I %A W !,"DDP is not available in this configuration"
        Q
STRCIR   S RV=$V($V(44)+444) F ND=1:1 S RV=$V(0,RV) Q:'RV  I $V(10,RV) D CIRON
        Q
CIRON   D GETCIR,ENBCIR^DDPSRV W:'$D(STU) "Circuit to ",NODE," - enabled",! Q
STPCIR  S RV=$V($V(44)+444) Q:'RV  F ND=1:1 S RV=$V(0,RV) Q:'RV  I $V(10,RV) D CIROFF
        Q
CIROFF  D GETCIR S N=NODE D ASCPK,DISCIR^DDPSRV W:'$D(STU) "Circuit to ",NODE," - disabled",! Q
CIRSTA  D C1 I RV>0 D C2 Q
        D CHKRV Q:'RV
        F ND=1:1 S RV=$V(0,RV) Q:'RV  I $V(10,RV) D C2
        Q
C1      W !?48,"Mounted",?61,"Ethernet"
        W !,"Circuit",?9,"Link",?15,"Link State",?30,"Circuit State",?46,"Volume Sets",?61,"Address",!! Q
C2      D GETCIR S N=NODE,L=LNK,D=LNKSTA,S=ADDR I $E(LNKSRV)="O" S D=LNKSRV
        F I=1:1 D  S (N,L,D,S)="" I $P(VOL,",",I+1)="",$P(STA,",",I+1)="" Q
        .W ?2,N,?10,L,?14,D,?32,$P(STA,",",I),?50,$P(VOL,",",I),?61,S,!
        Q
GETRV   S N=NODE D ASCPK S RV=$V($V(44)+444) I 'RV Q
        F I=1:1 Q:$V(10,RV)=N  S RV=$V(0,RV) Q:'RV
        Q
CHKRV   S RV=$V($V(44)+444) I 'RV!'$V(0,RV) W !,"No circuits defined",!
        Q
PKASC   S N=$C(N\2048+64,N\64#32+64,N\2#32+64) Q
ASCPK   S N=$A(N)-64*32+$A(N,2)-64*32+$A(N,3)-64*2 Q
LOAD    Q
EXINOP  D EXIT K %NOPAUSE Q
EXIT    K NODE,RV,DEF,ANS
        S %NOPAUSE=1 Q
IV      W !,"Invalid response, Type ? for help",! Q
NOD     W !,"Node name" Q
NODH    W !,"Enter the 3-character uppercase node name of the system"
        W !,"you are referencing.  The node name is the name of the"
        W !,"booted, SYSTEM VOLUME set name.",!
        W !,"Type * if you wish to list or reference all KNOWN nodes",! Q
