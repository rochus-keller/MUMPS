SSD     ;DSM11 UTILITIES; COPYRIGHT 1980 DEC; SHUT DOWN SYSTEM
        S %ALRED=0
        S ID=^SYS(0,"RUNNING") I ID="" W !,"Can't shut down from baseline" Q
        D CHKSYS^SYSROU Q:%A
START   K (%ALRED,ID) S ST=$V(44),$ZT="ABO^SSD"
        V ST::64 I $V(ST+204)\8#2 V ST+204::$V(ST+204)-8
SYSWAIT D QUIET^SYSWAIT I %FAIL W !,"Important system processes are still active, please wait",! G SYSWAIT
        S CT=0
        S DT=$V($V(44)+8),PT=$V($V(44)+6)
        S JOB=%JO F J=0:1 S J(J)=$P(JOB,",",1),JOB=$P(JOB,",",2,99) Q:J(J)=""
        D RELSYS^SYSWAIT
        U 0 G ASKO:%ALRED
        W ! W:'J "NO" W:J J W " JOB" W:J=1 " IS" W:J'=1 "S ARE"
        W " CURRENTLY LOGGED IN.",!
        W "LOGINS ARE NOW DISABLED."
        S %ALRED=1
ASKO    S QUES="EQ",DEF="" D EN I ANS=""!%A G RETURN
        I ANS'?1N!(ANS=0)!(ANS>3) D IV G ASKO
        I ANS=1 D %SSD^BACKLOGO G START
        I ANS=3 G SHUT
TIMED   S QUES="MIQ",DEF="" D ASK G START:ANS=""!%A I ANS'?.N!'ANS D IV G TIMED
        S MINS=ANS
SEND    S QUES="MSGQ",DEF="ALL" D ASK G TIMED:%A
        K J S ALL=0,N=1,J(1)=$J G S2:ANS="NONE" I ANS="ALL" S ALL=1 G S2
        I ANS?1"*".E S ANS=$E(ANS,2,255),ALL=-1,N=0
        F I=1:1 S J=$P(ANS,",",1) Q:J=""  Q:J'?.N!(J<1)!(J>63)  S N=N+1,J(N)=J,ANS=$P(ANS,",",2,255)
        I ANS'=""!'N D IV G SEND
        F I=1:1:N F K=I+1:1:N I J(I)=J(K) D IV G SEND
S2      S QUES="LOG" D ASKN G SEND:%A
        S STA=(ANS="N"*64)
        G WAIT
WAIT    V $V(44)::STA B 1
        S T0=$P($H,",",2),TEND=MINS*60+T0 G W3
W2      S T=$P($H,",",2) S:T<T0 T=86400+T
        I TEND-T>(60*MINS) H 10 G W2
        G SHUT:MINS<1
W3      I 'ALL F I=1:1:N S J=J(I) I $V(PT+J+J) D SAY
        I ALL F J=1:1:63 I $V(PT+J+J) D SAYE
        I MINS>10 S MINS=MINS-1\5*5
        E  S MINS=MINS-1
        G W2
SHUT    V $V(44)::64 D QUIET^SYSWAIT
        S JOLI=%JO G ALOF:%JO="" D %SSD^BACKLOGO
        W !!,"DO YOU WISH TO KILL THESE JOBS AND SHUT DOWN NOW (10 SECONDS "
        W "TO ANSWER)",!,"  [ Y/N ] ?  <Y>   "
        R ANS:10 G YES:'$T G YES:"YES"[ANS G ABO3
YES     W ! D STOP^CARE W ! H 2 D STPDDP^DDPLNK
Y0      S JOB=$P(JOLI,",",1),JOLI=$P(JOLI,",",2,99)
        D SHUTJ^RJD
Y1      I $V(ST+74)#256 H 1 G Y1
        W !,"... JOB # ",JOB," HAS BEEN KILLED"
        G Y0:JOLI'=""
