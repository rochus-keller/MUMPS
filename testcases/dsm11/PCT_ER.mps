%ER     ;ERROR DISPLAY ROUTINE : JEC ; 23-DEC-80  5:44 PM
        I '$D(^%ER) S ^%ER="60\100\1\1"
        I ^%ER="" S ^%ER="60\100\1\1"
        K
OPT     R !!,"(D)isplay Errors,  (P)urge Errors,  (S)et Parameters: <D> ",X
        G END:X="^"!(X="^Q")
        I X="?" S XQF="4,22,23" X ^%Q("ER") G OPT
        I X="" S X="D"
        I "S/P/D"'[X D IR G OPT
        G MX:X="S",PUR:X="P",DAT
MX      S DEF=$P(^%ER,"\",2)
        W !!,"Maximum Number of Errors to log in One Day: <",DEF,"> " R X G OPT:X="^",END:X="^Q"
        I X="?" S XQF="1,2,23,20" X ^%Q("ER") G MX
        I X="" S X=DEF
        I +X<1!(X'?.N) W *7," - Must be a number > 0." G MX
        S ^%ER=$P(^%ER,"\",1)_"\"_+X_"\"_$P(^%ER,"\",3,99),^%Q("ER",35)=+X
CON     S DEF=$S($P(^%ER,"\",3):"Y",1:"N")
        W !!,"Print Error Message when Error occurs ? <",DEF,"> " R X G OPT:X="^",END:X="^Q"
        I X="?" S XQF="1,2,26" X ^%Q("ER") G CON
        I X="" S X=DEF
        I "Y\N"'[X D IR G CON
        S ^%ER=$P(^%ER,"\",1,2)_"\"_$S(X="Y":1,1:0)_"\"_$P(^%ER,"\",4,99),^%Q("ER",36)=$P(^%ER,"\",3)
DSC     S DEF=$S($P(^%ER,"\",4):"Y",1:"N")
        W !!,"Log <DSCON> Errors ? <",DEF,"> " R X G OPT:X="^",END:X="^Q"
        I X="?" S XQF="1,2,12" X ^%Q("ER") G DSC
        I X="" S X=DEF
        I "Y\N"'[X D IR G DSC
        S ^%ER=$P(^%ER,"\",1,3)_"\"_$S(X="Y":1,1:0)_"\"_$P(^%ER,"\",5,99),^%Q("ER",37)=$P(^%ER,"\",4)
        G OPT
PUR     S DEF=+^%ER
        W !!,"Number of Days to Retain: <",DEF,"> " R NUM G OPT:NUM="^",END:NUM="^Q"
        I NUM="?" S XQF="1,2,23,21" X ^%Q("ER") G PUR
        I NUM="" S NUM=DEF
        I +NUM<0!(NUM'?.N) W *7," - Must be a positive number." G PUR
        S ^%ER=+NUM_"\"_$P(^%ER,"\",2,99)
        S NUM=+$H-NUM
        R !!,"Ready to Purge? [Y/N] ",X G PUR:X'="Y"
        W "   *** PURGE IN PROGRESS ***"
        S X=0
        F I=-1:0 S I=$N(^%ER(I)) Q:I<0!(I>NUM)  K ^%ER(I) S X=X+1
        W !!,X," Day(s) of Errors Purged." G OPT
DAT     R !!,"Which date: ",X:300 G OPT:'$T!(X="^")!(X=""),DIS:X="?",END:X="^Q"
        S DAT=X D UDD I $D(ERR),ERR=1 D IR G DAT
        S DAT=DTH K DTH G DO
DIS     W !,"Errors have been logged on: "
        S FST=0,H=+$H,X=""
        F J=-1:0 S J=$N(^%ER(J)) R X:0 Q:J<0!(X'="")  W $S(FST:",",1:""),"T" S FST=1 I J'=H W "-",H-J
        S XQF="1,2,11" X ^%Q("ER") G DAT
DO      S NE=$D(^%ER(DAT)) I 'NE D E1 G DAT
        S NE=^(DAT) D E1
ERR     R !!,"Which error: ",X:300 G END:'$T!(X="^Q")
        I X?1"???".E S D=1 D LST G ERR
        I X?1"??".E S D=0 D LST G ERR
        I X="?" D E1 S XQF="1,2,8,14,18,19" X ^%Q("ER") G ERR
        I X'?1N.N G DAT:X="^"!(X="") D E1,IR G ERR
        I X>NE D IR G ERR
        S NUM=X
        I '($D(^%ER(DAT,NUM))#2) W !,"Error not on File" G ERR
WRT     R !!,"Which symbol: ",X:300 G END:'$T!(X="^Q")
        I X="?" S XQF="1,2,8,24,25,10,15" X ^%Q("ER") G WRT
        I X=""!(X="^") G ERR
        I X="$" D DV G WRT
        I X="^R" S $ZT="RERR^%ER" X ^%Q("ER",40)
        S I=-1 W !! I X="^L" S SYM="" G WFS
        S SYM=X
WFS     S I=-1,C=1,X=""
WF      S I=$N(^%ER(DAT,NUM,"REF",I)) R X:0 G WRT:X'="" I I<0 W:SYM'=""&C !,"No such symbol" G WRT
        S A=^(I),B=^%ER(DAT,NUM,"DAT",I)
        I SYM'="",$E(A,1,$L(SYM))'=SYM G WF
        S C=0 W A,"=" I B?.PUNL,B'["\" W B,! G WF
        F K=1:1 S Z=$E(B,K) Q:Z=""  W $S(Z'?1C:Z,1:"\"_$E($A(Z)+1000,2,4)) I Z="\" W "\"
        W ! G WF
IR      W !!,"Incorrect response - enter '?' for more information" Q
E1      W !,$S(NE:NE-1,1:"No")," error",$S(NE'=1:"s",1:"")," logged on ",DTE Q
END     Q
LST     S X=-1,Q=""
T1      S X=$N(^%ER(DAT,X)) R Q:0 Q:Q'=""  G T2:X<0,T1:'($D(^(X))#2) S P=^(X) I P["<DSCON>",D S D=D+1 G T1
        S TM=$P($P(P,"\",1),",",2),W="AM",HH=TM\3600,R=TM-(3600*HH),MM=R\60,SS=R-(60*MM) S:HH>11 W="PM" S:HH>12 HH=HH-12 D:'(X-1#22) T3
        W !,$J(X,3),")  ",$P(P,"\",2),?39,$S(HH<10:0,1:""),HH,":",$S(MM<10:0,1:""),MM,":",$S(SS<10:0,1:""),SS," ",W,?52,$P(P,"\",7),?61,$P(P,"\",3),?66,$P(P,"\",4) G T1
T2      I D W !!,$S(D-1:D-1,1:"No")," disconnect error",$S(D-1>1:"s",1:""),!
        Q
T3      W !!,?11,"$ZE",?41,"Time",?52,"UCI,VOL",?61,"$J",?66,"$I",! Q
DV      S P=^%ER(DAT,NUM) W ! F I=1:1:13 W:I#2 ! W ?I-1#2*40,$P("$H\$ZE\$J\$I\$ZA\$ZB\UCI,VOL\$X\$Y\$S of Symbols\$T\$ZV\Job Status","\",I),?I-1#2*40+3," = ",$P(P,"\",I)
        Q
UDD     ;
        K DTE,DTH,ERR
        G T:DAT?1"T".E S %F=DAT F %I=32,44:1:46 S %Y=$C(%I) D R
B       S %Y="//" D R S %M=$E($P(%F,"/",1),1,3),%D=$P(%F,"/",2),%Y=$P(%F,"/",3) G E:%M=""
        G P:%M'?3A,E:%Y=""&(%D="")
        S %M=$F("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC",%M)-1 G E:%M#3 S %M=%M/3
P       S:%D=""&(%Y="") %D=%M,%M="" G A:%M=""!(%Y="")
        G E:'%D!(%D'?1N.N),E:'(%Y?2N!(%Y?4N))
        S:%Y?2N %Y=19_%Y S %Z=%Y-1841 G L:%M>0&(%Z>-1)&(%M?1N.N),E
L       I %M=2 G E:%D>29 I %D=29,%Y#4>0!(%Y#100=0&(%Y#400>0))!(%Z#4/3+28<%D) G E
        G E:%Z>357,C:"3 5 7 8 10 12"[%M&(%D<32),E:"4 6 9 11"'[%M!(%D>30),E:%Z>357
C       ;
        I $E(%Y,1,2)="19" S %Y=$E(%Y,3,4)
        S DTE=%M_"/"_%D_"/"_%Y
        S %Y=%M-1\2,DTH=-2*%Y+%M-1*(-%M\10+31)+(%Y*61)+(%Z\4)+(%Z*365)
        S DTH=%M\9+%D+DTH S:DTH>21607 DTH=DTH-1 S:%M>2 DTH=%Z#4\3+DTH-2 G K
A       G E:%D="" S DTH=$P($H,",",1) D UDA
        S:%F'["/" %F=$P(DTE,"/",1)_"/"_%F S %F=%F_"/"_$P(DTE,"/",3) K DTE G B
T       S %T=$E(DAT,2,99) I %T'="" G E:%T?7E.E,E:%T'?1"-"1N.N&(%T'?1"+"1N.N)
        S DTH=$P($H,",",1)+%T G E:DTH<0 D UDA G K
R       Q:%F'[%Y  S %F=$P(%F,%Y,1)_"/"_$P(%F,%Y,2,256) G R
E       S ERR=1 K DTE,DTH
K       K %F,%I,%T,%D,%M,%Z,%Y Q
UDA     ;
        I '$D(DTH) S DTH=$P($H,",",1)
        K DTE S %G=DTH-(DTH<21608) I $L(%G)>5!(%G'?.N)&(%G'=-1) K %G S ERR=1 Q
        S %C=%G#1461,%B=(%C=1460),%A=1841-%B+(%C\365)+(%G\1461*4),%L=28+(%C>1095),%C=%C#365+(%B*365),%B=0
        F %I=31,%L,31,30,31,30,31,31,30,31,30,31,1 S %B=%B+1,%C=%C-%I Q:%C<0
        S %C=%C+%I+1,%Z=%A I $E(%Z,1,2)="19" S %Z=$E(%Z,3,4)
        S DTE=%B_"/"_%C_"/"_%Z
        K %A,%B,%C,%G,%I,%L,%N,%Z Q
RERR    U 0 W:$E($ZE,2)="Z" !,"Symbol table loaded"
        Q:$ZE["NLOA"  I $ZE["PLOA" W !,"Loading ^",^%Q("ER",50),"..." X "ZR  ZL @^(50) ZT"
        U 0 W !!,"Unable to restore environment.   $ZE = ",$ZE,!,"Symbol table cannot fit into available space or",!,"the routine that received the error no longer exists."
R1      R !!,"(C)ontinue or (Q)uit ? ",X G R1:"C\Q"'[X,%ER:X="C" Q
Z       P %ER ZS %ER
