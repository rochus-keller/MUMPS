BACKSTR ;YZH;29-SEP-83;BACKUP START OPTION SELECTOR
START   S QUES="NMQ",DEF="" X ^%Q("EN") Q:ANS=""!%A  S NM=ANS
        I '$D(^SYS(0,"BACKUP",NM)) D NMQH G START
        I '$D(^SYS(0,"UNATTENDED BACKUP TIME")) S (^("UNATTENDED BACKUP TIME"),^("UNATTENDED BACKUP FILE"))=""
        S J=0,M=1 D DSK^DPBEGIN,TYPES^SYSROU
TEST    S J=J+1,TSIZE=0,K=0 G:'$D(^SYS(0,"BACKUP",NM,"DISK "_J)) DAT
        I ^("DISK "_J,"TO")="M" G DAT
        S TYU=^("FROM","UNIT"),DKNUM=$F(TYPES,$E(TYU,1,2))\3-1*8+$E(TYU,3)
        I '$D(DSK(DKNUM)) G ERR
        S FSIZE=$P(DSK(DKNUM)," ",5)
RP      S K=K+1,TYU=$P(^SYS(0,"BACKUP",NM,"DISK "_J,"TO","UNIT"),";",K)
        I TYU="" G:TSIZE<FSIZE Q1 G TEST
        S DKNUM=$F(TYPES,$E(TYU,1,2))\3-1*8+$E(TYU,3)
        I '$D(DSK(DKNUM)) G ERR
        S TSIZE=TSIZE+$P(DSK(DKNUM)," ",5) G RP
Q1      W !!,"YOU MAY NOT HAVE ENOUGH SPACE IN BACKUP DISK(S) TO HOLD THE"
        W !,"BACKED UP INFORMATION."
Q2      R !!,"ARE YOU SURE YOU WANT TO CONTINUE ? <N> ",ANS,!
        I ANS?1"?".E W !!,"ENTER Y(ES) OR N(O)",!  G Q2
        I ANS'?1"Y".E G START
DAT     W !!,"Backup-command-file '",NM,"' exists. Please enter the following:"
B1      G:'$D(^SYS(0,"$HLAST")) ST S %DT=$P(^SYS(0,"$HLAST"),",",1) D %CDS^%H
        W !,"Scheduled backup starting date  <",%DAT1 R "> ",%D1 S:%D1="" %D1=%DAT1 G CK
ST      R !,"Scheduled backup starting date  [ DD-MMM-YY ]  > ",%D1
CK      I %D1="^" K %D1 G START
        G HLP2:%D1="?"!(%D1="") S D=$P(%D1,"-",1),M=$P(%D1,"-",2),Y=$P(%D1,"-",3)
        G HLP2:%D1'?1N.N1"-"3A1"-"2N!'D
        F I=1:1:12 S DM(I)=$P("31-29-31-30-31-30-31-31-30-31-30-31","-",I)
        S DM(2)=(Y#4=0)+28,%M1="" F %I=1:1:3 S %C=$A(M,%I) S:%C>96 %C=%C-32 S %M1=%M1_$C(%C)
        S M=$F("JAN-FEB-MAR-APR-MAY-JUN-JUL-AUG-SEP-OCT-NOV-DEC",%M1)\4
        G HLP2:'M G HLP2:(DM(M)<D)!(Y<80)
        S H=50768
        F I=80:1:Y-1 S H=(I#4=0)+365+H
        F I=1:1:M-1 S H=H+DM(I)
        S H=H+D
TIM     R !,"Scheduled backup starting time  [ HH:MM:SS ]  > ",%T1
        I %T1="^" G START
        G HLP3:%T1'?1N.N1":"1N.N&(%T1'?1N.N1":"1N.N1":".N)!(%T1="")
        G HLP3:$P(%T1,":",2)>59!($P(%T1,":",3)>59)
        S %T=%T1*60+$P(%T1,":",2)*60+$P(%T1,":",3)
        I $D(^SYS(0,"$HLAST")) I $V($V(44)+44)=$P(^SYS(0,"$HLAST"),",",1),%T+300'>$P(^SYS(0,"$HLAST"),",",2) G CHK
ASK     S %TM=%T W !,"Is this " D CVT^%T W " in the ",$S(%T<43200:"Morning",%T>43199&(%T<64800):"Afternoon",1:"Evening") R " ? <Y> "
,A S:A="" A="Y" G TIM:A'?1"Y".E
        S TIMFL=^SYS(0,"UNATTENDED BACKUP TIME")
        F I=1:1 S DATIM=$P(TIMFL,";",I) Q:DATIM=""!($P(DATIM,",",1)>H)  I $P(DATIM,",",1)=H Q:$P(DATIM,",",2)'<%T
        S ^("UNATTENDED BACKUP TIME")=$P(^("UNATTENDED BACKUP TIME"),";",1,I-1)_$S(I-1:";",1:"")_H_","_%T_";"_$P(^("UNATTENDED BACKU
P TIME"),";",I,999)
        S ^SYS(0,"UNATTENDED BACKUP FILE")=$P(^SYS(0,"UNATTENDED BACKUP FILE"),";",1,I-1)_$S(I-1:";",1:"")_NM_";"_$P(^("UNATTENDED B
ACKUP FILE"),";",I,999)
        W !!!,"*** Unattended backup scheduling for '",NM,"' has been completed"
        W !,"*** Backup-command-file '",NM,"' will be run automatically at ",%T1," on ",%D1,! Q
CHK     R !,"Are you sure you entered time on 24-hour clock ? <Y> ",A
        G HLP4:A="?" I A=""!(A?1"Y".E) G ASK
        I A="^"!(A?1"N".E) G TIM
        G HLP4
ERR     W !!,"DISK '",TYU,"' NOT IN SYSTEM. SCHEDULED BACKUP CAN NOT PROCEED.",!! G START
HLP2    W !!," Like this:  90-MAR-83",!
        W:$D(^SYS(0,"$HLAST")) " Or enter <CR> to accept default",! G B1
HLP3    W !!," Like this:   18:30         (6:30 PM)",! G TIM
HLP4    W !!,"Enter <CR> or Y(ES) to set backup time"
        W !,"Enter N(O) to re-enter the time",! G CHK
NMQ     W !,"Enter name of the backup command file you wish to execute" Q
NMQH    W !,"You must enter the name of an existing backup command file.",! Q
IV      W !!,"Incorrect response.  Enter '?' for more information.",! Q
