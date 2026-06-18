%PSD    ;1-Dec-8 ;UTILITY ;SYMBOLS ;PRODUCES A DIRECTORY OF EDITOR SYMBOLS ;JHM
        U 0 W !,"PROGRAM SYMBOL DIRECTORY "
        S %QTY=2,%DEF=0 D ^%IOS G %DN:'$D(%IOD)
        U 0 W !
        U %IOD W !!,?19,"PROGRAM SYMBOL DIRECTORY " D INT^%D,INT^%T W %DAT
        D ^%GUCI S DIR=%UCI
        U %IOD W !?19,"of ",DIR
        I '$D(^P) U 0 W !!,"No files in this directory",! G %CLOSE
        S LIB=-1
NEXT    S LIB=$N(^P(LIB)) G %CLOSE:LIB=-1
        U %IOD W !!,LIB," Library" S X=$X
        W ! F I=1:1:X W "-"
        W ! S SYM=-1
N2      S SYM=$N(^P(LIB,SYM)) G NEXT:SYM=-1
        W !,SYM,?40,"= ",^(SYM) G N2
%CLOSE  U 0 I %IOD'=$I C %IOD
%DN     U 0 K %CT,%DAT,%TIM,%GO,%UTILITY,I Q
