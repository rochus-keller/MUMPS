%GR     ; DB ; 9-NOV-80 ; DSM11 VERSION 1 GLOBAL RESTORE
        W !!,"Global Restore",! ; S %ZERR=$ZE,$ZE="%ERR^%GR" S:%ZERR?1"<".E %ZERR=""
%ST     S %QTY=1,%GIO="" K %DEF,%AVL D ^%IOS I '$D(%IOD) G %EXIT
        I "MT,SDP"'[%DTY!(%DTY="") W !,?5,"Improper device selection" G %DONE
        G %MT:%DTY'["MT"
        U %IOD I @(%MTON_"=0") U 0 W !,"Drive not ready" G %DONE
        I @(%MTWLK_"=0") U 0 W "  ** Tape is not write protected **"
        U %IOD I @(%MTBOT_"=0") U 0 D %REW^%IOS I '$D(%REW) G %DONE
%MT     S %TRP=0
%GET    U %IOD R %DATIM,%HEAD U 0 I %DATIM="**",%HEAD="**" Q
        S %CT=0 W !!,?8,"Globals were saved on ",%DATIM,!,"Header: ",%HEAD
        I %TRP U %IOD G %SAV
%ASK    R !,"Restore all (A) or selected (S) ? <A> ",%X,! G:%X="^" %DONE
        I %X="?" W !,?5,"Enter 'A' or 'S'" G %ASK
        S %ALL=0 I %X=""!(%X="A") S %ALL=1 G %A1
        I %X'="S" D %IV G %ASK
%A1     U %IOD
%GO     R %NAM,%DIR
        I %NAM="**",%DIR="**" R %DIR G %DONE
        I %ALL S @%NAM=%DIR,%SAV=1 U 0 W !,%NAM U %IOD G %SAV
        U 0
%RES    W !,"Restore as ? <",%NAM R "> ",%X,! G:%X="^" %DONE G:%X="?" %HELP
        S %SAV=1 I %X="" S @%NAM=%DIR U %IOD G %SAV
        I %X="-" U %IOD S %SAV=0 G %SAV
        I '(%X?1"%"1AN.AN!(%X?1A.AN)) D %IV G %RES
        S %NAM="^"_%X,@%NAM=%DIR U %IOD
%SAV    R %IN,%DATA I %DTY="MT",@%MTEOT G ET
        I %IN="**",%DATA="**" U 0 D %STA G %DONE
        I %IN="*",%DATA="*" U 0 D %STA G %A1
        I %SAV S @(%NAM_%IN)=%DATA
        G %SAV
%DONE   U 0 I $D(%IOD) C:%IOD'=$I %IOD
        G %ST
%STA    W $S(%SAV:" Restored",1:" Skipped") Q
%IV     W !,?5,"Incorrect response - Enter '?' for more information" Q
%HELP   W !!,?5,"Enter   <CR>  To restore the global with the same name NAME"
        W !,?8,"or    -    To skip restoring this global"
        W !,?8,"or    ^    To abort",!,?8,"or    A new name for restoring this global",!! G %RES
%ERR    S %ZA=$ZA I $ZE'?1"<MTERR".E G %E2
        I @(%MTTMK_"=1") G %DONE
ET      ;
        U 0 W !!,"** End of tape detected **",!,"After current tape rewinds, mount next tape"
        U %IOD W *5 U 0 R !,"Type <CR> to continue",%GO G %DONE:%GO="^" S $ZE="%ERR^%GR"
        S %TRP=1 G %GET
%E2     U 0 I $ZE?1"<INRPT".E W !?5,*7,"Unexpected interrupt",! G %EXIT
        W !,"$ZE = ",$ZE,"  $ZA = ",%ZA,!
%EXIT   U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %ALL,%CT,%DATA,%DATIM,%DIR,%DTY,%GIO,%HEAD,%IN,%IOD,%NAM,%REW,%SAV,%TRP,%ZERR Q
