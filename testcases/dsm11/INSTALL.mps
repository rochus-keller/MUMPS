INSTALL ;23-Mar-85 ;UTILITIES ;INSTALLATION ;INITIAL SETUP ROUTINE ;JBH
        Q
COPENT  S $ZT="NXTP" X %LOAD
INS     S %LABEL="TAPENT",%LOAD="U 47 ZL  S Z=$ZA U 0 ZT:Z<128&(Z>63)  W !,""Load error -- stopping."",! F I=1:1"
DISKENT U 0:(::::16384) S ST=$V(44)
        W !!,?9,"Begin ",$ZV," system installation",!
        W !,"Answer with a question mark (?) any time you wish more information.",!!
DATIM   S QUES="DATQ" D ASK F I=1:1:3 S @$P("D-M-Y","-",I)=$P(A,"-",I)
        S N=$F("JAN-FEB-MAR-APR-MAY-JUN-JUL-AUG-SEP-OCT-NOV-DEC",M)\4
        S DAYS="31-29-31-30-31-30-31-31-30-31-30-31"
        F I=1:1:12 S DM(I)=$P(DAYS,"-",I)
        I $L(M)'=3!'N!($L(Y)'=2)!(Y<80)!($P(DAYS,"-",N)<D) D HELP G DATIM
        S H=50768
        F K=80:1:Y-1 S H=(K#4=0)+365+H
        S DM(2)=(Y#4=0)+28 F J=1:1:N-1 S H=H+DM(J)
        S HH=H+D
ASKTM   S QUES="TIMQ" D ASK F I=1:1:3 S @$P("H:M:S",":",I)=$P(A,":",I)
        I S>59!(M>59)!(H>23)!((A'?.N1":"2N)&(A'?.N1":"2N1":"2N)) D HELP G ASKTM
        S T=H*60+M*60+S
        V ST+44::HH,ST+42::T#65536,ST+40::$V(ST+40)#256+(T\65536*256)
NXTP    K N,DAYS,DM,H,HH
        S $ZT=%LABEL X %LOAD
HELP    S HROU=QUES_"H" D:$L($T(@HROU)) @HROU Q
ASK     W ! D @QUES R " ?  > ",A,! Q:A'="?"  D HELP G ASK
DATQ    W !,"Please enter today's date  [ DD-MMM-YY ] " Q
DATQH   W !,"Like this:   3-JUL-80",! Q
TIMQ    W ?17,"and time  [ HH:MM:SS  ] " Q
TIMQH   W !,"Like this:   17:30:00        (5:30 PM)",!!
QUIT    Q
