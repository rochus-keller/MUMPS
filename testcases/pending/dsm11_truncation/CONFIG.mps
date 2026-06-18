CONFIG  ;29-Mar-83 ;UTILITY ;SYSGEN ;CREATES THE AUTOCONFIGURE DATA IN ^SYS ;JHM
        S $ZT="FAIL^CONFIG"
        S ST=$V(44),DEVAST=$V(ST+60),ACF=$V(ST+130)
        I '($V(ST+35)#2) W !,"This utility may only be run in baseline mode" G EXIT
        S %GARTRA=ST+364 I $V(%GARTRA) W !,"Waiting for Garbage collector to complete" F I=1:1 H 1 W "." Q:$V(%GARTRA)=0
        S WRTIM=$V(ST+354)*5+10\10
        D STRACF H WRTIM V DEVAST::5,DEVAST+2::ACF+1024 H 2
SHODAT  V ST::1024 H 1
        K ^SYS(0,"AUTO") S DBPTR=ACF
        D GETPRO
        W !!,"Processor Type: " S M=1,OPT=$V(DBPTR) F I=1:1:$L(PTYP,":") Q:OPT\M#2  S M=M*2
        S M=$P(PTYP,":",I),^SYS(0,"AUTO","PROCESSOR")=M W M
        S QB=$E($P(M,"/",2),2)=3
        S O=$V(ST+418)\32*2 S ^SYS(0,"AUTO","OPTIONS","MEMORY")=O W !!,"Memory Size: ",O," KB",!
        W !,"Processor/Memory Options:",! S M=1,OPT=$V(DBPTR+2)
        F I=1:1:16 D
        .I OPT\M#2 S O=$P($T(POPT+I),":",2) I O'="RESERVED" W !?5,O S ^($P($T(POPT+I),":",3))=""
        .S M=M*2
        S TVEC=10,TCSR=TVEC+10,TUNIT=TCSR+10,TTYPE=TUNIT+10,TREM=TTYPE+10
        W !!,"Name",?TVEC-1,"Vector",?TCSR+1,"CSR",?TUNIT-1,"Unit",?TTYPE,"Type",?TREM,"Description"
        S DBPTR=ACF+6 D CODE^DPBEGIN
        K MCOD F I=2:1 S O=$P($T(MMT),":",I) Q:O=""  S MCOD(+O)=O
