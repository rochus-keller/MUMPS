KTRUDA  ;DECODE ERROR PACKET SENT BY UDA50 CONTROLLER AND STORED IN ^SYS
SANITY  I TY'="DU"!ERR="" G EXIT
VAR     K I,J,K,Y,BT,IX,LB,RV,%B,%HX,%OD,ADR,WORD,DUBBK
DUMP    ;
        W !,"This error was " I $P(ERR,",",5)\32768 W "successfully recovered."
        E  W " *NOT* successfully recovered, a ^FASTIC run is recommended."
        W !!,"------------------------------------------------------------------------------",!,"MSCP ERROR LOG PACKET",!,?5,"(values are in octal)",!
        W "WORD N+3",?15,"WORD N+2",?31,"WORD N+1",?46,"WORD N",?60,"BYTE OFFSET",!!
        F K=0:1:6 D DMPLN
FRMAT   ;
        S WORD=$P(ERR,",",5),K=WORD#256\128
        I (WORD#256)=255 S TY="BBRPK" G GETLN
        I K>0 S TY="ENDPK" G GETLN
        S K=WORD#128,TY=$S(K=0:"CNTER",K=1:"MEMER",K=2:"TRANER",K=3:"SDIER",K=4:"SMDKER",1:"UNKNOWN")
        I TY="UNKNOWN" W !,"PACKET FORMAT UNKNOWN" G BBK
        I TY="SDIER" S J=$P(ERR,",",16)#PW(8)\PW(0),TY=$S(J=4:"SDI60",1:"SDI80")
GETLN   D:TY="CNTER" CNTDECD S WORD=$P($T(@TY),";;",1),WORD=$P(WORD," ",2,255) W !,?10,"TYPE OF PACKET = ",WORD
        F K=1:1 S ADR=$P($T(@TY),";;",K+1) Q:ADR=""  D LINE
BBK     ;
EXIT    K J,K,Y,BT,IX,LB,RV,%B,%HX,%OD,ADR,WORD,DUBBK Q
LINE    S RV=$P(ERR,",",K),BT=-1
        F I=1:1 S BT=$N(^%Q("KTR",ADR,BT)) Q:BT=-1  S LB=$N(^%Q("KTR",ADR,BT,-1)) D RB
        Q
        ;;
RB      I BT>15 D DBLWRD
        S:BT<16 IX=RV#PW(BT+1)\PW(LB)
        I $N(^%Q("KTR",ADR,BT,LB,-1))=-1 G R1
        I $D(^%Q("KTR",ADR,BT,LB,IX)) D
        .I ADR="DUBBRCODE" W !,?10,"BBR MESSAGE NO. ",IX
        .W !,?10,^%Q("KTR",ADR,BT,LB),^%Q("KTR",ADR,BT,LB,IX)
        Q
R1      I (TY="BBRPK")&(IX>134217729) W !,?10,^%Q("KTR",ADR,BT,LB)," "," Not valid in this case." Q
        I BT'=LB W !,?10,^%Q("KTR",ADR,BT,LB) S %DO=IX D %DO^%DOC W %DO_"(OCT)  ",IX_"(DEC)" D:(ADR="DU60/27")!(ADR="DU80/27") WRD27 Q
        I IX=1 W !,?10,^%Q("KTR",ADR,BT,LB)
        Q
        ;;
CNTDECD ;
        S J=$P(ERR,",",6) I J=10 S TY="LSTPK" Q
        S TY="CNTPK" Q
DBLWRD  ;
        I (BT'=31)&(BT'=47) G DBLOTH
        I BT=31 S IX=RV+($P(ERR,",",K+1)*65536),K=K+1 Q
        S IX=$P(ERR,",",K+2)*65536+$P(ERR,",",K+1)*65536+RV,K=K+2 Q
DBLOTH  I (BT=27)&(ADR="DULBN1") S IX=RV+($P(ERR,",",K+1)#4096*65536) Q
        S J=BT\16,Y=BT/16 I Y>J S J=J=1
        S K=K+J,IX=0 Q
WRD27   S %HX=IX D %HEX W "  ",%HX," (HEX)" Q
DMPLN   F J=4:-1:1 S %DO=$P(ERR,",",4*K+J) D %DO,PAD,OUT
        Q
%DO     S %B=%DO,%DO=""
AA      S %DO=%B#8_%DO,%B=%B\8 G:%B>7 AA S:%B %DO=%B_%DO Q
PAD     I $L(%DO)<6 S %DO="0"_%DO G PAD
        Q
%HEX    S %B=%HX,%HX=""
BB      S Y=$P("0^1^2^3^4^5^6^7^8^9^A^B^C^D^E^F","^",(%B#16)+1),%HX=Y_%HX,%B=%B\16 G:%B>15 BB S:%B %HX=$P("0^1^2^3^4^5^6^7^8^9^A^B^C^D^E^F","^",%B+1)_%HX Q
        Q
OUT     S Y=$P("46^31^15^0","^",J)
        I J=1 W ?Y,%DO,?65,$P("0^10^20^30^40^50^60","^",K+1),! Q
        W ?Y,%DO Q
        ;;
CNTPK   Controller Error Packet;;DUREFN;; ;; ;; ;; ;;DUSTACD;; ;; ;; ;; ;;DUDAVER
ENDPK   End Packet;;DUREFN;; ;;DUDRVN;; ;; ;;DUSTACD;; ;; ;; ;; ;; ;; ;; ;; ;;DULBN1;;DULBN2
LSTPK   Last Fail Packet;; ;; ;; ;; ;; ;;DUSTACD;; ;; ;; ;; ;;DUDAVER;;DULFCD
MEMER   Host Memory Access Error Packet;;DUREFN;; ;; ;; ;; ;;DUSTACD;; ;; ;; ;; ;;DUDAVER;; ;;DUMEMAD
SDI60   SDI Error Packet;;DUREFN;; ;;DUDRVN;; ;; ;;DUSTACD;; ;; ;; ;; ;;DUDAVER;; ;;DUDRSN;; ;; ;;DUDRTY;; ;; ;; ;; ;;DULBN1;;DULBN2;;DUSTAT1;;DUSTAT2;; ;; ;; ;;DU60/27
SDI80   SDI Error Packet;;DUREFN;; ;;DUDRVN;; ;; ;;DUSTACD;; ;; ;; ;; ;;DUDAVER;; ;;DUDRSN;; ;; ;;DUDRTY;; ;; ;; ;; ;;DULBN1;;DULBN2;;DUSTAT1;;DUSTAT2;; ;; ;; ;;DU80/27
SMDKER  Small Disk Error Packet;;DUREFN;; ;;DUDRVN;; ;; ;;DUSTACD;; ;; ;; ;; ;;DUDAVER;; ;;DUDRSN
TRANER  Disk Transfer Error Packet;;DUREFN;; ;;DUDRVN;; ;; ;;DUSTACD;; ;; ;; ;; ;;DUDAVER;; ;;DUDRSN;; ;; ;;DUDRTY;; ;; ;; ;; ;;DULBN1;;DULBN2
BBRPK   BBR packet;;DUREFN;; ;;DUDRVN;;DUBBRCODE;; ;;DUBADLBN;; ;;DUNEWRBN;; ;;DUOLDRBN;; ;;SECT0FLAGS;;DUVALD
