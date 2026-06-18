SGDEVS  ;25-Apr-83 ;UTILITIES ;SYSGEN ;GATHERS VECTOR AND CSR INFO FOR ALL DEVICES ;JHM
        Q
START   S PROC=^SYS(ID,"PROCESSOR") F CONREC=1:1:$P($T(CONTAB)," ",2) D  I %A G:CONREC=1 RETURN G START
        .S CONINF=$T(CONTAB+CONREC),TRUE=$P(CONINF,";;",2),CONAM=$P(CONINF,";;",3),MAX=$P(CONINF,";;",4)
        .S HELP=$P(CONINF,";;",5)
        .I @(TRUE_"=0") K ^SYS(ID,"CONTROLLER",CONAM) S ^SYS(ID,"CONTROLLER",CONAM)=0 Q
        .I 'EDIT S:'$D(^SYS(ID,"CONTROLLER",CONAM)) ^SYS(ID,"CONTROLLER",CONAM)=0 Q
        .S NUM=0,@("MAX="_MAX)
        .I $D(^SYS(ID,"CONTROLLER",CONAM)) S NUM=^(CONAM)
ASK     .S DEF=NUM,QUES=HELP X ^%Q("SGASK") I %A Q
        .I ANS'?1N.N!(ANS>MAX) D IV G ASK
        .S (^SYS(ID,"CONTROLLER",CONAM),NUM)=ANS Q:'ANS
        .F CONUM=0:1:NUM-1 S (CSR,VEC)="",FOR=CONAM_" controller #"_CONUM D  I %A G:CONUM=0 ASK S CONUM=CONUM-2
        ..I $D(^SYS(ID,"CONTROLLER",CONAM,CONUM,"VECTOR")) S VEC=^("VECTOR")
        ..I $D(^SYS(ID,"CONTROLLER",CONAM,CONUM,"CSR")) S CSR=^("CSR")
        ..D VECCSR^SGSUB I %A Q
        ..S ^SYS(ID,"CONTROLLER",CONAM,CONUM,"CSR")=CSR,^("VECTOR")=VEC
DONE    S CONAM="" F I=1:1 S CONAM=$O(^SYS(ID,"CONTROLLER",CONAM)) Q:CONAM=""  S CONUM=^(CONAM) D
        .F J=CONUM:1 Q:'$D(^SYS(ID,"CONTROLLER",CONAM,J))  K ^(J)
        S ^SYS(ID,"CONTROLLER","CONSOLE DL")=1,^("CONSOLE DL",1,"VECTOR")=60,^("CSR")=177560
        F CONUM=0:1:^SYS(ID,"CONTROLLER","DH11")-1  D
        .I '$D(^SYS(ID,"CONTROLLER","DM11-BB",CONUM)) K ^SYS(ID,"CONTROLLER","DH11",CONUM,"MODEM CONTROL") S ^("MODEM CONTROL")="N"
Q
        .S VEC=^(CONUM,"VECTOR"),CSR=^("CSR"),^SYS(ID,"CONTROLLER","DH11",CONUM,"MODEM CONTROL")="Y"
        .S ^("MODEM CONTROL","CSR")=CSR,^("VECTOR")=VEC
        F CONT="DZ11","DZV11" F NO=1:1:^SYS(ID,"CONTROLLER",CONT) S ^SYS(ID,"CONTROLLER",CONT,NO-1,"MODEM CONTROL")="Y"
        S MAX=16*^SYS(ID,"CONTROLLER","DH11")+63
        F DEV=64:1:MAX S ^SYS(ID,"TTY",DEV,"CONTROLLER")="DH11" S LPR=14151 D GLOB
        S DEV=MAX,MAX=8*^SYS(ID,"CONTROLLER","DHV11")+MAX
        F DEV=DEV+1:1:MAX S ^SYS(ID,"TTY",DEV,"CONTROLLER")="DHV11" S LPR=56728 D GLOB
        S DEV=MAX,MAX=16*^SYS(ID,"CONTROLLER","DHU11")+MAX
        F DEV=DEV+1:1:MAX S ^SYS(ID,"TTY",DEV,"CONTROLLER")="DHU11" S LPR=56728 D GLOB
        S DEV=MAX,MAX=8*^SYS(ID,"CONTROLLER","DZ11")+MAX
        F DEV=DEV+1:1:MAX S ^SYS(ID,"TTY",DEV,"CONTROLLER")="DZ11" S LPR=DEV#8+7704 D GLOB
        S DEV=MAX,MAX=4*^SYS(ID,"CONTROLLER","DZV11")+MAX
        F DEV=DEV+1:1:MAX S ^SYS(ID,"TTY",DEV,"CONTROLLER")="DZV11" S LPR=DEV#4+7704 D GLOB
        F DEV=DEV+1:1:223 K ^SYS(ID,"TTY",DEV)
        S ^SYS(ID,"OPTIONS","MODEM")="Y"
        K PROC,CONREC,CONTAB,CONINF,MODEM,CONAM,MAXNUM,VEC,CSR,HELP,LPR,TRUE,FOR,MAX,NUM,DEV,NO,CONUM,DMB,SAVQ,CONT
        D START^SGDMC I %A G:EDIT START
