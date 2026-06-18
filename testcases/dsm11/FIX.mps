FIX     ;EDIT BLOCKS TO FIX STRUCTURE @SMB@
1       K  D START^%STRTAB S (LB,MAP)=0,STRTAB=$V($V(44)+12),X=$V(STRTAB+2)
        S MGRGD=$V(4,X)#256*65536+$V(2,X),MGRRD=$V(5,X)*65536+$V(6,X)
B       K (LB,MAP,STR,MGRRD,MGRGD,STRNO)
        S $ZT="TRAP"
        C 63 R !,"Enter block # > ",BLK G Q:("^"[BLK!(BLK=""))
        I BLK="?" D HELP G B
        I BLK="M",MAP S BLK=MAP_":"_STRNO W "  ",BLK
        I BLK?1N.N S BLK=BLK_":S0" W "  ",BLK
        I BLK'?1N.N1":S"1N D IV G B
        S STRNO=$P(BLK,":",2),BLK=$P(BLK,":",1) I '$D(STR($E(STRNO,2))) D HELP G B
        I STR($E(STRNO,2))="" D NOMNT G B
        S MAP=BLK\400*400+399,LOC=BLK-MAP+399*2,LB=BLK
        O 63:2:1 E  W !,"view buffer wait..." O 63:2
        U 63:(1:1),0 I LOC=798 G READ
        V MAP:STRNO S UCI=$V(LOC,0)#256,UCIS=$V(LOC+1,0)
        I $V(1008,0)-21845!($V(1010,0)-43690) W !,"Map block indicates that this is not in the database area" G B
        I UCI=255&(UCIS<253)!(UCI&'UCIS)!(UCIS&'UCI) W !,"Illegal map block entry: low byte=",UCI," high byte=",UCIS G B
        I BLK=MGRRD!(BLK=MGRGD),UCI=255,UCIS=255 S (UCI,UCIS)=1
        W !,"MAP block entry indicates block is " I UCI+UCIS=0 W "free" G B
        I UCI-255 W "in UCI ",UCI," set by UCI ",UCIS G READ
        I UCIS=253 W "free, but changed by DBT to indicate a discrepancy" G B
        I UCIS=254 W "a bad block" G B
        W "a system block" G B
        -
READ    U 63:(1:1:"CT") V BLK:STRNO S ZA=$ZA U 0
        I ZA\64#2=0 G COPY
        I ZA\16#2=0 W !,"Disk hardware error, can't read block." G B
        W !,"Block ",BLK," has a 'forced error'.  You can clear the error"
        W !,"by 'filing' the block with ^FIX.  Before you do that, however,"
        W !,"you should inspect all data in the block for errors, and make"
        W !,"the appropriate corrections.",! V -BLK:STRNO
COPY    U 63:(1:2) V 1024:0:0:0:1024 U 63:(2:1),0
        I LOC=798 G ^FIXMAP
        S TYP=$V(1021,0)#128,T="T"_TYP S:$T(@T)="" TYP=0
T       W !,"Block type: " W:TYP "<",$P($T(@T),";;",2),"> " R " ",R
        G B:R="^",@T:R=""&TYP,LST:"?"[R
        F I=1,2,4,6,8,16 S Y=$T(@("T"_I)),X=$P(Y,";;",2) I $E(X,1,$L(R))=R W $E(X,$L(R)+1,999) G OK
        W *7," Type ? for list" G T
        -
OK      G @T:I=TYP
OK1     R " OKAY? <N> ",R S R=$E(R,1) G T:"^N"[R
        I R'="Y" W !,"Enter Y to change the block type to ",X,!," or N to re-ask block type" G OK1
        S TYP=I V 1020:0:$V(1020,0)#256+((TYP+($V(1021,0)\128*128))*256) G @("T"_TYP)
        -
LST     W ! F I=1,2,4,6,8,16 S Y=$T(@("T"_I)) W !?5,$P(Y,";;",2)
        G T
        -
TYPES   ;;
T1      G ^FIXGD ;;GLOBAL DIRECTORY
T2      G ^FIXPTR ;;POINTER
T4      F I=4,1010:2:1018 V I:0:0 ;;FAKE ROUTINE
        V 0:0:256,2:0:64,1020:0:1024,1022:0:6 G VIEW
T6      G ^FIXPTR ;;BOTTOM LEVEL POINTER
T8      G ^FIXDATA ;;DATA
T16     G ^FIXROU ;;ROUTINE
        -
VIEW    U 63:(1:1:"CVTP") V BLK:STRNO S ZA=$ZA
        I ZA\64#2=0 G WRITE
        I ZA\16#2=1 G WRITE
        C 63 W !!,"Sorry, but some other user has changed block ",BLK," since your"
        W !,"'FIX' session started, so your changes have been discarded."
        W !,"Please try again to make your changes.",! G B
        -
WRITE   U 63:(1:2) V 0:0:1024:0:1024
        U 63:(1:1:"CP") V -BLK:STRNO
        U 0 W " FILED" G B
        -
TRAP    U 0 W !,$ZE I $ZE[">S^FIXDATA1"!($ZE[">S+1^FIXDATA") S $ZE="TRAP^FIX" W " (ILLEGAL SUBSCRIPT>" G R^FIXDATA
        I $ZE[">S^FIXPTR1"!($ZE[">S+1^FIXPTR1") S $ZE="TRAP^FIX" W " (ILLEGAL SUBSCRIPT>" G R^FIXPTR
        C 63 Q:$ZE["<INRPT"  G B
        -
HELP    W !!,"Enter a valid DSM-11 block number in the following forms:",!
        W !,?5,"500:S0       - where 500 is the block number and"
        W !,?5,"               and S0 is the structure number"
        W !,?5,"500          - S0 will be the default structure number"
        W !,?5,"M            - The map block for the previous block referenced"
        W !,?5,"               will be calculated and used as the default",! Q
IV      W !!,"Invalid response, type  ?  for more help.",! Q
NOMNT   W !!,"There is no disk mounted in Structure ",STRNO,".",!
        W "Type ""D ^MOUNT"" to mount the structure.",! Q
Q       C 63 K  Q
