%GE     ;YAEL ; DSM UTILITIES ; GLOBAL EFFICIENCY
START   W !,"Global Efficiency",!
GET     C 63 D ^%GSEL G:'$D(%GO) END I $O(^UTILITY($J,""))="",%GO G START
        G:'%GO END S GN=""
ASK     S GN=$O(^UTILITY($J,GN)) I GN="" G END
        W !,"-------------------------------------------",!
        I GN["[" W "Global must reside in your own directory.",! G ASK
        S STR=$P($ZU(""),",",2),UN=+$ZU("")
        S LEVEL=0,CNT(0)=1 K FB
        S ST=$V(44),STRTAB=$V(ST+12),UTMM=$V($V(ST+34)#256*STR+STRTAB+2),UTOFF=UN-1*20
        S BLN=$V(UTOFF+4,UTMM)#256*65536+$V(UTOFF+2,UTMM)
        W !,$ZU(0),"  Global Directory Block:  ",BLN,!!
        O 63::0 E  W ?5,*7,"View Buffer busy",! G END
        S UTLB=$V(ST+158)
1       D I I '(TYPE=1) W "Error.  Not a directory block!",! G START
        S P=-1
A1      S NAM=""
B1      S P=P+1,C=$V(P,0)#256,NAM=NAM_$C(C/2) G B1:C#2
        I NAM=GN G B2
        S P=P+8 G A1:P<BLOFFSET
        I NXTBL S BLN=NXTBL G 1
        W "Not found!",! G ASK
B2      S P=P+6 D BLKNUM S BLN=BN
        W "Global ^",GN,"  First block: ",BN,!
        D G
2       D I I '(TYPE=2) G 6+1:(TYPE=6) S T=2 G ERR
        D DATABL:'$D(FB)
        S TP=TP+BLOFFSET,CNT(LEVEL)=CNT(LEVEL)+1
        I NXTBL S BLN=NXTBL G 2
        S BLN=FB,L="P" K FB D J,H,G
        D I I TYPE=2 G 2+1
        G 6+1
6       D I
        I '(TYPE=6) S T=6 G ERR
        D DATABL:'$D(FB)
        S TP=TP+BLOFFSET,CNT(LEVEL)=CNT(LEVEL)+1
        I NXTBL S BLN=NXTBL G 6
        S BLN=FB,L="Bottom p" K FB D J,H,G
8       D I I '(TYPE=8) S T=8 G ERR
        S CNT(LEVEL)=CNT(LEVEL)+1
        S TP=TP+BLOFFSET I NXTBL S BLN=NXTBL G 8
        W !,"Data level",?22 D H G ASK
DATABL  S P=$V(1,0)#256+2 D BLKNUM S FB=BN Q
BLKNUM  S BN=$V(P+2,0)#256*256+($V(P+1,0)#256)*256+($V(P,0)#256) Q
DMP     F YI=0:1:BLOFFSET D D1:'(YI#16) S %DO=$V(YI,0)#256 D %DO W $J(%DO,4) I (YI#2=1) W "  " I (YI#16=15) W !
        W ! K YI,%DO Q
D1      S %DO=UTLB+YI D %DO W $J(%DO,6) S %DO=YI D %DO W $J(%DO,6),":  " Q
%DO     S %B=%DO,%DO=""
%DO1    S %DO=%B#8_%DO,%B=%B\8 G:%B>7 %DO1 S:%B %DO=%B_%DO K %B Q
G       S LEVEL=LEVEL+1,CNT(LEVEL)=0,TP=0 Q
H       S W=TP/CNT(LEVEL)/1018*100 W " -",$J(CNT(LEVEL),9),$J(W,8,0),"%",!
        Q
I       V BLN:"S"_STR S BLOFFSET=$V(1022,0)-1,TYPE=$V(1021,0)#32,P=1018 S:TYPE=1 P=1014 D BLKNUM S NXTBL=BN Q
J       W !,L,"ointer level ",LEVEL,?22 Q
ERR     W "Wrong block was found.  Should have been type ",T," ; found ",TYPE,!
        I BLN#262144#400=399 W "Bit map block",! G F
        I TYPE/32#2 W "Assigned to the Garbage Collector",!
        E  W "?????",!
F       S BLOFFSET=1023 D DMP G ASK
HELP    W !,"Enter the name of a global in your directory.",!,"Enter '^D' to list your global directory.",!,"Enter '^' or <CR> to ex
it.",! G ASK
END     C 63 K I,TYPE,BN,BLOFFSET,CNT,FB,GN,GD,LEVEL,NAM,NXTBL,ST,UN,UT,UTLB,L,%,C,P,TP,W,UTMM,UTOFF,STRTAB
        Q
