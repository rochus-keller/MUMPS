%GS     ; DB ; 9-NOV-80 ; DSM11 VERSION 1 GLOBAL SAVE
        W !!,"Global Save",! S %GSTO=60,%ZERS=$ZE,$ZE="%ERR^%GS" S:%ZERS?1"<".E %ZERS=""
%ST     S %QTY=2,%GIO="" K %DEF D ^%IOS S:'$D(%MTM) %MTM="" I '$D(%IOD) G %EXIT
        S %ZERS=$ZE,$ZE="%ERR^%GS" I %ZERS?1"<".E S %ZERS=""
        I "MT,TRM,SDP,LP,SC"'[%DTY!(%DTY="") W !,"Improper device selection" G %DONE
        G %SET:%DTY'["MT"
        U %IOD S ZA=$ZA I @(%MTON_"=0") U 0 W !,"Drive not ready" G %DONE
        I @%MTWLK U 0 W !,"Tape is write protected" G %DONE
        I @(%MTBOT_"=0") U 0 D %REW^%IOS I '$D(%REW) G %DONE
%SET    S %CTC=0 S:((%DTY="MT")&(%MTM["V")) %CTC=1
        U 0 S CHK=0 I %DTY="MT" R !,"Do you want to check for control characters ? < NO > ",CHK G CHKHLP:CHK="?",%DONE:CHK="^" S CHK=CHK?1"Y".E
%HEAD   R !,"Header comment... ",%HEAD I %HEAD="^" G %DONE
        I %HEAD="?" W !,?5,"Enter any text to be used as a heading" G %HEAD
%GSEL   D ^%GSEL G %ST:'$D(%GO) I '%GO G %HEAD
        S (%NAM,%CT)="" I $ZS(^UTILITY($J,%NAM))="" G %DONE
        D INT^%D,INT^%T U %IOD
        I %DTY="SDP"!(%DTY="MT") S %DATM=%DAT1_"     "_%TIM W:%CTC %DATM,%HEAD W:'%CTC %DATM,!,%HEAD,! D %ST^%GS1 G %ST
        W #,!,"Global listing ",%DAT1,"     ",%TIM,!,%HEAD,!!
%G1     S %NAM=$ZS(^(%NAM)) I %NAM="" S %CT=0 W #! D %ST^%GS1 G %ST
        W:'(%CT#8) ! W ?(%CT#8*10),%NAM S %CT=%CT+1 G %G1
%DONE   U 0 C:%IOD'=$I %IOD G %ST
        G %ST
%ERR    S %ZA=$ZA I $ZE'?1"<MTERR".E G %E2
        I @(%MTTMK_"=1") G %DONE
EOT     ;
        U 0 W !!,"** End of tape detected **",!,"After current tape rewinds, mount next tape"
        U %IOD W *3,*3,*5 U 0 R !,"Type <CR> to continue",%GO G %DONE:%GO="^" S $ZE="%ERR^%GS"
        D INT^%D,INT^%T U %IOD
        S %DATM=%DAT1_"     "_%TIM W:%CTC %DATM,%HEAD W:'%CTC %DATM,!,%HEAD,!
        I POS=1 W:%CTC "**","**" W:'%CTC "**",!,"**",! G %DONE
        I POS=2 G %ER2^%GS1
        I POS=3!(POS=5)!(POS=7) W:%CTC "*","*" W:'%CTC "*",!,"*",! G %ST^%GS1
        I POS=4 G %ER4^%GS1
        I POS=6 G %ER6^%GS1
%E2     U 0 I $ZE?1"<INRPT".E W !?5,*7,"Unexpected interrupt",! G %EXIT
        W !,"$ZE = ",$ZE,"  $ZA = ",%ZA,!
%EXIT   U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %CT,%CTC,%DAT,%DAT1,%DATM,%DCF,%DTY,%GIO,%GO,%GSTO,%NAM,%REW,%TIM,%UCIN,%ZERS,AR,CHK,D,DD,EN,F,GLN,GLREF,I,II,IN,L,LCT,LNO,POS,S,ST,TEMP,V,VS,X,Y,ZA Q
CHKHLP  W !,?5,"Answer ""Y[ES]"" if you want to include a check for"
        W !,?5,"control characters in the global data. If  included"
        W !,?5,"each record containing control characters   will be"
        W !,?5,"displayed on your terminal so that they can be  re-"
        W !,?5,"stored manually. The control character check   will"
        W !,?5,"impact the speed of global save." G %SET
