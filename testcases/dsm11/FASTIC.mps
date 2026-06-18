FASTIC  ;9-Jan-86 ;DSM-11 ;V 3.2 ;Fast Integrity Check ;kfd
        I ^SYS(^SYS(0,"RUNNING"),"OPTIONS","SDP")'="Y" W !,"Please include SDP in this configuration" Q
        S $ZT="TRAP" L ^FIC:2 G START:$T
        W !,"Sorry, integrity checker is already running " Q
START   ;
        O 63::1 I '$T W !," View device is unavailable ! " Q
CHK     D START^%STRTAB S (XST,MAPS)="",%IOD=$I K SWITCH
RD      R !!,"Integrity Check for which volume set ? < S0 > ",STR
        G:STR="^" EXIT S:STR="" STR="S0"
        I STR'?1"S"1N&(STR'?3U) D HELP G RD
        F I=1:1 S XST=$O(STR(XST)) Q:XST=""  G:XST=$E(STR,2)!(STR=STR(XST)) MNT
        W !!,"Volume set ",STR," not in system",! G RD
MNT     I STR(XST)="" W !!,"There is no disk mounted in Volume set ",STR
        I  W !,"Type ""D ^MOUNT"" to mount the Volume set.",! G START
MAPS    F I=$O(STR(XST,"")):0 D  S I=$O(STR(XST,I)) Q:I=""
        .S DSK=STR(XST,I),NMA=$P(DSK,":",2),MAPS=MAPS+NMA
        .S DSK=$P(DSK,":",1),UNIT=$E(DSK,3),IDT=$E(DSK,1,2) Q:DSK'?2U1N
        .S NUM=$F(TYPES,IDT)\3-1*8+UNIT*4,MAP(I)=NMA_":"_NUM
SYS     S ST=$V(44),STRTAB=$V(ST+12),STRSIZ=$V(ST+34)#256,XFRT=$V(ST+316)
        S VWMAX=$V(ST+352),GBFNUM=$V(ST+32),N=GBFNUM-1\64,HASH=1,HD=""
        F I=1:1 Q:'N  S HASH=HASH*2,N=N\2
        S MINBUF=HASH*2+2,TOTNUM=GBFNUM-MINBUF,BYTSIZ=MAPS*100,SWITCH=""
        I TOTNUM-2*1024<BYTSIZ G BITLM
        S ALLOC=TOTNUM*1024-BYTSIZ\1024,ALLOC=$S(ALLOC>VWMAX:VWMAX,1:ALLOC)
        S ALLOC=$S(ALLOC>127:127,1:ALLOC),VWSIZ=$V(ST+312)
        S TOTNUM=BYTSIZ\1024+1+ALLOC,MINBUF=GBFNUM-TOTNUM,BLKLIM=MAPS*400
