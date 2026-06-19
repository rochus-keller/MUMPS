KTR     ;PRINT ERRORS LOGGED BY CARETAKER
        K
        S I=1 F IN=0:1:16 S PW(IN)=I,I=I*2
        S IN=1,I=-1 F K=1:1 S I=$N(^SYS(0,"ERROR",I)) Q:I<0  I $D(^(I))>9 S IN=0
        I IN W !!,"There are no errors logged by Caretaker.",! Q
SELECT  S $ZE="TRAP^KTR" I $D(%IOD) U 0 I %IOD'=$I C %IOD
        R !,"Print errors for devices <*> ? ",ANS S:ANS="" ANS="*" G:ANS="^" EXIT
        S CL=$E(ANS,1),CN=$E(ANS,2),UNT=$E(ANS,3) I $L(ANS)>3 G HELP
        I CL="*" G:CN'="" HELP S (CN,UNT)="*" G PRINT
        I "MDX"'[CL G HELP
        I CN="*" G:UNT'="" HELP S UNT="*" G PRINT
        S ANS=CL_CN
        F I=2:1:$L($T(TYP),";;") I ANS=$P($T(TYP),";;",I) G ANSVAL
        G HELP
ANSVAL  I UNT="*" G PRINT
        I UNT'=+UNT!(UNT<0)!(UNT>7) G HELP
PRINT   I $D(%IOD) U 0 I %IOD'=$I C %IOD
        S %DEF=0,%QTY=2 D ^%IOS G:'$D(%IOD) SELECT
STDAT   R !,"Starting date (DD-MMM-YY) <First entry> ",%DT G:%DT="^" PRINT
        I %DT="" S %DAT=-1 G STTIM
        D %CDN^%H I '$D(%DAT) W !?5,"Enter date in requested format." G STDAT
STTIM   R !,"Starting time (HH:MM) <First entry> ",%TM G:%TM="^" STDAT
        I %TM="" S %TIM=-1 G BEGIN
        D %CTN^%H I '$D(%TIM) W !?5,"Enter time in requested format." G STTIM
BEGIN   S SDAT=%DAT,STIM=%TIM U %IOD S ERROR="^SYS(0,""ERROR"",-1)" F Z=0:0 S ERROR=$ZN(@ERROR) Q:$P(ERROR,",",2)'="""ERROR"""  D ERR
        W # G SELECT
        ;;
