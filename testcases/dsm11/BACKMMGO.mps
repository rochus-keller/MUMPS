BACKMMGO        Q  ;DSM11 UTILITIES; COPYRIGHT 1980 DEC ;CALLED BY ^BACKSET
M1      S $ZT="E" V ST::SA
        I FM S D=FD_FU,L=FL,MA=1,B=FB_":"_""""_FD_FU_"""",S=FS,DE=FDE,FM=-1 D MNT
        U 63:(1:1:"Z"),0 V FB:FD_FU S FE=$S($V(916,0):$V(916,0),1:$V(812,0))*400+FB
        I $D(UNATTN) S DMSG="BEGIN UNATTENDED BACKUP (BACKUP-COMMAND-FILE: "_NM_")" D HD^BACKUNJR G ST
        D WRTTI W "BEGIN BACKUP # ",N,!
ST      D MWLB U UU:(1024:0) D MAG G MER:EOT
        S B0=0 G IU:IU
ALL     S F=FB+1,C=FE-F\MF*MF+F-MF,R=FE-F#MF,D=FD_FU
AGN     S $ZT="ALLR",J=1 U 0:(:::::::::$C(3,27)) B 0
        F F=F:MF:C D:$V(2,$J)\8#2 ESC U 63:(MF*J+1:MF) V F:D U UU:(MFS:MFS*J) W *4 S J='J
        S $ZT="" I R U 63:(1:R) V F+MF:FD_FU U UU:(MFS:0) W *4
BDON    U UU W *3,*3
        I $D(UNATTN) S DMSG="UNATTENDED BACKUP COMPLETE (BACKUP-COMMAND-FILE: "_NM_")" D HD^BACKUNJR G RET
        U 0 D WRTTI W "BACKUP # ",N," COMPLETE",! G RET
ALLR    I $ZE'["MTERR" G E
        U UU I $ZA\1024#2 S $ZT="E" W *1,*1,*1,*1 D NXT S F=F-(MF*3),J=1 G AGN
        S $ZT="E" G MER
IU      S J=FB,W=2
NXMAP   S F=J+399,C=F+1 D MC U 63:(BF:1) V J+399:FD_FU S F=J=FB+J
        I $V(1008,0)=21845,$V(1010,0)=43690,$V(1022,0)=399 G NX2
        S C=J+399 D MC
NX2     S J=J+400,W=0 G NXMAP:J<FE
        F S=1:MF:B0 U UU:(MFS:S-1*1024) D MAG
        G BDON
MC      S S=C-F Q:'S  I B0+S'>P U 63:(B0+1:S),0 V F:FD_FU S F=F+S,B0=B0+S Q
        I B0<P U 63:(B0+1:P-B0) V F:FD_FU S F=F+P-B0
        S B0=0 F M0=0:MFS:P*1024-1 U UU:(MFS:M0) D MAG I EOT D:F<FE NXT
        G MC
COR     G:$D(UNATTN) ERROR1^BACKMM D CHG W "PLEASE MOUNT THE CORRECT DISK" G MN2:MA<0,M3
MNT     G:$D(UNATTN) ERROR1^BACKMM U 0 W !,"PLEASE DISMOUNT RESIDENT DISK ",FRL," FROM DRIVE ",D
        W ", AND MOUNT",!
        W "MASTER DISK ",L G M3
REMN    G:$D(UNATTN) ERROR1^BACKMM W !,"PLEASE RE-MOUNT RESIDENT MASTER DISK ",L
M3      W " IN DRIVE ",D,!
        W "  *WRITE-" W:MA<1 "ENABLED*" W:MA=1 "PROTECTED*"
MN2     R !,"THEN TYPE  <CR>   ",A,! I A'="" G:A'="^" COR ZT "FAK1"
        U 63:(1:1:"Z"),0 S A=$ZT,$ZT="DE" V @B S $ZT=A U 63:(::"C"),0
        S I1=882,SZ=8 D GTF I M'["DSM11 V3" G:$D(UNATTN) ERROR2^BACKMM W "NOT A DSM11 V3 DISK!" G COR
        S I1=816,SZ=22 D GTF G MA:$V(814,0)#H=$A("M")
        G:$D(UNATTN) ERROR3^BACKMM W "NOT A MASTER DISK! - HAS BACKUP" G M4
M4A     W " DISK! - HAS MASTER"
M4      W " LABEL: ",M G COR
MA      I M'=L G:$D(UNATTN) ERROR4^BACKMM W "WRONG" G M4A
BBT     V DE::$V(DE)#16384+16384
        I MA<0 V DE::$V(DE)#16384+49152
        S MMS=$V(DE)\256#64+$V($V(44)+86)
        V DE+2::$V(812,0)
        F I=0:2:190 V I:MMS:$V(512+I,0)
        Q
CHG     Q:MA<0  W !!,"( ENTER '^' IF YOU HAVE CHANGED YOUR MIND AND DO NOT "
        W "WISH TO PROCEED WITH",!,"THE BACKUP)",!! Q
GTF     S M="""" F I=I1:1:I1+SZ-1 Q:$V(I,0)#256=0  S M=M_$C($V(I,0)#128)
        S M=M_"""" Q
