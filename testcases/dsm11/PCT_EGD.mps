%EGD    ;JTR; DSM UTILITIES ;EXTENDED GLOBAL DIRECTORY
START   O 63::0 E  W !,"View Buffer busy",! G EXIT
        S %DEF=0,%QTY=2 D ^%IOS G:'$D(%IOD) EXIT S %IO=$I,$ZT="ERR^%EGD" U %IOD
HEAD    W #!!?20,"Extended Global Directory",?51 D ^%D W !?27,"of ",$ZU(0),?51 D ^%T
        W !!,"  Global  Jrnl  Collating 1st Pointer  Growth Area    Protection  Codes"
        W !,"   Name           Type    Blk Address  Blk Address",!
SET     S ST=$V(44),UCI=$P($ZU(""),",")-1*20
        S VS="S"_$P($ZU(""),",",2)
        S MM=$V($P($ZU(""),",",2)*($V(ST+34)#256)+$V(ST+12)+2)
        S GD=$V(UCI+4,MM)#256*65536+$V(UCI+2,MM)
READ    V GD:VS S P=0
NAME    I $V(1022,0)'>P S GD=$V(1016,0)#256*65536+$V(1014,0) G READ:GD,EXIT
        S NAM="" F P=P:1 S A=$V(P,0)#256,NAM=NAM_$C(A\2) I A#2=0 Q
        S P=P+1,PROT=$V(P+1,0)#256
        F I=1:1:4 S @("A"_I_"=$P(""None,Read,R/W,RWD "","","",PROT#4+1)"),PROT=PROT\4
        S B=P+2 D  S BL1=B,B=P+5 D  S BL2=B
        .S B=$V(B+2,0)#256*256+($V(B+1,0)#256)*256+($V(B,0)#256)
        S COL=$V(P,0)#2+1
        S BITS=$V(P,0)\2#2+7
        W !,"^",NAM,?12,$S($V(P,0)\4#2:"Y",1:"N"),?17,$P("Numeric,String",",",COL),?26,BL2,?39,BL1,?52,"System:[",A4,"]  World:[",A3
,"]"
        W !,?17,BITS,"-bit",?52,"Group :[",A2,"]  User :[",A1,"]"
        S P=P+8 G NAME
ERR     U 0 I $ZE?1"<INRPT".E W !,"*** Interrupt ***"
        E  W !,*7,$ZE,!
EXIT    C 63 W !! U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %IO,%IOD,A,B,BL1,BL2,COL,GD,I,NAM,P,PROT,ST,UCI,MM Q
