STU     ;DSM-11 SYSTEM START-UP 4-JUN-80 JBH
        I '$V($V(44)+35) W "*** System not in baseline mode ***",! Q
START   S ^SYS(0,"RUNNING")="",^%Q(0,"RUNNING")="" D ^DAT,^TIM W !! I $D(%T),%T="^" G START
        I '$D(^SYS(0,"DEFAULT")) W !,"You have no defined configurations.",! G SYSGEN
DEFQ    K ^SYS(0,"STARTUP") S ID=^("DEFAULT") I '$D(^SYS(ID,"STARTUP")) D ASKDEF Q:STBAS="Y"!(STBAS="^")  D ^STUBLD Q:ID="^"  D VERI
FY G CMMND
        S QUES="DFLT" D ASKYN G:Y="^" START I Y D VERIFY G CMMND
BUILD   S QUES="BSLN" D ASKNY G DEFQ:Y="^",BASLIN:Y
CONF    R !,"Enter name of alternate configuration > ",CONF,! G BUILD:CONF=""!(CONF="^"),IDHLP:CONF="?" I '$D(^SYS(CONF)) W "Configu
ration ",CONF," does not exist.  Type '?' for help.",! G CONF
        S ID=CONF I '$D(^SYS(ID,"STARTUP")) D ENTER^STUBLD G:ID'="^" CMMND W ! G CONF
MOD     S QUES="MODF" D ASKNY G CONF:Y="^",MODFH:Y="?" I 'Y D VERIFY G CMMND
NEWC    D ENTER^STUBLD I ID="^" W ! G CONF
CMMND   D CHKVER^SYSROU G DEFQ:%A=0,SYSGEN:%A=1 D ^STUCSR G:$D(NOCSR) DEFQ D DATIM S ^SYS(0,"STARTUP","DATE-TIME")=DATIM S ZID=ID,ID
=0 D WRTCMD^STUBLD2 S ID=ZID
        G AUP:JRN'="Y",JINI:JSN'?1N
MQ      S QUES="JRNM",DEF="" X ^%Q("EN") G DEFQ:%A,MQ:ANS'="",AUP
JINI    S QUES="INQ",DEF="CONTINUE" X ^%Q("ASK") G:%A DEFQ
        I "IC"'[$E(ANS,1)!("CONTINUE"'[ANS&("INITIALIZE"'[ANS)) G JINI
        S ^SYS(0,"STARTUP","JOURNAL SPACE INIT")=$E(ANS,1)
AUP     I ^SYS(0,"STARTUP","PATCHED")="Y" D MEMPAT^AUPAT
        K (ID) G START^STU1
VERIFY  K MAP,DRV,DSK
        S PAT=^SYS(ID,"STARTUP","PATCHED"),JRN=^("JOURNAL"),SPL=^("SPOOLING")
        S JSN=^("JOURNAL SPACE NAME"),CTK=^("CARETAKER"),EDEV=^("CARETAKER PRINTER"),ELOG=$S($D(^("ERR JCDEV")):^("ERR JCDEV"),1:"N"
)
        S DSPL=^("DESPOOLER"),DSD=^("DEFAULT SPOOL DEVICE"),DDP=^("DDP"),LOADR=^("DRIVER"),MAP=^("ROUTINE MAP"),MNT=^("MOUNT"),%A=""
        F I=0:0 S %A=$O(^SYS(ID,"STARTUP","DRIVER",%A)) Q:%A=""  S DRV(%A)=^(%A)
        F I=0:0 S %A=$O(^SYS(ID,"STARTUP","ROUTINE MAP",%A)) Q:%A=""  S MAP(%A)=^(%A)
        F I=0:0 S %A=$O(^SYS(ID,"STARTUP","MOUNT",%A)) Q:%A=""  S DSK(%A)=^(%A)
        Q
BASLIN  V 2:$J:1 B 1 Q
DATIM   S %DT=$P($H,",",1) D %CDS^%H S %TM=$P($H,",",2) D %CTS^%H S DATIM=%DAT1_" "_%TIM Q
SYSGEN  I $D(^SYS(0,"DEFAULT")) S ID=^("DEFAULT") D
        .W !,ID," is the current default configuration",! D CHKVER^SYSROU
        .I %A=0 K ^SYS(0,"DEFAULT")
        .E  W "You must run SYSGEN on this configuration to make",!,"it ",$ZV," compatible.",!
        R !,"Do you wish to proceed directly to SYSGEN ? <Y> ",ANS
        I ANS=""!(ANS?1"Y".E) D ^SYSGEN G:'$D(^SYS(0,"DEFAULT")) SYSGEN G DEFQ
        I ANS?1"N".E G BASLIN
        W !!?5,"Please enter Y(ES) or N(O)",! G SYSGEN
DFLT    W "Start up the default system (",ID,")" Q
DFLTH   W !?5,"Startup will be automatic if you answer ""Y""." D UP Q
BSLN    W "Remain in baseline mode" Q
BSLNH   W !,"Baseline mode allows only MGR UCI, TTY #1, the system disk,"
        W !,"one tape drive, and one line printer. No software options are activated." D UP Q
JRNM    W !,"When Journal Tape is ready, and positioned where you want it, on"
        W !,"  Magtape Unit# ",JSN,",  type  <CR> " Q
JRNMH   W !,"Rewind it if you wish to Journal starting at the beginning." D UP Q
IDHLP   W !,"Your currently defined configurations are:",! S ID=0
NEXTID  S ID=$N(^SYS(ID)) G:ID=-1 CONF W ?5,ID,! G NEXTID
MODF    W "Modify startup command file for configuration ",ID Q
MODFH   W !,"Type 'Y' to modify the existing startup file for this configuration."
        W !,"Type 'N' or <CR> to use the existing startup file." D UP Q
UP      W !,"Type '^' to return to the previous question.",!! Q
INQ     W !,"Initialize Journal Space '",JSN,"',  or Continue-where-"
        W "left-off",!,"  [ I or C ] " Q
INQH    W "Type  'C'  if you wish the current contents of the Journal-"
        W "space * preserved *.",!
        W ?11,"Journaling will then begin following the most recent block",!
        W ?11,"Journaled into.",!!
        W "Type  'I'  to have the current contents of the space * erased *."
        W !,?11,"Journaling will then start at the beginning of the space." D UP Q
ASKYN   S DEF="Y" G YNASK
ASKNY   S DEF="N"
YNASK   D @QUES W " [Y/N] ?  <",DEF,">  " R Y,! Q:Y="^"  I "YN"'[$E(Y,1) S HROU=QUES_"H" D @HROU G YNASK
        S:Y="" Y=DEF S Y=($E(Y,1)="Y") Q
ASKDEF  R "You do not have a startup command file,",!,"Do you wish to remain in baseline mode ? <N> ",STBAS
        S:STBAS="" STBAS="N" I "YN"[$E(STBAS,1)!(STBAS="^") W ! Q
        W !!,"Enter Y or N please",!! G ASKDEF
