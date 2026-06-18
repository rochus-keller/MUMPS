FIXGD   ;REPAIR GLOBAL DIRECTORY @SMB@
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
        S %QTY=2,%DEF=0 K %MTM D ^%IOS I $D(%IOD) U %IOD D DIS U 0 C:%IOD'=$I %IOD
        G R
O4      V 1022:0:0 G DONE ;;CLEAR BLOCK;;1
O5      G INSERT ;;INSERT GLOBAL
O6      G DEL ;;ERASE GLOBAL
O7      ;;OFFSET
        W !,"Offset: <",$V(1022,0) R "> ",O G NA:"^"[O
        I O?.N,O<1015 V 1022:0:O G DONE
        W " 0 through 1015" G O7
O8      S BYT=1014 G PTR ;;RIGHT LINK POINTER
O9      ;;DOWN POINTER
        S W="FOR" D G G R:"^"[G D FIND G O9:BYT<0 S BYT=BYT+$L(G)+5 G PTR
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
BUMP    Q:'N  S O=$V(1022,0) G DOWN:N<0 I O+N>1014 U 0 W "OOPS" *
        I N#2=0 F I=O#2+O-2:-2:BYT-1 V I+N:0:$V(I,0) ;;I is EVEN
        E  F I=O#2=0+O+N-2:-2:BYT+N-1 S X=0 S:I'<N X=$V(I-N,0) V I:0:$V(I-N+1,0)#256*256+X ;;I is ODD
BO      V 1022:0:$V(1022,0)+N Q
        -
DOWN    I O<-N U 0 W "OOPS" *
        S X=BYT G ODD:N#2
        I X#2 V X+N-1:0:$V(X,0)*256+($V(X+N-1,0)#256) S X=X+1
        F I=X:2:O-1 V I+N:0:$V(I,0) ;;I is EVEN
        G BO
ODD     I X#2=0 V X+N-1:0:$V(X,0)#256*256+($V(X+N-1,0)#256) S X=X+1
        F I=X:2:O-1 V I+N:0:$V(I+1,0)#256*256+$V(I,0) ;;I is ODD
        G BO
        -
DIS     S BYT=1014,O=$V(1022,0) D GETPTR
        W !!,"OFFSET: ",O,?25,"RIGHT LINK POINTER: ",PTR,":",STRNO
        W !! S P=0
DIS1    Q:P=O  I P>O W !,"Illegal offset!! Should be ",P,"." Q
        S BYT=P,N="" F P=P:1 S X=$V(P,0)#256,N=N_$C(X\2) Q:X#2=0
        W !,$J(BYT,4),": ",N,?20 S BYT=P+6 D GETPTR W PTR S P=P+9 G DIS1
        -
INSERT  S M=1014-$V(1022,0)-8 I M<1 W !,"Directory block full" G R
        S W="INSERT" D G G R:"^"[G
        I $L(G)>M W !,"Longest name that can fit is ",M G INSERT
B       R !,"Pointer block # ",BT G INSERT:"^"[BT S B=$P(BT,":",1)
        I B'?1N.N!($P(BT,":",2)'=STRNO)!'B W *7," Enter a valid block number like this: 234:",STRNO G B
        F I=1:1:$L(G) S A=I<$L(G),A=$A(G,I)*2+A,BYT=$V(1022,0)+I-1 D PUTBYT
        S BYT=BYT+1,A=0 D PUTBYT S BYT=BYT+1,A=195 D PUTBYT
        S PTR=0,BYT=BYT+1 D SETPTR
        S BYT=BYT+3,PTR=B D SETPTR V 1022:0:$V(1022,0)+$L(G)+8 W " Inserted" G INSERT
        -
DEL     S W="ERASE" D G G R:"^"[G S P=0 D FIND G DEL:BYT<0
        S N=-$L(G)-8,BYT=BYT-N D BUMP W " Erased" G DEL
        -
FIND    S P=0,O=$V(1022,0)
F1      I P'<O W " Not found" S BYT=-1 Q
        S N="",BYT=P F P=P:1 S X=$V(P,0)#256,N=N_$C(X\2) Q:X#2=0
        Q:N=G  S P=P+9 G F1
        -
G       W !,W R " Global ^",G Q:"^"[G  I $L(G)<9,G?1A.AN!(G?1"%".AN) Q
        Q:W="ERASE"  W " Enter valid global name, please" G G
        -
PTR     D GETPTR W !,"BLOCK # <",PTR,":",STRNO R "> ",B G NA:"^"[B
        S:B="" B=PTR_":"_STRNO S PTR=$P(B,":",1)
        I PTR'?1N.N!($P(B,":",2)'=STRNO) W " Enter valid DSM block number" G PTR
        D SETPTR G DONE
