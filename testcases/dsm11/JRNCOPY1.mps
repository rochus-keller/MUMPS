JRNCOPY1        ;16-Sep-83 ;UTILITIES ;JOURNAL ;OFFLOAD DISK TO TAPE ;DRS
        Q
TAPEMODE        ;
        C TAPE O TAPE U TAPE W *5 C TAPE O TAPE:("BT":0:1024)
        Q
TAPESTAT        ;
        U TAPE D %SET^%MTCHK
        I @%MTERR D ^%MTCHK S OK=0 Q
        I @%MTWLK D WRTENABL Q:'OK
        S OK=1 Q
WRTENABL        u 0 w !,"The tape is not write-enabled."
        w !,"Please make it write-enabled, then press RETURN."
        w !,"If you have changed your mind, answer with ""^""."
        N Z R Z I Z="" S OK=1 Q
        I Z="^" S OK=0 Q
        G WRTENABL
BOUNDS  ;
        S START=^SYS(0,"JOURNAL SPACE",JSPACENN,"START")
        S END=^SYS(0,"JOURNAL SPACE",JSPACENN,"END")
        S DISK=^SYS(0,"JOURNAL SPACE",JSPACENN,"DISK")
        I END#400=399 S END=END-1
        E  ZT
        V END:DISK D ZCHK I '%Z G BOUNDS4
        V START:DISK D ZCHK I %Z U 0 W !,"This journal space has nothing written to it." Q
        S DONE=0,%A=START,%B=END
        S %=%A+%B\2 S:%#400=399 %=%+1
BOUNDS2 ;
        V %:DISK D ZCHK
        I %Z D  G BOUNDS4:DONE,BOUNDS2
        .I %A+1=% S END=%A,DONE=1 Q
        .S %B=%,%=%A+%\2 S:%#400=399 %=%-1
        E  D  G BOUNDS4:DONE,BOUNDS2
        .I %+1=%B S END=%,DONE=1 Q
        .S %A=%,%=%B+%\2 S:%#400=399 %=%-1
BOUNDS4 U 0 W !!,"Now ready to offload the ",JSPACE," journal space."
        W " (#",JSPACENN,")"
        W !,"The offload will start at block " W START,":",DISK
        I END>0 W !,"It will copy up to and including block " W END,":",DISK
        E  W !,"It will copy as long as it finds journal records."
        W !!,"You may hit <ESC> at any time to see the number of blocks"
        W !,"processed thus far."
        Q
ZCHK    ;
        S %Z=$V(0,0)!$V(2,0)!$V(4,0)!$V(6,0),%Z='%Z Q
OFFLOAD ;
        S $ZT="OFFZT" S DONE=0
        S S=START,E=END,T=TAPE,D=DISK
        U T F B=S:1:E I B#400'=399 V B:D Q:'$V(0,0)  W *4 D RPT
        U T W *3,*3
        U T W *5 C T
        Q
        S NCOP=0,HALF=0
        F BLK=START:1:$S(END>0:END,1:^SYS(0,"JOURNAL SPACE",JSPACENN,"END")) DO  Q:DONE
        .I $V(2,$J)\8#2 D ESC Q:'OK
        .I BLK#400=399 Q
        .U 63:HALF+1 V BLK:DISK S HALF='HALF
        .I '$V(0,0),'$V(2,0),'$V(4,0),'$V(6,0) S DONE=1
        .E  U TAPE W *4 S NCOP=NCOP+1
        U TAPE W *3,*3
        U TAPE W *5 C TAPE
        Q
OFFZT   I $ZE["MTERR" D  Q:'OK  G OFFLOAD
        .U TAPE S ZA=$ZA U 0
        .I ZA\1024#2 S $ZT="OFFZT" D NXTVOL S START=B Q
        .S $ZT="OFFZT2"
        .W !,"Magtape error, $ZA = ",ZA," (decimal) "
        .W !,"About ",BLK-START," blocks were processed."
        .S OK=0
OFFZT2  U 0 I $ZE["<DK" D  Q
        .W !,"Disk error, cannot read near block ",BLK,":",DISK
OFFZT3  U 0 W !,"$ZE=",$ZE zt
RPT     U 0 R *X:0 U T Q:X<0  U 0
        W !,B-START," blocks processed, last block copied was "_B_"."
        W !,"Type ""^"" to abort copy, ""<CR>"" to continue: " R X W !
        U T Q:X'="^"  S B=E Q
REPORT  ;
        U 0 W !!,"Journal space ",JSPACE," has been offloaded to tape."
        W !,"The tape is usable by the ^DEJRNL utility."
        W !
        Q
NXTVOL  U TAPE W *3,*3,*5
        U 0 W !,"Out of space on this magtape,."
        w !,"After it rewinds, mount a new tape on unit ",TAPE-47
        W !,"and press RETURN  when it's ready             > " R X
        I X="^" W !,"Stopping" S OK=0 Q
        I X="" W !,"Continuing (Block = "_B_")",! D TAPESTAT I 'OK G NXTVOL
        E  Q
        G NXTVOL
