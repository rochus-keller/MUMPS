JRNCOPY ;16-Sep-83 ;UTILITIES ;JOURNAL ;OFFLOAD DISK TO TAPE ;DRS
        SET $ZT="ERROR^JRNCOPY" C 47,63
        DO 00
QUIT    C:$D(TAPE) TAPE C 63
        Q
00      DO GETVIEWS Q:'OK
10      DO JSPACE QUIT:'OK
20      DO STOPJRN QUIT:'OK
30      DO GETTAPE GOTO 10:'OK
40      DO TAPEMODE^JRNCOPY1 ZTRAP:'OK
50      DO TAPESTAT^JRNCOPY1 GOTO 30:'OK
60      DO BOUNDS^JRNCOPY1
        U 0 W !,"*** " D ^%T W " Begin journal copy"
70      DO OFFLOAD^JRNCOPY1
        U 0 W !,"*** " D ^%T W " Journal copy complete"
80      ;
90      DO REPORT^JRNCOPY1
        QUIT
GETVIEWS        ;
        O 63:1 S OK=1 Q
        S NBUFS=$V($V(44)+32)-5 S:NBUFS<3 NBUFS=3 S:NBUFS>14 NBUFS=14
        F NBUFS=NBUFS:-2:2 C 63 O 63:NBUFS:1 Q:$T
        I '$T D  Q
        .W !!,"Couldn't get enough view buffers (need at least 2).",!,"Stopping.",! S OK=0 Q
        W !!,"Proceeding with ",NBUFS," buffers.",!
        S OK=1 Q
JSPACE  K ND D NOMSG^JRNLSHOW
        I '$D(ND(1)) D  S OK=0 Q
        .W !,"There are no journal spaces currently mounted."
        w !,"Enter the name of the disk journaling space"
        w !,"   which you wish to offload to magtape    > "
        r JSPACE i "^"[JSPACE S OK=0 Q
        I JSPACE="?" D JSPACEH G JSPACE
        S OK=0 F I=1:1 Q:'$D(ND(I))  D  Q:OK
        .I ^SYS(0,"JOURNAL SPACE",ND(I),"NAME")=JSPACE S OK=1,JSPACENN=ND(I) Q
        Q:OK  W !!,*7,"There is no journal space named """,JSPACE,""""
        W " currently mounted.",!,"Answer with '?' to see a list of"
        W " journal space names.",!
        G JSPACE
JSPACEH D ^JRNLSHOW Q
STOPJRN ;
        S A=^SYS(0,"JOURNAL SPACE",JSPACENN,"NEXT")="CURRENT"
        S A=$V($V(44)+410)#2&($V($V(44)+410)\256#2=0)'=0*2+A
        I 'A S OK=1 Q
        I A#2 D  S OK=0 Q
        .W !!,"Journal space ",JSPACE," is being used for journaling"
        .W !,"at the present time.  You cannot offload an journal"
        .W !,"space which is being actively journaled to; you should"
        .W !,"STOP journaling to this space before proceeding.",!
        W !,"Journaling will continue, but only ",JSPACE," will be offloaded, of course."
        W ! S OK=1 Q
GETTAPE W !,"Offload to which tape unit (0,1,2,3) <0> "
        R TAPE S:TAPE="" TAPE=0 I "^"[TAPE S OK=0 Q
        G:TAPE="?" GETTAPE I TAPE'?1N!(TAPE>3) W *7 G GETTAPE
        S TAPE=TAPE+47 S $ZT="NODEV" O TAPE::2
        I '$T D  G GETTAPE
        .W !,"Tape unit # ",TAPE-47," is owned by another user."
        W !!,"Please mount a tape, write-enabled, on tape unit # ",TAPE-47
        W !,"and press RETURN when it's ready > " R X
        G:X="^" GETTAPE I X="" S OK=1 Q
        W *7," ??" G GETTAPE1
        S OK=1
        Q
NODEV   W *7,!,"Tape unit ",TAPE," is not in this configuration."
        W !,"Answer with ""^"" if you have changed your mind"
        W !,"and don't want to proceed with the offload."
        Q
ERROR   U 0 W !,$ZE,!,"Unexpected error in "
        W $P($T(+0),";",1),$P($T(+0),";",3,5)
        W !,"Stopping now, offload has NOT been successful."
        C TAPE,63
        Q
