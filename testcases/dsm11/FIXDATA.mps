FIXDATA ;REPAIR DATA BLOCK @SMB@
        S W="" G GL:$V(0,0)#256 S R=$V(1,0) G GL:'R
        F I=1:1:R S W=W_$C($V(I+1,0)#256\2) Q:$V(I+1,0)#256#2=0
        I W'?1A.AN,W'?1"%".AN S W="" G GL
        I $L(W)>8 S W="" G GL
        S W="^"_W
GL      W !,"Data block for" W:W]"" " <",W,"> " R " ^",R S:R="" R=W
        I "^"[R W " (block not filed)" G B^FIX
        S:R'="?"&(R'["^") R="^"_R S NUMCOL=1,GL=$E(R,2,999)
        I $L(R)<10,R?1"^"1A.AN!(R?1"^%".AN) G COL
        W " Enter the name of some global" G GL
        -
COL     R !,"Numeric collating? <Y> ",R G GL:R="^" S R=$E(R,1)
        G R:"Y"[R I R="N" S NUMCOL=0 G R
        W " Enter Y or N please" G COL
        -
R       R !!,"OPTION: ",R G RQ:R="?" I R="^" S R="" W " "
        F I=1:1 S O="O"_I,L=$T(@O) G ER:L="" S L=$P(L,";;",2) Q:$E(L,1,$L(R))=R
        W $E(L,$L(R)+1,999) S W="OK",R=1 D SURE:$P($T(@O),";;",3) G @O:R,NA
        -
RQ      W ! F I=1:1 S O="O"_I,L=$T(@O) G R:L="" W !,$P(L,";;",2)
        -
ER      W " Type ? for list" G R
        -
DONE    U 0 W " Done." G R
        -
NA      U 0 W " No action taken." G R
        -
O       ;;OPTIONS
O1      G B^FIX ;;PUNT (LEAVING BLOCK UNCHANGED);;1
O2      G VIEW^FIX ;;FILE BLOCK;;1
O3      ;;LIST BLOCK
        S %QTY=2,%DEF=0 K %MTM D ^%IOS I $D(%IOD) U %IOD D DIS^FIXDATA1 U 0 C:%IOD'=$I %IOD
        G R
O4      V 1022:0:0 G DONE ;;CLEAR BLOCK;;1
O5      G INSERT ;;INSERT NODE
O6      G DEL ;;ERASE NODE
O7      ;;OFFSET
        W !,"Offset: <",$V(1022,0) R "> ",O G NA:"^"[O
        I O?.N,O<1015 V 1022:0:O G DONE
        W " 0 through 1015" G O7
O8      S BYT=1018 G PTR ;;RIGHT LINK POINTER
        -
SURE    W !,W R " ? <Y> ",R S R=$E(R,1) I "Y"[R S R=1 Q
        I "^N"[R S R=0 Q
        W *7," Enter Y or N please" G SURE
        -
GETPTR  I BYT#2 S PTR=$V(BYT+1,0)*256+($V(BYT,0)#256) Q
        S PTR=$V(BYT+2,0)#256*65536+$V(BYT,0) Q
        -
SETPTR  I BYT#2 V BYT+1:0:PTR\256,BYT-1:0:PTR#256*256+($V(BYT-1,0)#256) Q
        V BYT:0:PTR#65536,BYT+2:0:$V(BYT+3,0)*256+(PTR\65536) Q
        -
PUTBYT  I BYT#2 V BYT-1:0:A*256+($V(BYT-1,0)#256) Q
        V BYT:0:$V(BYT+1,0)*256+A Q
        -
INSERT  S M=1014-$V(1022,0)-4 I M<1 W !,"Data block full" G R
        S W="Insert" D G^FIXDATA1 G R:'$D(G)
        I G-1>M W !,"Longest internal node that can fit is ",M G INSERT
        S N=G-R1+2,O=$V(1022,0),R=9999
        I O>BYT S R=$V(BYT,0)#256,U=$V(BYT+1,0)#256 I R2>R S N=N-R2+R
        D BUMP^FIXGD S A=R1 D PUTBYT S A=G-R1-1,BYT=BYT+1 D PUTBYT
        F I=R1+2:1:G S BYT=BYT+1,A=G(I) D PUTBYT
        S BYT=BYT+1,A=0 D PUTBYT
        I R2>R S BYT=BYT+1,A=R2 D PUTBYT S BYT=BYT+1,A=U+R-R2 D PUTBYT
        W " Inserted" G INSERT
        -
DEL     S W="ERASE" D G^FIXDATA1 G R:'$D(G)
        S R1=$V(BYT,0)#256,N=$V(BYT+1,0)#256+2,N=N+$V(BYT+N,0)#256+1,O=$V(1022,0),BYT=BYT+N,R=0
        I BYT<O S R=$V(BYT,0)#256 I R>R1 S N=N+R1-R,U=$V(BYT+1,0)#256
        S N=-N D BUMP^FIXGD G D1:R'>R1 S BYT=BYT+N+R1-R,A=R1 D PUTBYT
        S A=U+R-R1,BYT=BYT+1 D PUTBYT
        F I=1:1:R-R1 S BYT=BYT+1,A=G(R1+I+1) D PUTBYT
D1      W " Erased" G DEL
        -
PTR     D GETPTR W !,"BLOCK # <",PTR,":",STRNO R "> ",B G NA:"^"[B
        S:B="" B=PTR_":"_STRNO S PTR=$P(B,":",1)
        I PTR'?1N.N!($P(B,":",2)'=STRNO) W " Enter valid DSM block number" G PTR
        D SETPTR G DONE
