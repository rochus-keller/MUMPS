UCIEDIT ;DSM11 UTILITIES; COPYRIGHT 1983 DEC
        I $V($V(44)+35)#2 W !!,"This routine cannot be run in baseline mode.",! Q
        C 63 O 63::3 E  W "View buffer busy",! G EXIT
        S ST=$V(44),UCID=0
        D START^%STRTAB S NXSTR=0
        F I=0:0 S NXSTR=$O(STR(NXSTR)) Q:NXSTR=""  I STR(NXSTR)'="" G GET
        S STRNO="S0" G ST
GET     R !,"Edit UCI data for which volume set ? > ",STRNO,!
        I STRNO="^"!(STRNO="") G DONE
        I STRNO'?1"S"1N&(STRNO'?3AN) D HELP G GET
        S NXSTR="" F I=1:1 S NXSTR=$O(STR(NXSTR)) Q:NXSTR=""  I STRNO=("S"_NXSTR)!(STRNO=STR(NXSTR)) G CHK
        W !!,"Structure ",STRNO," not in system",! G GET
CHK     I STR(NXSTR)="" W !!,"There is no disk mounted in Structure ",STRNO,".",!
        I  W "Type ""D ^MOUNT"" to mount the structure.",! G DONE
ST      S $ZT="ERR^UCIEDIT"
        S:STRNO?3AN STRNO="S"_NXSTR S STRNR=$E(STRNO,2)
        S TABLE=$V(ST+12),LKU=$V(TABLE+($V(ST+34)#256*STRNR)+2)
        U 63:(::"Z") V 0:STRNO U 63:(::"C"),0 S UCIBLK=$V(512+400,0)#256*65536+$V(512+398,0)
VIEW    V UCIBLK:STRNO S UCINO=1
SETUP   S UCIOFF=UCINO-1*20,I=$V(UCIOFF,0) G:'I OPT
        S UNM(UCINO)=$C(I\2048+64)_$C(I#2048\64+64)_$C(I#64\2+64) S UCINO=UCINO+1 G SETUP
OPT     W !,"Enter one of the following:",!
        W "  1. Edit UCI name",!
        W "  2. Edit default library",!
        R "Enter option (1 or 2) >  ",OP,!
        I OP?1"?".E D OPHELP G OPT
        I OP="^"!(OP="") G DONE
        I OP'=1&(OP'=2) W !,"Incorrect response.  Enter '?' for more information.",!! G OPT
WHICH   R !!,"Enter UCI name >  ",UCED,!
        I UCED="^"!(UCED="") G OPT
        I UCED'?3A W "Enter the three-character name of the UCI",! G WHICH
        F I=1:1 Q:'$D(UNM(I))  I UNM(I)=UCED G:OP=1 EDIT G LIB
        W !,"No such UCI on this volume set",! G WHICH
EDIT    R !,"New name ? >  ",NEW,!
        I NEW="^"!(NEW="") G WHICH
        I NEW'?3A W "Enter 3 alphabetic characters, or hit <CR>",! G EDIT
        F J=1:1 Q:'$D(UNM(J))  I I'=J I UNM(J)=NEW G DUPNAM
        S UNM=$A(NEW,1)#32*32+($A(NEW,2)#32)*32+($A(NEW,3)#32)*2,UCID=1
        V I-1*20:LKU:UNM,I-1*20:0:UNM,-UCIBLK:STRNO G VIEW
LIB     S DEF=$V(I-1*20+18,0)\256 W !,"Library UCI ? <",DEF R "> ",LIBUCI,!
        S:LIBUCI="" LIBUCI=DEF I LIBUCI="^" G WHICH
        I LIBUCI'?.N!(LIBUCI>50) D LIBHLP G LIB
        V I-1*20+18:LKU:$V(I-1*20+18,LKU)#256+(LIBUCI*256)
        V I-1*20+18:0:$V(I-1*20+18,0)#256+(LIBUCI*256),-UCIBLK:STRNO G VIEW
DUPNAM  W !," -- Name already in use on this volume set",! G EDIT
ERR     U 0 I $ZE?1"<INRPT".E W *7,!,"  UCI modification aborted",! G DONE
        W !,$ZE,! K  C 63 Q
DONE    I UCID D UPDTAB^TRANTAB
EXIT    K  C 63 W ! Q
HELP    W !!,"Enter   A valid structure number (ex. S0) or structure name (ex. SYS)"
        W !?8,"in the configuration you are currently running for which"
        W !?8,"you want to edit the UCI data",!! Q
OPHELP  W !!,"Enter '1' to change the name of a UCI on this volume set."
        W !,"Enter '2' to change the library UCI's on this volume set.",!! Q
LIBHLP  W !!,"Enter the UCI number of the UCI which you like this"
        W !,"UCI to use as the default LIBRARY UCI.  A library is"
        W !,"the UCI which contains % utilities and globals.  If"
        W !,"you enter 0, the default UCI will be the MANAGER'S"
        W !,"UCI on Volume Set S0.",!! Q