RETURN  Q
GLOB    Q:$D(^("PARITY"))  S ^("PARITY")="NONE",^("LPR")=LPR,^("ZUSE")="Y",^("AUTOBAUD")="N"
        S (^("ROUTINE"),^("STALL COUNT"))=0,(^("OUTPUT ONLY"),^("MODEM CONTROL"))="N",^("OUTPUT MARGIN")=80
        S (^("TAB CONTROL"),^("CRT"),^("LOWER CASE"),^("LOGIN"))="Y",^("COMMENT")=""
        Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
CONTAB  16
        ;;1;;LP11;;8;;LP
        ;;1;;DL11;;17-^SYS(ID,"CONTROLLER","LP11");;DL
        ;;PROC'?1"11/"1N1"3";;DMC11;;4;;DMC
        ;;PROC'?1"11/"1N1"3";;DEUNA;;4-^SYS(ID,"CONTROLLER","DMC11");;DUNA
        ;;PROC?1"11/"1N1"3";;DEQNA;;4;;DQNA
        ;;PROC'?1"11/"1N1"3";;DH11;;10;;DH
        ;;^SYS(ID,"CONTROLLER","DH11");;DM11-BB;;^SYS(ID,"CONTROLLER","DH11");;DM
        ;;PROC'?1"11/"1N1"3";;DHU11;;10-^SYS(ID,"CONTROLLER","DH11");;DHU
        ;;PROC'?1"11/"1N1"3";;DZ11;;20-(^SYS(ID,"CONTROLLER","DH11")+^("DHU11")*2);;DZ
        ;;PROC?1"11/"1N1"3";;DHV11;;20;;DHV
        ;;PROC?1"11/"1N1"3";;DZV11;;-^SYS(ID,"CONTROLLER","DHV11")*2+40;;DZV
        ;;1;;RX02;;1;;RX
        ;;1;;TU58;;1;;TU
        ;;PROC?1"11/"1N1"3"&'($V(ST+160)#2);;DUV11;;4;;DUV
        ;;PROC'?1"11/"1N1"3"&'($V(ST+160)#2);;DUP11;;4;;DUP
        ;;PROC?1"11/"1N1"3"&'($V(ST+160)#2);;DPV11;;4;;DPV
LPH     ;;2
        ;;Enter the number of LP11 line printer controllers in this configuration
        ;;
DLH     ;;3
        ;;Enter the number of DL11 single line asynchronous controllers in this
        ;;configuration.  Do not include the console DL.
        ;;
DUNAH   ;;2
        ;;Enter the number of DEUNA ETHERNET controllers in this configuration.
        ;;
DQNAH   ;;2
        ;;Enter the number of DEQNA ETHERNET controllers in this configuration.
        ;;
DMCH    ;;3
        ;;Enter the number of DMC11 synchronous controllers in this configuration.  Make
        ;;sure to enter all DMC's regardless of their use in the system.
        ;;
DHH     ;;3
        ;;Enter the number of DH11 16-line asynchronous multiplexors in this
        ;;configuration.
        ;;
DHUH    ;;3
        ;;Enter the number of DHU11 16-line asynchronous multiplexors in this
        ;;configuration.
        ;;
DHVH    ;;3
        ;;Enter the number of DHV11 8-line asynchronous multiplexors in this
        ;;configuration.
        ;;
DZH     ;;2
        ;;Enter the number of DZ11 8-line asynchronous multiplexors in this configuration.
        ;;
DZVH    ;;2
        ;;Enter the number of DZV11 4-line asynchronous multiplexors in this configuration.
        ;;
RXH     ;;3
        ;;Enter the number of RX02 dual-density diskette controllers in this
        ;;configuration.  (Note that one controller supports two diskette drives.)
        ;;
TUH     ;;3
        ;;Enter the number of TU58 cassette tape controllers in this configuration.
        ;;(Note that one controller supports two cassette drives.)
        ;;
DMH     ;;2
        ;;Enter the number of DM11-BB modem control units in this configuration.
        ;;
DUPH    ;;3
        ;;Enter the number of DUP11/ synchronous line controllers in this configuration.
        ;;These devices are only used with the BISYNC protocol emulator product.
        ;;
DUVH    ;;3
        ;;Enter the number of /DUV11 synchronous line controllers in this configuration.
        ;;These devices are only used with the BISYNC protocol emulator product.
        ;;
DPVH    ;;3
        ;;Enter the number of DPV11/ synchronous line controllers in this configuration.
        ;;These devices are only used with the BISYNC protocol emulator product.
        ;;
LP      ;;0
DL      ;;0
DMC     ;;0
DH      ;;0
DHU     ;;0
DHV     ;;0
DZ      ;;0
DZV     ;;0
RX      ;;0
TU      ;;0
DM      ;;0
DUV     ;;0
DUP     ;;0
DPV     ;;0
DUNA    ;;0
DQNA    ;;0
        W !,"3.",CONREC+2,?6,"How many ",CONAM,"'s are there (max = ",MAX,")" Q
