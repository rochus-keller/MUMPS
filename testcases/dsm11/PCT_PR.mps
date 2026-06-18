%PR     ;13-Jan-82 ;UTILITY ;PROGRAM MAINTENANCE ;RESTORES A PROGRAM FROM TAPE ;JHM
        W !!,"Program Restore",! S %ZERR=$ZE,$ZE="%ERR^%PR" S:%ZERR?1"<".E %ZERR=""
%ST     S %QTY=1,%GIO="" K %DEF,%AVL D ^%IOS I '$D(%IOD) G %EXIT
        I "MT,SDP"'[%DTY!(%DTY="") W !,?5,"Improper device selection" G %DONE
        G %MT:%DTY'["MT"
        U %IOD I @(%MTON_"=0") U 0 W !,"Drive not ready" G %DONE
        I @(%MTWLK_"=0") U 0 W "  ** Tape is not write protected **"
        U %IOD I @(%MTBOT_"=0") U 0 D %REW^%IOS I '$D(%REW) G %DONE
%MT     S %TRP=0
%GET    U %IOD R %DATIM,%HEAD U 0 I %DATIM="**",%HEAD="**" Q
        S %CT=0 W !!,?8,"Programs were saved on ",%DATIM,!,"Header: ",%HEAD
        I %TRP U %IOD G %SAV
%ASK    R !,"Restore all (A) or selected (S) ? <A> ",%X,! G:%X="^" %DONE
        I %X="?" W !,?5,"Enter 'A' or 'S'" G %ASK
        S %ALL=0 I %X=""!(%X="A") S %ALL=1 G %A1
        I %X'="S" D %IV G %ASK
%A1     U %IOD
%GO     R %DIR,%NAM
        I %NAM="**",%DIR="**" R %DIR G %DONE
        I $D(^PRG(%DIR,%NAM))#2 S %VER=^(%NAM)+1
        E  S %VER=1
        I %ALL S %SAV=1 U 0 W !,%NAM,".",%DIR,";",%VER G %SSAV
        U 0
%RES    W !,"Restore as ? <",%NAM,".",%DIR,";",%VER R "> ",%X,! G:%X="^" %DONE G:%X="?" %HELP
        S %SAV=1 I %X="" G %SSAV
        I %X="-" S %SAV=0 G %SSAV
        I %X'?1NUP.NUP!($P(%X,".",1)="") D %IV G %RES
        S %NAM=$P(%X,".",1),%VER=$P(%X,";",2),%DIR=$P($P(%X,".",2),";",1)
        I %DIR="" S %DIR="SOU"
        I %VER="" S %VER=1 I $D(^PRG(%DIR,%NAM))#2 S %VER=^(%NAM)+1
%SSAV   S %PRG="^PRG("""_%DIR_""","""_%NAM_""","_%VER_","
        I %SAV D
        .I $D(^PRG(%DIR,%NAM))#2 S:%VER>^(%NAM) ^(%NAM)=%VER
        .E  S ^PRG(%DIR,%NAM)=%VER
        U %IOD
%SAV    R %IN,%DATA
        I %IN="**",%DATA="**" U 0 D %STA G %DONE
        I %IN="*",%DATA="*" U 0 D %STA G %A1
        I %SAV S @(%PRG_%IN_")")=%DATA
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
        I @(%MTEOT_"=0") G %E2
        U 0 W !!,"** End of tape detected **",!,"After current tape rewinds, mount next tape"
        U %IOD W *5 U 0 R !,"Type <CR> to continue",%GO G %DONE:%GO="^" S $ZE="%ERR^%PR"
        S %TRP=1 G %GET
%E2     U 0 I $ZE?1"<INRPT".E W !?5,*7,"Unexpected interrupt",! G %EXIT
        W !,"$ZE = ",$ZE,"  $ZA = ",%ZA,!
%EXIT   U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %ALL,%CT,%DATA,%DATIM,%DIR,%DTY,%GIO,%HEAD,%IN,%IOD,%NAM,%REW,%SAV,%TRP,%ZERR,%PRG,%VER Q
