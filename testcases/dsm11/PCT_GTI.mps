%GTI    ;GLOBAL INPUT @SMB@!!!! CAN ONLY BE USED WITH %GTO !!!!
        W !!,"This routine restores globals saved with %GTO",!!
        S %GTITO=60,$ZE="TRAP^%GTI"
DEV     S %QTY=1,%GIO="" K %DEF,%AVL D ^%IOS I '$D(%IOD) G DONE
        I "MT,SDP"'[%DTY!(%DTY="") W !,?5,"Improper device selection" G DONE
        G GO:%DTY'["MT"
        U %IOD I @(%MTON_"=0") U 0 W !,"Drive not ready" G DONE
        I @(%MTWLK_"=0") U 0 W "  ** Tape is not write protected **"
        U %IOD I @(%MTBOT_"=0") U 0 D %REW^%IOS I '$D(%REW) G DONE
GO      U %IOD R %DATIM,%HEAD U 0
        W !!,?8,"Globals were saved on ",%DATIM,!,"Header: ",%HEAD
ASK     R !,"Restore all (A) or selected (S) ? <A> ",%X:%GTITO G:'$T!(%X="^") DONE
        I %X="?" W !,?5,"Enter 'A' or 'S'" G ASK
        S (NAM,NEW)="",ALL=1,SET=1 I "A"'[%X S ALL=0 I %X'="S" D IV G ASK
        G SDP:%DTY="SDP"
MT      U %IOD S ZE=$ZE,$ZE="" R X,Y S $ZE=ZE I $ZA>32767 G MTE
        I X'="**END**" D NODE G MT:ALL!(%X'="^")
        G END:Y=X I Y="**EOT**" D MOUNT G MT
        *
SDP     U %IOD S ZE=$ZE,$ZE="" R X,Y S $ZE=ZE G SDPE:$ZA<0 I X'="**END**" D NODE G SDP
        G END:X=Y *
NODE    I $P(X,"(",1)=NEW S:SET @X=Y Q
        I $P(X,"(",1)=NAM S @(NEW_$E(X,$L(NAM)+1,999)_"=Y") Q
        U 0 S (NAM,NEW)=$P(X,"(",1) W !,NAM," starting at " D ^%T G NODE:ALL
LOD     W !,"Load as ^ <",$P(NAM,"^",2) R "> ",%X S:%X="" %X=NAM I %X="?" D HELP G LOD
        I %X="-" W " skipping." S SET=0,NEW=NAM G NODE
        G:%X="^" QUIT S:%X'?1"^".E %X="^"_%X
        I %X?1"^%".AN!(%X?1"^"1A.AN) S SET=1,NEW=%X W " OK.  Loading..." G NODE
        D IV G LOD
        -
MOUNT   U 0 W !,"**  End of tape detected **",!,"After current tape rewinds, mount next tape"
        U %IOD W *5 U 0 R !,"Type <CR> to continue: ",%X,!
        U %IOD S ZE=$ZE,$ZE="" R X,Y S $ZE=ZE,ZA=$ZA I ZA>32767 G MTE
        I X'=%DATIM!(Y'=%HEAD) U 0 W !,"Sorry, that's not the continuation tape" U %IOD W *5 G MOUNT
        Q
        -
MTE     S ZA=$ZA U 0 W !,"MAG TAPE ERROR: $ZA="_ZA G TRAP1
        -
SDPE    S ZA=$ZA U 0 W !,"SDP ERROR: $ZA="_ZA G TRAP1
        -
IV      W !,?5,"Incorrect response - Enter '?' for more information" Q
HELP    W !!,?5,"Enter   <CR>  To restore the global with the same name NAME"
        W !,?8,"or    -    To skip restoring this global"
        W !,?8,"or    ^    To abort",!,?8,"or    A new name for restoring this global",!! Q
        -
TRAP    U 0 W !,$ZE
TRAP1   Q:'$D(%IOD)  Q:%IOD=$I  C %IOD Q
        -
END     U %IOD S ZA=$ZA,ZB=$ZB I %DTY["MT" R X W:%MTM["C" *1
        U 0 W !,"Finished" I %IOD>58,%IOD<63 W " with block ",ZA," byte ",ZB
        W " at " D ^%T W !
DONE    U 0 I $D(%IOD),%IOD'=$I C %IOD
        K %X,X,Y,NAM,NEW,%IOD,%DTY,%MTM,%DATIM,%HEAD,ALL,SET Q
QUIT    S (X,Y)="*" Q
