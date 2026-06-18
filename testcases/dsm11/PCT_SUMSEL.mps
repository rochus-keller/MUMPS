%SUMSEL ;Select routine name for summary routine : JEC ; 19-OCT-81 10:40 PM
        K ^UTILITY($J) I '$D(%JB) R !!,"For which summary: ",%JB Q:%JB=""
        S %ZERSEL=$ZE,$ZE="ERR^%SUMSEL" S:%ZERSEL["<" %ZERSEL=""
ASK     R !,"Routine(s) ? > ",%X,! G Q1:%X="?",EXIT:%X=""!(%X="^")
        S %MI=0 I $E(%X,1)="-" S %MI=1,%X=$E(%X,2,999)
        I %X="*",'%MI S %FI=1,%ST=$C(127) D GET G ASK
        I %X="*" K ^UTILITY($J) G ASK
        I %X?.E1"*" S %FI=$E(%X,1,$L(%X)-1),%ST=%FI_$C(127) D GET G ASK
        I %X?1E.E1"-"1E.E S %FI=$P(%X,"-",1),%ST=$P(%X,"-",2) D GET G ASK
        I %X'?1A.AN,%X'?1"%".AN D IV G ASK
        I %MI K ^UTILITY($J,%X) G ASK
        I $D(^UTILITY("SUM",%JB,%X)) S ^UTILITY($J,%X)="" G ASK
        W "   ",*7,"No such routine" G ASK
        -
GET     G MINUS:%MI S %N=%FI G GET2:%N="",GET2:'$D(^UTILITY("SUM",%JB,%N))
GET1    Q:%N]%ST  S ^UTILITY($J,%N)=""
GET2    Q:%N=%ST  S %N=$ZS(^UTILITY("SUM",%JB,%N)) G GET1:%N]"" Q
MINUS   K ^UTILITY($J,%FI) S %N=%FI
R1      S %N=$ZS(^(%N)) I %N=""!(%N]%ST) Q
        K ^(%N) G R1:%N'=%ST Q
IV      W !?5,*7,"Incorrect response - Enter '?' for more information" Q
NONE    W !?5,*7,"No routines selected" Q
ERR     W !,$ZE Q
EXIT    S $ZE=%ZERSEL K %X,%ST,%FI,%MI,%N,%ZERSEL,%A
        Q
Q1      W !!?5,"Enter   A routine name"
        W !?8,"or   NAM*       For all routines beginning with letters 'NAM'"
        W !?8,"or   NAM1-NAM2  To select routines whose names are in the range"
        W !?24,"from NAM1 to NAM2, inclusive"
        W !?8,"or    *    To select all routines"
        W !?8,"or    -    Followed by any of the above to de-select routines"
        W !?19,"which have been selected"
        W !?8,"or   <CR>  When done selecting"
        W !?8,"or    ^    To terminate without selection"
        G ASK
        -
Z       P %SUMSEL ZS %SUMSEL
