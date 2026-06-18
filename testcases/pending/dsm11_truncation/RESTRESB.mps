RESTRESB        Q  ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
RE      ;
        S $ZT="ER" B 0 B 2
        S VL=1 D NX2 G TERM:%FAIL S MAPS=$V(902,0),IU=$V(881,0),MBS=$V(815,0)
        S XE=$V(812,0)*400+XB
        U 63:(2:1),0 S MP=$V(812,0)
        I MP<MAPS W !,"Master disk is too small to recover the restored database",! G S
        I MBS U 63:(1:1:"C"),0 V 0:XD_XU V 914:0:$V(XDE)#256+((XDE-$V(ST+224)\32)*256)
NOBB    U 63:(1:2),0 S ME=MAPS*400+MB
        F I=496,498,704:2:811,904:2:983 V I+1024:0:$V(I,0)
        V 8+1024:0:$V(9,0)*256+($V(8+1024,0)#256)
        S V=$V(ST+310)\4*4+($V(ST+310)#2),WB=MB
        U 63:(2:1:"Z"),0 V ST+310::V+2 S $ZT="DEW" V -16777216:MD_MU S $ZT="ER" V ST+310::V U 63:(::"C"),0
        S WB=MB+1,RB=XB+1 U 0 D WRTTI W "BEGIN RESTORE",! G IU:IU
ALL     S C=ME,P=BF D C G DON
IU      S MAP=0,W=2
IU2     G DON:MAP'<MAPS S MJ=MAP*400+399+MB,K=0
        I RB'<XE D NXVL G TERM:%FAIL
        U 63:(BF:1) V RB:XD_XU S RB=RB+1 U 0 V -MJ:MD_MU
R       R *A:0 I  G R:A'=27 D ESC
        I $V(1008,0)=21845,$V(1010,0)=43690,$V(1022,0)=399 G NXTMP
        S C=MJ,P=BF D C
NXTMP   S MAP=MAP+1,WB=MAP*400+MB,W=0 G IU2
DON     U 0 D WRTTI W "RESTORE COMPLETE",!! G REMNT
C       U 0 R *A:0 I  G C:A'=27 D ESC
        I WB+P>C S P=C-WB Q:'P
        I RB+P'>XE U 63:(1:P) V RB:XD_XU U 0 S RB=RB+P V -WB:MD_MU S WB=WB+P G C
        S R=XE-RB I R U 63:(1:R) V RB:XD_XU U 0 V -WB:MD_MU S WB=WB+R
        D NXVL G TERM:%FAIL S P=BF-1 G C
GTF     S M="""" F I=I1:1:I1+SZ-1 Q:$V(I,0)#256=0  S M=M_$C($V(I,0)#128)
        S M=M_"""" Q
MHA     D MHLP
MNTIT   S %FAIL=0 W !,"Please mount "
        W:'MA "the Backup disk to be restored *FROM*",!
        W:MA "the Master disk to be restored *TO*,  label =  ",ML,!
MNT2    W "in drive ",DDU,", *WRITE-"
        W:MA "ENABLED*" W:'MA "PROTECTED*"
MCR     R !,"  THEN TYPE  <CR>   ",A,! I A="^" S %FAIL=1 Q
        G:A'="" MHA
MOU     V DE::$V(DE)#16384+16384,DE+2::0
        U 63:(::"TZ"),0 V @B S A=$ZA\64#2 U 63:(::"C"),0 I A W !,"Disk not ready?" G MHA
        D DSM G:'M MHA
        S I1=816,SZ=22 D GTF
        Q
MHLP    W !,"Please mount the correct disk and type  <CR>, otherwise ",!
        W "type   ^   if you do not wish to proceed with the Restore",! Q
TERM    U 0 W !,"TERMINATED BY OPERATOR.",! G REMNT
S       W " -- STOPPING." G REMNT
REMNT   ;
        G RET:'RESY
REM2    U 0 W !,"Please re-mount the original system disk:  ",MSY,!
        W "in drive ",SYU,"  *WRITE-ENABLED*",!
        W "  THEN TYPE  <CR>   " F I=1:1 R *A:0 E  Q
        R A,! G REM2:A'=""
        V MDE::MSAV,MDE+2::MBB
        U 63:(1:1:"Z"),0 S RB=MB_":"_""""_MD_MU_"""" S:RESY<0 RB=XB_":"_""""_XD_XU_"""" V @RB U 63:(::"C"),0 S I1=816,SZ=22 D GTF G
REM2:M'=MSY
RET     G FIN^RESTMNT
DEW     V ST+310::V
ER      G ER2:$ZE'?1"<DK".E
        S A="WRIT",B=WB_":"_""""_MD_MU_"""" S:$I=63 A="READ",B=RB_":"_""""_XD_XU_"""" U 0
        W !,"! ERROR:  ",$ZE,!,A,"ING NEAR BLK # ",B G S
ER2     U 0 W !,"! ERROR:  ",$ZE,! G S
ESC     U 0 W !,?2,WB-MB," BLKS PROCESSED, ",ME-WB," TO GO.",!
ES2     R "TYPE  <CR>  TO CONTINUE,",!,?7,"^    TO TERMINATE  : ",A,!
        Q:A=""  G ES2:A'="^" S $ZT="TERM",= FAKE ERR TO POP STACK
NXVL    U 0 W !!,"** END OF BACKUP VOLUME # ",VL,! S VL=VL+1
NX2     U 0 W !,"Please mount backup volume # ",VL," in drive ",XD,XU
        W "  *WRITE-PROTECTED*",!
NXR     R "then type  <CR>   ",A,! S %FAIL=0 I A="^" S %FAIL=1 Q
        I A'="" D MHLP G NX2
        U 63:(1:1:"Z"),0 S RB=XB V RB:XD_XU U 63:(::"C"),0 S:VL=1 MBS=$V(815,0) S RB=RB+'MBS
        D DSM I 'M D MHLP G NX2
        G WR:MAS S TT=$C($V(878,0)#128,$V(879,0)#128),VV=$V(880,0)#H
        S I1=838,SZ=22 D GTF I VV'=VL!(M'=ML) G WR
        I TT'=MD&'MBS G WR
        S I1=869,SZ=9 D GTF S:VL=1 BDA=$E(M,2,10) G WR:$E(M,2,10)'=BDA
        V XDE+2::$V(812,0) S MMS=$V(XDE)\256#64+$V($V(44)+86)
        F I=0:2:190 V I:MMS:$V(512+I,0)
        Q
WR      W !,"! LABEL EXPECTED:  ******, BACKUP VOL # ",VL," OF "
        W MD," MASTER: ",ML,! W:VL>1 " CREATED ",BDA,!
        W !,"LABEL FOUND:  " W:MAS "MASTER" W:'MAS "BACKUP" W " LABEL "
        S I1=816,SZ=22 D GTF W M I MAS D MHLP G NX2
        S I1=838 D GTF I $L(M)<3 W !," -- NOTHING BACKED UP ON THIS DISK",!
        I  D MHLP G NX2
        W !,"BACKUP VOL # ",VV," OF ",TT," MASTER: ",M
        W " CREATED " S I1=869,SZ=9 D GTF W $E(M,2,$L(M)-1),! D MHLP G NX2
DSM     S MAS=$V(814,0)#H=$A("M"),I1=882,SZ=8 D GTF S M=M["DSM11 V3" Q:M
        W !,"CONTAINS NO VALID DSM11 V3 LABEL!",! Q
WRTTI   S TI=$P($H,",",2),T1=TI\3600,T2=TI#3600\60,TI=TI#60
        S:T2<10 T2=0_T2 S:TI<10 TI=0_TI W !,"**",$J(T1_":"_T2_":"_TI,9),"   "
        K T1,T2,TI Q
