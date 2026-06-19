STUBLD2 ;18-Jul-83 ;UTILITIES ;STARTUP COMMAND FILE BUILDER ;PART 2 ;JHM
CTK     S QUES="CTKR^STUBLDH",DEF=CTK X ^%Q("ASKYN") G:%A STDDP^STUBLD S CTK=ANS
LOADR   I ^SYS(ID,"OPTIONS","USRDRV")="N" G:%A CTK G EDEV
        K DRV S QUES="USRDRV^STUBLDH",DEF=LOADR X ^%Q("ASKYN") G:%A CTK
        S LOADR=ANS G EDEV:ANS="N"
        S DRV="",QUES="DRIVER^STUBLDH"
LOAD2   F I=0:0 S DRV=$O(^SYS(ID,"DRIVERS",DRV)) Q:DRV=""  I ^(DRV)="Y" D  G:%A LOADR
        .S DEF="Y" I $D(^SYS(ID,"STARTUP","DRIVER",DRV)) S DEF=^(DRV)
        .X ^%Q("ASKYN") Q:%A  S DRV(DRV)=ANS
EDEV    S DEF=1,QUES="ERDEV^STUBLDH" X ^%Q("EN")
        I %A G CTK:^SYS(ID,"OPTIONS","USRDRV")="N",LOADR
        I ANS'?1N.N!'$D(^SYS(ID,"TTY",ANS)) D IV G EDEV
        S EDEV=ANS
ELOG    S QUES="ELOGG^STUBLDH",DEF=ELOG X ^%Q("ASKYN") G CTK:%A S ELOG=ANS G RMAP:ANS="N"
        I CTK'="Y"!(^SYS(ID,"OPTIONS","JOBCOM")'="Y") D ELOGH1^STUBLDH S ELOG="N" G ELOG
