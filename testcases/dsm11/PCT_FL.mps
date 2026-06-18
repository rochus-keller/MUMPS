%FL     ;FDN;5-JUN-80;FIRST-LINE LIST OF SPECIFIED ROUTINES
        W !,"Routine First-line List",!!
        S $ZT="%ERR^%FL"
%GET    S %QTY=2,%TRM=$I K %DEF D ^%IOS G:'$D(%IOD) %END
        K ^UTILITY($J) D ^%RSEL G:'$D(%GO) %DONE G:'%GO %DONE
        S %NAM="" G:$ZS(^UTILITY($J,%NAM))="" %DONE D ^%GUCI
        U %IOD W #!?28,"First line list of ",%UCI K %UCI,%UCN
        W !,?30 D ^%D W ?40 D ^%T W !!
%GO     S %NAM=$ZS(^UTILITY($J,%NAM)) G:%NAM="" %DONE
        X "ZL @%NAM W %NAM,?10,$P($T(+1),"" "",1),?17,$P($T(+1),"" "",2,99),!" W:$Y>60 # G %GO
%DONE   U 0 I $D(%IOD) C:%IOD'=%TRM %IOD G %GET
%END    K %NAM,%DTY,%GO,%IOD,%QTY,%TRM Q
%ERR    S ZE=$ZE,$ZT="%ERR^%FL" U 0
        I ZE?1"<INRPT".E W !!,*7,"*** Interrupt ***",*7,! G %DONE
        I ZE?1"<PGMOV".E,$D(%NAM) W !,*7,%NAM,?17,"** Too large to list in this partition **",*7,!! G %GO
        I ZE?1"<NOPGM".E,$D(%NAM) W #!,*7,%NAM,?12,"has been deleted since creation of your list.  Continuing...",*7,!# G %GO
        W !,*7,ZE,! G %DONE
