PARTAB  ;RLW;DISPLAY PARTITION TABLE;11SEPT79
        K %DEF S %QTY=2 D ^%IOS I '$D(%IOD) G EXIT
        S ST=$V(44),A=0,PT=$V(ST+6)
        D INT^%D,INT^%T
        U %IOD W #!,"Partition Table Report",?40,%DAT1,"  ",%TIM,!!,"Standard size = ",$V(PT)#256," K Bytes" S LINE=4
        U %IOD W !!,"Partition #",?20,"Partition size     Base address (octal)" S LINE=LINE+4
        F P=PT+2:2:PT+126 S A=A+1 I $V(P)>0 U %IOD W !,?6,A,?24,$V(P)#16+1," K bytes",?42 D CONV S LINE=LINE+1 I LINE>54 D PAGE
        U %IOD W !!,"End of report",!!
EXIT    U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %DAT,%DAT1,%DO,%DTY,%IOD,%TIM,A,LINE,P,PT,ST Q
CONV    ;
        S %DO=$V(P)\16*1024 D ^%DO U %IOD W %DO
        Q
PAGE    W #,!! S LINE=2 Q