ERR     I $P(ERROR,",",2)'="""ERROR""" Q
        S TY=$P(ERROR,"""",4) I CL'="*" Q:CL'=$E(TY,1)  I CN'="*" Q:CN'=$E(TY,2)
        I $P(ERROR,",",4)="" Q
        I $P(@ERROR,";",1)="CONTROLLER ERROR" D ^KTR1 G END
        S UN=$P(ERROR,",",4) I UNT'="*" Q:UN'=UNT
        S %DT=$P(ERROR,",",5),%TM=$P(+$P(ERROR,",",6),".")
        Q:%DT<SDAT  I %DT=SDAT Q:%TM<STIM
        W !!,"-------------------------------------------------------------------------------"
        S ERR=@ERROR W !,"Error on device ",TY,UN," at " D %CTS^%H,%CDS^%H W %TIM," on ",%DAT
        I $E(TY)="D" W "    DSM block number: ",$P(ERR,";",3)," (Decimal)  "
        I TY="DU" G ^KTRUDA
        W !!,"Location",?15,"Contents",?30,"CSR-Meaning(s)",!!
CON     F K=1:1 S ADR=$P($T(@TY),";;",K+1) Q:ADR=""  D LINE
        I $E(TY,1)="M" G MTD
        G:TY="XE" DEUNA G:TY="XH" DEQNA G:TY="XM" DMR G:TY="XL" DELUA
        ;;S %R=$P(ERR,";",4) S %RC="un" S:%R>100 %RC="",%R=%R-1000 I %R<0 S %R=16+%R G REC
        ;;S %R=32-%R
        S %R=$P(ERR,";",4),%R1=$P(ERR,";",6),%R2=$P(ERR,";",7)
        I %R1]"" S %RC=$S(%R1\2#2:"successfully ",%R1\4#2:"un",1:"??un?? ")
        E  S %RC=$S(%R>200:"",1:"un")
        S:%R>200 %R=%R-1000 S %R=$S(%R<0:%R+32,1:32-%R+31)
REC     W !,"Disk error ",%RC,"recovered after ",%R," unsuccessful attempt" W:%R'=1 "s" W "."
END     W ! Q
        ;;
MTD     W !,"Unsuccessful attempts before recovery: ",$P(ERR,";",3),! Q
        ;;
LINE    S %DO=K-1*2+$P(ERR,";",2) D %DO,PAD W %DO,?15 S (RV,%DO)=$P(ERR,",",K) D %DO W $J(%DO,6),?28,ADR,?33 W:ADR'?." " "-"
        I TY="DK" S ADR=ADR_"-RK05"
        I TY="DL" S:ADR="RLCS" FN=RV\2#8 S:ADR="RLDA" ADR="RLDA-"_$S("5/1/6/4/7"[FN:"READ/WRITE",FN=2:"GET",FN=3:"SEEK",1:"") S:ADR="RLMP" ADR="RLMP-"_$S("5/1/6/7"[FN:"READ/WRITE",FN=2:"GET",FN=4:"READHDR",1:"")
BITS    S BT=-1
        F I=1:1 S BT=$N(^%Q("KTR",ADR,BT)) Q:BT=-1  S LB=$N(^%Q("KTR",ADR,BT,-1)) D RB
        Q
        ;;
RB      S IX=RV#PW(BT+1)\PW(LB)
        I $N(^%Q("KTR",ADR,BT,LB,-1))=-1 G R1
        I $D(^%Q("KTR",ADR,BT,LB,IX)) W ?34,^%Q("KTR",ADR,BT,LB),^%Q("KTR",ADR,BT,LB,IX),!
        Q
R1      I BT'=LB W ?34,^%Q("KTR",ADR,BT,LB) S %DO=IX D %DO^%DOC W %DO,! Q
        I IX=1 W ?34,^%Q("KTR",ADR,BT,LB),!
        Q
        ;;
%DO     S %B=%DO,%DO=""
AA      S %DO=%B#8_%DO,%B=%B\8 G:%B>7 AA S:%B %DO=%B_%DO Q
PAD     W:$X>1 ! F I=1:1:6-$L(%DO) W 0
        Q
        ;;
HELP    W !?5,"Use 3-character device names, for instance, DM0 for RK06 unit 0."
        W !?5,"You can also use ""*"" as a wild card, e.g., ""*"" for all errors,"
        W !?5,"or MS* for all TS11 tape errors, or D* for all disk errors."
        W !?5,"Enter ""^"" to exit.",! G SELECT
        ;;
TRAP    I $ZE?1"<INRPT".E W !?5,*7,"Unexpected interrupt",! G EXIT
        W !,$ZE,! G EXIT
DMR     W ! S ADR="XDCODE",RV=$P(ERR,",",2) D BITS W ! Q
DEUNA   W ! S ADR="XUCODE",RV=$P(ERR,",",5) D BITS W !
        G:RV=16 SERI G:RV=1 ONPD G:RV=2 PDT G:RV=3 PDR G:((RV>8)&(RV<15)) ONPD
        G:RV=15 PDT G:RV=64 ONPD G:RV=65 ONPD G:RV=66 PDR
        Q
SERI    W ! S ADR="USTATUS",RV=$P(ERR,",",17) D BITS W !
ONPD    D PADD Q
PDT     D PADD D DUTD Q
PDR     D PADD D DURD Q
DELUA   ;
DEQNA   W ! S ADR="XQCODE",RV=$P(ERR,",",6) D BITS W ! D PADD
        G:RV=1 TON G:RV=2 RON G:RV=4 TON G:RV=66 RON
        Q
RON     D DQRD Q
TON     D DQTD Q
DURD    S WD="Receive ",SA=19,TD=4,BW=8,TC="RDR" G DESPT
DUTD    S WD="Transmit ",SA=18,TD=4,BW=12,TC="TDR" G DESPT
DQRD    S WD="Receive ",SA=20,TD=6,BW=6,TC="RDB" G DESPT
DQTD    S WD="Transmit ",SA=19,TD=6,BW=12,TC="TDB" G DESPT
DESPT   W !,?30,WD,"Descriptor at " S %DO=$P(ERR,",",SA) D %DO W %DO,!
        F J=1:1:TD W !,?30,"WORD",J,! S RV=$P(ERR,",",BW+J) S ADR=TC_J D BITS
        W ! Q
PADD    W !,"Ethernet Node Address = " I TY="XE" S K=6
        I TY="XH" S K=3
        F I=1:1:3 D
        .S %DH=$P(ERR,",",K),K=K+1 D ^%DH
        .F II=1:1:(4-$L(%DH)) S %DH="0"_%DH
        .W $E(%DH,3,4),"-",$E(%DH,1,2)
        .I I<3 W "-"
        W ! Q
EXIT    U 0 I $D(%IOD) C:%IOD'=$I %IOD
        Q
TYP     ;;MT;;MM;;MS;;MU;;DK;;DM;;DR;;DB;;DL;;DU;;XE;;XH;;XM;;XL
XE      ;;PCSR0;;PCSR1;;PCSR2;;PCSR3
XM      ;;DMRCSR
XH      ;;VECTOR;;QCSR
MT      ;;MTS;;MTC;;MTBRC;;MTCMA;;MTD;;MTRD
MM      ;;MTCS1;;MTWC;;MTBA;;MTCS2;;MTFC;;MTFS;;MTER;;MTAS;;MTCC;;MTDB;;MTMR;;MTDT;;MTSN;;MTTC
MS      ;;TSBA;;TSSR;;MESSAGE BUFFER HEADER;;12.;;RESIDUAL COUNT;;XSTAT0;;XSTAT1;;XSTAT2;;XSTAT3
DK      ;;RKDS;;RKER;;RKCS;;RKWC;;RKBA;;RKDA;;UNUSED;;RKDB
DM      ;;RKCS1;;RKWC;;RKBA;;RKDA;;RKCS2;;RKDS;;RKER;;RKAS(OF);;RKDC;;UNUSED;;RKDB;;RKMR1;;RKECPS;;RKECPT;;RKMR2;;RKMR3
DR      ;;RMCS1;;RMWC;;RMBA;;RMDA;;RMCS2;;RMDS;;RMER1;;RMAS;;RMLA;;RMDB;;RMMR1;;RMDT;;RMSN;;RMOF;;RMDC;;RMHR;;RMMR2;;RMER2;;RMEC1;;RMEC2
DB      ;;RPCS1;;RPWC;;RPBA;;RPDA;;RPCS2;;RPDS;;RPER1;;RPAS;;RPLA;;RPDB;;RPMR;;RPDT;;RPSN;;RPOF;;RPDC;;RPCC;;RPER2;;RPER3;;RPEC1;;RPEC2
DL      ;;RLCS;;RLBA;;RLDA;;RLMP
