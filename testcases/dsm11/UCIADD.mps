UCIADD  ;DEFINE UCI TABLE
        I $V($V(44)+35)#2 W !!,"This routine cannot be run in baseline mode.",! Q
        C 63 O 63::3 E  W "View buffer busy",! G EXIT
        S ST=$V(44),DMB="B",ID=^SYS(0,"RUNNING"),UCID=0,UCIMAX=30
        D START^%STRTAB S NXSTR=0
        F I=0:0 S NXSTR=$O(STR(NXSTR)) Q:NXSTR=""  I STR(NXSTR)'="" G GET
        S STRNO="S0" G ST
GET     R !,"Inspect/Add UCI data for which volume set ? > ",STRNO
        I STRNO="^"!(STRNO="") G EXIT
        I STRNO'?1"S"1N&(STRNO'?3AN) D HELP G GET
        S NXSTR="" F I=1:1 S NXSTR=$O(STR(NXSTR)) Q:NXSTR=""  I STRNO=("S"_NXSTR)!(STRNO=STR(NXSTR)) G CHK
        W !!,"Volume Set ",STRNO," not in system",! G GET
CHK     I STR(NXSTR)="" W !!,"There is no disk mounted in Volume Set ",STRNO,".",!
        I  W "Type ""D ^MOUNT"" to mount the structure.",! G DONE
ST      W !!,"******* Inspect/Add UCI'S for Volume Set ",STRNO," *******",!
        S:STRNO?3AN STRNO="S"_NXSTR S STRNR=$E(STRNO,2),M=65536
        S STRTAB=$V(ST+12),LKU=$V(STRTAB+($V(ST+34)#256*STRNR)+2) D HEADER^MSUROU
        U 63:(::"Z") V 0:STRNO U 63:(::"C"),0 S UCIBLK=$V(512+400,0)#256*65536+$V(512+398,0)
        V UCIBLK:STRNO I STRNO="S0" D LOAD
        S UCINO=1 D SHOW
        I UCINO>UCIMAX W !!,"Volume set ",STRNO," UCI table full --"
        I  W " cannot add UCIs",! G DONE
ADD     U 0 W !,UCINO R ?5,NAM I NAM=""!(NAM="^") G DONE
        I NAM'?3A W "   Use 3 alphabetic characters",! G ADD
        F I=1:1:UCIMAX I $D(UNM(I)) I UNM(I)=NAM G DUPNAM
        S CHANGE="",UCID=UCID+1
        D SETUVARS^MSUROU V UCIBLK:STRNO
        S UCIOFF=UCINO-1*20 V UCIOFF+2:0:GD,UCIOFF+4:0:RDH*256+GDH
        V UCIOFF+6:0:RD,UCIOFF+8:0:RGA,UCIOFF+10:0:GDA,UCIOFF+12:0:GPA
        V UCIOFF+18:0:256
        V UCIOFF:0:$A(NAM,1)#32*32+($A(NAM,2)#32)*32+($A(NAM,3)#32)*2
        V -UCIBLK:STRNO
        F I=0:2:18 V UCIOFF+I:LKU:$V(UCIOFF+I,0)
        S UCINO=UCINO+1 G DONE:UCINO>UCIMAX,ADD
LOAD    I '$V(0,0) F I=0:2:18 V I:0:$V(I,LKU)
        V -UCIBLK:STRNO Q
SHOW    S UCIOFF=UCINO-1*20,I=$V(UCIOFF,0) I 'I S:'$D(XS) XS=200 Q
        S UNM(UCINO)=$C(I\2048+64)_$C(I#2048\64+64)_$C(I#64\2+64)
        D SETUP^MSUROU S XS=$V(UCINO-1*20+12,0)*400,UCINO=UCINO+1 G SHOW
DUPNAM  W !," -- Name already in use on this volume set",! G DONE
DONE    I UCID W !!,"  ",UCID," UCI" W:UCID>1 "s" W " added to disk,",!
        I UCID W "  ",UCID," UCI" W:UCID'=1 "s" W " added to memory.",!
        I UCID D UPDTAB^TRANTAB
EXIT    K (ID,DMB) C 63 W ! Q
HELP    W !!,"Enter   A valid Volume Set number (ex. S0) or Volume Set name (ex. SYS)"
        W !?8,"in the configuration you are currently running for which"
        W !?8,"you want to add the UCI data",!
        W !?8,"The following Volume Sets are mounted:",!
        D SHOW^%STRTAB Q
