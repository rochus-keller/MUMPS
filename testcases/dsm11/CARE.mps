CARE    ;DSM-11 CARETAKER MANAGEMENT 9/1/80 DB
ST05    S $ZT="ERR^CARE"
        D CHKSYS^SYSROU Q:%A
ST10    U 0 S ST=$V(44) D P0 W "Enter the option of your choice > " R %O
ST20    G:%O=""!(%O="^") EXIT F %I=1:1:7 I %O=%I D ST30 G ST10
ST25    D HLP R !!!,"Strike the <RETURN> key to continue.",%T G ST10
ST30    G @(%O)
1       D ST100 Q
ST100   S ST=$V(44) I $V(ST+204)\8#2=1 W " ...Caretaker job is already running." Q
        S ^SYS(0,"STARTUP","CARETAKER")="N"
        ZJ START^CTK:8 I '$T W !!,"No partition available for the Caretaker Background job." Q
        S ^("CARETAKER")=$ZB
        V ST+204::$V(ST+204)+8
        W !,"Caretaker is now running as job number ",^("CARETAKER"),"."
        S ^%Q("ER",34)=^("ERR JCDEV")
        Q
2       D STOP Q
STOP    S JOB=^SYS(0,"STARTUP","CARETAKER") Q:JOB="N"
        S ^("CARETAKER")="N",^%Q("ER",34)="N"
        V ST+204::$V(ST+204)-(8*($V(ST+204)\8#2))
        D SHUTJ^RJD W " ...Caretaker stopped.",! Q
3       D ^KTR Q
4       R !!,"Do you want to print the hardware error log first? <Y/N> ",%I Q:%I=""!(%I="^")  D:%I="Y" ^KTR
        W !
        S TY=-1 F I=1:1 S TY=$N(^SYS(0,"ERROR",TY)) Q:TY=-1  D GRET I TY=-1 G 4
        S HH=+$H,TY=-1
        F IN=1:1 S TY=$N(^SYS(0,"ERROR",TY)) Q:TY=-1  S H=HH-^(TY),UNT=-1 F JN=1:1 S UNT=$N(^SYS(0,"ERROR",TY,UNT)) Q:UNT=-1  S D=-1,C=0 D PUR
        Q
PUR     F I=1:1 S D=$N(^SYS(0,"ERROR",TY,UNT,D)) Q:D=-1  I D'>H S J=-1 F I=1:1 S J=$N(^SYS(0,"ERROR",TY,UNT,D,J)) Q:J=-1  K ^SYS(0,"ERROR",TY,UNT,D,J) S C=C+1
        I C S ^SYS(0,"$HFIRST")=$H
        W !!?5,C," Error(s) on ",TY,UNT," purged."
        Q
GRET    I $D(^SYS(0,"ERROR",TY))#2=0 S ^SYS(0,"ERROR",TY)=0
        W !,"Number of Days to Retain Device ",TY," errors <",^SYS(0,"ERROR",TY),">: " R H
        I H="?" W !!,"Enter Number of Days in the past that you wish to retain errors in ^SYS for this",!,"device. To retain zero days will purge all errors.",! G GRET
        I H="" Q
        I H="^" S TY=-1 Q
        I H<0 W "  - Must be > 0",*7 G GRET
        S ^SYS(0,"ERROR",TY)=H
        Q
5       S %DEF=$V($V(44)+346)#256,%QTY=102 K %MOD D ^%IOS I '$D(%IOD) Q
        I %DTY'="SC",%DTY'="TRM",%DTY'="LP" W !," -- must be a terminal or line printer.",!! G 5
        V $V(44)+346::$V($V(44)+347)*256+%IOD Q
6       D ^DSKTRACK Q
7       D ^%ER Q
EXIT    K %I,%T,%O Q
ERR     U 0 I $ZE?1"<INRPT".E W !,"Unexpected interrupt",!
        E  W !,$ZE,!
        G EXIT
P0      F %I=1:1 S %T=$T(P1+%I) Q:$P(%T,";;",1)["P2"  W $P(%T,";;",2,255),!
        W ! Q
P1      ;;Start of prompt text
        ;;
        ;;
        ;;Caretaker Utilities
        ;;
        ;;1. Start system Caretaker
        ;;2. Stop system Caretaker
        ;;3. Print hardware error log (^KTR)
        ;;4. Erase hardware error log
        ;;5. Change error printer
        ;;6. Print disk error summary (^DSKTRACK)
        ;;7. Software error log (%ER)
P2      ;;END OF TEXT
HLP     F %I=1:1 S %T=$T(HELP+%I) Q:$P(%T,";;",1)["END"  W $P(%T,";;",2,255),!
        W ! Q
HELP    ;;Start of help text
        ;;
        ;;                 Caretaker Management
        ;;
        ;;Start:  This option starts the Caretaker Background job. The functions
        ;;of this job are three-fold. First it monitors the status of the output-
        ;;only printers and the system disk. If a printer or the system disk goes
        ;;offline, a message is printed on the designated error printer, usually
        ;;the console terminal. A write-locked system disk is also reported this
        ;;way.  Secondly, caretaker records other types of disk errors, as well
        ;;as magnetic tape drive errors, in the ^SYS global.  Thirdly, caretaker
        ;;can optionally log software errors in routines that have $ZT set to the
        ;;^%ET routine.  This optional software error logging requires the JOBCOM
        ;;system feature (selectable at SYSGEN), and a designated JOBCOM channel,
        ;;which you specify at start-up (STUBLD). Software errors are logged into
        ;;the ^%ER global.
        ;;
        ;;Stop:   This option stops the monitoring of the system status  by  the
        ;;Caretaker Background job. The system operator will not be notified  of
        ;;any special conditions and errors will no longer be logged.
        ;;
        ;;Print hardware errors: Uses ^KTR to print hardware errors.
        ;;
        ;;Erase hardware errors:  Purges the ^SYS global of no-longer-needed
        ;;hardware error information, specified by date.
        ;;
        ;;Change error printer:  The error printer for Caretaker and DDP will
        ;;be changed in memory only. The printer specified in the startup command
        ;;will NOT be changed. Use ^STUBLD to change the startup command file.
        ;;
        ;;Print disk error summary:  This report collates logged disk errors
        ;;by disk drive and read/write head so that you can anticipate failing
        ;;disk read/write heads before they fail completely.
        ;;
        ;;Software error log:  Use routine %ER to show software errors, or to
        ;;re-load the symbol table and routine where a particular error occured.
END     ;;End of help text.
