RTHISTP W !,"PRINT STATISTICS REPORT FROM ^RTH GLOBAL",!
WHICH   R !!,"Which statistics session ? ",SUB I SUB="^"!(SUB="") Q
        G:$D(^RTH(SUB)) COM R " -- can't find it. Do you wish a list ? ",SUB I SUB'="Y" G WHICH
        W !,"Strike any key when you've seen enough...",! S SUB=""
        F I=1:1 S SUB=$O(^RTH(SUB)) G:SUB="" WHICH D ID R *X:0 I  G WHICH
COM     W !,"How many chars. to define a routine group <8> ? "
        R CNT,! I CNT="" S CNT=8
        I CNT="^" G WHICH
        I CNT="?" W ?5,"Enter 8 to list every routine, 0 to list only UCI.",! G COM
QUANT   W !,"How many reports starting with ",SUB," <1> ? "
        R QT,! G:QT="^" WHICH S:QT="" QT=1 I QT'?.N W "numerals please",! G QUANT
        F I=SUB:1:SUB+QT-1 I '$D(^RTH(I)) W "CAN'T FIND STATISTICS SESSION #",I,! G QUANT
        K %DEF D ^%IOS G:'$D(%IOD) COM W ! U %IOD:132
PRINT   D HEADING W !!?51,"Average Counts of Jobs",! D LINE1,LINE2 S RTN="",TOTAL=0,INC=.2
        S DIV=^RTH(SUB,"TOTAL"),UCI="In",TAB=3
        F COM="SHORTQ","IORQ","WAIT1Q","WAIT2Q","WAIT3Q","WAIT4Q" S HITS=^(COM),UCIP=1 D STARS
        S COM="Total CPU Bound",HITS=TOTAL,(TAB,UCIP)=0 D STARS,BLANK
        S TOTAL=0,TAB=3,COM="GLOBQ",HITS=^(COM),UCIP=1 D STARS
        S COM="GLOLKQ",HITS=^(COM),UCIP=1 D STARS
        S COM="Total Global Bound",HITS=TOTAL,(TAB,UCIP)=0 D STARS,BLANK
        S UCI="",TOTAL=0,TAB=0,COM="%GLOCK",HITS=^("%GLOCK"),INC=.002 D STARS
        S COM="%LOCKWAIT",HITS=^("%GLWAIT") D STARS
        S COM="Total % unavailable",HITS=TOTAL D STARS,BLANK
        S COM="GLOBAL",HITS=^RTH(SUB,COM),UCIP=1,TAB=3,UCI="In",INC=.2 D STARS,BLANK
        F COM="DKRBQ","JRNQ" S HITS=^(COM),UCIP=1 D STARS
        D LINE2,LINE1 W !?47,"Averages of Events per Second",! D LINE3,LINE2
        S INC=2,DIV=SECS,UCIP=0,TAB=10
        F Q=2:1 S COM=$P($T(NODES),";;",Q) Q:COM=""  S HITS=^RTH(SUB,COM) D STARS
        F K=1:1 Q:'$D(^RTH(SUB,"DDPIN"_K))  S HITS=^("DDPIN"_K),N=^("DDPNAM"_K) D PKASC S COM="DDPI "_N D STARS S HITS=^("DDPOUT"_K),N=^("DDPNAM"_K) D PKASC S COM="DDPO "_N D STARS
        D LINE2,LINE3
        W !?20,"| Block Read Requests per Global Reference (LOGRD/(ROUREF+GLOREF)):",?90
        W $J(^("LOGRD")/(^("ROUREF")+^("GLOREF")),5,2)
        W !,"Derivative Ratios:  | Actual Block Reads per Block Read Request (READS/LOGRD):",?90
        W $J(^("READS")/^("LOGRD"),5,2)
        W !?20,"| Block Write Requests per SET/KILL Command (LOGWT/(GLOSET+GLOKIL)):",?90
        W $J(^("LOGWT")/^("GLOSET"),5,2)
        W !?20,"| Actual Block Writes per Block Write Request ((WRITES-WTSYNC)/LOGWT):",?90
        W $J(^("WRITES")-^("WTSYNC")/^("LOGWT"),5,2)
        D HEADING
        W !!?31,"Time Spent Accessing Disk as a Percentage of Total Elapsed Time",!
        D LINE1,LINE2 S INC=.2,TOTAL=0,TAB=11,DIV=^RTH(SUB,"TOTAL")/100 W "Disk Drive"
        F UN=0:1:7 S COM=UN_" Read",HITS=^RTH(SUB,"DISK",UN,"READ") D STAR S COM=UN_" Write",HITS=^("WRITE") D STAR
        S TAB=0,HITS=TOTAL,COM="Total" D STARS,LINE2,LINE1
        D HEADING W !!?31,"Time Spent Executing Routines as a Percentage of Total Elapsed Time",!,"UCI       Routine" D LINE1 W "---       -------" D LINE2
        S RTN="",(UCIP,OTHER)=0,TAB=10
        S HITS=^RTH(SUB,"NOROOM"),COM="No Room" D STAR
        S COM="Idle",HITS=^("IDLE") D STARS
        S TY="RTN" D UCIS,LINE2,LINE1
        D HEADING W !!?50,"Global references per second",!,"UCI       Global" D LINE1 W "---       ------" D LINE2
        S DIV=SECS,TY="GLB",RTN="",UCIP=0,TAB=10
        S HITS=^RTH(SUB,"GLOVF"),COM="No Room" D STAR
        D UCIS,LINE2,LINE1 S SUB=SUB+1,QT=QT-1 I QT G PRINT
        W $C(12) U 0 C:%IOD'=$I %IOD K %IOD G WHICH
