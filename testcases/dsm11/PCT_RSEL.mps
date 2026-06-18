%RSEL   ;DSM UTILITIES ;ROUTINE NAME SELECTOR @SMB@
        ;; Returns list of routines selected in ^UTILITY($J)
        ;; if %UCI and %SYS specified, then directory from that
        ;; UCI and SYS is used
        ;;If a utility list already exists in ^UTILITY($J), then
        ;;then that list is used as a list to be edited.
        ;;
        I '$D(^UTILITY) S ^UTILITY=""
        S %GO=1,%RPT=$D(^UTILITY($J))#10
        I '%RPT K ^UTILITY($J)
        E  I ^($J)'="%RSEL" K ^($J)
        S ^UTILITY($J)="%RSEL"
        S %NOUCI=0 I '$D(%UCI)!'$D(%SYS) D ^%GUCI S %NOUCI=1
ASK     W !,"Routine(s) ? > " R %X,! G:%X="?" Q1 G:%X="" EXIT I %X="^" S %RPT=1 G EXIT
        I %X="^L" D LST G ASK
        I %X="^D" D %RSEL^%RD W ! G ASK
        S %MI=0 I $E(%X,1)="-" S %MI=1,%X=$E(%X,2,999)
        I %X="*",'%MI S %FI=1,%ST=$C(127) D GET G ASK
        I %X="*" K ^UTILITY($J) S %RPT=0 G ASK
        I %X?.E1"*" S %FI=$E(%X,1,$L(%X)-1),%ST=%FI_$C(127) D GET G ASK
        I %X?1E.E1"-"1E.E S %FI=$P(%X,"-",1),%ST=$P(%X,"-",2) D GET G ASK
        I %X'?1A.AN,%X'?1"%".AN D IV G ASK
        I %MI K ^UTILITY($J,%X) G ASK
        I $D(^[%UCI,%SYS] (%X)) S ^UTILITY($J,%X)="" G ASK
        W "   ",*7,"No such routine" G ASK
        -
GET     G:%MI MINUS S %N=%FI G:%N="" GET2 G:'$D(^[%UCI,%SYS] (%N)) GET2
GET1    Q:%N]%ST  S ^UTILITY($J,%N)=""
GET2    Q:%N=%ST  S %N=$O(^[%UCI,%SYS] (%N)) G:%N]"" GET1 Q
        -
        -
MINUS   K ^UTILITY($J,%FI) S %N=%FI
R1      S %N=$O(^(%N)) I %N=""!(%N]%ST) Q
        K ^(%N) G R1:%N'=%ST Q
        -
        -
IV      W !?5,*7,"Incorrect response - Enter '?' for more information" Q
NONE    W !?5,"No routines selected",! Q
LST     W:%RPT "(These are the routines from the previous selection)"
        S %A=0,%J=0 I $O(^UTILITY($J,""))="" G NONE
L1      S %A=$O(^(%A)) I %A="" K %A,%J Q
        W:'(%J#8) ! W ?(%J#8*10),%A S %J=%J+1 G L1
ERR     W !,$ZE Q
EXIT    K:%NOUCI %SYS,%UCI K %X,%ST,%FI,%MI,%N,%A,%NOUCI
        I $O(^UTILITY($J,""))="" K %GO,%RPT G NONE
        K %RPT S ^UTILITY($J)="%RSEL" Q
Q1      W !?5,"Enter   A routine name"
        W !?8,"or   NAM*       For all routines beginning with letters 'NAM'"
        W !?8,"or   NAM1-NAM2  To select routines whose names are in the range"
        W !?24,"from NAM1 to NAM2, inclusive"
        W !?8,"or    *    To select all routines"
        W !?8,"or    -    Followed by any of the above to de-select routines"
        W !?19,"which have been selected"
        W !?8,"or    ^L   To list selected routines"
        W !?8,"or    ^D   To list all routines in your UCI"
        W !?8,"or   <CR>  When done selecting"
        W !?8,"or    ^    To terminate without selection"
        W ! G ASK
