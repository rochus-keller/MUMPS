SGLOAD  ;3-May-83 ;UTILITIES ;SYSGEN ;GET LOADABLE DRIVER ASSIGNMENTS ;JHM
        Q
START   K ^SYS(ID,"DRIVERS") D INIT^LOADR S TTY=51,LOAD=0
        F I=1:1:+DRVLST S ^SYS(ID,"DRIVERS",$P(DRVLST,";",I+1))="N"
        F I=1:1 Q:'$D(DRVLST(I))  S CONTYP=$P(DRVLST(I),";;"),DRV=$P(DRVLST(I),";;",2),UNITS=$P(DRVLST(I),";;",3) D SETLOD
        S ^SYS(ID,"OPTIONS","USRDRV")=$S(LOAD:"Y",1:"N")
        I ^("USRDRV")="Y" S ADR=ST+148 D GETWORD^LOADR S LOAD=CON*64+LOAD+4+63\64*64
        S:'$D(^SYS(ID,"MEM.ALLOC","USRDRV")) ^SYS(ID,"MEM.ALLOC","USRDRV")=LOAD G:'LOAD DONE
        S QUES="ASNL" X:EXTH ^%Q("EXTH")
        W !,"The following LOADABLE DRIVER device assignments have been made:",!
        W !?6,"Device Number",?25,"Controller-Number",?43,"Unit",!
        F TTY=51:1:TTY-1 W !?11,TTY,?31,$P(TTY(TTY)," "),"-",$P(TTY(TTY)," ",2),?45,$P(TTY(TTY)," ",3)
        W ! I SOFT G ASNLOD
EDI2    S QUES="REDO" X ^%Q("SGASKN") G:%A RETURN G:ANS?1"N"."O" ASNLOD W !
        S QUES="EDIL" K NEW X:EXTH ^%Q("EXTH") F TTY=51:1:58 Q:'$D(TTY(TTY))  S DEF=TTY X ^%Q("SGEN") G:%A EDI2 D
        .I ANS'?1N.N D IV W ! S TTY=TTY-1 Q
        .I $D(NEW(ANS)) W !?2,"This device number is assigned to ",NEW(ANS),!! S TTY=TTY-1 Q
        .I ANS>58!(ANS<51) W !?2,"Devices must be numbered in the range from 51 to 58",!! S TTY=TTY-1 Q
        .S NEW(ANS)=TTY(DEF)
        K TTY F I=51:1:58 I $D(NEW(I)) S TTY(I)=NEW(I)
ASNLOD  F I=51:1:58 I $D(TTY(I)) D
        .S T=TTY(I),CONTYP=$P(T," "),CONUM=$P(T," ",2),UNIT=$P(T," ",3),DRV=$P(T," ",4),NUM=$P(T," ",5)
        .S ^SYS(ID,"DRIVERS",DRV,"CONTROLLER",NUM,"TYPE")=CONTYP,^("NUMBER")=CONUM,$P(^("DEVICES")," ",UNIT+1)=I
DONE    K TTY,CONTYP,CONUM,UNIT,DRV,NUM,NEW,T,UNITS,LOAD,DRVLN,CON,DRVBEG,DDBSIZ,USRADR,DF,DFI,ADR
        D START^SGOPTS
RETURN  Q
SETLOD  I ^SYS(ID,"CONTROLLER",CONTYP) D FINDR^LOADR I CON'=0 D
        .S LOAD=^SYS(ID,"CONTROLLER",CONTYP)*UNITS*DDBSIZ+LOAD
        .I ^SYS(ID,"DRIVERS",DRV)="N" S ^(DRV)="Y",^(DRV,"UNITS")=UNITS,^("CONTROLLER")=0,LOAD=LOAD+DRVLN+4-DDBSIZ
        .S NUM=^SYS(ID,"DRIVERS",DRV,"CONTROLLER")
        .S ^SYS(ID,"DRIVERS",DRV,"CONTROLLER")=^SYS(ID,"CONTROLLER",CONTYP)+NUM
        .F CONUM=0:1:^SYS(ID,"CONTROLLER",CONTYP)-1 S NUM=NUM+1 D
        ..S ^SYS(ID,"DRIVERS",DRV,"CONTROLLER",NUM,"TYPE")=CONTYP,^("NUMBER")=CONUM
        ..F UNIT=0:1:UNITS-1 S ^("DEVICES")=TTY_" ",TTY(TTY)=CONTYP_" "_CONUM_" "_UNIT_" "_DRV_" "_NUM,TTY=TTY+1
        ..I UNITS=1 S $P(TTY(TTY-1)," ",3)=""
        Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
REDOH   ;;3
        ;;If you would like to make your own device assignments to these controllers
        ;;answer Y.  Otherwise, these default assignments will remain for your system.
        ;;
EDILH   ;;5
        ;;Enter the new device assignment for this controller.  Loadable devices must
        ;;be numbered between 51 and 58 and they must be unique to a particular controller
        ;;and unit.
        ;;
        ;;
ASNLH   ;;3
        ;;LOADABLE DRIVERS support the TU58, RX02, and BISYNC. DSM-11 device numbers for
        ;;these devices may be assigned values between 51 and 58.
        ;;
REDO    ;;1;;6.3;;1
        ;;Do you wish to edit these assignments
EDIL    ;;0;;6.4;;1
        W %NUM,?6,$P(TTY(TTY)," ")," Controller #",$P(TTY(TTY)," ",2) W:$P(TTY(TTY)," ",3)'="" " Unit #",$P(TTY(TTY)," ",3) W " is assigned to" Q
