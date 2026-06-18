FIXMAP1 ;REPAIR MAP BLOCK, ALLOCATION WORDS @SMB@
1       R !,"For Block# ",BT G R^FIXMAP:"^"[BT S B=$P(BT,":",1)
        I B?1N.N,B<BLK,BLK-400<B
        E  W *7," Enter ",BLK-399,":",STRNO," thru ",BLK-1,":",STRNO," please." G 1
        S N=B-BLK+399*2,X=$V(N,0) I 'X S W="FREE BLOCK" G R
        I X=65535 S W="SYSTEM BLOCK" G R
        I X=65534 S W="BAD BLOCK" G R
        I X=65533 S W="DISCREPANCY BLOCK" G R
        I X#256'>MAX,X\256'>MAX S W="USED BLOCK" G R
        S W="" W "  ** Illegal word: ",X," **"
R       R !,"Allocation word: " W:W]"" "<",W,"> " R R S:R="" R=W G RQ:R="?",NA:"^"[R
        F I=1:1 S O="O"_I,L=$T(@O),X=","_I_"," G ER:L="" S L=$P(L,";;",2) Q:$E(L,1,$L(R))=R
        W $E(L,$L(R)+1,999) G @O,NA
        -
RQ      W ! F I=1:1 S O="O"_I,L=$T(@O),X=","_I_"," G R:L="" W !,$P(L,";;",2)
        -
ER      W " Type ? for list" G R
        -
DONE    U 0 W " Done." G 1
        -
NA      U 0 W " No action taken." G 1
        -
O       ;;OPTIONS
O1      S X=0 G SET ;;FREE BLOCK
O2      S X=65535 G SET ;;SYSTEM BLOCK
O3      S X=65534 G SET ;;BAD BLOCK
O4      S X=65533 G SET ;;DISCREPANCY BLOCK
O5      ;;USED BLOCK
        S (UCI,UCIS)="",X=$V(N,0)#256 S:X'>MAX&X UCI=X S X=$V(N+1,0)
        S:X'>MAX&X UCIS=X
UCI     W !,"Belongs to UCI: " W:UCI]"" "<",UCI,"> " R R S:R="" R=UCI
        G R:"^"[R I R?.N,R'>MAX,R S UCI=R G UCIS
        W *7," Enter 1 thru ",MAX," please" G UCI
        -
UCIS    W !,"Set by UCI: " W:UCIS]"" "<",UCIS,"> " R R S:R="" R=UCIS
        G UCI:"^"[R I R?.N,R'>MAX,R S X=R*256+UCI G SET
        W *7," Enter 1 thru ",MAX," please" G UCIS
        -
SET     S I=0 I X,'$V(N,0) S I=-1
        I 'X,$V(N,0) S I=1
        V N:0:X S X=$V(1022,0)+I I X'<0,X'>399 V 1022:0:X G DONE
        W !,"Done.  Illegal free count detected." G FC^FIXMAP