VIEW    S $ZT="RESET1",SWITCH=0 B 0
        V ST::$V(ST)\8192+1#2*8192+$V(ST)
        V ST+74::$J*2*256+($V(ST+74)#256)
        V ST+312::TOTNUM
        V ST+352::TOTNUM
        V ST+32::MINBUF
        C 63 O 63:(TOTNUM):1 S SUC=$T
        D RESET S SWITCH=1
        I 'SUC W !,"Not able to access global buffers" G EXIT
DEV     S %QTY=2,%DEF="0" D ^%IOS G EXIT:'$D(%IOD)
        I "SC^LP^TRM"'[%DTY!(%DTY="") D IV G DEV
        S $ZT="EXITA"
        I %IOD'=$I W !,"Terminal is now available for login",!,*7 C $I
PASS    K SET S SET=0,%=",",CHK="",REP=""
        S IST="S VAL=$ZC(IC,$P(MAP(I),"":"",2),MAP(I)+0,ALLOC,BLKLIM"
        F PASS=0,1 D
        .I PASS,$O(SET(""))="" S VAL=$ZC(IC) D NFPW Q
CLEAR   .S BYTCNT=BYTSIZ\1024+1
        .U 63:(ALLOC+1:BYTCNT)
        .S CNT=BYTCNT*1024
        .V 0:0:0
        .F DST=2:0:CNT-1 D
        ..S EXT=$S(DST>32767:32768,1:DST)
        ..S EXT=$S(EXT+DST>CNT:CNT-DST,1:EXT)
        ..V DST:0:0:0:EXT S DST=DST+EXT
UCIBL   .U 63:(1:1:"Z"),%IOD V 0:"S"_XST
        .S UCIBLK=$V(512+400,0)#256*65536+$V(512+398,0),VOLS=$V(512+401,0)
        .U 63:(1:1:"C"),%IOD V UCIBLK:"S"_XST
        .F UTAB=0:20 Q:'$V(UTAB,0)  D  U 63:(1:1:"C"),%IOD
        ..S GLOBLN=$V(UTAB+4,0)#256*65536+$V(UTAB+2,0)
        ..S ROUBLN=$V(UTAB+4,0)\256*65536+$V(UTAB+6,0)
        ..S FILBLN=$V(UTAB+18,0)#256*65536+$V(UTAB+16,0)
        ..S CP=1,DP=1 F BLKNUM=GLOBLN D SETBITS
        ..S CP=0 F BLKNUM=ROUBLN,FILBLN D SETBITS
        .I PASS F T=0:1 Q:'$D(SET(T))  D
        ..S CDE=SET(T)+0,BLKNUM=$P(SET(T),%,2)
        ..S CP=CDE=2,DP='CP D SETBITS
ZCALL   .F VER=0,1 D STMP F I=1:1:VOLS D  Q:VER
        ..F O=VER:1 X $P(IST,%,1,'O*6+1)_")" Q:VAL="0"  D
        ...U %IOD D:$Y>62 HEAD
        ...S PBK="* * * *" F X=1:1:$L(VAL,%) D
        ....S @($P("BWB,OFB,CDE,PBK",%,$L(VAL,%)-X+1)_"=$P(VAL,%,X)")
        ...I VER S OFB=PBK,(BWB,PBK)="* * * *",CDE=CDE+6
        ...I CDE<3,X=3 S PBK=OFB
        ...I BLKLIM'>PBK Q:PASS  S CDE=CDE+8
        ...I $S('PASS:CDE<3,1:CDE>2) D  Q
        ....S:'PASS&'CHK SET(SET)=CDE_%_PBK,SET=SET+1 Q:$S>1000!PASS!CHK
        ....S $P(SET(0),%,3)="*",CHK=1
        ...I CDE>8!PASS S X=OFB,OFB=PBK,PBK=X
        ...S OXT=$P($T(DES+CDE),":",2,99),REP=1
        ...W !,$P(OXT,":",1),$J($P(OXT,":",2),9),$J(OFB,9)
        ...W:PBK+0 $J($P(OXT,":",3),9),$J(PBK,8)
        ...W:BWB'["* * " " Byte within the block ",$J(BWB,4)
        ...W " ",$P(OXT,":",4)
        I $D(SET(0)),SET(0)["*" D WARN
        I 'REP W !,"<No Problems found in ",STR," >",*7
        G EXIT
SETBITS Q:BLKNUM=0
        U 63:(BLKNUM\4096+1+ALLOC:1:"C"),%IOD
        S WORD=BLKNUM\8#512,BIT=1
        F POW=1:1:BLKNUM#8 S BIT=BIT*4
        F Y=DP,CP D  S BIT=BIT*2
        .V:Y WORD*2:0:$V(WORD*2,0)\BIT+1#2*BIT+$V(WORD*2,0)
        Q
RESET1  S SWITCH=1
RESET   ;
        V ST+74::$V(ST+74)#256 Q:'SWITCH
        V ST+316::XFRT,ST+312::VWSIZ
        V ST+32::GBFNUM,ST+352::VWMAX
        V ST::$V(ST)\8192#2*-8192+$V(ST)
        Q
IV      W !!,"Incorrect response - Enter '?' for help",! Q
HELP    W !!,"Enter valid Volume set number (ex. S0) or name (ex. SYS)"
        W !?8,"in the configuration you are currently running for which"
        W !?8,"you want to run the integrity checker",!! Q
TRAP    ;;U 0 W !,$ZE
EXITA   U 0 W !,$ZE
EXIT    I $D(SWITCH) D RESET
        C 63
        I $D(%IOD),%IOD'=$I C %IOD L  H
        L
        K
        B 1
        Q
NFPW    W !,"Final pass not needed " D DSTM Q
BITLM   W !!,"There is not enough Global Buffer space to create"
        W !,"the in-memory bit map, please add more buffers at SYSGEN" Q
STMP    U %IOD W:'HD # W ! W:'PASS!'VER !! W $S(PASS:"Final",VER:"Verify of",'PASS:"Initial")
        W $S('PASS&VER:" in memory bit map",1:" disk scan")
        W " is ",$S(PASS&VER:"complete",1:"beginning")
        D DSTM,HEAD:'PASS!'VER Q
DSTM    S %DT=$P($H,%,1),%TM=$P($H,%,2)
        D %CDS^%H,%CTS^%H
        W !,%DAT1," ",%TIM1," . . . "
        Q
WARN    U %IOD W !,"Warning, this number of errors has exceeded the available"
        W !,"partition space, please correct the errors displayed, and"
        W !,"rerun the Integrity Check, repeat process until this message "
        W !,"disappears !"
        Q
        Q
HEAD    U %IOD S HD=1 W:$Y>62 #
        W !!?25,"FAST INTEGRITY CHECKER"
        W !?30,"Volume Set ",STR,!
        Q
DES     ;
        :Duplicate Down  Pointer:to Block: from Block
        :Duplicate Right Pointer:to Block: from Block
        :Invalid Character Count:in Block::(Remainder of Block is skipped !)
        :Invalid Offset         :in Block::(Remainder of Block is skipped !)
        :Invalid Block Type     :in Block::(Remainder of Block is skipped !)
        :Corrupted Map Block    :in Block::( All blocks in this Map are skipped !)
        :Down  Pointer Missing:to Block
        :Right Pointer Missing:to Block
        :Illegal Down  Pointer  :to Block: from Block
        :Illegal Right Pointer  :to Block: from Block
