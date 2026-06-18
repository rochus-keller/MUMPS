SGOPTS  ;28-Apr-83 ;UTILITIES ;SYSGEN ;DEFINE SYSTEM SOFTWARE OPTIONS ;JHM
        Q
START   W !,"PART 7:",?10,"SOFTWARE OPTIONS",!,"-------",!
        S ^SYS(ID,"OPTIONS","TTY")="Y",^("CONFIG")="N"
        F MOD=1:1:$P($T(MOD)," ",2) D  I %A S MOD=MOD-2 G:MOD<0 RETURN
        .S TAB=$T(MOD+MOD),OPT=$P(TAB,";;",3),NAME=$P(TAB,";;",2)
        .S SETDEF=$P(TAB,";;",4),MODSUB=$P(TAB,";;",5),OPTSHO=$P(TAB,";;",6)
        .S QUES=OPT X:EXTH ^%Q("EXTH")
        .I '$D(^SYS(ID,"OPTIONS",OPT))!SOFT D @SETDEF
        .I SOFT D @OPTSHO W ! S %A=0 Q
GETOPT  .S QUES=OPT,DEF=^SYS(ID,"OPTIONS",OPT) X ^%Q("SGASKYN") Q:%A
        .I "YN"'[ANS D IV G GETOPT
        .S ^SYS(ID,"OPTIONS",OPT)=$E(ANS)
        .D @MODSUB G:%A GETOPT Q
DONE    K MOD,SETDEF,OPT,ADR,CON,TAB,LOAD,USRADR,NAME,NEED,MODSUB,OPTSHO,DDBSIZ,DRVLN,SIZ
        D START^SGMEM I %A G START:'SOFT