PROCON  I $V(DBPTR)=65535 S ERR=0 G EXIT
        S CON=$C($V(DBPTR)#256)_$C($V(DBPTR+1)),CN=$C($V(DBPTR+2)#256),DBPTR=DBPTR+8
        S %DO=$V(DBPTR-4) D %DO S CSR=%DO
        S %DO=$V(DBPTR-2) D %DO S VEC=%DO
        S CONTYP="" F I=1:1:$P($T(CONTAB),";;",2) I $P($T(CONTAB+I),";;",2)=CON S CON=$P($T(CONTAB+I),";;",3),CONTYP=$P($T(CONTAB+I)
,";;",4+QB),REM=$P($T(CONTAB+I),";;",6) Q
        U 0 W !!,CON,CN
        I CONTYP="" W ?TVEC,VEC,?TCSR,CSR D NOSUP G PROCON
        S UNITS=$V(DBPTR-5)
        I VEC=177777 W ?TVEC,"??",?TCSR,CSR,?TTYPE,CONTYP D NOINT G PROCON
        S NO=1 I $D(^SYS(0,"AUTO",CONTYP)) S NO=^(CONTYP)+1
        S ^SYS(0,"AUTO",CONTYP)=NO,^(CONTYP,NO)=VEC_","_CSR_","_UNITS
        W ?TVEC,VEC,?TCSR,CSR,?TTYPE,CONTYP,?TREM,REM," Controller"
        G:'UNITS PROCON
UNITS   S UNTYP=$V(DBPTR+2)#256,UNIT=$V(DBPTR)#256
        I REM="Disk",$D(CODE(UNTYP)) S TYPNM=$P(CODE(UNTYP),",",2)
        E  I $D(MCOD(UNTYP)) S TYPNM=$P(MCOD(UNTYP),",",2)
        E  W !?TUNIT,UNIT,?TTYPE,"??",?TREM,"Unknown Unit Type" G UNIT1
        W !?TUNIT,UNIT,?TTYPE,TYPNM,?TREM,$S($E(TYPNM,1)="T":"Tape Drive",1:"Disk Drive")
        S ^SYS(0,"AUTO",CONTYP,NO,UNIT)=TYPNM
UNIT1   S DBPTR=DBPTR+4
        S UNITS=UNITS-1 G PROCON:'UNITS G UNITS
NOUN    W !?TUNIT,UNIT,?TTYPE,"??",?TREM,"Unknown Unit Type" G UNIT1
CONTAB  ;;24;;
        ;;DK;;DK;;RK11;;RK11;;Disk
        ;;DL;;DL;;RL11;;RL11;;Disk
        ;;DM;;DM;;RK611;;RK611;;Disk
        ;;DU;;DU;;MSCP;;MSCP;;Disk
        ;;RH;;RH;;RH11;;RH11;;Disk
        ;;DY;;DY;;RX02;;RX02;;Diskette
        ;;DD;;DD;;TU58;;TU58;;Cassette
        ;;MM;;MM;;RH11;;;;Tape
        ;;MT;;MT;;TM11;;;;Tape
        ;;MS;;MS;;TS11;;TSV05;;Tape
        ;;MX;;MS;;TU80;;;;Tape
        ;;MU;;MU;;TMSCP;;TMSCP;;Tape
        ;;XE;;XE;;DEUNA;;;;Ethernet
        ;;XH;;XH;;;;DEQNA;;Ethernet
        ;;LP;;LP;;LP11;;LP11;;Line Printer
        ;;YM;;YM;;DM11-BB;;;;DH Modem
        ;;YH;;YH;;DH11;;;;Asynch Multiplexor
        ;;YV;;YV;;DHU11;;DHV11;;Asynch Multiplexor
        ;;YZ;;YZ;;DZ11;;DZV11;;Asynch Multiplexor
        ;;XU;;XW;;DU11;;DUV11;;Synchronous Line
        ;;ZN;;ZN;;;;DPV11;;Synchronous Line
        ;;XW;;XW;;DUP11;;;;Synchronous Line
        ;;XM;;XM;;DMC11;;;;Synchronous Line
        ;;YL;;YL;;DL11;;DL11;;Asynch Single Line
MMT     :8,TU16:9,TE16:10,TU45:40,TU16:41,TE16:42,TU45:44,TU77:128,TK50:129,TU81:
GETPRO  S PTYP=$P($T(PTYP),":",2,$L($T(PTYP),":")) Q
PTYP    :UNKNOWN:UNKNOWN:UNKNOWN:PDP-11/53:PDP-11/23:PDP-11/24:PDP-11/34:PDP-11/40:PDP-11/44:PDP-11/45:PDP-11/60:PDP-11/70:PDP-11/70
:PDP-11/73:PDP-11/83:PDP-11/84
POPT    ;
        :Floating Point Unit:FPU
        :Commercial Instruction Set:CIS
        :Extended Instuction Set:EIS
        :Floating Instruction Set:FIS
        :22 Bit Addressing:22 BIT
        :UNIBUS Mapping Support:UMR
        :Console Display Register:CDR
        :Cache:CACHE
        :RESERVED:
        :KW11-P Programmable Clock:KW11-P
        :RESERVED:
        :Memory Parity:UMP
        :KW11-W Watchdog Timer:KW11-W
        :Console Switch Register:CSR
        :RESERVED:
        :Massbus magtape:MMT
STRACF  W !,"Configuring Host System . . . ",! Q
NOINT   W ?TREM,"Failed to Interrupt" Q
NOSUP   W ?TREM,"Device not supported" Q
%DO     S %B=%DO,%DO=""
AA      S %DO=%B#8_%DO,%B=%B\8 G:%B>7 AA S:%B %DO=%B_%DO K %B Q
FAIL    W !,"$ZE = ",$ZE,!,"*** AUTOCONFIGURE FAILED ***",! S ERR=1
EXIT    W !!
        K BOOTDK,BLK,ACF,CODE,MCOD,TTYPE,TUNIT,TREM,TVEC,TYPNM,UNITS,VEC,PTYP,OPT,REM,WRTIM,TCSR,O,M,J,CONTYP,CSR,DBPTR,%DO,%GARTRA,
CN,CON,DEVAST,I,NO,QB,UNIT,UNTYP Q
        U 0:80 S DBPTR=ACF
        F I=DBPTR:2:DBPTR+520 S %DO=$V(I) D ^%DO W $J(%DO,6),?8-$X#8+$X
        Q
