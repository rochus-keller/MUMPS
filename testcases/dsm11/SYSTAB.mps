SYSTAB  ;FDN;13-JUN-80;LIST CONTENTS OF SYSTEM TABLE
        W !,"Print contents of the System Table",! S $ZE="ERR^SYSTAB"
        I '$D(^SYSTAB(265)) D START^SYSTAB0
STAR    S %QTY=2 K %DEF D ^%IOS G:'$D(%IOD) EXIT
        I "^SC^LP^TRM"'[%DTY!(%DTY="") W !,?5,"Improper device selection" U 0 C:%IOD'=$I %IOD G STAR
        U %IOD W #!,^SYSTAB," on " D ^%D W " at " D ^%T W !!
START   S X=-1
STOP    S CNT=0 U 0 R !!,"Enter starting location or <CR> to continue display : ",YI S:'$T YI="^" I YI="^" G EXIT
        G:YI="?" HELP I '(YI=""!(YI?.N)!(YI?1"#".N)) D IV G STOP
        I $E(YI,1)="#" S %OD=$E(YI,2,$L(YI)) D %OD G IV2:%OD="B" S YI=%OD
        I YI>442 D IV1 G STOP
        I YI'="" S X=YI-1
        U 0 I %IOD'=$I W !,"Started: " D ^%T W !
HD      U %IOD W !!,"Location",?10,"Contents",?20,"Name",?35,"Description",!
        W "--------",?10,"--------",?20,"----",?35,"-----------",!
LOOP    S CNT=CNT+1 U 0 I %IOD'=$I U %IOD I '(CNT#18) W # G HD
        U 0 I %IOD=$I G STOP:(CNT>6)
        S X=$N(^SYSTAB(X)) S %DO=X D %DO S %DO="#"_%DO U %IOD W !,$J(%DO,4) S NO=^(X),D=$P(NO,",",1),E=$P(NO,",",2),F=$P(NO,",",3),G=$P(NO,",",4),NO=X
        D PRT U %IOD W ?19,$J(D,0) W:'(E="") ?28,$J(E,0) D DEC W:'(F="")&($E(F,1)'="@") ?28,$J(F,0) W:$E(F,1)="@" ?28,@$E(F,2,255) W ! G END:X=442 G LOOP
%OD     I %OD'?1N.N!($L(%OD)>27)!(%OD="")!(%OD[8)!(%OD[9) S %OD="B" Q
        S %B(1)=1,%B=0 F %I=2:1:8 S %B(%I)=%B(%I-1)*8
        F %I=1:1:$L(%OD) S %B=%B+($E(%OD,$L(%OD)+1-%I)*%B(%I))
        S %OD=%B K %I,%B
        Q
%DO     S %B=%DO,%DO=""
A       S %DO=%B#8_%DO,%B=%B\8 G:%B>7 A S:%B %DO=%B_%DO K %B Q
PRT     S DEC=X I G="" S PT=$V($V(44)+DEC),%DO=PT D %DO S %DO="#"_%DO U %IOD W ?9,$J(%DO,7) Q
        I G="1" S PT=$V($V(44)+DEC)#256,%DO=PT D %DO S %DO="#"_%DO U %IOD W ?9,$J(%DO,7) Q
DEC     W !,$J(X,4),$J(PT,12) Q
END     W !!,"End of System Table" W !# G EXIT
IV      U 0 W !?5,*7,"Incorrect response." D QUE Q
IV2     U 0 W !?5,*7,"Invalid octal number." D QUE G STOP
IV1     U 0 W !?5,*7,"Number exceeds the last location in the System Table." D QUE Q
QUE     X $S($X>40:"W !?5",1:"W ""  """) W "Enter '?' for more information." Q
HELP    U 0 W !?5,"Enter <CR> to start display of entire System Table."
        W !?5,"Enter ^ to abort."
        W !?5,"To start display at a specific location:"
        W !?8,"Enter  'NNN' for decimal location"
        W !?11,"or '#NNN' for octal location." G STOP
ERR     U 0 I $ZE?1"<INRPT".E W !?5,*7,"Unexpected interrupt",!
        E  W !,$ZE,!
EXIT    U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %DO,%DTY,%IOD,%OD,CNT,D,DEC,E,F,G,NO,PT,X,YI Q
