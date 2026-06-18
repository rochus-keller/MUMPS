%FGR1   ;19-Mar-85 ;DSM11 ;UTILITIES ;FAST GLOBAL RESTORE ;RWB
%DTLVL  S $ZT="DTERR^%FGR1"
        S (A,B)=%LVL(%LVL,1)-399,C=%LVL(%LVL,2)
        U 63:(3:1) V A+399:%S
%DT1    U 63:(1:1),%TD:(1024:0) W *6
%DTA    S W=1,INI=0,I=1
        U 63:(W+1:1),%TD:(1024:1024*W)
        S T=%LVL("LAST")
%DT2    F I=I:1:%LVL(%LVL)-1 D %DT3 Q:PROG="Q"
        G:PROG="Q" DTEND
        H 2
        S W='W U 63:(W+1:1)
        I (NL+NN) D
        .F K=0:1:NL-1 V K*2+2:0:NL(K)
        .S:'NL K=-1
        .I NN S K=(K+1)*2+2 V K:0:$V(K,0)\256*256+NN
        V -(A+C):%S
DTEND   K INI,A,B,C,D,W,K,I,R,T,BOB
        Q
%DT3    S $ZT="DT3ERR^%FGR1"
DT3A    W *6
DT3B    S W='W U 63:(3:1) S D=$V(C*2,0)
        I D=65534 F B=A+400:400 V B+399:%S S D=$V(800,0) Q:D'=65534  I B>T S ZA=0,ZE="RAN PAST END OF LINKED LIST" G DT3ER1
        U 63:(W+1:1),%TD:(1024:1024*W)
        I (NL+NN) D
        .F K=0:1:NL-1 V K*2+2:0:NL(K)
        .S:'NL K=-1
        .I NN S K=(K+1)*2+2 V K:0:$V(K,0)\256*256+NN
        S R=D+B V 1018:0:R#65536,1020:0:$V(1021,0)*256+(R\65536)
        V -(A+C):%S S A=B,C=D
        Q
DTERR   G:PROG="Q" RDERR
        S ZA=$ZA,ZE=$ZE
        S %TD="Q"
        S $ZE="",$ZT="DTERR^%FGR1"
        I '((ZA\16384#2)&(ZE["MTERR")) S INI=1 C %TD G RDERR
        U %TD W *5 C %TD
        W !,"******* END OF CURRENT TAPE *******",!
        D %RH^%FGR2 I '%RHRES G RDERR1
        G %DT1
RDERR   G:ZA="" RDERR1
        S FGZA=ZA,FGZE=ZE D DISPER^%TDN
        I INI W !,"THE FIRST BLOCK OF DATA LEVEL WAS BEING READ FROM TAPE."
        E  W !,"BLOCK NUMBER ",I-1," OF DATA LEVEL WAS BEING READ FROM TAPE."
RDERR1  S PROG="Q" G DTEND
DT3ERR  S ZA=$ZA,ZE=$ZE,INI=0
        S %TD="Q"
DT3ER1  S $ZE="",$ZT="DT3ERR^%FGR1"
        I '((ZA\16384#2)&(ZE["MTERR")) S PROG="Q" C %TD ZQ
        U %TD W *5 C %TD
        W !,"******* END OF CURRENT TAPE *******",!
        D %RH^%FGR2 I '%RHRES S PROG="Q" S ZA="" ZQ
        S W='W U 63:(W+1:1) U %TD:(1024:1024*W) W *6 S W='W U %TD:(1024:1024*W) G DT3A
%PTRLV  S $ZT="PTERR^%FGR1"
        S (A,B)=%LVL(%I,1)-399,C=%LVL(%I,2)
        S (E,F)=%LVL(%I+1,1)-399,G=%LVL(%I+1,2)
        U 63:(3:1) V (A+399):%S U 63:(4:1) V (E+399):%S
%PTC    S $ZT="PTERR^%FGR1"
        U 63:(1:1) U %TD:(1024:0) W *6
%PTCA   S W=1,I=1
        S T=%LVL("LAST")
%NINI   F I=I:1:(%LVL(%I)-1) D %NIT
        S W='W U 63:(W+1:1) H 2 D %PTRBK V -(A+C):%S
PTREND  K INI,A,B,C,D,E,F,G,H,W,K,I,J,Y,P,R,Q,T,BOB
        Q
%NIT    S $ZT="NITERR^%FGR1"
        U 63:(W+1:1) U %TD:(1024:W*1024) W *6
%NIT1   S W='W U 63:(W+1:1) D %PTRBK
        D XN U 63:(W+1:1) V 1018:0:(B+D)#65536,1020:0:Z*256+((B+D)/65536)
        V -(A+C):%S S A=B,C=D
        Q
