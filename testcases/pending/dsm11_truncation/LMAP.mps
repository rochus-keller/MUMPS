LMAP    ;9-Aug-80;Line map generator; DSM V3; JHM
        W !!,"System Line Map Generator",!
Q1      W !,"Configuration ? <",^SYS(0,"RUNNING") R "> ",ID
        I ID="?" D HQ1 G Q1
        G QUIT:ID="^" I ID=""!(ID=^SYS(0,"RUNNING")) S ID=^("RUNNING") G Q2
        I ID'?1NUP.NUP W !,"Invalid configuration name" G Q1
        I '$D(^SYS(ID)) D CONF G Q1
Q2      S %QTY=2,%DEF="LP" D ^%IOS G Q1:'$D(%IOD) I "LP,SC,TRM,SDP"'[%DTY W !,"Invalid response" G Q2
        W !!,"Printing: " D ^%T W !
        S DEV=-1,(DZ,DH,DHV,DHU,DH,DMC,LP,DL)=0 D HDR
        F IN=0:0 S DEV=$N(^SYS(ID,"TTY",DEV)) G DONE:DEV<0 D GTCHAR,PRCHAR
GTCHAR  ;;
DEF     S LPR=0,CNTLER=^SYS(ID,"TTY",DEV,"CONTROLLER"),COM=^("COMMENT")
        S PARDF=^("PARITY"),RTNDF=^("ROUTINE"),CRTDF=^("CRT"),DATADF=^("MODEM CONTROL"),OPDF=^("OUTPUT ONLY"),LOGDF=^("LOGIN")
        S STALDF=^("STALL COUNT"),TABDF=^("TAB CONTROL"),MARDF=^("OUTPUT MARGIN"),LOWDF=^("LOWER CASE"),AUTDF=^("AUTOBAUD"),ZUSDF=^(
"ZUSE")
        I CNTLER="LP11" S CNTLER="LP"_LP,LP=LP+1,CONT="LP" Q
        I CNTLER="DMC11" S CNTLER="DMC"_DMC,DMC=DMC+1,CONT="DMC" Q
        I CNTLER="SINGLE"!(CNTLER["DL") S CNTLER="DL"_DL,DL=DL+1,CONT="DL" Q
        I CNTLER="DH11" S CNTLER="DH"_(DH\16)_"-"_(DH#16),LPR=^("LPR"),C=$P($T(C),";;",2),RCVRDF=$P(C,",",LPR\64#16+1),XMITDF=$P(C,"
,",LPR\1024#16+1),DH=DH+1
        I CNTLER="DHU11" S CNTLER="DHU"_(DHU\16)_"-"_(DHU#16),LPR=^("LPR"),C=$P($T(D),";;",2),RCVRDF=$P(C,",",LPR\256#16),XMITDF=$P(
C,",",LPR\4096),DHU=DHU+1
        I CNTLER="DHV11" S CNTLER="DHV"_(DHV\8)_"-"_(DHV#8),LPR=^("LPR"),C=$P($T(D),";;",2),RCVRDF=$P(C,",",LPR\256#16),XMITDF=$P(C,
",",LPR\4096),DHV=DHV+1
        I CNTLER="DZ11"!(CNTLER="DZV11") S CNTLER="DZ"_(DZ\8)_"-"_(DZ#8),LPR=^("LPR"),B=$P($T(B),";;",2),RCVRDF=$P(B,",",LPR\256#16+
1),XMITDF=RCVRDF,DZ=DZ+1
        S CONT="MUX" Q
PRCHAR  ;;
        I $Y>57 D LIN W #,!! D HDR2
        W ?1,DEV,?10,CNTLER W:CONT="MUX" ?20,RCVRDF,?26,XMITDF,?32,PARDF
        I CONT="MUX"!(CONT="DL") W ?40,DATADF,?46,STALDF,?52,OPDF,?59,TABDF,?66,LOWDF,?72,CRTDF,?78,LOGDF,?85,MARDF,?91,RTNDF,?96,AU
TDF,?101,ZUSDF
        W ?104,COM,! D LIN Q
HDR     U %IOD W #,!!,?35,ID," System Line Map  " D ^%D W "  " D ^%T W !!
        D HDR2 Q
HDR2    W "Device  Controller  RCVR  XMT  Parity Modem Stall Output Tab   Lowcase CRT  Login  Output Tie Auto ZUSE Comment",!
        W "                   Speed Speed        Cntrl Count  Only  Cntrl  Cntrl      Allowed Margin Rtn Baud",!
        D LIN Q
LIN     W "-------------------------------------------------------------------------------------------------------------------------
------",! Q
HQ1     W !!,"This routine will print out a complete line map for any"
        W !,"system you have created.  Enter the name of the system for"
        W !,"which you wish to have a line map printed."
        W !!,"Type ^ to exit",!,"     <CR> to take the default"
        D CONF Q
CONF    W !!,"Current configurations are: ",!! S ID=0
        F I=0:0 S ID=$N(^SYS(ID)) Q:ID<0  W ID,!
        Q
B       ;;50,75,110,134.5,150,300,600,1200,1800,2000,2400,3600,4800,7200,9600
C       ;;0,50,75,110,134.5,150,200,300,600,1200,1800,2400,4800,9600
D       ;;75,110,134.5,150,300,600,1200,1800,2000,2400,4800,7200,9600,19200
DONE    U 0 W !,"Finished: " D ^%T W !
        I %IOD'=$I C %IOD
QUIT    K SIS,ID,%QTY,%DEF,%DTY Q