DE      U 0 G E2:$ZE'?1"<DK".E G:$D(UNATTN) ERROR5^BACKMM W !,$E($ZE,1,7),!,"  WHILE TRYING TO "
        W " READ DISK LABEL -" S E=2 G OVER
E       G E2:$ZE'?1"<DK".E G:$D(UNATTN) ERROR6^BACKMM
        U 0 W !,"! ERROR: ",$ZE,!,"READING NEAR BLK # ",F,":",FD,FU S E=5 G OVER
E2      I $ZE["<ZFAK" S E=$E($ZE,6) G RET
        G:$D(UNATTN) ERROR7^BACKMM
        U 0 W !,"ERROR: ",$ZE S E=3
OVER    U 0 W !,"MUST TRY AGAIN FROM THE BEGINNING."
RET     S $ZT="E" I '$D(UNATTN) U 0:(:::::::::$C(3))
RT1     S MA=-1 U 63:(1:1),UU W *5 U 0
        I FM<0 S L=FRL,D=FD_FU,B=FB_":"_""""_FD_FU_"""",S=FS,DE=FDE D REMN
        V ST::64+2048+8192
        G BACFAIL^BACKUPDO:E,BACNEXT^BACKUPDO
MWLB    U 63:(1:1:"Z"),0 V 0:FD_FU U 63:(::"C"),0
        S MA=0 V 814:0:$V(815,0)*H+$A("B")
        S L=$E(FL,2,$L(FL)-1) S:$L(L)<22 L=L_$C(0)
        F I=0:2:$L(L) V 838+I:0:$A(L,I+2)*H+$A(L,I+1)
        S A="*Magtape*"_$C(0) F I=1:2:10 V 815+I:0:$A(A,I+1)*H+$A(A,I)
        V 878:0:$A(FD,2)*H+$A(FD),880:0:IU*H+VL,902:0:FE-FB\400
        F I=0:2:6 V 860+I:0:$A(DA,I+2)*H+$A(DA,I+1)
        V 868:0:$A(DA)*H+$A(DA,9) F I=2:2:9 V 868+I:0:$A(DA,I+1)*H+$A(DA,I)
        V 898:0:MF
        U UU:(512:512) D MAG G MER:EOT Q
NXT     B  U UU W *3,*3,*5 U 0 S VL=VL+1
        S MTCNT=MTCNT+1,NXTUU=$P(MLST,";",MTCNT)
        I NXTUU'="" C UU S UU=NXTUU+47 G NXTB
NA      G:$D(UNATTN) ERROR8^BACKMM W !,"Out of space on Tape.  Please mount Backup Tape # ",VL
        W !,"  on Magtape Unit # ",UU-47,"   * WRITE-ENABLED *  (Ring In)"
NXTA    W !,"  then type  <CR>   " R A,! I A="^" ZT "FAK1"
        I A'="" D CHG G NA
NXTB    U 63:(1:BF),0 C UU O UU:"BT"_MD_$S(IU:"",1:"C"):1
        I '$T G:$D(UNATTN) MAGER1^BACKMM W !,"Tape Unit # ",UU-47," not available",!,"Please make the unit available," G NXTA
        I '$D(UNATTN) W !,"BACKUP CONTINUED ON TAPE UNIT # ",UU-47,!
        S ZT=$ZT,$ZT="" U UU W *5,*10 S ZA=$ZA U 0 S $ZT=ZT
        I ZA\64#2=0 G:$D(UNATTN) MAGER1^BACKMM W !,"** TAPE IS OFF-LINE! **",! G NB
        I ZA\4#2 G:$D(UNATTN) MAGER2^BACKMM W !,"** TAPE WRITE-PROTECTED! **",! G NB
        D MWLB U 63:(1:P),0 Q
NB      D CHG W "Please mount the correct tape," G NXTA
MAG     S $ZT="" W *4 W:'IU *10 S $ZT="E",EOT=$ZA\1024#2,ZA=$ZA-(1024*EOT) U 0 G MER:ZA>127!(ZA<64)
ES      Q:$D(UNATTN)  R *A:0 I  G ES:A'=27 D ESC
        Q
MER     G:$D(UNATTN) ERROR9^BACKMM U 0 W !!,"! TAPE ERROR !",!,"  $ZA= ",ZA," (DECIMAL)",!
        S:'$D(FB) FB=0 W "(Approximately ",F-FB," blks were processed from the input disk.)",!
        ZT "FAK7"
WRTTI   S TI=$P($H,",",2),T1=TI\3600,T2=TI#3600\60,TI=TI#60
        S:T2<10 T2=0_T2 S:TI<10 TI=0_TI W !,"**",$J(T1_":"_T2_":"_TI,9),"   "
        K T1,T2,TI Q
ESC     B 0 U 0 W !,?2,F-FB," BLKS PROCESSED SO FAR,  ",FE-F," TO GO.",!!
ES2     R "TYPE  <CR>  TO CONTINUE,",!,?7,"^    TO TERMINATE  : ",A,!
        Q:A=""  G ES2:A'="^" ZT "FAK1"
