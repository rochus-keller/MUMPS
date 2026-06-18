IC      ;INTEGRITY CHECKER
        S $ZE="TRAP" L (^IC,^ICS):0 G START:$T
        L ^IC:0 E  W !,"Sorry, an integrity checker is already running in the background" Q
        L  W !,"Sorry, someone else is starting an integrity checker now." Q
        -
START   K PRINT U 0 W !!,"1. Print existing report",!,"2. Compile new report"
        R !,"Enter one of the above options > ",ANS I ANS=""!(ANS="^") G U
        I ANS["?" D HLP1^IC2 G START
        I ANS=1 S PRINT="" G:$D(^IC(1))#2 DEV W !!,"Integrity checker report does not exist!",! G START
        I ANS'=2 D IV G START
REP     R !,"Do you want the report to automatically print when it's done ? <Y> ",ANS
        S:ANS="" ANS="Y" G:ANS="^" START
        I ANS["?" W !,?5,"Enter Y(es) or N(o),",!,?8,"or type '^' to return to the option selection question.",! G REP
        I ANS?1"N".E K ^IC G CHK
        I ANS'?1"Y".E D IV G REP
DEV     S %QTY=2 D ^%IOS
        I '$D(%IOD) G:$D(PRINT) START G REP
        I "SC^LP^TRM"'[%DTY!(%DTY="") D IV G DEV
        I $D(PRINT) U %IOD D REPORT^IC0 C:%IOD'=$I %IOD G START
        K ^IC S ^IC("OUTPUT DEVICE")=%IOD C:%IOD'=$I %IOD
CHK     D START^%STRTAB S CC=0
RD      R !!,"Check data base integrity for which volume set ? > ",STRNO
        I STRNO=""!(STRNO="^") G START
        I STRNO'?1"S"1N&(STRNO'?3AN) D HELP G RD
        S NXSTR="" F I=1:1 S NXSTR=$O(STR(NXSTR)) Q:NXSTR=""  I STRNO=("S"_NXSTR)!(STRNO=STR(NXSTR)) G MNT
        W !!,"Structure ",STRNO," not in system",! G RD
MNT     I STR(NXSTR)="" W !!,"There is no disk mounted in Structure ",STRNO,".",!
        I  W "Type ""D ^MOUNT"" to mount the structure.",! G START
        S:STRNO?3AN STRNO="S"_NXSTR C 63 O 63:(:::"Z") V 0:STRNO U 63:(::"C"),0
        S UCIBLK=$V(512+400,0)#256*65536+$V(512+398,0)
        V UCIBLK:STRNO
        F I=1:1 S UTAB=(I-1)*20 Q:'$V(UTAB,0)  D SET^IC2
        C 63
UCI     S ROU="Y",ST=$V(44) W !!,"Structure ",STRNO,":" R "  UCI ? > ",UCI
        I UCI="" G:'CC RD S ^IC(0)=CC,^("STRUCTURE #")=STRNO G ZJ
        I UCI="^" G CHK
        I UCI="?" D HLP2^IC2 G UCI
        I UCI="*" D STO^IC2 S ^IC(0)=CC,^("STRUCTURE #")=STRNO G ZJ
        I UCI'?3A,UCI'?.N D IV G UCI
        I UCI?.N G:$D(DISK(STRNO,UCI)) GLOBAL D IV G UCI
        S NXT="" F I=1:1 S NXT=$ZS(DISK(STRNO,NXT)) Q:NXT=""  I DISK(STRNO,NXT)=UCI S UCI=NXT G GLOBAL
        D IV G UCI
        -
GLOBAL  K DEF R !,?15,"Global ? > ^",GLOB I GLOB=""!(GLOB="^") G UCI
        I GLOB="*" S CC=CC+1,DEF="",^IC(CC,"GLOB")="*" G ROU
G1      I GLOB'?1"%".AN,GLOB'?1A.AN W !!," Enter a Global name",! W:'$D(DEF) ?4,"or '*' for all Globals",! G GLOBAL:'$D(DEF) G B3
        W !,"Searching directory..."
        O 63::1 E  W " <view buffer wait>" O 63
        S B=DISK(STRNO,UCI,4)#256*65536+DISK(STRNO,UCI,2)
B       V B:STRNO S C=0,O=$V(1022,0)
B1      S N="" F C=C:1 S N=N_$C($V(C,0)#256\2) Q:$V(C,0)#2=0
        I N=GLOB S GLOB=$V(C+8,0)#256*256+($V(C+7,0)#256)*256+($V(C+6,0)#256)_"^"_GLOB_";" G B2
        S C=C+9 G B1:C'>O S B=$V(1016,0)#256*65536+$V(1014,0) G B:B
        W " No such Global." G GLOBAL:'$D(DEF) G B3
B2      I '$D(DEF) S CC=CC+1,DEF="",^IC(CC,"GLOB")=GLOB G B3
        S ^IC(CC,"GLOB")=^("GLOB")_GLOB
B3      R !,?15,"Global ? > ^",GLOB G:GLOB="" ROU I GLOB="^" K ^IC(CC) S CC=CC-1 G UCI
        G G1
ROU     R !,"Check Routine Directory ? <Y> ",ROU I ROU="^" K ^IC(CC) S CC=CC-1 G GLOBAL
        S:ROU="" ROU="Y" S ROU=$E(ROU,1) I "YN"'[ROU W *7," Y or N please" G ROU
        D STO^IC2 G UCI
ZJ      W ! S ^IC=0
        I $V($V(44)+35) D STARTED^IC2 B 1 W !! G JOB^IC0
        F I=1:1:10 ZJ JOB^IC0 G STARTED^IC2:$T H 2
        W !,"No jobs available now",! G START
        -
IV      W !!,"Incorrect response - Enter '?' for help",! Q
HELP    W !!,"Enter   A valid structure number (ex. S0) or structure name (ex. SYS)"
        W !?8,"in the configuration you are currently running for which"
        W !?8,"you want to run the integrity checker",!! Q
TRAP    W !,$ZE
U       C 63 L  Q
