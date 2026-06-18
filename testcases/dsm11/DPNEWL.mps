DPNEWL  ;
QUIT    Q
COPENT  ;
DISKENT ;
TAPENT  S:'$D(VOLNAM) VOLNAM="SYS" S UNIT=1,UCB=92,MB="M" D START I %ER W " -- stopping.",! G H
NXTP    S $ZT=%LABEL X %LOAD
H       B 0 G H
START   I '%UPG F I=0:2:510,704:2:1022 V I:0:0
        S OF=MPOF+2,SZ=1,S="MB" D FILL
        I MB="M" S (MLB,DAB,MTY)=""
        S OF=MPOF+4,SZ=22,S="%LB" D FILL
        S S="MLB" D FILL
        D GETDAT S SZ=9,S="DA" D FILL
        S S="DAB" D FILL
        S SZ=2,S="MTY" D FILL
        I %UPG'=2 S VER="DSM11 V"_$E($ZV,16,24),OF=VEROF,SZ=16,S="VER" D FILL
        I %UPG G %WRITE
        V MPOF:0:%MP,512+404:0:%MP
        S Q="DSM-11      ",L=12,OF=IDOF D PUT
        D PUT
        D PUT
        I VOLNAM="" G %WRITE
        S OF=512+392
        V OF:0:CODE
        S OF=OF+2,Q=VOLNAM_UNIT,L=4 D PUT
        I UNIT'=1 G %WRITE
        V OF:0:UCB#65536
        V OF+2:0:1*256+(UCB\65536)
        V OF+4:0:$P(%D," ",4)*256+$P(%D," ")
%WRITE  S %ER=0,NOT=0
WRT2    B 0 U 63:(::"CZT")
        V -16777216:DDU I $ZA\64#2
        U 63:(::"C"),0 B 1 G DONE:'$T S NOT=NOT+1 G WRT2:NOT<10
        W !,"! Unable to write label block on ",$P(%D," ",2)," unit ",$E(DDU,3),!
AGQ     R "  Try to write it again [Y/N] ? ",Y,! S Y=$E(Y,1)
        G %WRITE:Y="Y",AGQ:Y'="N"
        S %ER=1 Q
DONE    K Q,ZZ,L,S,AA,VOF,IDOF,LOF,VER,VERZZ Q
FILL    S Q=@S,L=SZ F I=$L(Q)+1:1:L S Q=Q_$C(0)
PUT     S J=1
PUT2    Q:J>L  I OF#2 V OF-1:0:$V(OF-1,0)#256+($A(Q,J)*256)
        E  V OF:0:$V(OF+1,0)*256+$A(Q,J)
        S J=J+1,OF=OF+1 G PUT2
GETDAT  S D=$H-21608,Y=D\1461*4,D=D#1461
        F D=D:-365:1 S Y=Y+1
        S:'D D=366 F I=1:1:12 S M=I-1\5+I#2+30 Q:D'>M  S D=D-M
        S:I<11 Y=Y-1
        S M=$E("-MAR-APR-MAY-JUN-JUL-AUG-SEP-OCT-NOV-DEC-JAN-FEB-",4*I-3,4*I+1)
        S DA=$J(D_M_Y,9) K D,M,Y Q
