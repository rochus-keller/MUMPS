%FGR2   ;28-Mar-85 ;DSM11 ;UTILITIES ;SUBROUTINES FOR %FGR ;RWB
FR      S $ZT="FERR^%FGR2"
        S PROG="Q"
        O 63:(2:1:2):0 E  W !,"VIEW BUFFER NOT ACCESSIBLE" Q
        O %TD:("CB"):0 E  W !,"TAPE NOT OPERABLE" C 63 Q
FR1     S $ZT="FERR^%FGR2"
        U 63:(1:1),%TD:(1024:0) W *6 U 63:(2:1) V 1020:0:0 S PROG=0
        S W=1
FR15    F K=1:1 U 63:(W+1:1) Q:($V(1020,0)=3840)!(PROG="Q")  U %TD:(1024:1024*W) S W='W W *6
        Q:PROG="Q"
        U %TD W *1
FR2     S PROG=1 U 0 W !,"READING NEXT HEADER BLOCK ...",! D DSPHD
        S T=$V(0,0)#256,%NAME="" I (T<1)!(T>40) G FR25
        F K=2:2 D  G:L="@" FR25 Q:L="#"
        .S L=$V(K,0)
        .I (L'=35)&(L'=37)&((L<48)!((L>57)&(L<65))!((L>90)&(L<97))!(L>122)) S L="@" Q
        .S L=$C(L) Q:L="#"  S %NAME=%NAME_L
        S TT=$V(K+2,0),L=1,%N=0
        G:(TT<0)!(TT>40) FR25
        F K=K+4:2 S M=$V(K,0) Q:'M  S %LVL(L)=M,%N=%N+M,L=L+1
        S %LVL=L,%LVL(%LVL)=$V(K+2,0)+(65536*$V(K+4,0)),%N=%N+%LVL(%LVL)
        G:TT=T FR4
        W !,"GLOBAL DOES NOT BEGIN HERE",! G FR5
FR25    W !,"THIS IS NOT A %FGC TAPE",!
FR3     U %TD W *5 C %TD U 63:(1:2)
        S %TFLAG="CB" D ^%TDN I %TD="Q" S PROG="Q" C 63 G FR6
        G FR1
FR4     R !!,"PROCEED WITH RESTORE?  ",AN
        I AN["?" S %QM=9 D ^%FGR3 G FR4
        I (AN="Y")!(AN="y") C %TD S %TAPENO=T,%TS="Q" C 63 G FR6
FR5     R !,"STOP RESTORING FROM THIS TAPE?  ",AN
        I AN="^" G FR4
        I AN["?" S %QM=10 D ^%FGR4 G FR5
        I (AN="Y")!(AN="y") U %TD W *5 C %TD S %TD="Q" C 63 S PROG="Q" G FR6
FR55    R !,"MOVE AHEAD TO NEXT GLOBAL?  ",AN
        I AN="^" G FR5
        I AN["?" S %QM=11 D ^%FGR4 G FR55
        G:(AN'="Y")&(AN'="y") FR4 S PROG="Q" G FR1
FR6     K K,L,M,AN,T,TT,ZA,ZE,BOB
        Q
FERR    S ZA=$ZA,ZE=$ZE
        S $ZT="FERR^%FGR2"
        S $ZE=""
        I (ZA\16384#2)&(ZE["MTERR") G FGER15
        S FGZA=ZA,FGZE=ZE D DISPER^%TDN
        C %TD S %TD="Q" C 63 S PROG="Q" G FR6
FGER15  U 0 W !!,"TAPE ENDS WITHOUT A NEW GLOBAL",! U %TD W *5 C %TD S %TD="Q"
        S %TFLAG="CB" U 63:(1:2) D ^%TDN I %TD="Q" S PROG="Q" G FR6
        G FR1
DSPHD   S $ZT="DDD^%FGR2" NEW
        D FGCHD^%BLKWT
        Q
DDD     ZQ
%RH     S $ZT="RHERR^%FGR2",%RHRES=0
        G:PROG="Q" RHEND
        U 63:(1:5) S %TFLAG="CB" D ^%TDN
        I %TD="Q" G RHEND
        U 63:(5:1) U %TD:(1024:4096) W *6 H 1
        U 0 W !!,"HEADER BLOCK OF NEW TAPE",!
        D DSP
        G:PROG="Q" RHEND
        IF (%TAPENO'=$V(0,0)#256-1)!(%NAME'=%FGCH) U 0 W !,"** INCORRECT TAPE **" W *5 C %TD G %RH
        I %TDJ>0 S AN="Y" G RH35
RH3     U 0 R !,"Proceed? ",AN
        I AN["?" S %QM=14 D ^%FGR4 G RH3
RH35    I (AN="Y")!(AN="y") S %RHRES=1,%TAPENO=%TAPENO+1 G RHEND
RH4     R !,"Stop the restore? ",AN
        I AN["?" S %QM=12 D ^%FGR4 G RH4
        I (AN="Y")!(AN="y") W *5 C %TD S %TD="Q" G RHEND
        W *5 C %TD G %RH
RHERR   S ZZ=$ZE,ZQ=$ZA
        S $ZE=""
        I '((ZQ\16384#2)&(ZZ["MTERR")) G RHER1
        U 0 W !,"** TAPE ERROR **" U %TD W *5 C %TD K ZZ,ZQ S $ZT="RHERR^%FGR2" G %RH
RHER1   C %TD
        S FGZA=ZQ,FGZE=ZZ D DISPER^%TDN
        S (PROG,%TD)="Q" G RHEND
DSP     S $ZT="EEE^%FGR2" NEW (%FGCH)
        D FGCHD^%BLKWT
        Q
EEE     ZQ
RHEND   K ZZ,ZQ,%FGCH
        Q
