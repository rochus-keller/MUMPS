FIXMAP  ;REPAIR MAP BLOCK @SMB@
1       W !,"  Map Block" S MAX=30
        V BLK:STRNO
        G BAD:$V(1006,0)'=65535!($V(1012,0)'=32769)
        F I=1:1:4 S X=$T(@("T"_I)) I $P(X,"^",3)=$V(1008,0),$P(X,"^",4)=$V(1010,0) S W=$P(X,"^",2) G TYP
BAD     W !,"ILLEGAL MAP BLOCK PATTERN !!" S W=""
TYP     W !,"Map Type:" W:W]"" " <",W,">" R " ",R S:R="" R=W G:"^"[R B^FIX
        I R["?" F I=1:1:4 W !,?5,$P($T(@("T"_I)),"^",2)
        I  G TYP
        F I=1:1:4 S L=$T(@("T"_I)),X=$P(L,"^",2) G OK:$E(X,1,$L(R))=R
        W *7," Type ? for list" G TYP
        -
OK      W $E(X,$L(R)+1,99) V 1006:0:65535,1012:0:32769
        V 1008:0:$P(L,"^",3),1010:0:$P(L,"^",4)
        S X=$P(L,"^",5) I X]"" V 1022:0:X
        S OP=","_$P(L,"^",6)_"," G R
        -
T1      ^DATABASE^21845^43690^^1,2,3,5,6
T2      ^SDP^43690^21845^0^1,2
T3      ^JOURNAL^13107^52848^0^1,2
T4      ^SPOOL^56173^56173^0^1,2,4
        -
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
O4      S BYT=800 G PTR ;;RIGHT LINK BLOCK;;;; SPOOLING ONLY
FC      W !,"Recalculating free count."
O5      ;;RESET FREE COUNT
        S X=0 F I=0:1:398 S X='$V(I*2,0)+X
        V 1022:0:X W " ",X," Free blocks." G DONE
O6      G ^FIXMAP1 ;;ALLOCATION WORD
        -
SURE    W !,W R " ? <N> ",R S R=$E(R,1) I "Y"=R S R=1 Q
        I "^N"[R S R=0 Q
        W *7," Enter Y or N please" G SURE
        -
DIS     W !,"BLOCK ",BLK,":",STRNO,! S N=0
        F I=0:1:398 W:I#4=0 ! W ?I#4*20,BLK+I-399,"=" D DIS1
        W !!,"Total free blocks: ",N Q:$V(1022,0)=N
        W " Discrepancy: Map thinks ",$V(1022,0)," blocks are free!!" Q
        -
DIS1    S X=$V(I*2,0) I X=65535 W "SYSTEM" Q
        I X=65534 W "BAD" Q
        I X=65533 W "DISCREP" Q
        I X=0 W "FREE" S N=N+1 Q
        S A=$V(I*2,0)#256,B=$V(I*2+1,0) W A,",",B
        I A,B,A'>MAX,B'>MAX Q
        W " ??" Q
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
