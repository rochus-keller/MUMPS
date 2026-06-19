DSKTRACK        ;TRACK DISK ERRORS - PJH; 19-JUL-82
        K
        S FST="T"
ST      R !!,"(D)uplicate Block Errors Report, (H)ead Summary Report: ",OPT G EX:OPT=""!(OPT="^")
        I OPT="?" D HELP G ST
        I "D/H"'[OPT!($L(OPT)'=1) W "  -  Invalid Option",*7 G ST
        I '$D(^SYS(0,"ERROR")) W !,"There are no Disk Errors logged",*7 G ST
        I FST="T" D COMP S FST="F"
        S YN=""
        I OPT="H" R !,"Output by Date? <N>: ",YN S YN=$S(YN="Y":1,1:0)
        K (OPT,YN,FST,%IOD) S %QTY=2,%DEF=$S($D(%IOD):%IOD,1:0)=2,IOO=$I D ^%IOS G ST:'$D(%IOD)
        U %IOD
        D BLKP:OPT="D",TRKP:OPT="H"
        W # C:IOO'=%IOD %IOD
        G ST
        -
EX      K ^SYS(0,"KTRBLK"),^SYS(0,"KTRTRK"),^SYS(0,"KTRTDT")
        Q
        -
COMP    ;
        W !!,"** COMPILATION IN PROGRESS **",!
        S TYS=$T(@"TYPE") K CR,CH,CL,TR,TH,TL,SR,SH,SL
        F I=2:1 S TY=$P(TYS,";;",I) Q:TY=""  S P=$T(@TY),C=$P(P,";;",2),T=$P(P,";;",3),S=$P(P,";;",4),CR(TY)=+C,CH(TY)=$P(C,",",2),CL(TY)=$P(C,",",3),TR(TY)=+T,TH(TY)=$P(T,",",2),TL(TY)=$P(T,",",3),SR(TY)=+S,SH(TY)=$P(S,",",2),SL(TY)=$P(S,",",3)
        S I=1 F IN=0:1:16 S PW(IN)=I,I=I*2
        K ^SYS(0,"KTRBLK"),^SYS(0,"KTRTRK"),^SYS(0,"KTRTDT")
        S (TY,UNT,DT,TM)=""
TY      S TY=$O(^SYS(0,"ERROR",TY)) Q:TY=""  G TY:TYS'[TY
UNT     S UNT=$O(^SYS(0,"ERROR",TY,UNT)) G TY:UNT=""
DT      S DT=$O(^SYS(0,"ERROR",TY,UNT,DT)) G UNT:DT=""
TM      S TM=$O(^SYS(0,"ERROR",TY,UNT,DT,TM)) G DT:TM=""
        S X=^(TM),BLK=$P(X,";",3),U=TY_UNT,C=$P(X,",",CR(TY))#PW(CH(TY)+1)\PW(CL(TY)),T=$P(X,",",TR(TY))#PW(TH(TY)+1)\PW(TL(TY)),S=$P(X,",",SR(TY))#PW(SH(TY)+1)\PW(SL(TY))
        I TY="DL" I "5\1\6\4\7"'[(+X\2#8) G TM
        S ^SYS(0,"KTRTRK",U,T,C,S)=$S($D(^SYS(0,"KTRTRK",U,T,C,S)):^(S)+1,1:1)_"^"_BLK
        S ^SYS(0,"KTRTDT",U,DT,T,C,S)=$S($D(^SYS(0,"KTRTDT",U,DT,T,C,S)):^(S)+1,1:1)_"^"_BLK
        S ^SYS(0,"KTRBLK",U,BLK,DT,TM)=$S($D(^SYS(0,"KTRBLK",U,BLK,DT,TM)):^(TM)+1,1:1)
        G TM
        -
BLKP    ;
        W #,?20,"DUPLICATE BLOCK ERRORS REPORT",?60,"Printed: " S %DT=+$H D %CDS^%H W %DAT1
        W !!,"Disk    Block #     Date       Times"
        W !,"----    -------     ----       -----"
        S (U,B)=""
