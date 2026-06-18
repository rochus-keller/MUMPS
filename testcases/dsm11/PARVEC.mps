PARVEC  ;FDN;13-SEP-83;LIST CONTENTS OF PARTITION VECTOR /KFD FOR 3.0
        W !,"Print contents of a Partition Vector",! S $ZE="ERR^PARVEC"
        S VECSIZ=400
        D:'$D(^PARVEC(VECSIZ-2)) START^PARVEC0
        S ST=$V(44),PT=$V(ST+6)
STAR    S %QTY=2 K %DEF
        U 0 I $D(%IOD) C:%IOD'=$I %IOD
        D ^%IOS G:'$D(%IOD) EXIT
        I "^SC^LP^TRM"'[%DTY!(%DTY="") W !,?5,"Improper device selection" U 0 C:%IOD'=$I %IOD G STAR
WHO     U 0 R !!,"Partition to dump <$J> ",PTN G:PTN="^" STAR S:PTN="" PTN=$J I PTN'?1N.N D BADP G WHO
        I PTN<0!(PTN>128)!($V(0,PTN)="") D BADP G WHO
        U %IOD W #!,^PARVEC," on " D ^%D W " at " D ^%T W !!
        S X=""
STOP    S CNT=0 U 0 R !!,"Enter starting location or <CR> to continue display : ",YI G:YI="^" WHO
        G:YI="?" HELP I '(YI=""!(YI?.N)!(YI?1"#".N)) D IV G STOP
        I $E(YI)="#" S %OD=$E(YI,2,$L(YI)) D %OD G IV2:%OD="B" S YI=%OD
        I YI>VECSIZ D IV1 G STOP
        S:YI]"" X=YI-1
HD      U %IOD W !!,"Location",?10,"Contents",?20,"Name",?35,"Description",!
        W "--------",?10,"--------",?20,"----",?35,"-----------",!
LOOP    U 0 I %IOD=$I S CNT=CNT+1 I CNT>6 G STOP
        I %IOD'=$I U %IOD I $Y>55 W # G HD
        S X=$O(^PARVEC(X)) S %DO=X D %DO S %DO="#"_%DO U %IOD W !,$J(%DO,4) S NO=^(X),D=$P(NO,",",1),E=$P(NO,",",2),F=$P(NO,",",3),G
=$P(NO,",",4),NO=X
        D PRT U %IOD W ?19,$J(D,0) W:E]"" ?28,E D DEC W:F]"" ?28,F W ! G END:X=VECSIZ,LOOP
%OD     I %OD'?1N.N!($L(%OD)>27)!(%OD="")!(%OD[8)!(%OD[9) S %OD="B" Q
        S %B(1)=1,%B=0 F %I=2:1:8 S %B(%I)=%B(%I-1)*8
        F %I=1:1:$L(%OD) S %B=%B+($E(%OD,$L(%OD)+1-%I)*%B(%I))
        S %OD=%B K %I,%B
        Q
%DO     S %B=%DO,%DO=""
A       S %DO=%B#8_%DO,%B=%B\8 G:%B>7 A S:%B %DO=%B_%DO K %B Q
PRT     S DEC=X,PT=$V(DEC,PTN),PT=$S(G:PT#256,1:PT),%DO=PT D %DO S %DO="#"_%DO U %IOD W ?9,$J(%DO,7) Q
DEC     W !,$J(X,4),$J(PT,12) Q
END     W !!,"End of Partition Vector for partition #",PTN W !# G WHO
IV      U 0 W !?5,*7,"Incorrect response." D QUE Q
IV2     U 0 W !?5,*7,"Invalid octal number." D QUE G STOP
IV1     U 0 W !?5,*7,"Number exceeds the last location in the Partition Vector." D QUE Q
BADP    W !?5,"Enter a valid partition number whose vector you wish to dump."
        W !?5,"Enter <CR> to dump your own partition.",!?8,"or ^ to return to the previous question." Q
QUE     X $S($X>40:"W !?5",1:"W ""  """) W "Enter '?' for more information." Q
HELP    U 0 W !?5,"Enter <CR> to start display of entire Partition Vector."
        W !?5,"Enter ^ to abort."
        W !?5,"To start display at a specific location:"
        W !?8,"Enter  'NNN' for decimal location"
        W !?11,"or '#NNN' for octal location." G STOP
ERR     U 0 I $ZE?1"<INRPT".E W !?5,*7,"Unexpected interrupt",!
        E  W !,$ZE,!
EXIT    U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %DO,%DTY,%IOD,%OD,CNT,D,DEC,E,F,G,I,NO,PT,PTN,ST,X,YI Q
