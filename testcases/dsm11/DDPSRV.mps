DDPSRV  ;DDP SERVER UTILITY; DDP ; JHM
        Q
A       D ULOKCON S $ZT="E"
L       ZY 30,N G @$A(N)
2       ;
6       ZA @$E(N,3,255):0 I  ZY 26,"S" G L
        ZY 26,"F" G L
4       ;
8       ZD @$E(N,3,255) ZY 26,"" G L
32      S $ZT="CERR" D PROCON G A
E       I $E($ZE,1,4)="<DST"!($E($ZE,1,4)="<PAR") D LOKCON G @$E($ZE,2,5)
        S $ZT="E1" ZY 28,$E($ZE,1,7) G A
E1      I $E($ZE,1,4)="<DST"!($E($ZE,1,4)="<PAR") D LOKCON G @$E($ZE,2,5)
        D LOKCON G PAR5
CERR    D STAT W "Error occurred during circuit table update: ",$ZE G A
PROCON  S C=N,LNK=$A(C,2),DDB=$V(ST+422)+4
        F I=0:1:LNK-1 Q:'DDB  S DDB=$V(DDB+2)
        Q:'DDB  S N=$A(C,14)*256+$A(C,13) Q:N=$V($V(ST+12))
        S $ZT="PROCER" D ONEJOB,FIND,@$E(C,5,6),CLRJOB Q
PROCER  D CLRJOB ZQ
WI      I FOUND D DISCIR,UPD,INIT,SAYINIT
        I 'FOUND D CREATE Q:'RV
        G SII
WS      I FOUND D UPD G SIS
        D CREATE Q:'RV  G SII
IS      I FOUND D UPD Q
        D CREATE Q:'RV  G SII
II      I FOUND D DISCIR,UPD,INIT,SAYINIT Q
        D CREATE Q
ID      I FOUND D DISCIR,REMOV,SAYREM
        Q
ALINKS  Q:'$V(ST+144)  S DDB=$V(ST+422)+4 F LNK=0:1 Q:'DDB  D @SCM S DDB=$V(DDB+2)
        Q
