SPL     ;DSM11 Utilities; Copyright 1980 DEC
        Q
SPON    I $V($V(44)+35)#2 W !," -- Can't while running the baseline system.",!!
        I  G DONE
        D INIT I SP W !,"SPOOLING is already enabled" G FAIL
        S SDO=1
S2      S QUES="D2" D ASKY I %A S ^("DESPOOLER")="N" G FAIL
        S ^("DESPOOLER")=ANS G DO:ANS="N"
GETD    S QUES="DFD",DEF=^SYS(0,"STARTUP","DEFAULT SPOOL DEVICE") D EN
        I ANS="N"!%A S ^("DESPOOLER")="N" G S2:SDO,FAIL
        I ANS'?1N.N D IV G GETD
        I ANS=1!($D(^SYS(^SYS(0,"RUNNING"),"TTY",ANS))'>1) D DFDH G GETD
        I ^(ANS,"OUTPUT ONLY")'="Y" D DFDH G GETD
        S ^SYS(0,"STARTUP","DEFAULT SPOOL DEVICE")=ANS
DO      G DO2:'SDO D SPLDO^STU4 G FAIL:%FAIL S ^SYS(0,"STARTUP","SPOOLING")="Y"
        W !,"Spooler has been started."
DO2     G DONE:^SYS(0,"STARTUP","DESPOOLER")'="Y" D DSPLDO^STU4 G FAIL:%FAIL
        W !,"Despooler has been started." G DONE
DSON    I $V($V(44)+35)#2 W !," -- Can't while running the baseline system.",!!
        I  G DONE
        D INIT S SDO=0
        I 'SP W !,"SPOOLER is not active - cannot start the "
        I  W "DESPOOLER",! G FAIL
        I DSP W !,"The Despooler is already running.",! G DONE
        S ^("DESPOOLER")="Y" G GETD
DSOF    D INIT I 'DSP W !,"The Despooler is not running." G FAIL
        S ^("DESPOOLER")="N" V $V(ST+230)::0 W !,"The Despooler has been shut down." G DONE
SPOF    D INIT I 'SP W !,"Spooling is not currently enabled." G FAIL
        I DSP W !,"You must shut down the Despooler before you can shut "
        I  W "down Spooling." G FAIL
        S DEVTAB=$V(ST+8),DDB=$V(ST+10)+$V(ST+68),DFD=$V(DDB+18)
        V DEVTAB+2::$V(DEVTAB+3)*256+255
        I DFD#2 V DEVTAB+DFD-1::$V(DEVTAB+DFD-1)#256
        I DFD,DFD#2=0 V DEVTAB+DFD::$V(DEVTAB+DFD+1)*256
        S ^("SPOOLING")="N" W !,"Spooling has been shut down." G DONE
FAIL    ;
DONE    W ! Q
INIT    S SP=^SYS(0,"STARTUP","SPOOLING")="Y",DSP=^("DESPOOLER")="Y"
        S ST=$V(44),%FAIL=0 Q
IV      W !,"Incorrect response - enter '?' for more information",! Q
DFD     W "Enter the default spool device number" Q
DFDH    W !,"The default spool device must be an output-only terminal or a "
        W "line printer.",! Q
D2      W !,"Start the Despooler, too" Q
D2H     W !,"The Spooler simply routes the output to disk.  The Despooler is "
        W "the job",!
        W "that prints this output on the default output device.",! Q
EN      S QMK="",%YN="" G SAYQ
ASKY    S DEF="Y" G ASKYN
ASKN    S DEF="N"
ASKYN   S QMK=" ?",%YN=" [Y OR N]" G SAYQ
ASK     S QMK=" ?",%YN=""
SAYQ    D @QUES W %YN,QMK,"  " W:DEF'="" "<",DEF W ">   " R ANS,!
        I ANS="?" D:$L($T(@(QUES_"H"))) @(QUES_"H") G SAYQ
        S %A=0 S:ANS="^" %A=1 S:ANS="" ANS=DEF Q:%YN=""
        S ANS=$E(ANS,1) Q:"YN^"[ANS  D VALID^SYSROU G SAYQ
