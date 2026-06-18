BLDMP1  ;22-AUG-78;DUMP DISK BLOCKS ;UPDATED FOR V2 -FDN
OPEN    D O63 G:O63 EXIT^BLDMP S UTLB=$V($V(44)+158) V ARG1:ARG2 S BLOFF=$V(1022,0),BTYP=$V(1021,0),P=1018 S:BLOFF BLOFF=BLOFF-1 S:B
TYP=1 P=1014
        D BLKNUM S NXTBL=BN I BTYP=16 S NXTBL=$V(1016,0)#256*65536+$V(1014,0)
        O %IOD U %IOD W #!,ARG1,":",ARG2 I AREA'="G" S NXTBL="" G B
        I 'NXTBL W "  Last" G B
        W "  Next ",NXTBL,":",STRNR
B       I ARG1#400=399 W !,"Bit Map block" G F
        I '(AREA="G") W "  Area: ",AREA,! G F
        W !,"Block type-" I ",1,2,6,8,16,"[(","_(BTYP#32)_",") W:BTYP\32#2 "(Assigned to the Garbage Collector) - " G @(BTYP#32)
        W "??????"
F       W !! S BLOFF=1022 D DMP G NXBL
1       W "Global Directory" D LINE
        I 'BLOFF G NXBL
        S P=-1
A1      S NAM="",%DO=P+1,START=%DO D %DO
B1      S P=P+1,C=$V(P,0)#256,NAM=NAM_$C(C/2) G B1:C#2
        D:BYTES BYTES S P=P+6 D BLKNUM W !,$J(%DO,4),": ",NAM,?20,BN,":",STRNR S P=P+2 G A1:P<BLOFF
        G NXBL
2       W "Pointer" D LINE
        S PB=1 G DATABL
        G NXBL
6       W "Bottom level pointer" D LINE
        S PB=1 G DATABL
8       W "Data" D LINE S PB=0
DATABL  S P=-1,COM=""
NEXT    S P=P+1 G END:P'<BLOFF S %DO=P,START=P D %DO S C=$V(P,0)#256,COM=$E(COM,1,C*2),P=P+1,LSUB=$V(P,0)#256,SUB="",D="("
        I BTYP\128#2 D EIGHTB^BLDMP G CON
        F I=1:2:$L(COM) I '($E(COM,I)="^") S SUB=SUB_$E(COM,I) I '($E(COM,I+1)) S SUB=SUB_D,D=","
        F I=1:1:LSUB S P=P+1,C=$V(P,0)#256 D DA
CON     D:BYTES BYTES W !,$J(%DO,4),": ",SUB," = "
        I PB=1 S P=P+1 D BLKNUM W ?20,BN,":",STRNR S P=P+2 G N1
        S P=P+1,DL=$V(P,0)#256 I 'DL G NEXT:(P<BLOFF) G END
        S DATA="" F I=1:1:DL S P=P+1,DATA=DATA_$C($V(P,0)#256)
        W DATA
N1      G NEXT:(P<BLOFF)
END     W !,"P=",P,!
        G NXBL
DA      I C<32 S COM=COM_"^1" Q
        S SUB=SUB_$C(C/2),COM=COM_$C(C/2)
        I C#2 S COM=COM_"1" Q
        S COM=COM_"0" I I<LSUB S SUB=SUB_D,D="," Q
        I D="," S SUB=SUB_")" Q
        Q
16      W "Routine" I $V(0,0)#256'=0!($C($V(2,0)#256)'="@") S BLOFF=1023 D LINE S P=0 G RE
        S BLOFF=1023 D LINE S L=$V(1,0),NAM="",P=2 F I=1:1:L-1 S P=P+1,NAM=NAM_$C($V(P,0)#256/2)
        W NAM," ; "
        S P=P+4+(P#2),CNT=$V(P,0),P=P+1 W "Length=",CNT,!
        S CNT=CNT-2
A16     G B16:(CNT=0) D E F I=1:1:9-L W " "
        D E
        D C I '($V(P,0)#256=255) W "Error3",! G B16
        W ! G A16:(CNT>0)
B16     W !,"End",!
        G NXBL
BLKNUM  S BN=$V(P+2,0)#256*256+($V(P+1,0)#256)*256+($V(P,0)#256) Q
LINE    W ! F I=1:1:50 W "-"
        W ! Q:YN="N"
DMP     F YI=0:2:BLOFF D ASCII:'(YI#16),D1:'(YI#16) S %DO=$V(YI,0) D %DO W $J(%DO,8) I (YI#8=7) W !
        D LAST:(YI=BLOFF)!(YI=BLOFF-1) W ! Q
D1      S %DO=YI W $J(%DO,6) D %DO W $J(%DO,6),": " Q
        W "XXXXXXXXXXXXXXXXXXXXXXXXXX",! Q
C       S CNT=CNT-1,P=P+1 I P<1014 Q
        D BLKNUM I 'BN W "Error1",! Q
        U 63 V BN:ARG2 S P=0 U %IOD
        S X=$X I YN="N" W !,!
        E  W # W:%DTY'="LP" !!!!
        W BN,":",STRNR,!,"_____________",! D DMP:YN="Y" W $J(" ",X) Q
D       F I=1:1:L D C W $C($V(P,0)#256) I CNT<0 W "Error2",! Q
        Q
E       D C:(CNT>0) S L=$V(P,0)#256 D D:L
        Q
%DO     S %B=%DO,%DO=""
AA      S %DO=%B#8_%DO,%B=%B\8 I %B<8 S:%B %DO=%B_%DO K %B Q
        G AA
NXBL    I 'NXTBL!(BTYP=16)!(STRNR="S?") C 63 G BLOCK^BLDMP
        U 0 W !!,"Next block (",NXTBL,":",STRNR,") ? (Y or N) >" R ANS I ANS="Y" W !! S ARG1=NXTBL,ARG2=STRNR G OPEN
        I ANS="?" D HELP G NXBL
        I "N"'[ANS D IV G NXBL
        G BLOCK^BLDMP
HELP    W !?5,"Enter 'Y' to continue to the next (right-linked) block"
        W !?8,"or 'N' or <CR> to terminate." Q
IV      W !?5,"Incorrect response - Enter '?' for more information." Q
O63     S O63=0 O 63::0 I $T Q:'$D(PHY)  U 63:(::$S(PHY="P":"Z",1:"C")) Q
        W !?5,*7,"View Buffer busy"
        R !,"Try again <N>",YN S:YN="" YN="N"
        G:$E(YN,1)="Y" O63 S O63=1 Q
ASCII   Q:YI=0  W !,?17 S HOLD=YI,YI=YI-16 F A=YI:1:HOLD-1 S:(A#2) X=-1 S:'(A#2) X=1 S P=$V(A,0)#256 S:(P<32!(P>127)) P=42 W $J($C(P
),2) I (A#2) W "    "
        S YI=HOLD W ! Q
LAST    W !,?17 S:$D(HOLD) HOLD=YI,YI=YI-(HOLD#16) S:'($D(HOLD)) HOLD=YI,YI=0 F A=YI:1:HOLD+1 S P=$V(A,0)#256 S:(P<32!(P>127)) P=42
W $J($C(P),2) I (A#2) W "    "
        W ! Q
BYTES   W !,START,": " F BYTES=START:1:P W " ",$V(BYTES,0)#256
        Q
RE      W !,"** Warning:  This is routine continuation block, 1st line of interpretation",!?13,"might be incorrect **",!!
        F I=1:1 S CHAR=$V(P,0)#256,P=P+1 Q:CHAR=255  W $C(CHAR)
CONT    W ! S L=$V(P,0)#256 I L F I=1:1:L S P=P+1 G:P'<1014 DONE W $C($V(P,0)#256)
        F I=1:1:9-L W " "
        S P=P+1,L=$V(P,0)#256 I L F I=1:1:L S P=P+1 G:P'<1014 DONE W $C($V(P,0)#256)
        S P=P+2 G:$V(P,0)'=255 CONT
DONE    C 63 G BLOCK^BLDMP