ALOF    I $V(ST+410) D BAKSTOP^JRNSTOP
        I ^SYS(0,"STARTUP","DESPOOLER")="Y" D DSOF^SPL
        I ^SYS(0,"STARTUP","SPOOLING")="Y" D SPOF^SPL
        W ! D QUIET^SYSWAIT
        I %FAIL S QUES="AGN" D ASKY G START:ANS="Y",RETURN
        V ST::64 W !!,"READY TO HALT",!
        H
EX      Q
SAYE    I ALL=-1 F I=1:1:N G EX:J(I)=J
SAY     S DEV=$V(146,J)#256 Q:DEV>255!'DEV  Q:$V(DT+DEV)#256\2'=J
        ZU DEV:(:::::32) W !,$C(7),"** SYSTEM GOING DOWN IN ",MINS," MINUTE"
        W:MINS'=1 "S" W " **",$C(7),!
        U 0 Q
RETURN  ;
        O 46 V ST::0 C 46
        B 1
        Q
ABO     S MS=$ZE,$ZT="ABO^SSD",CT=CT+1
ABO2    U 0 W !,MS
ABO3    U 0 W !,"SHUTDOWN ABORTED",!
        G RETURN
IV      W !,"Invalid response - enter '?' for more information",! Q
EQ      W !!,?4,"1.  Display Logged-In Jobs",!
        W ?4,"2.  Perform Timed Shutdown",!
        W ?4,"3.  Terminate All Jobs, Perform Immediate Shutdown",!!
        W "ENTER OPTION" Q
EQH     W !,"TYPE  <CR>  IF YOU DO NOT WISH TO SHUT DOWN DSM.  IF YOU DO "
        W "WISH TO",!
        W "SHUT DOWN, YOU MAY ENTER OPTION 2 AND YOU WILL BE ASKED 'HOW",!
        W "LONG BEFORE SHUTDOWN', AND WHETHER TO BROADCAST A MESSAGE, ETC.",!! Q
FAIL    Q:%FAIL=-1!(%FAIL=1)
        U 0 W !,"** SYSTEM STILL ACTIVE -- PLEASE TRY AGAIN",! Q
MIQ     W !,"HOW MANY MINUTES TILL SHUTDOWN" Q
MIQH    W !,"Enter '^' if you have changed your mind and do not wish to "
        W "shut down",!,"the system.",! Q
MSGQ    W !,"Broadcast 'SYSTEM GOING DOWN' messages to which jobs" Q
MSGQH   W !,"Enter 'ALL' or 'NONE', or the individual job numbers separated "
        W "by commas.",!
        W "If you wish the messages to be broadcast to all *except* "
        W "certain jobs,",!
        W "precede the list of job numbers by an asterisk, like this:",!
        W "   *4,7,22",!! Q
LOG     W !,"DO YOU WISH TO RE-ENABLE LOG-INS UNTIL SHUT-DOWN TIME" Q
LOGH    W !,"In the present state, no new jobs can log in during the "
        W MINS," minutes",!
        W "remaining till shut-down.  Answer 'Y' if you would like to "
        W "permit new",!,"log-ins during this interval.",! Q
AGN     W !!,"SYSTEM IS STILL ACTIVE -- TRY AGAIN TO SHUT DOWN" Q
AGNH    Q
EN      S QMK="",%YN="" G SAYQ
ASKY    S DEF="Y" G ASKYN
ASKN    S DEF="N"
ASKYN   S QMK=" ?",%YN=" [Y OR N]" G SAYQ
ASK     S QMK=" ?",%YN=""
SAYQ    D @QUES W %YN,QMK,"  " W:DEF'="" "<",DEF W ">   " R ANS,!
        I ANS="?" D:$L($T(@(QUES_"H"))) @(QUES_"H") G SAYQ
        S %A=0 S:ANS="^" %A=1 S:ANS="" ANS=DEF Q:%YN=""
        S ANS=$E(ANS,1) Q:"YN^"[ANS  D VALID^SYSROU G SAYQ
