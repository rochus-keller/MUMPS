DAT     ; DSM UTILITIES ; SETS DATE INTO $HOROLOG ; COPYRIGHT 1980 DEC ;
BEG     G:'$D(^SYS(0,"$HLAST")) ST S %DT=$P(^SYS(0,"$HLAST"),",",1) D %CDS^%H
        W !,"Please enter today's date  <",%DAT1 R "> ",A S:A="" A=%DAT1 G CK
ST      R !,"Please enter today's date  [ DD-MMM-YY ]  > ",A
CK      I A="^" K A Q
        G HLP:A="?"!(A="") S D=$P(A,"-",1),M=$P(A,"-",2),Y=$P(A,"-",3)
        G HLP:A'?1N.N1"-"3A1"-"2N!'D
        F I=1:1:12 S DM(I)=$P("31-29-31-30-31-30-31-31-30-31-30-31","-",I)
        S DM(2)=(Y#4=0)+28,%M1="" F %I=1:1:3 S %C=$A(M,%I) S:%C>96 %C=%C-32 S %M1=%M1_$C(%C)
        S M=$F("JAN-FEB-MAR-APR-MAY-JUN-JUL-AUG-SEP-OCT-NOV-DEC",%M1)\4
        G HLP:'M G HLP:(DM(M)<D)!(Y<80)
        S H=50768
        F I=80:1:Y-1 S H=(I#4=0)+365+H
        F I=1:1:M-1 S H=H+DM(I)
        S H=H+D,WKDAY=$P("Thursday-Friday-Saturday-Sunday-Monday-Tuesday-Wednesday","-",H#7+1)
WKDAY   W !,"Is today ",WKDAY R " ? <Y> ",A
        G HLP1:A="?" I A=""!(A?1"Y".E) G SET
        I A="^"!(A?1"N".E) G BEG
        G HLP1
SET     V $V(44)+44::H K %C,%I,%M1,D,M,Y,H,I,A,%DAT1,WKDAY,DM Q
HLP     W !!," Like this:  12-MAR-80",!
        W:$D(^SYS(0,"$HLAST")) " Or enter <CR> to accept default",! G BEG
HLP1    W !!,"If today is ",WKDAY,", enter <CR> or Y(ES)"
        W !,"Otherwise, enter N(O) to re-enter today's date",! G WKDAY
Z       P DAT ZS DAT Q
