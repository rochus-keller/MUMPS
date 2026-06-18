STUBLD  ;BUILD A STARTUP COMMAND FILE  11-JUL-80
        I '$D(^SYS(0,"DEFAULT")) W !,"^SYS GLOBAL NOT CREATED.  PLEASE DO ^SYSGEN." Q
        W !,"Begin defining a new startup command file.",!
QCONF   W !,"Configuration ? <",^SYS(0,"DEFAULT"),">  " R ID Q:ID="^"
        I ID="?" W !,"The currently defined configurations are:",!! D  G QCONF
        .S ID=0 F %I=0:0 S ID=$O(^SYS(ID)) Q:ID=""  W ?5,ID,!
        I ID="" S ID=^SYS(0,"DEFAULT") W ID
ENTER   W ! I '$D(^SYS(ID)) W !,ID," is not a defined configuration, type ? for Help" G QCONF
        I $D(^SYS(ID,"STARTUP")) D VERIFY^STU S DEV=DSD,ELDEV=$S(ELOG="N":"",1:ELOG),ELOG=$S(ELOG="N":"N",1:"Y")
        I '$D(^SYS(ID,"STARTUP")) S (MAP,PAT,JRN,SPL,DSPL,DDP,ELOG,LOADR,MNT)="N",(JSN,DEV,ELDEV,DSD)="",CTK="Y",EDEV=1
        E  D VERIFY^STU S DEV=DSD,ELDEV=$S(ELOG="N":"",1:ELOG),ELOG=$S(ELOG="N":"N",1:"Y")
PA      S QUES="PATCH^STUBLDH",DEF=PAT X ^%Q("ASKYN") G:%A QCONF S PAT=ANS
JN      I ^SYS(ID,"OPTIONS","JRNL")="N" G:%A PA S JSN="",JRN="N" G SPLR
        S QUES="JRNL^STUBLDH",DEF=JRN X ^%Q("ASKYN") G:%A PA S JRN=ANS
        I JRN="N" S JSN="" G SPLR
        I ^SYS(ID,"OPTIONS","MAGTAPE")'="Y" G JS
JD      S QUES="JDEV^STUBLDH",DEF=$S(JSN?1N:"M",1:"D") X ^%Q("ASK")
        G:ANS=""!%A JN S ANS=$E(ANS,1) G JTOM:ANS="M",JD:ANS'="D"
JS      S QUES="JNAM^STUBLDH",DEF="" I JSN?1A.E S DEF=JSN
        X ^%Q("ASK") G JN:ANS=""!%A,JNSET:ANS?1A.ANP!(ANS?1"*"1N.N1"-"1A.ANP)
        W !,"** Illegal Journal Space name",! G JS
JTOM    S QUES="JMAG^STUBLDH",DEF="" S:JSN?1N DEF=JSN X ^%Q("ASK")
        G JN:ANS=""!%A,JTOM:ANS'?1N!(ANS>3)
JNSET   S JSN=ANS
SPLR    S ANS="N" I ^SYS(ID,"OPTIONS","SPOOL")="N" G:%A JN
        E  S QUES="SPOOL^STUBLDH",DEF=SPL X ^%Q("ASKYN") G:%A JN
        S SPL=ANS I ANS="N" S DSPL="N",DSD="" G STDDP
DSP     S QUES="DSPLR^STUBLDH",DEF=DSPL X ^%Q("ASKYN") G:%A SPLR
        S DSPL=ANS G:ANS="N" STDDP
DSPDEV  S DEF=DEV,QUES="DEFSPL^STUBLDH" X ^%Q("EN") I ANS=""!%A G DSP
        I ANS=1!'$D(^SYS(ID,"TTY",ANS)) D IV G DSPDEV
        I ^SYS(ID,"TTY",ANS,"OUTPUT ONLY")'="Y" D IV G DSPDEV
        S DSD=ANS
STDDP   I ^SYS(ID,"OPTIONS","DDP")="N" G:%A SPLR G CTK^STUBLD2
        S QUES="DDPJ^STUBLDH",DEF=DDP X ^%Q("ASKYN") G:%A SPLR S DDP=ANS G:ANS="N" ^STUBLD2
STSRV   S QUES="SERV^DDPUTL",DEF=^SYS(ID,"DDP","SERVERS") X ^%Q("EN") G:%A STDDP
        I ANS'?1N.N D IV G STSRV
        S ^SYS(ID,"DDP","SERVERS")=ANS G ^STUBLD2
IV      W !,"Invalid response - type  ?  for Help",!! Q
IDHLP   W !,"Your currently defined configurations are:",! S ID=0
NEXT    S ID=$N(^SYS(ID)) G:ID=-1 QCONF W ?5,ID,! G NEXT