B1      S U=$O(^SYS(0,"KTRBLK",U)) Q:U=""
B2      S B=$O(^SYS(0,"KTRBLK",U,B)) G B1:B="" S D=$O(^SYS(0,"KTRBLK",U,B,"")),DAY=$O(^(D)),TIM=$O(^(D,"")),T=$O(^(TIM)) G B2:DAY=""&(T="")
        W !!,U,?8,B
        S (D,TM)=""
B3      S D=$O(^SYS(0,"KTRBLK",U,B,D)) G B2:D="" S %DT=D D %CDS^%H W:$X>18 ! W ?18,%DAT1
B4      S TM=$O(^SYS(0,"KTRBLK",U,B,D,TM)) G B3:TM="" S %TM=TM D %CTS^%H W:$X>71 !?29 W:$X>29 ", " W ?29,%TIM1 G B4
        -
TRKP    W #,?20,"HEAD SUMMARY REPORT" W:YN " (by Date)" W ?60,"Printed: " S %DT=+$H D %CDS^%H W %DAT1
        I YN G DATP
        W !!,"Disk    Head     Cylinder   Sector    Errors     DSM block",!
        W "----    ----     --------   ------    ------     ---------"
        S (U,T,C,S)=""
T1      S U=$O(^SYS(0,"KTRTRK",U)) Q:U=""  W !!,U
T2      S T=$O(^SYS(0,"KTRTRK",U,T)) G T1:T="" W ?10,T
T3      S C=$O(^SYS(0,"KTRTRK",U,T,C)) G T2:C="" W ?20,C
T4      S S=$O(^SYS(0,"KTRTRK",U,T,C,S)) G T3:S="" W ?30,S,?40,$P(^(S),"^",1),?50,$P(^(S),"^",2),! G T4
        -
DATP    S (D,TM,U,T,C,S)=""
        W !!,"Disk     Date     Head     Cylinder   Sector    Errors     DSM block",!
        W "----     ----     ----     --------   ------    ------     ---------"
D1      S U=$O(^SYS(0,"KTRTDT",U)) Q:U=""  W !!,U
D2      S D=$O(^SYS(0,"KTRTDT",U,D)) G D1:D="" S %DT=D D %CDS^%H W ?6,$J(%DAT1,9)
D3      S T=$O(^SYS(0,"KTRTDT",U,D,T)) G D2:T="" W ?20,T
D4      S C=$O(^SYS(0,"KTRTDT",U,D,T,C)) G D3:C="" W ?30,C
D5      S S=$O(^SYS(0,"KTRTDT",U,D,T,C,S)) G D4:S="" W ?40,S,?50,$P(^(S),"^",1),?60,$P(^(S),"^",2),! G D5
        -
TYPE    ;;DK;;DM;;DR;;DB;;DL
        ;;Cyl Reg #;;Hi Bit,Low bit ;; Trk Reg #,Hi Bit,Low Bit;; Sec Reg #,Hi,Low
DK      ;;6,12,5;;6,4,4;;6,3,0
DM      ;;9,9,0;;4,10,8;;4,4,0
DR      ;;15,9,0;;4,12,8;;4,4,0
DB      ;;15,9,0;;4,12,8;;4,4,0
DL      ;;3,15,7;;3,6,6;;3,5,0
HELP    W !!,"The Duplicate Block Errors Rpt prints all disk blocks for which more than one",!
        W "error has occured. The object is to catch blocks in the process of going bad",!
        W "where they fail the first read but recover before the 32 retries are up.",!
        W "Such warning errors are logged by KTR.",!!
        W "The Head Summary Rpt prints all disk errors by track which corresponds to the",!
        W "disk head. The object is to catch heads that are going flaky, before a head crash",!
        W "occurs. A number of errors on the same track (head) may constitute such a trend.",!!
        W "*WARNING* No automatic conclusion should be drawn on the basis of these reports",!
        W "alone. If a trend is spotted then the errors which comprise the trend must be",!
        W "investigated to verify that there is some validity to the trend."
        Q
