%BLKWT  ;21-Feb-85 ;DSM11 ;UTILITIES ;WRITE OUT THE CONTENTS OF A DISK BLOCK ;RWB
        S $ZT="HARD^%BLKWT"
        U 0
        BREAK 0
        S %TYPE=$V(1021,0)
        I %TYPE=15 D FGCHD G END
        I %TYPE#2 D GLBBLK
        I %TYPE\2#2 D PTRBLK
        I %TYPE\8#2 D DATBLK
        I %TYPE\16#2 D ROUBLK
        I %TYPE\32#2 D GARBLK
        I %TYPE\64#2 D SEQBLK
END     K PV,PL,I,J,OFF,PX,A
        BREAK 0
        Q
HARD    BREAK 0
        S %RIGHT=0,%DOWN=0,%TYPE=0
        G END
        Q
GETP    S PV=$V(PL,0)#256+($V(PL+1,0)#256*256)+($V(PL+2,0)#256*65536)
        S %DO=PV D ^%DO S PX=PV_"/"_%DO S A=15 D CENTER
        Q
WRTSHT  S A=15 G CON
WRTOUT  S A=30
CON     S PX=""
        I CMCNT=0 D GLBNM S I=I+1
        I CMCNT'=0 S I=PL
        F I=I:1:PL+CNT-1 S PV=$V(I,0)#256\BIT D
        .I (PV<32)!(PV>126) S PV=" "
        .E  S PV=$C(PV)
        .S PX=PX_PV
        D CENTER
        Q
VAL1    S A=256 G VAM
VAL     S A=65536
VAM     S PV=$V(PL,0)#A S %DO=PV D ^%DO S PX=PV_"/"_%DO S A=15 D CENTER
        Q
GLBNM   S PX=""
        F I=PL:1 S PV=$V(I,0)#256\2 D CHG S PX=PX_PV Q:'($V(I,0)#2)
        Q
CHG     I (PV<32)!(PV>126) S PV=" "
        E  S PV=$C(PV)
        Q
CENTER  I $L(PX)>(A-2) S PX=$E(PX,1,(A-3))_"*"
        S A=A-$L(PX)
        F K=1:1:A\2 S PX=" "_PX
        F K=1:1:A\2 S PX=PX_" "
        I A#2 S PX=PX_" "
        Q
ROUBLK  ;
GARBLK  ;
SEQBLK  ;
GLBBLK  W !,"This block type not yet supported",!
        S %RIGHT=0,%DOWN=0,%TYPE=0
        Q
FGCHD   W !,?20,"FGC HEADER BLOCK",!
        S J=$V(0,0)#256 G:(J<0)!(J>40) QQ25
        W !,"TAPE NUMBER: ",J
        W !,"GLOBAL NAME: "
        S %FGCH=""
        F I=2:2 D  G:J="999" QQ25 Q:J="#"
        .S J=$V(I,0)
        .I (J'=37)&(J'=35)&((J<48)!((J>57)&(J<65))!((J>90)&(J<97))!(J>122)) S J="999" Q
        .S J=$C(J) Q:J="#"  S %FGCH=%FGCH_J
        W %FGCH
        S J=$V(I+2,0) G:(J<0)!(J>40) QQ25
        W !,"TAPE ON WHICH THIS GLOBAL BEGINS : ",J S I=I+4
        F L=I:2 S J=$V(L,0) Q:'J  W !,"NUMBER OF BLOCKS IN LEVEL ",(L-I)/2,": ",J
        W !,"NUMBER OF BLOCKS IN DATA LEVEL: ",$V(L+2,0)+(65536*$V(L+4,0)),!!
        S HH="" F I=L+6:2 S J=$C($V(I,0)) Q:J="#"  S HH=HH_J
        NEW (HH)
        W "DATE AND TIME OF COPY:  "
        S %DT=$P(HH,",",1) D %CDS^%H
        I '$D(%NP) W %DAT1,"  "
        S %TM=$P(HH,",",2) D %CTS^%H
        I '$D(%NP) W %TIM1
EGH     K %TIM,%TIM1,%TM,%NP,%DAT,%DAT1,%DT
        Q
QQ25    W !!,"THIS IS NOT A FAST GLOBAL COPY HEADER BLOCK",!!
        G EGH
PTRBLK  I %TYPE\4#2 W !,?20,"BOTTOM LEVEL POINTER BLOCK",!
        E  W !,?20,"INTERMEDIATE LEVEL POINTER BLOCK",!
        S PL=$V(1,0)+2 D GETP S %DOWN=PV
        S PL=1018 D GETP S %RIGHT=PV W !,"RIGHT LINK POINTER: ",PX
        S PL=1014 D GETP W !,"GARBAGE COLLECTION POINTER: ",PX
        S PL=1021 D VAL W !,"BLOCK TYPE: ",PX
        S PL=1022 D VAL S OFF=PV W !,"BLOCK OFFSET: ",PX
        W !!,"    COMMON       NON-COMMON   "
        W "    NON-COMMON CHARACTERS         POINTER",!
        W "    ------       ----------       ---------- ----------     "
        W "    -------",!
        S $ZT="PTRERR^%BLKWT" S BIT=2-(%TYPE\128#2)
        BREAK 1
        S J=0
        F L=0:1 Q:J'<OFF  D  Q:'%FULLWR
        .S PL=J D VAL1 S CMCNT=PV W PX
        .S PL=J+1 D VAL1 W PX
        .S PL=J+2,CNT=PV D WRTOUT W PX
        .S PL=J+2+CNT D GETP W PX,!
        .S J=J+5+CNT
        BREAK 0
        W !!
        Q
PTRERR  I $ZE["<INRPT>" W !!,?27,"-----------",!! G END Q
        E  ZQUIT
        Q
DATBLK  W !,?20,"DATA BLOCK",!
        S %DOWN=0
        S PL=1018 D GETP S %RIGHT=PV W !,"RIGHT LINK POINTER: ",PX
        S PL=1014 D GETP W !,"GARBAGE COLLECTION POINTER: ",PX
        S PL=1021 D VAL W !,"BLOCK TYPE: ",PX
        S PL=1022 D VAL S OFF=PV W !,"BLOCK OFFSET: ",PX
        W !!,"    COMMON       NON-COMMON        KEY      "
        W " SIZE             DATA"
        W !,"    ------       ----------        ---       ----"
        W "             ----",!
        S $ZT="DATERR^%BLKWT" S BIT=(%TYPE\128#2)
        BREAK 1
        S J=0
        F L=0:1 Q:J'<OFF  D  Q:'%FULLWR
        .S PL=J D VAL1 S CMCNT=PV W PX
        .S PL=J+1 D VAL1 W PX
        .S PL=J+2,CNT=PV D WRTSHT W PX
        .S PL=J+2+CNT D VAL1 S A=5,PX=PV D CENTER W PX
        .S J=J+3+CNT,PL=J S CNT=PV S CMCNT=1 D WRTOUT W PX,!
        .S J=J+CNT
        BREAK 0
        W !!
        Q
DATERR  I $ZE["<INRPT>" W !!,?27,"-----------",!! G END Q
        E  ZQUIT
        Q