ELD     S QUES="ELD^STUBLDH",DEF=ELDEV X ^%Q("EN") G ELOG:%A S ELD=ANS G:ELD="" ELOG
        I ELD<225!(ELD>(^SYS(ID,"JOBCOM","CHANNELS")*2+223))!(ELD#2=0) D ELDH^STUBLDH G ELD
RMAP    I ^SYS(ID,"OPTIONS","RMAP")="N" G:%A ELOG G MOUNT
        S DEF=MAP,QUES="RMAP^STUBLDH" X ^%Q("ASKYN") G:%A ELOG S MAP=ANS G:ANS="N" MOUNT
        S NAM="",QUES="IMAP^STUBLDH"
RMAP2   S NAM=$O(^SYS(0,"ROUTINE MAP",NAM)) G:NAM="" MOUNT S DEF="N"
        I $D(^SYS(ID,"STARTUP","ROUTINE MAP",NAM)) S DEF=^(NAM)
        X ^%Q("ASKYN") G:%A RMAP S MAP(NAM)=ANS G RMAP2
MOUNT   I ^SYS(ID,"OPTIONS","MOUNT")="N" G:%A RMAP G SD
        S QUES="MNT^STUBLDH",DEF=MNT X ^%Q("ASKYN") G:%A RMAP S MNT=ANS G:ANS="N" SD
        W !,"Enter the disk mounting information."
        W !,"    Type ? for help",! D TYPES^DPBEGIN S DSK=""
MNTHD   W !,"DISK",?8," DATABASE  ",?23,"LABEL/VOLUME"
        W !,"UNIT",?8,"VOLUME SET?",?23,"  SET NAME  "
        W !,"----",?8,"-----------",?23,"------------"
        F I=0:0 S DSK=$O(DSK(DSK)) Q:DSK=""  W !,DSK,?12,$P(DSK(DSK),"^"),?23,$P(DSK(DSK),"^",2) I $P(DSK(DSK),"^",3)'="" W ?33,"Alternate name: ",$P(DSK(DSK),"^",3)
MNTDSK  R !,DSK G:DSK="^" MNTBK G:DSK="?" MNTH I DSK="" W ! G SD
        I $E(DSK)="-" S DSK=$E(DSK,2,4) G:'$D(DSK(DSK)) MNTDSK W ?12,$P(DSK(DSK),"^"),?23,$P(DSK(DSK),"^",2),?33," - removed from startup list" K DSK(DSK) G MNTDSK
        F I=1:1:$L(TYPES) I $E(DSK,1,2)=$P(TYPES,",",I),$E(DSK,3)<8 G MNTYP
        D IV G MNTDSK
MNTYP   R ?12,MTYP G:MTYP="^" MNTBK G:MTYP="?" MNTH
        I MTYP="" G:'$D(DSK(DSK)) MNTYP S MTYP=$P(DSK(DSK),"^") W MTYP G LAB
        I "YN"'[MTYP D IV W !,DSK G MNTYP
LAB     R ?23,LAB G:LAB="^" MNTBK G:LAB="?" MNTH
        I LAB="" G:'$D(DSK(DSK)) LAB S LAB=$P(DSK(DSK),"^",2) W LAB
        I MTYP="Y",LAB'?3U W !!,"Volume Set names must be 3 uppercase alphabetics",! G RWRT
        I MTYP="Y" S N=LAB D CHKNM I %A D  G:%A RWRT
ALAB    .R ?33,"Alternate Volume set name > ",N I N="^"!(N="") S %A=1 Q
        .I N="?" D ALAB^STUBLDH W ! G ALAB
        .I N'?3U D IV G ALAB
        .D CHKNM I %A W !,"Alternate name must be unique",! G ALAB
        .S LAB=LAB_"^"_N,%A=0
        I MTYP="N",$L(LAB)>24!($E(LAB)'="""")!($E(LAB,$L(LAB))'="""") W !!,"Labels must be 1-22 characters enclosed in quotes",! G RWRT
        S DSK(DSK)=MTYP_"^"_LAB G MNTDSK
RWRT    W !,DSK,?12,MTYP G LAB
MNTH    D MOUNTH^STUBLDH S DSK="XXX" G MNTHD
MNTBK   W !! G MOUNT
CHKNM   S A="",%A=0 F I=0:0 S A=$O(DSK(A)) Q:A=""  S %A=$P(DSK(A),"^",2)=N Q:%A
        Q
SD      S QUES="STUDF^STUBLDH" X ^%Q("ASKY") G MOUNT:%A,CMMND:ANS="N" D DATIM
        S ^SYS(ID,"STARTUP","CREATED")=DATIM D WRTCMD
DF      I ID'=^SYS(0,"DEFAULT") S QUES="IDEF^STUBLDH" X ^%Q("ASKN") I ANS="Y" S ^SYS(0,"DEFAULT")=ID
CMMND   Q
WRTCMD  S ^SYS(ID,"STARTUP","PATCHED")=PAT,^("JOURNAL")=JRN,^("SPOOLING")=SPL
        S ^("DESPOOLER")=DSPL,^("JOURNAL SPACE NAME")=JSN
        S ^("DEFAULT SPOOL DEVICE")=DSD,^("DDP")=DDP,^("CARETAKER")=CTK
        S ^("CARETAKER PRINTER")=EDEV,^("ERR JCDEV")=$S(ELOG="Y":ELD,1:"N")
        S ^("DRIVER")=LOADR K ^("ROUTINE MAP"),^("MOUNT") S ^SYS(ID,"STARTUP","ROUTINE MAP")=MAP,^("MOUNT")=MNT,(MAP,DRV,DSK)=""
        F I=0:0 S DRV=$O(DRV(DRV)) Q:DRV=""  S ^SYS(ID,"STARTUP","DRIVER",DRV)=DRV(DRV)
        F I=0:0 S MAP=$O(MAP(MAP)) Q:MAP=""  S ^SYS(ID,"STARTUP","ROUTINE MAP",MAP)=MAP(MAP)
        F I=0:0 S DSK=$O(DSK(DSK)) Q:DSK=""  S ^SYS(ID,"STARTUP","MOUNT",DSK)=DSK(DSK)
DATIM   S %DT=$P($H,",",1) D %CDS^%H S %TM=$P($H,",",2) D %CTS^%H S DATIM=%DAT1_" "_%TIM Q
IV      W !,"Invalid response - type  ?  for Help",!! Q
