%TDN    ;1-Apr-85 ;DSM11 ;UTILITIES ;Open a tape drive for %FGR,%FGC, and %FGT ;RWB
        S $ZT="%TDERR^%TDN"
        I %TDI>0 S %TD=$P(%TD(%TDI),",",1),%DEN=$P(%TD(%TDI),",",2),%TDI=%TDI-1,%TFLAG="CB" G %SHORT
        I '$D(%TFLAG) S %TFLAG=0
%LOOP   U 0
        R !,"ENTER TAPE DRIVE NUMBER (0-3) OR ""Q"" TO QUIT ",%TD
        I %TD["?" S %QM=1 D ^%FGR3 G %LOOP
        S %F=1
        I (%TD="Q")!(%TD="q")!(%TD="^") S %TD="Q" G %QUIT
        I ((%TD<0)!(%TD>3)!(%TD="")) W !,"INCORRECT TAPE DRIVE NUMBER" G %LOOP
%LP1    R !,"DENSITY <800> : ",%RES
        I %RES["?" S %QM=2 D ^%FGR3 G %LP1
        G:%RES="^" %LOOP
        I (%RES=800)!(%RES="") S %DEN=3 G %LP2
        I %RES=1600 S %DEN=4 G %LP2
        W !,"INCORRECT DENSITY" G %LP1
%LP2    S %TD=%TD+47
%LP3    R !,"MOUNT TAPE AND TYPE <RETURN> TO CONTINUE OR ""Q"" TO QUIT ",%RES
        I %RES["?" S %QM=3 D ^%FGR3 G %LP3
        I (%RES="Q")!(%RES="q") S %TD="Q" G %QUIT
        G:(%RES="^") %LP1
%SHORT  I %TFLAG=0 S %DEV="%TD:("""_%DEN_"""):0" G %S1
        S %DEV="%TD:("""_%TFLAG_%DEN_"""):0"
%S1     O @(%DEV) E  U 0 W !,"TAPE CANNOT BE OPENED" G %LOOP
        U %TD:(1024:0) W *10
        I (($ZA\32768#2)!'($ZA\64#2)!($ZA\1024#2)!($ZA#2)) S FGZA=$ZA,FGZE="<BAD MOUNT>NOT APPLICABLE" D DISPER U %TD C %TD G %LOOP
        I '($ZA\32#2) D
%LP4    .U 0 R !,"NOT AT BEGINNING OF TAPE - REWIND? ",%RES
        .I %RES["?" S %QM=5 D ^%FGR3 G %LP4
        .I (%RES="Y")!(%RES="y") U %TD W *5
        I (($ZA\32768#2)!'($ZA\64#2)!($ZA\1024#2)!($ZA#2)) S FGZA=$ZA,FGZE="<BAD MOUNT>" D DISPER U %TD C %TD G %LOOP
        U 0
%QUIT   K %RES,%OPEN,%TFLAG
        Q
%TDERR  S FGZA=$ZA,FGZE=$ZE,$ZE="",$ZT="%TDERR^%TDN"
        C:%TD'="Q" %TD D DISPER G %LOOP
D       NEW
        D ^%D W "  " D ^%T W !
        Q
%MTDN   U 0 R !!,"MULTIPLE TAPE DRIVES ? ",J
        I J["?" S %QM=4 D ^%FGR3 G %MTDN
        S (%TDI,%TDJ)=0
        Q:(J'="Y")&(J'="y")
%MT1    R !,"ENTER TAPE DRIVE NUMBER (0-3) OR ""Q"" TO QUIT ",J
        I J["?" S %QM=6 D ^%FGR3 G %MT1
        I (J="Q")!(J="q") G %MT4
        I J="^" S:%TDI>0 %TDI=%TDI-1 G %MT1
        I ((J<0)!(J>3)!(J="")) W !,"INCORRECT TAPE DRIVE NUMBER" G %MT1
%MT2    R !,"DENSITY <800> : ",I
        I I["?" S %QM=7 D ^%FGR3 G %MT2
        G:I="^" %MT1
        I (I=800)!(I="") S %DEN=3 G %MT3
        I I=1600 S %DEN=4 G %MT3
        W !,"INCORRECT DENSITY" G %MT2
%MT3    S J=J+47,%TDI=%TDI+1,%TD(%TDI)=J_","_%DEN G %MT1
%MT4    F I=1:1:%TDI\2 S K=%TD(I),%TD(I)=%TD(%TDI-I+1),%TD(%TDI-I+1)=K
        S:%TDI>0 %TDJ=1
        K I,J,%DEN,K
        Q
%NOCNTY S %USMOD=$V(2,$J)
        V 2:$J:%USMOD\2*2
        Q
%CNTY   V 2:$J:%USMOD
        Q
DISPER  U 0 W !!,?10,"****  ERROR CONDITION  ****",!
        W !,"ERROR CODE = ",$P($P(FGZE,"<",2),">",1)
        W !,"PROGRAM AND LINE WHERE ERROR OCCURRED = ",$P(FGZE,">",2)
        W !,"VALUE OF $ZA = ",FGZA,!
        I (FGZE["MTERR")!(FGZE["BAD MOUNT") D MTCODE
        W !!,?10,"***************************",!
        K FGZA,FGZE
        Q
MTCODE  W !,"MT ERROR FLAGS SET IN $ZA:",!
        S II=1
        F JJ=1:1:3 W:FGZA\II#2 !,?5,$T(MTC+JJ) S II=II*2
        S II=II*4 I FGZA\II#2 W !,?5,$T(MTC+6)
        S II=II*2
        I FGZA\II#2 W !,?5,$T(MTC+17)
        E  W !,?5,$T(MTC+7)
        S II=II*2
        F JJ=8:1:16 W:FGZA\II#2 !,?5,$T(MTC+JJ) S II=II*2
        K II,JJ
        Q
MTC     ;
        Bit  0 - Logical error
        Bit  1 - Positioning in progress
        Bit  2 - Tape is write protected
        Bit  3 - Unused
        Bit  4 - Unused
        Bit  5 - Beginning of tape (BOT)
        Bit  6 - NOT SET - unit does not exist, off line, or powered down
        Bit  7 - Nonexistent memory
        Bit  8 - Bad tape error
        Bit  9 - Block length error
        Bit 10 - End of tape (EOT)
        Bit 11 - Bus grant late
        Bit 12 - Parity error
        Bit 13 - Cyclical redundancy
        Bit 14 - Tape mark
        Bit 15 - Error condition
        Bit  6 - SET - normal state for flag
SETPRO  BREAK 0 U 63:(1:1:"CP") V %GFINB:%S S %PROT=$V(%GFINQ,0)#256
        S U=1,V=0
        F I=1:1:4 S X=%PROT#(4*U)\U S:X>0 X=1 S V=V+(X*U),U=U*4
        D PRT U 63:(1:1:"C") BREAK 1 D QRT
        K U,V,I,X
        Q
PRT     I %GFINQ#2 V %GFINQ-1:0:$V(%GFINQ-1,0)#256+(256*V)
        E  V %GFINQ:0:$V(%GFINQ+1,0)*256+V
        V -%GFINB:%S
        Q
QRT     NEW
        D ZGLAST^%SYSROU
        Q
RESPRO  Q:%PROT="Q"  BREAK 0 U 63:(1:1:"CP") V %GFINB:%S
        S V=%PROT,%PROT="Q" D PRT U 63:(1:1:"C") BREAK 1 Q
        Q