RETURN  Q
USRSPC  D INIT^LOADR S DRV="",NEED=0
        V ST+148\1024+2:"S0" S SIZ=$V(ST+148#1024,0)*64
        F CNT=0:0 S DRV=$O(^SYS(ID,"DRIVERS",DRV)) Q:DRV=""  I ^(DRV)="Y" D
        .I 'NEED W ?6,"The selected loadable drivers are:",!!?6,"Driver",?15,"Bytes/Driver",?30,"Bytes/Unit",!?6,"------",?15,"-----
-------",?30,"-----------",! S NEED=1
        .D FINDR^LOADR I CON'=0  W ?6,DRV,?18,DRVLN-DDBSIZ+4,?30,DDBSIZ,!
        I $E(ANS)="N" W:NEED !,"Note: You will not be able to use your TU58, RX02 or BISYNC driver without this option",! Q
        S DEF=^SYS(ID,"MEM.ALLOC","USRDRV"),QUES="DRV" X ^%Q("SGASK") Q:%A
        I ANS'?1N.N D IV G USRDRV
        I ANS>(8192-SIZ) W !?6,"Only ",(8192-SIZ)," bytes of memory may used for LOADABLE DRIVERS",!?6,"The remaining space will sti
ll be allocated.",!
        S ^SYS(ID,"MEM.ALLOC","USRDRV")=ANS Q
JOBCMR  I $E(ANS)="N" S ^SYS(ID,"OPTIONS",OPT)="Y" Q  ;; do not change thisfor V3.1
        Q:$E(ANS)="N"  S DEF=^SYS(ID,"JOBCOM","CHANNELS"),QUES="CHANS" X ^%Q("SGASK") Q:%A
        I ANS'?1N.N!(ANS<0)!(ANS>16) D IV G JOBCOM
        S ^SYS(ID,"JOBCOM","CHANNELS")=ANS
RBSIZ   S DEF=^SYS(ID,"JOBCOM","RBSIZE"),QUES="RING" X ^%Q("SGASK") G:%A JOBCOM
        I ANS'?1N.N!(ANS<2)!(ANS>255) D IV G RBSIZ
        S ^SYS(ID,"JOBCOM","RBSIZE")=ANS Q
SDPR    S ^SYS(ID,"OPTIONS","SDP")="Y" Q
JRNLR   I $E(ANS)="N" S ^SYS(ID,"MEM.ALLOC","JOURNAL BUFFERS")=0 Q
        S DEF=^SYS(ID,"MEM.ALLOC","JOURNAL BUFFERS"),QUES="JBS" X ^%Q("SGASK") Q:%A
        I ANS'?1N.N!(ANS<1)!(ANS>99) D IV G JRNL
        S ^SYS(ID,"MEM.ALLOC","JOURNAL BUFFERS")=ANS Q
TABSPC  S ^SYS(ID,"MEM.ALLOC","TRANSLATION TABLE")=$E(ANS)="Y"*1280 Q
RMPSPC  S:$E(ANS)="N" ^SYS(ID,"MEM.ALLOC","ROUTINE MAP")=0 Q
NOP     Q
SETY    S ^SYS(ID,"OPTIONS",OPT)="Y" Q
SETN    S ^SYS(ID,"OPTIONS",OPT)="N" Q
SETJRN  S ^SYS(ID,"MEM.ALLOC","JOURNAL BUFFERS")=2 G SETY
SETJOB  S ^SYS(ID,"JOBCOM","CHANNELS")=16,^("RBSIZE")=64 G SETY
SETMNT  S ^SYS(ID,"MEM.ALLOC","UCITAB")=1024*8 G SETY
SETAB   S ^SYS(ID,"MEM.ALLOC","TRANSLATION TABLE")=1280 G SETY
SETMAP  S ^SYS(ID,"MEM.ALLOC","ROUTINE MAP")=0 G SETN
SETDRV  Q
JBCSHO  D SHODEF W !?2,"With ",^SYS(ID,"JOBCOM","CHANNELS")," communication channels"
        W !?2,"and a ",^("RBSIZE")," byte default ring buffer size" Q
JRNSHO  D SHODEF W !?2,"With ",^SYS(ID,"MEM.ALLOC","JOURNAL BUFFERS")," buffers" Q
USRSHO  D SHODEF I ^SYS(ID,"OPTIONS","USRDRV")="Y" W !?2,"with ",^SYS(ID,"MEM.ALLOC","USRDRV")," bytes for TU58, RX02 or BISYNC supp
ort"
        Q
SHODEF  W !?2,NAME," support:",?50,$S(^SYS(ID,"OPTIONS",OPT)="Y":" ",1:" Not "),"Included" Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
SDP     ;;0
JRNL    ;;0
SPOOL   ;;0
JOBCOM  ;;0
USRDRV  ;;0
RMAP    ;;0
TRANTAB ;;0
MOUNT   ;;0
        W !,"7.",MOD,?6,"Include support for ",NAME Q
CHANS   ;;0
        W ?6,"How many communication channels do you want" Q
RING    ;;0
        W ?6,"Enter the size, in bytes, for each RING BUFFER channel" Q
JBS     ;;0
        W ?6,"Enter the number of DISK-TAPE buffers to allocate to JOURNAL" Q
DRV     ;;0
        W !?6,"Enter BYTES to allocate for LOADABLE DRIVERS" Q
CHANSH  ;;0
RINGH   ;;0
JBSH    ;;0
        S TAG=QUES_"H" D TEXT^SGMEM Q
DRVH    ;;0
SDPH    ;;0
JRNLH   ;;0
SPOOLH  ;;0
JOBCOMH ;;0
USRDRVH ;;0
RMAPH   ;;0
TRANTABH        ;;0
MOUNTH  ;;0
HELP    S TAG=QUES_"H" D TEXT^SGOPTH Q
MOD     8
        ;;SEQUENTIAL DISK PROCESSOR;;SDP;;SETY;;SDPR;;SHODEF
        ;;JOURNAL;;JRNL;;SETJRN;;JRNLR;;JRNSHO
        ;;SPOOLING;;SPOOL;;SETN;;NOP;;SHODEF
        ;;INTERJOB COMMUNICATIONS;;JOBCOM;;SETJOB;;JOBCMR;;JBCSHO
        ;;LOADABLE or USER DRIVER SPACE;;USRDRV;;SETDRV;;USRSPC;;USRSHO
        ;;MAPPED ROUTINES;;RMAP;;SETMAP;;RMPSPC;;SHODEF
        ;;UCI TRANSLATION TABLES;;TRANTAB;;SETAB;;TABSPC;;SHODEF
        ;;MOUNTABLE DATABASE VOLUME SETS;;MOUNT;;SETMNT;;RMPSPC;;SHODEF
