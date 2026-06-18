%RR     ; GEF ; DSM UTILITIES ; ROUTINE RESTORE
        W !!,"Routine Restore",! S %ZERR=$ZE,$ZE="%ERR^%RR" I %ZERR?1"<".E S %ZERR=""
%ST     S %QTY=1 K %DEF D ^%IOS I '$D(%IOD) S $ZE="" G %EXIT
        I "MT,SDP"'[%DTY W !,?5,*7,"Improper device selection" G %DONE
        G:%DTY'["MT" %MT U %IOD I @(%MTON_"=0") U 0 W !?5,*7,"Drive not ready" G %DONE
        I @(%MTWLK_"=0") U 0 W !?5,*7,"  ** Tape not write protected **"
        U %IOD I @(%MTBOT_"=0") U 0 D %REW^%IOS I '$D(%REW) G %DONE
%MT     S %TRP=0
%GET    U %IOD R %DATIM,%HEAD U 0 I %DATIM="",%HEAD="" W !?5,*7,"Tape is not in expected Routine Save format" G %EXIT
        S %CT=0 W !!,?8,"Routines were saved on ",%DATIM,!,"Header: ",%HEAD
        I %TRP G %A1
%ASK    R !,"Restore all (A) or Selected (S) ? <A> ",%X G:%X="^" %DONE
        I %X="?" W !,?5,"Enter 'A' or 'S'",! G %ASK
        S %ALL=0 I %X=""!(%X="A") S %ALL=1 G %A1
        I %X'="S" D %IV G %ASK
%A1     U %IOD I %DTY["MT",@%MTEOT G ET
%GO     R %NAM I %NAM="" G:%DTY'["MT" %DONE W:%MTM["L" *2,*2,*2 W:%MTM["C" *1 G %DONE
        U 0 I %ALL W:'(%CT#8) ! W ?(%CT#8*10),%NAM G %SAV
%RES    W !,"Restore as ? <",%NAM R "> ",%X G:%X="^" %DONE G:%X="?" %HELP
        I %X="" G %SAV
        I %X="-" U %IOD X "ZL" U 0 W "  Skipped" G %A1
        I '(%X?1"%"1AN.AN!(%X?1A.AN)) D %IV G %RES
        I $L(%X)>8 D %IV G %RES
        S %NAM=%X
%SAV    X "S $ZT=""%E3^%RR"" U %IOD ZL  ZS @%NAM" I '%ALL U 0 W "  Restored"
        S %CT=%CT+1 G %A1
%DONE   U 0 I $D(%IOD) C:%IOD'=$I %IOD
        G %ST
%EXIT   U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %MTBOT,%MTEOT,%MTLER,%MTON,%MTPIP,%MTTMK,%MTTYP,%MTWLK
        K %ALL,%CT,%DATIM,%DTY,%HEAD,%IOD,%NAM,%REW,%TRP,%X S $ZE=%ZERR K %ZERR Q
%IV     W !,?5,"Incorrect response - Enter '?' for more information" Q
%HELP   W !!,?5,"Enter   <CR>  To restore the routine with the same name"
        W !,?8,"or    -    To skip restoring this routine"
        W !,?8,"or    ^    To terminate restoring",!,?8,"or    A new name for restoring this routine",!! G %RES
%ERR    S ZA=$ZA,ZE=$ZE
        I ZE?1"<INRPT".E U 0 W !?5,*7,"Unexpected interrupt",! G %EXIT
        G:ZE'?1"<MTERR".E %E2 S $ZE="%ERR^%RR" I @(%MTTMK_"=1") G %DONE
ET      I @(%MTEOT_"=0") G %E2
        U 0 W !!?5,*7,"** End of tape detected **",!?5,"After current tape rewinds, mount next tape"
        U %IOD W *5 U 0 W !?5,"Type <CR> to continue, ^ to abort " R %X,! G:%X="^" %DONE
        S %TRP=1 G %GET
%E2     U 0 W !,*7,ZE,"   $ZA = ",ZA G %DONE
%E3     ZQ
