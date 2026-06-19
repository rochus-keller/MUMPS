STU4    Q  ;JBH 16-JUL-80 LAST STARTUP ROUTINE, START BACKGROUND JOBS
START   V ST+70::$V(ST+70)#256+(^SYS(ID,"DISK","WRITE CHECK")="Y"*256)
        S PAC=^SYS(ID,"PROGRAMMER ACCESS CODE")
        V ST+76::$A(PAC,2)*256+$A(PAC),ST+78::$A(PAC,3)
        S FREQ=^SYS(ID,"MISCELLANEOUS","LINE FREQUENCY")
        V ST+36::FREQ/10*257,ST+420::FREQ*(^("POWER RESTART DELAY"))
        V ST+282::^("LOGOUT DELAY")*256+($V(ST+282)#256)
        V ST+70::$V(ST+70)\256*256 I ^("LOGIN ECHO")="N" V ST+70::$V(ST+70)+1
        V 2:$V(ST+132):^("ABORT KEY")*256+($V(2,$V(ST+132))#256)
        V ST+82::$V(ST+82)#256+(^("ALTKEY")*256)
        V ST+388::$V(ST+389)*256+(^("DZ11 TIMER")\100)
        V ST+354::^("WRITE DEMON TIMER")\100
        V ST+310::$V(ST+310)\2*2+(^("VIEW RESTRICTION")="Y")
        V ST+386::$V(ST+386)#256+(256*(^("ZUSE RESTRICTION")="Y"))
        V ST+40::$V(ST+41)*256+^("UDA BITS")
        S UNITS=^("UDA DUAL-PORTED UNITS") I UNITS'="NONE" D
        .C 63 O 63
        .F I=1:1:$L(UNITS,",") S U=$P(UNITS,",",I) D
        ..S $ZT="UDAER^STU4" V 0:"DU"_U
        .C 63 S $ZT=""
        K (ST,ID) V ST+74::$J*512+($V(ST+74)#256)
        I $D(^("GLOBAL DEFAULT")) D GCHST
        V ST+264::$V(ST+265)*256+^("DIVSIG")
        I ^SYS(0,"STARTUP","MOUNT")="Y" D
        .S DDU="",STRN=1
MLOOP   .S DDU=$O(^SYS(0,"STARTUP","MOUNT",DDU))  Q:DDU=""
        .S VOLNAM=$P(^(DDU),"^",2),STNAM=$P(^(DDU),"^",3) S:STNAM="" STNAM=VOLNAM
        .I $P(^(DDU),"^")="Y" S STR=STRN
        .I $P(^(DDU),"^")="N" S STR=-1,%LB=$E(VOLNAM,2,$L(VOLNAM)-1) F I=$L(%LB):1:21 S %LB=%LB_$C(0)
        .S STMAP=0,XDDU=DDU D START^MAPMOUNT
        .I %A W !!,"Mounting of disk ",DDU," aborted.",!
        .I '%A,STR'=-1 S STRN=STRN+1
        .S DDU=XDDU
        .G MLOOP
        I '$D(^%ER) S ^%ER="60\100\1\1"
        I ^%ER="" S ^%ER="60\100\1\1"
        S ^%Q("ER",35)=$P(^%ER,"\",2),(^SYS(0,"STARTUP","ERR JCDEV"),^%Q("ER",34))=$S($D(^SYS(ID,"STARTUP","ERR JCDEV")):^("ERR JCDEV"),1:"N"),^%Q("ER",36)=$P(^%ER,"\",3),^%Q("ER",37)=$P(^%ER,"\",4)
        U 0 S CTKDEV=^SYS(0,"STARTUP","CARETAKER PRINTER") V ST+346::$V(ST+347)*256+CTKDEV
        I '$D(^SYS(ID,"TTY",CTKDEV)) W !,"Caretaker device ",CTKDEV," not in this configuration" G DDP
        I ^SYS(0,"STARTUP","CARETAKER")="Y" D ST100^CARE
DDP     I ^SYS(ID,"OPTIONS","DDP")="Y" D STU^DDPCON
        I ^SYS(0,"STARTUP","DDP")="Y" W !,"DDP will start in 5 seconds" J STU^DDPLNK
        I ^SYS(0,"STARTUP","SPOOLING")'="Y" G DRIVER
        D SPLDO G:^SYS(0,"STARTUP","DESPOOLER")'="Y"!%FAIL DRIVER
        D DSPLDO
DRIVER  I ^SYS(0,"STARTUP","DRIVER")="Y" D STU^LOADR
        I ^SYS(0,"STARTUP","ROUTINE MAP")="Y" S SETNAM="" D
        .F %XY=0:0 S SETNAM=$O(^SYS(0,"STARTUP","ROUTINE MAP",SETNAM)) Q:SETNAM=""  D
        ..I '$D(^SYS(0,"ROUTINE MAP",SETNAM)) K ^SYS(ID,"STARTUP","ROUTINE MAP",SETNAM) W !,"Routine map, ",SETNAM,", does not exist - deleted from Startup Command File",! Q
        ..I ^SYS(0,"STARTUP","ROUTINE MAP",SETNAM)="Y" D LOAD^RMLOAD
JRNL    I ^SYS(0,"STARTUP","JOURNAL")'="Y" G USER
        W !,"JOURNAL STARTUP",! D JRNGO^JRNSTU W !
USER    S $ZE="",$ZT="NOSTU^STU4" D ^USERSTU G DONE
NOSTU   I $ZE'["NOPGM" W !,$ZE,!
DONE    H 5 V ST::1024 H 1 V ST+74::$V(ST+74)#256 W !!,$ZV," ",^SYS(0,"RUNNING")," is now up and running!"
        H
GCHST   S GLDEF=^("GLOBAL DEFAULT"),B8DEF=$P($P(GLDEF,";",1),",",2)
        S JLDEF=$P($P(GLDEF,";",2),",",2),CSDEF=$E($P(GLDEF,";",3),1)
        V ST+292::(B8DEF="Y")*2+((JLDEF="Y")*4)+(CSDEF="S")*256+($V(ST+292)#256)
        K GLDEF,OVDEF,JLDEF,CSDEF Q
SPLDO   S %FAIL=0 I ^SYS(0,"SPOOL SPACE","INDEX")'>1 G NSPLR
        D SETDDB^STUSPL
        Q
DSPLDO  S %FAIL=0,^SYS(0,"STARTUP","DESPOOLER")="N"
        S D=^("DEFAULT SPOOL DEVICE") O D::1 E  W !,"Default spool device (",D,") is not available, " G NDSPLR
        C D ZJ START^DESPOOL:12 E  W !,"No partition for DESPOOLER, " G NDSPLR
        V 2:$ZB:$V(2,$ZB)+2560,$V(ST+230)::D
        S ^("DESPOOLER")="Y" K D Q
NSPLR   S ^SYS(0,"STARTUP","SPOOLING")="N" W !,"No SPOOL SPACE on disk, running with SPOOL device (#2) disabled",! I ^("DESPOOLER")="N" G NDFLT
NDSPLR  W "running without DESPOOLER",! K D
NDFLT   S ^("DEFAULT SPOOL DEVICE")=""
        V $V(ST+230)::0 S %FAIL=1 Q
UDAER   I $ZE'["DK" W !,"ERROR: ",$ZE,"when releasing dual-port drive","I"
        Q
