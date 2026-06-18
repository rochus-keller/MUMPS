%RCE    ;GEF ; DSM UTILITIES ; ROUTINE SEARCH:UPDATED-7AUG79-PJM ; CHANGED TO CHANGE EVERY KFD JUN-85
%ST     S $ZT="%ERR^%RCE",%TRM=$I,%QTY=2 I $D(%IOD) C:%IOD'=$I %IOD
        K %DEF D ^%IOS G:'$D(%IOD) %EXIT
        I "LP,TRM,SC"'[%DTY W !,?5,*7,"Improper device selection" G %RSE
%RSEL   K ^UTILITY($J) D ^%RSEL G:'$D(%GO) %ST G:'%GO %ST
        S %NAM="" I $ZS(^UTILITY($J,%NAM))="" G %EXIT
%ASK    U 0 K %CHK R !,"Search for ? > ",%SE G:%SE="^Q" %EXIT I %SE=""!(%SE="^") G %RSEL
        G:%SE="?" %HELP
%CTO    R !,"Change to: ",%CT G:%CT="^Q" %EXIT
        I %CT="^" G %ASK
        G:%CT="?" %HELPC
%CK     U %IOD
        W #,!,?35,"Routine Search",!,?35,"Searching for",!,?(40-($L(%SE)/2)),"""",%SE,""""
        W !,?32 D ^%D W "  " D ^%T W !!
        S %LK="F %I=1:1 S %LN=$T(+%I) X:%LN="""" ""ZS:%ZS  "" Q:%LN=""""  I %LN[%SE W !,*7,"">>>>>"",%NAM,""+"",%I-1,!,%LN S %C=0,%C
HK=1 X %REP,%INS:%ALT"
        S %C=0,%REP="",%ALT="",%INS="ZI %LN:"_"+%I"_" ZR +%I S %ZS=1 W !,%LN,!"
        I %CT'="""" S %REP="S %FLN=1,%ALT=0 F %K=0:1 S %FLN=$F(%LN,%SE,$L(%CT)-$L(%SE)+%FLN) Q:'%FLN  S %LN=$E($E(%LN,1,%FLN-$L(%SE)
-1)_%CT_$E(%LN,%FLN,255),1,255),%ALT=1"
        S %NAM=""
%GO     U %IOD S %NAM=$ZS(^UTILITY($J,%NAM)) I %NAM="" W !!! I '$D(%CHK) W "`",%SE,"'"," Not found ",!!! G %ASK
        I %NAM="" W !!! G %ASK
        S %ZS="" X "ZL @%NAM W:$X+$L(%NAM)>72 ! W %NAM,"", "" S %C=%C+1 X %LK"
        G %GO
%EXIT   U 0 K %NAM,%DTY,%GO,%LK,%SE,%C,%H,%I,%ALT,%CT,%FLN,%INS,%K,%LN,%REP,%ZS
        I $D(%IOD) C:%IOD'=%TRM %IOD
        K %IOD,%TRM Q
%ERR    S ZE=$ZE U 0 S $ZT="%ERR^%RCE"
        I ZE?1"<INRPT".E W !!,*7,"** Interrupt **",*7,! G %ST
        I ZE?1"<PGMOV".E,$D(%NAM) W #!,*7,%NAM,?17,"** Too large to search in this partition **",*7,!!# U %IOD G %GO
        W !,*7,ZE,! Q
%HELP   W !!,"Do you really want help (H),",!?5,"or do you want to search for a '?' (S)",! R "Enter `H' or `S' > ",%H
        I %H="S" K %H G %CK
        G:%H="^Q" %EXIT I %H=""!(%H="^") K %H G %ASK
        W !,"Enter the character(s) for which you want to search",!
        W "Enter <CR> or ^ to exit the routine",! K %H G %ASK
%HELPC  W !!,"Enter the string you would like to insert"
        W !,"Enter ^Q, to quit or ^ to go to prior prompt"
        Q
