MSUROU  ;SUBROUTINES FOR UCI MANIPULATIONS
        Q
SETUP   D A,B,C Q
SETUVARS        S Q=0,AL=1,TAB=12 D GET S A(2)=X,GD=X#M,GDH=X\M
        S AL=0,TAB=23 D GET S A(3)=X,GPA=X\400
        S AL=1,TAB=38 D GET S A(4)=X,RD=X#M,RDH=X\M
        S AL=1,TAB=51 D GET S A(5)=X,RGA=X\400 D F
        S AL=0,TAB=65 D GET S A(6)=X,GDA=X\400
        D B I Q W !,"  *ACTUAL*" D C2
        E  D CC
        Q
A       ;
        S LKUOFF=UCINO-1*20
        F I=0:1 S TYP(I)=$P(TYPES,",",I+1) Q:TYP(I)=""
        S X=$V(LKUOFF,LKU)/2 F I=1:1:3 S X(I)=X#32,X=X\32,X(I)=X(I)+64
        S A(2)=$V(LKUOFF+4,LKU)#256*M+$V(LKUOFF+2,LKU),A(4)=$V(LKUOFF+5,LKU)*M+$V(LKUOFF+6,LKU)
        S A(5)=$V(LKUOFF+8,LKU)*400,A(6)=$V(LKUOFF+10,LKU)*400
        S A(3)=$V(LKUOFF+12,LKU)*400
        Q
B       ;
        F I=2:1:6 S BLK=A(I) D GETBL S B(I)=BLK
        Q
C       ;
        W !,UCINO,?5,*X(3),*X(2),*X(1)
C2      W ?12,B(2),?23,B(3),?38,B(4),?51,B(5),?65,B(6)
CC      W !,?12,A(2),":",STRNO,?23,A(3),":",STRNO,?38,A(4),":",STRNO,?51,A(5),":",STRNO,?65,A(6),":",STRNO
        Q
ASK     R ?TAB,X S (DBDEF,SW)=0 I X="" S DBDEF=1,SW=1 Q
D       ;
        G D1:X'?2A1N1":"1N.N1":"1N.N
        S TYPE=$P(X,":",1) S TYPE=$E(TYPE,1,2) F I=1:1:3 S X(I)=$P(X,":",I)
        S U=$E(X(1),3) G D1:U>7
        S X(1)=$F(TYPES,TYPE)\3-1 G D1A:X(1)<0,D1:X(3)>399
        S NXSTR=""
        F I=1:1 S NXSTR=$O(STR(NXSTR)) Q:NXSTR=""  S NXVOL="" F K=1:1 S NXVOL=$O(STR(NXSTR,NXVOL)) Q:NXVOL=""  I $P(STR(NXSTR,NXVOL)
,":",1)=(TYPE_U) G E
        G D1A
E       U 63:(::"Z") V 0:$P(STR(NXSTR,NXVOL),":",1) U 63:(::"C"),0 S MPS=$V(512+300,0)
        G D2A:X(2)'<MPS
        S X=X(2)*400+X(3)
        Q
D2A     W !,"Map no. must be less than ",MPS G D1
D1A     W !,"No such disk in configuration "
D1      W " ???",! G ASK
GET     ;
        D ASK
        I DBDEF S BLK=XS D GETBL F I=1:1:3 S X(I)=$P(BLK,":",I)
        I DBDEF S TYPE=$E(X(1),1,2),U=$E(X(1),3),X=X(2)*400+X(3) U 63:(::"Z") V 0:TYPE_U U 63:(::"C"),0 S MPS=$V(512+300,0)
        S MAP=X\400,NB=MPS
        S XO=X,M0=0,BLB=X#400 G NXMP:MAP'<NB
AL1     ;
        S VB=MAP*400+399 U 63:(::"CP") S BLK=TYPE_U_":"_VB D GETDB V BLK:STRNO
        I $V(1010,0)=43690&($V(1012,0)=32769) F I=BLB*2:2:796 G E1:'$V(I,0)
NXMP    S BLB=0,MAP=MAP+1 G AL1:MAP<NB,NS:M0 S M0=1,MAP=0,X=1 G AL1
NS      U 63:(::"C") U 0 W !,"No space on ",TYPE,U,! G GET
E1      I AL V I:0:UCINO*256+UCINO,1022:0:$V(1022,0)-1,-BLK:STRNO
        U 63:(::"C") U 0 S X=I\2+(MAP*400)
E2      S BLK=(TYPE_U)_":"_(X\400)_":"_(X#400) D GETDB S X=BLK,XS=X+1 I SW W TYPE,U,":",MAP,":",I\2 Q
        I X-(MAPS*400)'=XO S Q=1 W "*"
        Q
F       U 63:(::"CP") S BLK=GDH*M+GD V BLK:STRNO,1014:0:0,1016:0:0,1018:0:0,1020:0:256,1022:0:0,-BLK:STRNO
        S BLK=RDH*M+RD V BLK:STRNO,0:0:256,2:0:X#256*256+64,4:0:X\256,1022:0:6,1020:0:6*256 F I=1010:2:1018 V I:0:0
        V -BLK:STRNO
        S BLK=X V BLK:STRNO,2:0:64,0:0:256,4:0:0 F I=1010:2:1018 V I:0:0
        V 1020:0:16*256,1022:0:6,-BLK:STRNO U 63:(::"C") U 0
        Q
GETBL   S K=1,STRNR=$E(STRNO,2)
CON     I '$D(STR(STRNR,K)) S ERROR=1 Q
        S STRVOL=STR(STRNR,K),MAPS=$P(STRVOL,":",2)
        I BLK'<(400*MAPS) S K=K+1,BLK=BLK-(400*MAPS) G CON
        S BLK=$P(STRVOL,":",1)_":"_(BLK\400)_":"_(BLK#400),ERROR=0
        Q
GETDB   S MAPS=0,K=1,STRNR=$E(STRNO,2),DSKTYP=$P(BLK,":",1)
CONT    I '$D(STR(STRNR,K)) S ERROR=1 Q
        I DSKTYP'=$P(STR(STRNR,K),":",1) S MAPS=MAPS+$P(STR(STRNR,K),":",2),K=K+1 G CONT
        I $P(BLK,":",3)="" S BLK=400*MAPS+$P(BLK,":",2),ERROR=0 Q
        S BLK=400*MAPS+(400*$P(BLK,":",2))+$P(BLK,":",3),ERROR=0
        Q
HEADER  W !!,"Enter disk data as   DDU:M:BL",!,?10,"Where  DD = disk type",!,?17,"U  = unit no.",!,?17,"M  = map no.",!,?17,"BL = bl
ock no. within map",!
        W "or hit  <CR>  to accept default values.",!!
        W "For ""UCI name"" enter 3 alphabetic chars., or hit  <CR>  if done adding UCIs.",!
HDR2    W !!,?12,"GLOBAL",?23,"NEW GLOBALS",?38,"ROUTINE",?51,"NEW ROUTINE",?65,"NEW GLOBALS"
        W !,"UCI# NAME   DIRECTORY  POINTER AREA",?38,"DIRECTORY  ",?51,"GROWTH AREA  ",?65,"DATA AREA"
        W !,"---------   ---------  ------------",?38,"--------- ",?51,"------------  ",?65,"---------"
        D TYPES^SYSROU F I=0:1 S TYP(I)=$P(TYPES,",",I+1) I TYP(I)="" K TYP(I) Q
        Q
