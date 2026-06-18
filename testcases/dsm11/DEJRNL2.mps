DEJRNL2 ;YZH;23-JUN-80;JOURNAL GLOBAL RESTORE FROM DISK AND MAGTAPE
        K %LIST U 0 R !,"Do you want to print the Global data being restored ? <N> ",%X I %X="" W ! G %VALID
        I %X="^" G:$D(DKJRN) %JSP^DEJRNL U 0 C %JIO G %ASK^DEJRNL1
        I %X="?" W !,?5,"Enter Y(es) or N(o),",!,?8,"or type '^' to return to the previous question.",! G DEJRNL2
        I %X?1"Y".E S %LIST="" G %DEV
        I %X?1"N".E W ! G %VALID
        D %IV G DEJRNL2
%DEV    S %QTY=2 D ^%IOS
        I '$D(%IOD) G DEJRNL2
        I "SC^LP^TRM"'[%DTY!(%DTY="") D %IV G %DEV
        W ! G %VALID
%VALID  R !,"Do you want to validate each restoration ? <N> ",%X G:%X="^" DEJRNL2
        I %X["?" D %Q1 G %VALID
        I %X=""!(%X?1"N".E) S %VALID=0 G %CK
        I %X?1"Y".E S %VALID=1 G %CK
        D %IV G %VALID
%CK     W !!,"**   " D ^%T W "   Dejournal Begin" K %X G:'$D(DKJRN) %READ S JSP=JRNSP
%ST     S JBLK=^SYS(0,"JOURNAL SPACE",JSP,"START"),JEND=^("END"),NMAP=(JEND-JBLK)\400+1
        S DDU=^("DISK")
        O %JIO:(-NMAP:JBLK:DDU)
%READ   S $ZT="%ERR" U %JIO R %REC
        I '$D(DKJRN) I $ZA\16384#2 G %END
        I $D(DKJRN) I $ZA=-1 C %JIO G:'$D(%ALL) %END S JSP=$N(^SYS(0,"JOURNAL SPACE",JSP)) G:JSP'?.N %END G %ST
        S %CT=2,%GREF=$E(%REC,%CT+1,255)
        R:$E(%REC,%CT)="S" %VAL
%SET    I '%VALID G:$E(%REC,%CT)="K" %K G %S
        U 0 R *X:0 I '$D(%X) G %C2
        I %X="*" I X'=13 G:$E(%REC,%CT)="K" %K G %S
%C2     I $E(%REC,%CT)="K" G %ASK2
%ASK1   U 0 W !,"<S ^",%GREF R "> Restore ? <Y> ",%X
        I %X="*" W !!,"   De-journal in progress.  Type <CR> to return to Step Mode",! G %S
        I %X["?" D %Q2 G %ASK1
        I %X="^" G:'$D(DKJRN) %END C %JIO G %END
        I %X'=""&($E("NO",1,$L(%X))=%X) W "          Skipped" G %READ
        I $E("YES",1,$L(%X))'=%X D %IV G %ASK1
%S      S @%GREF=%VAL I %VALID W:%X'="*" "          Restored"
        I $D(%LIST) U %IOD W !," S ",%GREF," = ",%VAL
        G %READ
%ASK2   U 0 W !,"<K ^",%GREF R "> Kill ? <Y> ",%X
        I %X="*" W !!,"   De-journal in progress.  Type <CR> to return to Step Mode",! G %K
        I %X["?" D %Q2 G %ASK2
        I %X="^" G:'$D(DKJRN) %END C %JIO G %END
        I %X'=""&($E("NO",1,$L(%X))=%X) W "          Skipped" G %READ
        I $E("YES",1,$L(%X))'=%X D %IV G %ASK2
%K      K @%GREF I %VALID W:%X'="*" "          Killed"
        I $D(%LIST) U %IOD W !," K ",%GREF
        G %READ
%END    U 0 I $D(%LIST) C:%IOD'=$I %IOD
        I '$D(DKJRN) U %JIO W *5
        U 0 W !!,"**   " D ^%T W "   Dejournal Complete"
        S $ZT="" G ^DEJRNL
%IV     W !,?5,"Incorrect response.  Enter '?' for more information",! Q
%Q1     W !!,?5,"Enter 'Y' to validate each Global reference before restoration"
        W !,?5,"Enter 'N' or <CR> to omit this validation.",! Q
%Q2     W !!,?5,"Enter Y(es) or <CR> to Restore/Kill the Global reference."
        W !,?5,"Enter N(o) to skip to the next Global reference."
        W !,?5,"Enter '^' to abort de-journaling."
        W !,?5,"Enter '*' to Restore/Kill this and all following Global references."
        W !,?5,"Then type <CR> at any time to return to step mode.",! Q
%ERR    I $ZE'["MTERR" U 0 W !!,$ZE,!,"Func= ",$E(%REC,%CT),"   Ref= ",%GREF W:$E(%REC,%CT)="S" !,"Val= ",%VAL G %READ
        D %SET^%MTCHK I '%MTON U 0 W !!,"Tape unit off line",! G %END
        I @%MTERR G %END
        U 0 W !!,"Tape error: ",! U %JIO D ^%MTCHK U 0 W ! G %END
