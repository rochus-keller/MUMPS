SGSOFT  ;28-Apr-83 ;UTILITIES ;SYSGEN ;DEFINE SOFTWARE OPTIONS ;JHM
        Q
START   W !,"PART 5:",?10,"SOFTWARE CONFIGURATION",!,"-------",!
        I $D(^SYS(ID,"ALTERED","COMMENT")) S SOFT=0 G SOF1
SOFDEF  S QUES="SOFT" X ^%Q("SGASKY") G:%A RETURN I "YN"'[$E(ANS) D IV G SOFDEF
        S SOFT=$E(ANS)="Y"
SOF1    S SING=^SYS(ID,"CONTROLLER","DL11")+^("LP11")+^SYS(ID,"DMC","LINES")
        S ^SYS(ID,"CONTROLLER","SINGLE")=SING
        F TTY=SING+3:1:19 Q:'$D(^SYS(ID,"TTY",TTY))  K ^(TTY)
        K TTY,CON
        I SING S TTY=2 F CONTYP="LP11","DL11","DMC11" F NUM=0:1:^SYS(ID,"CONTROLLER",CONTYP)-1 D
        .I CONTYP="DMC11",^SYS(ID,"CONTROLLER","DMC11",NUM,"DDP")="Y" Q
        .S TTY=TTY+1,TTY(TTY)=CONTYP_"-"_NUM
        W !,"PART 6:",?10,"ASSIGN DEVICE NUMBERS",!,"-------",!
        I 'SING G SETSIN
        S QUES="ASN" X:EXTH ^%Q("EXTH")
        W !,"The following single line device assignments have been made:",!!?6,"Device Number",?25,"Controller-Number",!
        F TTY=3:1:TTY W !?11,TTY,?31,TTY(TTY)
        W ! I SOFT G SETSIN
EDIT    S QUES="REDO" X ^%Q("SGASKN") G:%A RETURN G:ANS?1"N"."O" SETSIN W !
        S QUES="GETNM" K NEW X:EXTH ^%Q("EXTH") F TTY=3:1:TTY S DEF=TTY X ^%Q("SGEN") G:%A EDIT D
        .I ANS'?1N.N D IV W ! S TTY=TTY-1 Q
        .I $D(NEW(ANS)) W !?2,"This device number is assigned to ",NEW(ANS),!! S TTY=TTY-1 Q
        .I ANS>(SING+2)!(ANS<3) W !?2,"Devices must be numbered in the range from 3 to ",SING+2,!! S TTY=TTY-1 Q
        .S NEW(ANS)=TTY(DEF)
        K TTY F I=3:1:SING+2 S TTY(I)=NEW(I)
SETSIN  F TTY=1,3:1:SING+2 D
        .I '$D(^SYS(ID,"TTY",TTY,"CONTROLLER")) D
        ..S ^SYS(ID,"TTY",TTY,"COMMENT")="",^("MODEM CONTROL")="N",(^("ROUTINE"),^("STALL COUNT"))=0
        ..S (^("AUTOBAUD"),^("TAB CONTROL"),^("CRT"),^("OUTPUT ONLY"))="N",^("OUTPUT MARGIN")=132
        ..S ^("PARITY")="NONE",(^("LOWER CASE"),^("LOGIN"),^("ZUSE"))="Y"
        F TTY=3:1:SING+2 D
        .S CONTYP=$P(TTY(TTY),"-",1),^SYS(ID,"TTY",TTY,"CONTROLLER")=CONTYP,^("CONTROLLER NUMBER")=$P(TTY(TTY),"-",2)
        .I CONTYP="LP11" S ^("OUTPUT ONLY")="Y",^("TAB CONTROL")="N",^("ZUSE")="N"
        S ^SYS(ID,"TTY",1,"CONTROLLER")="CONSOLE DL",^("CONTROLLER NUMBER")=1
        K TTY,NEW
DONE    K TTY,CONTYP,CONUM,UNIT,DRV,NUM,NEW,T D START^SGLOAD I %A G:$D(^SYS(ID,"ALTERED")) RETURN G START
RETURN  Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
REDOH   ;;3
        ;;If you would like to make your own device assignments to these controllers
        ;;answer Y.  Otherwise, these default assignments will remain for your system.
        ;;
GETNMH  ;;8
        ;;Enter the new device assignment for this controller.  Devices must be numbered
        ;;sequentially from 3 to a maximum of 19.  For example, if you have 3 single
        ;;line controllers, the largest device number can not exceed 5.
        ;;
        ;;The number may not be less than 3 and must not be assigned to more than 1
        ;;device.
        ;;
        ;;
SOFTH   ;;23
        ;;You may choose to take the STANDARD SOFTWARE OPTIONS which will greatly
        ;;reduce the number of questions asked to configure this system.
        ;;
        ;;The STANDARD system includes:
        ;;
        ;;              Journal
        ;;              EBCDIC support
        ;;              Interjob communications
        ;;              Sequential Disk Processor
        ;;              Mountable Database Volume Sets
        ;;              UCI Translation Table
        ;;              Default sizes for all System Data Structures
        ;;              Default values for Basic System Software Parameters
        ;;
        ;;The STANDARD system does not include:
        ;;
        ;;              Mapped routines
        ;;              Executive Debbuging Tool
        ;;              Spooling
        ;;
        ;;The exact values of all of these parameters will be reported to you
        ;;during the SYSGEN process as they are assigned.  Answer Y if you
        ;;wish to use the STANDARD SYSTEM
        ;;
ASNH    ;;4
        ;;Single line devices are numbered from 3 to 19 in DSM-11.  The DL11, LP11,
        ;;and DMC11 (used as single line device, not for DDP) are all considered
        ;;Single line devices.
        ;;
SOFT    ;;1;;5.1;;1
        ;;Do you wish to use the STANDARD SOFTWARE OPTIONS
REDO    ;;1;;6.1;;1
        ;;Do you wish to edit these assignments
GETNM   ;;0;;6.2;;1
        W %NUM,?6,$P(TTY(TTY),"-",1)," Controller #",$P(TTY(TTY),"-",2)," is assigned to" Q
