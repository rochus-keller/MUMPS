RESTDOMG        Q  ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
RE      ;
        S $ZT="ER" B 0 B 2
        G BOTH:'RESY U 63:(2:1),0 D MNTIT G TERM:%FAIL
        S I1=816,SZ=22 D GTF G BOTH:M=ML&MAS
        W !,"! WRONG DISK - HAS " W:MAS "MASTER" W:'MAS "BACKUP"
        W " LABEL ",M,! G S
BOTH    U 63:(1:2),0 S MP=$V(1024+812,0)
        I MP<MAPS W !,"The target disk is too small for this BACKUP",! G S
        I MP=MAPS G BBTAB
        I $C($V(909,0))>1 W !,"The target disk is the wrong size or type for this BACKUP",! G S
        I $V(909,0) V 914:0:DE-$V(ST+224)\32*256+($V(DE)#256)
BBTAB   V DE+2::MP S MMS=$V(DE)\256#64+$V($V(44)+86)
        F I=0:2:190 V I:MMS:$V(1024+512+I,0)
LABEL   S ME=MAPS*400+MB
        F I=496,498,704:2:811,904:2:983 V I+1024:0:$V(I,0)
        V 8+1024:0:$V(8+1024,0)#256+($V(9,0)*256)
        U 63:(2:1) S V=$V(ST+310)\4*4+($V(ST+310)#2),WB=MB
        V ST+310::V+2 S $ZT="DEW" U 63:(::"Z"),0 V:MB -MB:MD_MU V:'MB -16777216:MD_MU U 63:(::"C"),0 S $ZT="ER" V ST+310::V
        S WB=MB+1,(B0,B1,TMK)=0 U 0 D WRTTI W "BEGIN RESTORE",! G IU:IU
ALL     S C=ME G STR
DON     D WRTTI W "RESTORE COMPLETE",!! G REMNT
IU      S MAP=0,W=2
IU2     G DON:MAP'<MAPS S MJ=MAP*400+399+MB,K=0
        S WW=WB,WB=MJ,C=MJ+1 D MC S WB=WW U 63:(BF:1),0 V MJ:MD_MU
        I $V(1008,0)=21845,$V(1010,0)=43690,$V(1022,0)=399 G NXTMP
        S C=MJ D MC
NXTMP   S MAP=MAP+1,WB=MAP*400+MB,W=0 G IU2
MC      S BW=C-WB,B2=B1-B0 I 'B2 D FILL S B2=B1-B0
        I BW'>B2 U 63:(B0+1:BW),0 V -WB:MD_MU S WB=WB+BW,B0=B0+BW Q
        U 63:(B0+1:B2),0 V -WB:MD_MU S WB=WB+B2 D FILL G MC
FILL    R *A:0 I  G FILL:A'=27 D ESC
        S B0=0,B1=P I TMK D NXVL G TERM:%FAIL S TMK=0
        F M0=1:FAC:P U UU:(MFS:M0-1*1024) W *6 S ZB=$ZB=MFS G:$ZA>127!($ZA<64) TER G:'ZB LER
        U 0 Q
STR     S STOK=0,TMK=0 I BF'<(FAC*2) S STOK=1
NXTTAP  I TMK D NXVL G TERM:%FAIL S TMK=0
STRM    S $ZT="TER",J=0 U 0:(:::::::::$C(3,27)) B 0
        I STOK U 63:(FAC+1:FAC),UU:(MFS:MFS) W *6,*10
        U 63:(1:FAC)
        F WB=WB:FAC D:$V(2,$J)\8#2 ESC U UU:(MFS:MFS*J) W *6 S:STOK J='J U 63:(FAC*J+1:FAC) U:(WB+FAC>ME) 63:(FAC*J+1:ME-WB) V -WB:M
D_MU
F2      G:LER LER G:'IU DON S B1=M0-1+FAC Q
TER     S TMK=$ZA\16384#2,A=$ZA\1024#2,A=$ZA-(TMK*16384)-(A*1024),LER=$ZA\512#2
        U 0 I A>63,A<128,'IU G:'TMK F2 G:(WB'>ME) NXTTAP G DON
        U 0 I A>63,A<128,IU G:'TMK F2 S B1=M0-1 G:'B1 FILL Q
        W !!,"TAPE ERR !",!,"$ZA= ",A+(TMK*16384)," DECIMAL",!
HS      W " -- UNABLE TO PROCEED",! S $ZE="S",=
LER     U UU S A=$ZB U 0 W !,"TAPE RECORD-LEN ERR:",!
        W "EXPECTED LEN: ",MFS," BYTS;  ACTUAL: ",A,! G HS
GTF     S M="""" F I=I1:1:I1+SZ-1 Q:$V(I,0)#256=0  S M=M_$C($V(I,0)#128)
        S M=M_"""" Q
MHA     D MHLP
MNTIT   S %FAIL=0 W !,"Please mount "
        W "the Master disk to be restored *TO*,  label =  ",ML,!
MNT2    W "in drive ",DDU,", *WRITE-ENABLED*"
MCR     R !,"  THEN TYPE  <CR>   ",A,! I A="^" S %FAIL=1 Q
        G:A'="" MHA
MOU     V DE::$V(DE)#16384+16384,DE+2::0
        U 63:(::"TZ"),0 V @B S A=$ZA\64#2 U 63:(::"C"),0 I A W !,"Disk not ready?" G MHA
        D DSM G:'M MHA
        S I1=816,SZ=22 D GTF
        Q
MHLP    W !,"Please mount the correct " W:'MAG "disk" W:MAG "tape"
        W !," and type  <CR>, otherwise ",!
        W "type   ^   if you do not wish to proceed with the Restore",! Q
TERM    U 0 W !,"TERMINATED BY OPR.",! G AB
S       W " -- STOPPING."
AB      S $ZT="REMNT",=
REMNT   ;
        G RET:'RESY
REM2    U 0 W !,"Please re-mount the original system disk:  ",MSY,!
        W "in drive ",SYU,"  *WRITE-ENABLED*",!
        W "  THEN TYPE  <CR>   " F I=1:1 R *A:0 E  Q
        R A,! G REM2:A'=""
        V MDE::MSAV,MDE+2::MBB
        U 63:(1:1:"Z"),0 V MB:MD_MU U 63:(::"C"),0 S I1=816,SZ=22 D GTF G REM2:M'=MSY
RET     G FIN^RESTMNT
DEW     V ST+310::V
ER      G ER2:$ZE'?1"<DK".E
        U 0 W !,"! ERROR:  ",$ZE,!,"WRITING NEAR BLK # ",WB,":",MD,MU G S
ER2     U 0 W !,"! ERROR:  ",$ZE,! G S
ESC     B:'IU 0 U 0 W !,?2,WB-MB," BLKS PROCESSED, ",ME-WB," TO GO.",!
ES2     R "TYPE  <CR>  TO CONTINUE,",!,?7,"^    TO TERMINATE  : ",A,!
        Q:A=""  G ES2:A'="^" S $ZT="TERM",= FAKE ERR TO POP STACK
NXVL    U UU W *5 U 0 W !!,"** END OF BACKUP TAPE # ",VL,! S VL=VL+1 G NX2
NXH     D MHLP
NX2     S MA=0 W !,"Please mount backup Tape # ",VL," on Magtape Unit# ",UU-47
NXR     R !,"  then type  <CR>   ",A,! S %FAIL=0 I A="^" S %FAIL=1 Q
        G NXH:A'="" U 63:(1:1),UU:(512:512) W *5,*6,*10 H 1 S A=$ZA U 0
        I A\64#2=0 W !,"OFF-LINE !" G NXH
        I A>127 W !,"TAPE ERR !" G NXH
NM      D DSM G NXH:'M
        S TT=$C($V(878,0)#128,$V(879,0)#128),VV=$V(880,0)#H
        G WR:(VV'=VL)
        S I1=838,SZ=22 D GTF G WR:M'=ML
        S I1=869,SZ=9 D GTF S:VL=1 BDA=$E(M,2,10) G WR:$E(M,2,10)'=BDA
        Q
WR      W !,"! LABEL EXPECTED:  ******, BACKUP VOL # ",VL," OF "
        W MD," MASTER: ",ML,! W:VL>1 " CREATED ",BDA,!
        W !,"LABEL FOUND:  BACKUP LABEL "
        S I1=816,SZ=22 D GTF W M S I1=838 D GTF
        I $L(M)<3 W !," -- NOTHING BACKED UP ON THIS TAPE!",! G NXH
        W !,"BACKUP VOL # ",VV," OF ",TT," MASTER: ",M
        W " CREATED " S I1=869,SZ=9 D GTF W $E(M,2,$L(M)-1),! G NXH
DSM     S MAS=$V(814,0)#H=$A("M"),I1=882,SZ=8 D GTF S M=M["DSM11 V3" Q:M
        W !,"CONTAINS NO VALID DSM11 V3 LABEL!",! Q
WRTTI   S TI=$P($H,",",2),T1=TI\3600,T2=TI#3600\60,TI=TI#60
        S:T2<10 T2=0_T2 S:TI<10 TI=0_TI W !,"**",$J(T1_":"_T2_":"_TI,9),"   "
        K T1,T2,TI Q
