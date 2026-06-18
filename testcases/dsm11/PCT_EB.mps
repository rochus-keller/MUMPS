%EB     ;31-Jul-81 REV 1.1 ;SYSTEM UTILITY; PROGRAM EDITOR; STORE COMMAND FOR .BLK TYPE FILES; JHM
STRT    S CUR=4 D GNXT G ER1:'CUR
        I $P(LN,"=",1)'="BLKTYP" G ER2
        S BLKTYP=$P(LN,"=",2)
        I BLKTYP=2!(BLKTYP=6) S PB=1 G CONT
        I BLKTYP=8 S PB=0 G CONT
        G ER3
CONT    D GNXT G ER1:'CUR D GNXT G ER1:'CUR
        I $P(LN,"=",1)'="BLKNXT" G ER1
        S NXTBL=$P(LN,"=",2),COM="",CC=0,NC=0,P=0
        W !,"[Saving in View buffer]"
GSUB    G DONE:'CUR D GNXT G GSUB:LN=""
        K S I $E(LN,$L(LN))="[" S LN=LN_" "
        F NS=1:1 S S(NS)=$P(LN,"],[",NS) I S(NS)="" K S(NS) S NS=NS-1 Q
        S OCM=COM,COM="" F J=1:1:NS-1 D SUB
        F CC=1:2:$L(OCM)+1 I $E(COM,CC)'=$E(OCM,CC) Q
        S CT=CC-1\2,NC=$L(COM)\2-CT
        S C=CT D VW S C=NC D VW
        F I=CC:2:$L(COM)-1 S C=$A($E(COM,I))*2+$E(COM,I+1) D VW
        G SBN:PB=1
        S C=$L(S(NS)) D VW
        F I=1:1:$L(S(NS)) S C=$A(S(NS),I) D VW
        G GSUB
SBN     F I=1,256,65536 S C=S(NS)\I#256 D VW
        G GSUB
DONE    V 1018:0:NXTBL#65536 V 1020:0:NXTBL\65536#256+(BLKTYP*256)
        V 1022:0:P
        G QUIT
SUB     I S(J)?.N S COM=COM_$C($L(S(J)))_"1"
        F K=1:1:$L(S(J))-1 S COM=COM_$E(S(J),K)_"1"
        S COM=COM_$E(S(J),$L(S(J)))_"0" Q
VW      I P#2 V P-1:0:$V(P-1,0)#256+(C*256) S P=P+1 Q
        V P:0:$V(P+1,0)*256+C S P=P+1 Q
ER1     W !,"File incomplete",*7 G QUIT
ER2     W !,"Blocktype field missing",*7 G QUIT
ER3     W !,"Illegal Blocktype",*7 G QUIT
GNXT    S LN=^(CUR),CUR=+LN,LN=$P(LN,"^",3,255) Q
QUIT    K P,COM,CC,C,NC,OCM,PB,NXTBL,BLKTYP,K,K,I,NS,S Q
