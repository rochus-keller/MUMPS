TIM     ; DSM UTILITIES ; SETS TIME INTO $HOROLOG ; COPYRIGHT 1980 DEC ;
BEG     W !,"Please enter time"
RD      R "  [ HH:MM:SS  ]  > ",%T
        I %T="^" Q
        G HLP:%T'?1N.N1":"1N.N&(%T'?1N.N1":"1N.N1":".N)!(%T="")
        G HLP:$P(%T,":",2)>59!($P(%T,":",3)>59)
        S %T=%T*60+$P(%T,":",2)*60+$P(%T,":",3)
        I $D(^SYS(0,"$HLAST")) I $V($V(44)+44)=$P(^SYS(0,"$HLAST"),",",1),%T+300'>$P(^SYS(0,"$HLAST"),",",2) G CK
SET     S %=$V(44) V %+40::$V(%+40)#256+(%T\65536*256),%+42::%T#65536
ASK     W !,"Is this " D ^%T W " in the ",$S(%T<43200:"Morning",%T>43199&(%T<64800):"Afternoon",1:"Evening") R " ? <Y> ",A S:A="" A="Y" G TIM:A'?1"Y".E
        K %,%T,A Q
CK      R !,"Are you sure you entered time on 24-hour clock ? <Y> ",A
        G HLP1:A="?" I A=""!(A?1"Y".E) G SET
        I A="^"!(A?1"N".E) G BEG
        G HLP1
HLP     W !!," Like this:   15:30         (3:30 PM)",! G BEG
HLP1    W !!,"Enter <CR> or Y(ES) to set current time"
        W !,"Enter N(O) to re-enter the time",! G CK
