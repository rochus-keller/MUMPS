%RM1    ;17-Jan-86 ;UTILITIES ;LIBRARY ;GET MAPPED ROUTINE ;SMB
1       W ! D ROUNAM Q:"^"[R
        D INT W !,ROUSTA G 1
        -
ROUNAM  ;
        D VARS I ROUSTR'=0 W !,*7,ROUSTA S R="" Q
        R !,"Routine: ",R,! Q:"^"[R
        I R="*L" D LIST G ROUNAM
        I R'?.1"%"1A.AN W *7," Enter *L for a list, or a nice routine name, please" G ROUNAM
        Q
LIST    F RN=0:1:RNUM-1 W:RN#8=0 ! D L1
        Q
L1      W ?RN#8*10
        F I=0:1:7 S X=$V(RN*8+I,MMNAM)#256 Q:X=255  W *X
        I '$V(RN*2,MMADR) W "*"
        Q
        -
VARS    ;
        S ST=$V(44),ROUMAP=$V(ST+38),ROUSTR=0,ROUSTA=""
        I 'ROUMAP S ROUSTR=-1,ROUSTA="No rouitne mapping set up." Q
        S UCN=$ZU(""),UCN=$P(UCN,",",2)*32+UCN
        F ENT=0:1 G GOTMAP:$V(ENT*8,ROUMAP)#256=UCN Q:'$V(ENT*8,ROUMAP)
        S ROUSTR=-2,ROUSTA="UCI has no routine Mapping" Q
        -
GOTMAP  I $V(ENT*8+1,ROUMAP) S ROUSTR=-3,ROUSTA="Routine Mapping disabled for UCI" Q
        S RNUM=$V(ENT*8+2,ROUMAP),MMNAM=$V(ENT*8+6,ROUMAP),MMADR=$V(ENT*8+4,ROUMAP)
        S ROUSTR=0 Q
        -
INT     ;
        N ENT,I,MMADR,MMNAM,RN,RNAM,RNUM,ROUMAP,ST,UCN
        D VARS Q:ROUSTR'=0
        F I=$L(R)+1:1:8 S R=R_$C(255)
        F I=0:1:3 S RNAM(I)=$A(R,I*2+2)*256+$A(R,I*2+1)
        F RN=0:1:RNUM-1 F I=0:1:3 Q:$V(RN*8+(I*2),MMNAM)'=RNAM(I)  G GOTROU:I=3
        S ROUSTR=-4,ROUSTA="Routine not mapped" Q
        -
GOTROU  S ROUSTR=$V(RN*2,MMADR)
        I 'ROUSTR S ROUSTA="Routine mapped but disabled" Q
        S ROUSTA="Routine Mapped" Q