UCIS    S UCI="",TAB=10 F I=1:1 S UCIP=1,UCI=$O(^RTH(SUB,TY,UCI)) Q:UCI=""  D BLANK,UCI
        Q
UCI     S (RTN,COM)="",(HITS,OTHER,TOTAL)=0 F I=1:1 S RTN=$O(^RTH(SUB,TY,UCI,RTN)) D LINE Q:RTN=""
        S COM="Other",HITS=OTHER,RTN="" D STAR S COM="Total",HITS=TOTAL D STARS
        Q
LINE    I RTN'="",$E(RTN,1,CNT)=COM S HITS=HITS+^(RTN) Q
STAR    I HITS=0 G END
STARS   S STARS=HITS/(DIV*INC),STARS=$E($P(STARS,".",2),1)>4+$P(STARS,".",1)
        I UCIP S UCIP=0 W UCI
        S X="*" I COM["Total" S X="-"
        W ?TAB,COM,?20,"|" F I=1:1:STARS W X Q:I=100
        S STAR=STARS+5\5*5 F I=STAR:5:100 W ?I+20,"|"
        W $J(HITS/DIV,6,2),! S TOTAL=TOTAL+HITS
END     S COM=$E(RTN,1,CNT) S:RTN'="" HITS=^(RTN) Q
ID      W !?18,"Statistics Session #",SUB," Was Logged on " S %DT=$P(^RTH(SUB,"STIME"),",",1) D %CDS^%H W %DAT1
        S SECS=$P(^("ETIME"),",",1)-$P(^("STIME"),",",1)*86400+$P(^("ETIME"),",",2)-$P(^("STIME"),",",2)
        S %TM=$P(^("STIME"),",",2) D %CTS^%H W " at ",%TIM1,"  for an Elapsed Time of",$J(SECS/60,7,2)," Minutes"
        I $D(^("LABEL")),^("LABEL")'="" W !?132-$L(^("LABEL"))\2,^("LABEL")
        Q
LINE1   W ?20,"0    1    2    3    4    5    6    7    8    9    10   11   12   13   14   15   16   17   18   19   20",! Q
LINE2   W ?20,"|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|",! Q
LINE3   W ?20,"0    10   20   30   40   50   60   70   80   90  100  110  120  130  140  150  160  170  180  190  200",! Q
NODES   ;;SWAPINS;;ROUREF;;MAPROU;;GLOREF;;GLOSET;;GLOKIL;;LOGRD;;READS;;TOTRD;;LOGWT;;WRITES;;WTSYNC;;TRYLAST;;GOTLAST;;ALLOC;;DEALL;;TTYIN;;TTYOUT
        ;;
HEADING W $C(12),!!?50,"System Performance Statistics",!?50,^RTH(SUB,"CONF"),! D ID
        W !?37,"Average Number of Jobs Running During Session: ",$J(^RTH(SUB,"JOBS")/^("TOTAL"),5,2)
        Q
        ;;
BLANK   F I=20:5:120 W ?I,"|"
        W ! Q
PKASC   S N=$C(N\2048+64,N\64#32+64,N\2#32+64) Q