%PTRBK  S $ZT="BKE^%FGR1"
        I (NL+NN) D
        .F K=0:1:(NL-1) V K*2+2:0:NL(K)
        .S:'NL K=-1
        .I NN S K=(K+1)*2+2 V K:0:$V(K,0)\256*256+NN
        S Y=$V(1022,0),P=0,Z=$V(1021,0)
        F J=1:1 Q:P'<Y  D
        .I G=65534 D XM U 63:(W+1:1)
        .S Q=P+2+($V(P+1,0)#256),R=E+G
        .I Q#2 V (Q-1):0:$V((Q-1),0)#256+(R#256*256),(Q+1):0:R\256
        .E  V Q:0:R#65536,(Q+2):0:$V((Q+3),0)*256+(R\65536)
        .D XM U 63:(W+1:1) S G=H,E=F,P=Q+3
        Q
BKE     S ZA=$ZA,ZE=$ZE U 0
        W !!,"ERROR DURING POINTER BLOCK PROCESSING OF BLOCK ",I," OF LEVEL ",%I
        W !,"$ZA = ",ZA," AND $ZE = ",ZE
        S PROG="Q" ZQ
XN      S $ZT="BKF^%FGR1"
        U 63:(3:1) S D=$V(2*C,0)
        Q:D'=65534
        F B=A+400:400 V B+399:%S S D=$V(800,0) Q:D'=65534
        I B>T S ZA=0,ZE="RAN OFF END OF LINKED LIST" G BKF1
        Q
BKF     S ZA=$ZA,ZE=$ZE U 0
BKF1    W !!,"ERROR DURING POINTER BLOCK PROCESSING OF BLOCK ",I," OF LEVEL ",%I
        W !,"$ZA = ",ZA," AND $ZE = ",ZE
        S PROG="Q" ZQ
XM      S $ZT="BKG^%FGR1"
        U 63:(4:1) I G=65534 G XM1
        S H=$V(2*G,0)
        Q
XM1     F F=E+400:400 V F+399:%S S G=$V(800,0) Q:G'=65534
        S E=F
        Q
BKG     S ZA=$ZA,ZE=$ZE U 0
        W !!,"ERROR DURING POINTER BLOCK PROCESSING OF BLOCK ",I," OF LEVEL ",%I
        W !,"$ZA = ",ZA," AND $ZE = ",ZE
        S P=Y+1
        S PROG="Q" ZQ
PTERR   S ZA=$ZA,ZE=$ZE,$ZE=""
        I PROG="Q" S INI=0 G RLERR
        I '((ZA\16384#2)&(ZE["MTERR")) S INI=1 C %TD S %TD="Q" G RLERR
        I %TD'="Q" U %TD W *5 C %TD S %TD="Q"
        W !,"******* END OF CURRENT TAPE *******",!
        D %RH^%FGR2 I '%RHRES G RLERR1
        G %PTC
RLERR   G:ZA="" RLERR1
        S FGZA=ZA,FGZE=ZE D DISPER^%TDN
        I INI W !,"THE FIRST BLOCK OF LEVEL ",%I," WAS BEING READ FROM TAPE."
        E  W !,"BLOCK NUMBER ",I+1," OF LEVEL ",%I," WAS BEING READ FROM TAPE."
RLERR1  S PROG="Q" G PTREND
NITERR  S ZA=$ZA,ZE=$ZE,INI=0
        S $ZE=""
        I '((ZA\16384#2)&(ZE["MTERR")) S PROG="Q" C %TD S %TD="Q" ZQ
        U %TD W *5 C %TD S %TD="Q"
        W !,"******* END OF CURRENT TAPE *******",!
        D %RH^%FGR2 I '%RHRES S PROG="Q" S ZA="" ZQ
        S W='W U 63:(W+1:1) U %TD:(1024:1024*W) W *6 S W='W G %NIT
CLNUP1  S A=%LVL(1,1),C=%LVL(1,2),%T=0 F E=1:1:%LVL-1 S %T=%T+%LVL(E)
        D %TRARP
        Q
CLNUP2  S A=%LVL(%LVL,1),C=%LVL(%LVL,2) S %T=%LVL(%LVL)
%TRARP  BREAK 0 U 63:(1:1:"CP")
        V A:%S
        F E=1:1:%T D
        .I C=65534 F A=A+400:400 V A:%S S C=$V(800,0) Q:C'=65534
        .S D=$V(C*2,0)
        .V C*2:0:BB I 'BB V 1022:0:$V(1022,0)+1
        .I D'=65534 G %TR1
        .F B=800:2:804 V B:0:0
        .V 830:0:0
        .V -A:%S
%TR1    .S C=D
        U 63:(1:1:"C") BREAK 1
        K A,B,C,D,E,%T
        Q
