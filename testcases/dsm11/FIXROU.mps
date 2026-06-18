FIXROU  ;REPAIR ROUTINE BLOCK @SMB@
1       S W="Y" S:$V(1022,0) W="N" W !,"Routine continuation block? <",W,"> "
        R R I R="^" G B^FIX
        S:R="" R=W S R=$E(R,1) I "YN"'[R W " Enter Y or N please" G 1
        I R="Y" V 1022:0:0 S OP=",1,2,3,4,"
        E  S OP=",1,2,3,4,5,"
R       R !!,"OPTION: ",R G RQ:R="?" I R="^" S R="" W " "
        F I=1:1 S O="O"_I,L=$T(@O),X=","_I_"," G ER:L="" I OP[X S L=$P(L,";;",2) Q:$E(L,1,$L(R))=R
        W $E(L,$L(R)+1,999) S W="OK",R=1 D SURE:$P($T(@O),";;",3) G @O:R,NA
        -
RQ      W ! F I=1:1 S O="O"_I,L=$T(@O),X=","_I_"," G R:L="" I OP[X W !,$P(L,";;",2)
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
O4      S BYT=1014 G PTR ;;RIGHT LINK BLOCK
O5      ;;SIZE
        S BYT=$V(1,0),BYT=BYT#2=0+5+BYT,W=$V(BYT,0)
        W !,"SIZE: <",W,"> " R R G R:"^"[R I R?.N,R,R<65536 V BYT:0:R G DONE
        W *7," Enter 1 thru 65535 please." G O5
        -
SURE    W !,W R " ? <Y> ",R S R=$E(R,1) I "Y"[R S R=1 Q
        I "^N"[R S R=0 Q
        W *7," Enter Y or N please" G SURE
        -
DIS     W !,"BLOCK ",BLK,":",STRNO,! S P=0 I OP'[",5," S END=1013 W " (CONTINUATION BLOCK)" G DIS2
        W !,"ROUTINE: " F I=3:1:$V(1,0)+1 W *$V(I,0)#256/2
        S BYT=1014 D GETPTR W ?30," RIGHT LINK POINTER: ",PTR,":",STRNO
        S P=I#2+4+I,END=$V(P,0)+P-1 S:END>1013 END=1013 W !,"ROUTINE LENGTH: ",$V(P,0) S P=P+2
DIS1    S L=$V(P,0)#256 I L>8 G DISER
        W ! F I=1:1:L G END:P+I>END S X=$V(P+I,0)#256 G DISER:X=255 W *X
        W $C(9) S P=P+L+1 G END:P>END S L=$V(P,0)#256
        F I=1:1:L G END:P+I>END S X=$V(P+I,0)#256 G END:X=255 W *X
        S P=P+L+2 G END:P>END,DIS1
DIS2    S P=0 W !! F I=0:1:254 S X=$V(I,0)#256 G DIS3:X=255 W *X
DISER   W !!,P,?6,"????" Q
DIS3    S P=I+1 G DIS1
END     W !!,P," ** END **" Q
        -
GETPTR  I BYT#2 S PTR=$V(BYT+1,0)*256+($V(BYT,0)#256) Q
        S PTR=$V(BYT+2,0)#256*65536+$V(BYT,0) Q
        -
SETPTR  I BYT#2 V BYT+1:0:PTR\256,BYT-1:0:PTR#256*256+($V(BYT-1,0)#256) Q
        V BYT:0:PTR#65536,BYT+2:0:$V(BYT+3,0)*256+(PTR\65536) Q
        -
PTR     D GETPTR W !,"BLOCK # <",PTR,":",STRNO R "> ",B G NA:"^"[B
        S:B="" B=PTR_":"_STRNO S PTR=$P(B,":",1)
        I PTR'?1N.N!($P(B,":",2)'=STRNO) W " Enter valid DSM block number" G PTR
        D SETPTR G DONE
        -
TRAP    C 63 U 0 W !,$ZE Q:$ZE'["<BLPRT>"
        W !,"Can't repair block ",BLK,":",STRNO," from this UCI.  This block either contains"
        W !,"a FIX routine, or points to one from the routine directory."
        Q
