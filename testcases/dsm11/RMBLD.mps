RMBLD   ;24-Jun-83 ;UTILITIES ;ROUTINE MAP ;BUILDS A ROUTINE MAP ST ;JHM
        S $ZT="ERROR^RMBLD"
EN      W !,"Create, Edit, or Delete a Routine Set",!
        D CHKRM G EXIT:%A
EN1     S %SYS=$P($ZU(0),",",2),%UCI="",SETNAM="",EXTH=0
Q0      D GETNAM G:%A EXIT I SETNAM="*" G DELALL
        G:'$D(^SYS(0,"ROUTINE MAP",SETNAM)) Q1
        S %UCI=$P(^(SETNAM),",",2),%SYS=$P(^(SETNAM),",",3)
        D SETDEF
Q01     S DEF="E",QUES="ED" X ^%Q("SGEN") G:%A Q0 G:ANS="E" CHK
        I ANS'="D" D IV G Q01
        D SHOKIL G EN1
Q1      S DEF=%UCI,QUES="UCI" X ^%Q("SGEN") G:%A Q0
        I ANS'?1U2NU D IV G Q1
        S %UCI=ANS
Q2      S DEF=%SYS,QUES="SYS" X ^%Q("SGEN") G:%A Q1
        I ANS'?1U2NU D IV G Q2
        S %SYS=ANS
CHK     D GETUCN G EN1:'UCN
        K ^UTILITY($J)
        S RNAM="" F I=0:1 S RNAM=$O(^SYS(0,"ROUTINE MAP",SETNAM,RNAM)) Q:RNAM=""  S ^UTILITY($J,RNAM)=""
        W !,"Enter routines names to add or delete"
        I I W !,"Type ? for HELP" S ^UTILITY($J)="%RSEL"
        W ! D ^%RSEL
        S RNAM="",SUM=0 K ^SYS(0,"ROUTINE MAP",SETNAM)
        F RNUM=0:1 S RNAM=$O(^UTILITY($J,RNAM))  Q:RNAM=""  S ^SYS(0,"ROUTINE MAP",SETNAM,RNAM)="",SUM=$P(^[%UCI,%SYS] (RNAM),",",3)
+63\64*64+SUM
        I 'RNUM D SHOKIL G EN1
        S ^SYS(0,"ROUTINE MAP",SETNAM)=RNUM_","_%UCI_","_%SYS
        S SUM=RNUM+1\2*2*2+63\64*64+SUM
        S SUM=RNUM+1\2*2*8+63\64*64+SUM
        D SHODON G EN1
GETNAM  S DEF=SETNAM,QUES="SET" X ^%Q("SGEN") Q:%A  I ANS="" S %A=1 Q
        I ANS="*" S SETNAM=ANS Q
        I ANS="^L" S ANS="" D  G GETNAM
        .W ! F I=0:1 S ANS=$O(^SYS(0,"ROUTINE MAP",ANS)) Q:ANS=""  W ?$X+9\10*10,ANS W:$X>60 !
        .W ! W:'I !,"No ROUTINE MAPS defined",!
        I ANS'?1.10NU D IV G GETNAM
        S SETNAM=ANS
        I $D(^SYS(0,"ROUTINE MAP",SETNAM)) S %SYS=$P(^(SETNAM),",",3),%UCI=$P(^(SETNAM),",",2)
        Q
ERROR   I $ZE["<INRPT" W !,"RMBLD aborted"
        E  W !,$ZE
        G RESET
EXIT    K %UCI,SETNAM,%SYS,UCN,ANS,RNAM,RNUM,QUES,DEF,ST,EXTH
RESET   Q
CHKRM   S ST=$V(44) I $V(ST+38) S %A=0 Q
        I $V(ST+35) W !,"This utility may not be used in baseline mode",! S %A=1 Q
        W !,"Mapped Routine Support was not included in this configuration."
        W !,"You may run SYSGEN to include support.",! S %A=1 Q
SETDEF  W !,"Set, ",SETNAM,", is defined for ",$P(^SYS(0,"ROUTINE MAP",SETNAM),",",2,3),! Q
SHODON  W !,"Routine Set:",?22,$J(SETNAM,12)
        W !,"Number of routines:",?22,$J(RNUM,12)
        W !,"Size of Routine Set:",?22,$J(SUM,12)," bytes",! Q
SHOKIL  W !,"MAPPED ROUTINE SET, ",SETNAM,", deleted",!
        K ^SYS(0,"ROUTINE MAP",SETNAM) Q
DELALL  W !,"Are you sure you want to delete all mapped routine sets ? "
        R ANS I ANS="Y"!(ANS="y") K ^SYS(0,"ROUTINE MAP") W " - done." G EN
        W " - no action taken." G EN
IV      W !,"Invalid response - type ? for help",! Q
GETUCN  S $ZT="CHKUCI",UCN=$ZU(%UCI,%SYS),UCN=$P(UCN,",",2)*32+UCN
        Q
CHKUCI  W ! I $ZE["<NOUCI" W !,"The UCI, ",%UCI,","
        E  I $ZE["<NOSYS" W !,"The Volume Set, ",%SYS,","
        E  W !,$ZE ZQ
        W " is not in the current configuration",! S UCN=0,%A=1 Q
UCI     ;;1
        ;;Enter the UCI name in which the routines reside
UCIH    ;;4
        ;;Enter the UCI name which holds the routines you wish to
        ;;include in the ROUTINE SET.  The UCI must currently be
        ;;loaded.  A UCI name must contain 3 UPPER CASE characters.
        ;;
SET     ;;1
        ;;Enter the ROUTINE SET name
SETH    ;;13
        ;;A ROUTINE SET is a list of routines which can be mapped into
        ;;memory.  Each SET is associated with a UCI and VOLUME SET
        ;;name allowing you to create a separate set for each UCI
        ;;in your system.
        ;;
        ;;Enter the name that is associated with this ROUTINE
        ;;SET.  This name is used in all references to
        ;;specify this ROUTINE SET.  The name may not exceed 10
        ;;characters.  Specify "*" to select all routine sets.
        ;;
        ;;Type ^L to get a list of currently defined ROUTINE SETS.
        ;;Type ^ to go back to the previous question.
        ;;
SYS     ;;1
        ;;Enter the VOLUME SET name in which the routines reside
SYSH    ;;4
        ;;Enter the 3 character VOLUME SET name which holds the
        ;;routines to include in the ROUTINE SET.  The VOLUME SET must
        ;;currently be loaded.
        ;;
ED      ;;1
        ;;Edit or Delete this Routine Map [E or D]
EDH     ;;5
        ;;Enter E if you wish to edit the UCI, VOLUME SET or contents
        ;;of this routine map.
        ;;
        ;;Enter D if you wish to delete this routine map entirely.
        ;;
