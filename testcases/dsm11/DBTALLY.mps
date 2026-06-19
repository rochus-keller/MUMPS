DBTALLY ;ACTUAL CALCULATION OF TALLY BY MARCHING THROUGH MAP BLOCKS.
        W !,"THIS IS A SUBROUTINE OF DBT",!! Q
T       S I=0 W !!
T1      S I=I+1,FLG=0 I I>DSK(0) G DONE
        S ADR=0,NMP=$P(DSK(I),":",2),DDU=$P(DSK(I),":")
        S MAP=0,(TF,TA,TSD,TSP,TJR,TBD,TSYS)=0 K TUCI
HDR     D INT^%D,INT^%T U %IOD W #,!,"**",DDU,"**     ",%DAT1,"  ",%TIM,!!
        W ?8,"Free",?16,"Alloc",?27,"Bad",?37,"UCI",?43,"Allocated",?59,"Caused",!
        S B="Blocks" W "Map",?7,B,?16,B,?26,B,?46,"to",?57,"allocation"
T2      S MAP=MAP+1 I MAP>NMP G SUBT
        S BLK=ADR+(MAP*400-1),(F,A,NM,SD,SP,JR,BD,SYS)=0
        V BLK:DDU I '($V(1006,0)=65535!($V(1012,0)=32769)) S NM=399 G SHOW
        S SDP=$V(1008,0)=43690&($V(1010,0)=21845),SPL=$V(1008,0)=56173,JRN=$V(1008,0)=13107&($V(1010,0)=52428),FBC=$V(1022,0)
        I SDP S SD=399 D SHOW G T2
        I JRN S JR=399 D SHOW G T2
        I SPL S SP=399 D SHOW G T2
        S P=-2
T3      S P=P+2 I P>796 D SHOW G T2
        S X=$V(P,0) I X=65535 S SYS=SYS+1,A=A+1 G T3
        I 'X S F=F+1 G T3
        S H=X\256#256,L=X#256 I H=255 S BD=BD+1 G T3
        S A=A+1,H=H#90,L=L#90
        I '$D(UCI(H)) S UCI(H)="0/0"
        I '$D(UCI(L)) S UCI(L)="0/0"
        S UCI(L)=+UCI(L)_"/"_($P(UCI(L),"/",2)+1),UCI(H)=+UCI(H)+1_"/"_$P(UCI(H),"/",2)
        G T3
SHOW    W !," ",MAP-1,?9,F,?17,A,?26,BD
        I NM=399 W !,"Map block corrupted (words 1006 and 1012 are wrong)",! G T2
        I SYS W ?35,"SYSTEM",?45,SYS,?61,SYS,!
        I SP!(SD)!(JR) W ?35,$S(SP:"*SPL*",SD:"*SDP*",JR:"*JRN*"),?45,"399",?61,"399",!
        S J=""
SUCI    S J=$ZS(UCI(J)) I J="" G STOT
        S X=J I '$D(U(J)) S X=0,FLG=1
        W ?37,U(X),?45,$P(UCI(J),"/",2),?61,+UCI(J),!
        I '$D(TUCI(J)) S TUCI(J)="0/0"
        S TUCI(J)=+TUCI(J)+UCI(J)_"/"_($P(UCI(J),"/",2)+$P(TUCI(J),"/",2))
        G SUCI
STOT    I FBC=F G ST1
        W !,"Map ",MAP-1," Discrepancy -  F.B.C.= ",FBC,"   Counted ",F," Blocks"
        S BAD=255*256+253
        F K=0:2:796 I '$V(K,0) V K:0:BAD
        V 1022:0:0,-BLK:DDU
ST1     S TF=TF+F,TA=TA+A,TSD=TSD+SD,TSP=TSP+SP,TJR=TJR+JR,TBD=TBD+BD,TSYS=TSYS+SYS
        K UCI Q
SUBT    W !!,"Subtotal",?9,TF,?16,TA,?24,TBD
        I TSYS W ?35,"SYSTEM",?45,TSYS,?61,TSYS,!
        S J=""
SUB1    S J=$ZS(TUCI(J)) I J="" W ?35,"*SDP*",?45,TSD,?61,TSD,!,?35,"*SPL*",?45,TSP,?61,TSP,!,?35,"*JRN*",?45,TJR,?61,TJR,! D:FLG UNK G T1
        S X=J I '$D(U(J)) S X=0,FLG=1
        W ?35,U(X),?45,$P(TUCI(J),"/",2),?61,+TUCI(J),!
        G SUB1
UNK     W !!,"A map word contained a number that is not in the UCI table and is",!,"designated as ""???""",!! Q
DONE    U 0 I %IOD'=$I C %IOD
        C 63 K A,ADR,BLK,DISKTAB,DSK,F,FBC,FLG,H,I,J,L,MAP,NMP,P,S,SDP,ST,SYS,TA,TF,TS,TSYS,TUCI,U,UCI,UNUM,UTAB,Z,%DTY,%IOD
        K %DAT,%DAT1,%TIM,%TIM1,B,BD,C,JR,JRN,M,N,NAM,NM,OFFSET,PTR,SATBEG
        K SD,SP,SPL,TBD,TJR,TSD,TSP,TY,UN,X
        Q
