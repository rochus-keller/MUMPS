%RSE    ;GEF ; DSM UTILITIES ; ROUTINE SEARCH:UPDATED-7AUG79-PJM
%ST     S $ZT="%ERR^%RSE",%TRM=$I,%QTY=2 I $D(%IOD) C:%IOD'=$I %IOD
        K %DEF D ^%IOS G:'$D(%IOD) %EXIT
        I "LP,TRM,SC"'[%DTY W !,?5,"Improper device selection" G %RSE
%RSEL   K ^UTILITY($J) D ^%RSEL G:'$D(%GO) %ST G:'%GO %ST
        S %NAM="" I $ZS(^UTILITY($J,%NAM))="" G %EXIT
%ASK    U 0 K %CHK R !,"Search for ? > ",%SE G:%SE="^Q" %EXIT I %SE=""!(%SE="^") G %RSEL
        G:%SE="?" %HELP
%CK     U %IOD
        W #,!?35,"Routine Search",!?39,$ZU(0),!?35,"Searching for",!?(40-($L(%SE)/2)),"""",%SE,""""
        W !,?32 D ^%D W "  " D ^%T W !!
        S %LK="F %I=1:1 Q:$T(+%I)=""""  I $T(+%I)[%SE W !,"">>>>>"",%NAM,""+"",%I-1,!,$T(+%I),! S %C=0,%CHK=1",%C=0
        S %NAM=""
%GO     U %IOD S %NAM=$ZS(^UTILITY($J,%NAM)) I %NAM="" W !!! I '$D(%CHK) W "`",%SE,"'"," Not found ",!!! G %ASK
        I %NAM="" W !!! G %ASK
        W "." X "ZL @%NAM X %LK"
        G %GO
%EXIT   U 0 K %NAM,%DTY,%GO,%LK,%SE,%C,%H,%I I $D(%IOD) C:%IOD'=%TRM %IOD
        S $ZT="" K %IOD,%TRM Q
%ERR    S ZE=$ZE U 0 S $ZT="%ERR^%RSE"
        I ZE?1"<INRPT".E W !!,"** Interrupt **",! G %ST
        I ZE["PGMOV"!(ZE["STORE"),$D(%NAM) W #!,*7,%NAM,?17,"** Too large to search in this partition **",*7,!!# U %IOD G %GO
        W !,*7,ZE,! Q
%HELP   W !!,"Do you really want help (H),",!?5,"or do you want to search for a '?' (S)",! R "Enter `H' or `S' > ",%H
        I %H="S" K %H G %CK
        G:%H="^Q" %EXIT I %H=""!(%H="^") K %H G %ASK
        W !,"Enter the character(s) for which you want to search",!
        W "Enter <CR> or ^ to exit the routine",! K %H G %ASK