SWI     S C="WI" D BLDSTA,SNDMC Q
SWS     S C="WS" D BLDSTA,SNDMC Q
SIS     S C="IS" D BLDSTA,SNDPP Q
SII     S C="II" D BLDSTA,SNDPP Q
SID     S C="ID" D BLDSTA,SNDPP Q
MID     S C="ID" D BLDSTA,SNDMC Q
MIS     S C="IS" D BLDSTA,SNDMC Q
BLDSTA  S D=$V(ST+422)+4 F I=0:1:LNK-1 S D=$V(D+2)
        F I=30:1:35 S C=C_$C($V(D+I)#256)
        F I=$V(ST+12):$V(ST+34)#256:$V(ST+34)#256*7+$V(ST+12) I $V(I) S C=C_$C($V(I)#256,$V(I+1))
        F I=$L(C):1:23 S C=C_$C(0)
        S C=C_$C($V(ST)#256) Q
SNDMC   S $ZT="SNDR" ZY 32,$C(LNK,0)_C Q
SNDPP   S $ZT="SNDR" ZY 32,$C(N#256,N\256)_C Q
SNDR    Q
FIND    S LRV=$V(ST+444),RV=$V(0,LRV)
F2      G:'RV NFND F I=1:1 Q:$V(10,RV)=N  S LRV=RV,RV=$V(0,RV) G:'RV NFND
        F I=0:1:7 I $V(I+4,RV)#256'=$A(C,I+7) S LRV=RV,RV=$V(0,RV) G F2
        S FOUND=1 Q
NFND    S FOUND=0 Q
CREATE  S LRV=$V(ST+444),RV=$V(0,LRV) I 'RV G APEND
        F I=1:1 Q:'$V(10,RV)  S LRV=RV,RV=$V(0,RV) Q:'RV
        I RV D INIT,UPD,SAYCRT Q
APEND   I LRV+$V(ST+404)'<$V(ST+448) S RV=0 D SAYFUL Q
        S RV=LRV+$V(ST+404) D UPD,INIT,SAYCRT V 0:LRV:RV,0:RV:0 Q
UPD     F J=13:2:27 I $A(C,J+1),$A(C,J) S VS=$A(C,J+1)*256+$A(C,J) D
        .S R=$V(0,$V(ST+444)) F I=1:1 Q:'R  D  S R=$V(0,R)
        ..I R'=RV F I=10:2:24 I $V(I,R)=VS D  V I:R:0
        ...I I=10 S ON=N,N=VS D DISCIR S N=ON
        .F I=0:1:7 I VS=$V($V(ST+34)#256*I+$V(ST+12)) D
        ..I $V(2,$J)\64#2 D STAT W "WARNING - Node ",$C(N\2048+64,N\64#32+64,N\2#32+64)," has mounted Volume Set ",$C(VS\2048+64,VS\64#32+64,VS\2#32+64)," which is already mounted on this node"
        V 2:RV:DDB F I=4:2:8 V I:RV:$A(C,I+4)*256+$A(C,I+3)
        F I=10:2:24 V I:RV:$A(C,I+4)*256+$A(C,I+3)
        V 26:RV:$A(C,29)
        Q
INIT    V 28:RV:$S($V(DDB+7):3,1:5)*256 F R=30:2:48,50:2:60,318:2:830 V R:RV:0
        F R=62:2:316 V R:RV:65535
        Q
REMOV   S RV=$V(ST+444) F I=1:1 Q:$V(10,RV)=N  S RV=$V(0,RV) Q:'RV
        I RV V 10:RV:0 V:'$V(0,RV) 0:RV-$V(ST+404):0
        Q
DISCIR  ZY -8,$C(N\256,N#256) S D=$V(2,$J)\64#2 V:'D 2:$J:$V(2,$J)+64
        V 408:$J:N F A=1:1:255,0 V 284:$J:A*256+($V(284,$J)#256) ZD
        V:'D 2:$J:$V(2,$J)-64 Q
ENBCIR  V 26:RV:$V(26,RV)-($V(26,RV)\128#2=1*128) Q
PKASC   S N=$C(N\2048+64,N\64#32+64,N\2#32+64) Q
ASCPK   S N=$A(N)-64*32+$A(N,2)-64*32+$A(N,3)-64*2 Q
PAR1    D STAT,LINK S N=$V(10,RV) D PKASC W "Circuit to node ",N," is down" G A
PAR2    D STAT,LINK W "Link restarting" D ULOKCON H 0 ZY -4,LINE ZY -6,LINE G A
PAR3    D STAT,LINK W "Link disabled " ZY -4,LINE G A
PAR4    D STAT W "DDP communications shutdown - ^DDP server halted " D ULOKCON S $ZT="" H
PAR5    D STAT,LINK W "Request received from UNKNOWN NODE",!?39,"Node: ",NODE,"  Job #: ",JOB G A
0       ;
PAR6    D STAT,LINK W "Request received with invalid DDP code",!?39,"Node: ",NODE,"   Job #: ",JOB,"  Code: ",CODE G A
DSTD    D STAT,LINK W "Link error while sending response" G A
SAYINIT S S="initialized" G LNK
SAYCRT  S S="created" G LNK
SAYREM  S S="deleted" G LNK
SAYFUL  S S="cannot be created - circuit table full"
LNK     D:$V(2,$J)\64#2 STAT W "Circuit to node ",$C(N\2048+64,N\64#32+64,N\2#32+64)," through link #",LNK," ",S Q
STAT    ZU $V($V(44)+346)#256:(:::::32) W !
        S %TM=$P($H,",",2)
        S %M=%TM#3600\60,%S=%TM#60,%TIM=%TM\3600_":"_(%M\10)_(%M#10)
        S %TIM1=%TIM,%A=$S(%TM<43200:"AM",1:"PM") I $P(%TIM,":",1)>12 S %TIM1=$P(%TIM,":",1)-12_":"_$P(%TIM,":",2,99)
        S %TIM1=%TIM1_" "_%A
        W %TIM,?8,"DDP server ",$J," - " Q
LINK    S RV=$V(402,$J),DDB=$V(400,$J),N=$V(408,$J),CODE=$V(284,$J)#256,JOB=$V(285,$J)\2 D PKASC S NODE=N
        S LINE=$V(DDB+6)#256,DEV=$C($V(DDB+16)#256,$V(DDB+17))_($V(DDB+14)#256)
        W "DDP Link #",LINE," - Device: ",DEV," - " Q
START   V 2:$J:64+2
        S ST=$V(44) G A
LOKCON  O 46 Q
ULOKCON C 46 Q
ONEJOB  V ST+74::$J*512+($V(ST+74)#256) Q
CLRJOB  V ST+74::$V(ST+74)#256 Q
