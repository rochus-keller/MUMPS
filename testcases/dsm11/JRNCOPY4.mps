JRNCOPY4        ;16-Sep-83 ;UTILIITIES; ;JOURNAL ;OFFLOAD DISK TO TAPE ;DRS
        Q
OFFLOAD S BLK=START
        S SIDE=0
        S SIDESIZ=NBUFS\2
        U 0:(:::::::::$C(3,27))
A       S $ZT="ERR"
        F MAP=START:400:END D
        .F BLK=MAP:7:MAP+399 D
        ..Q:BLK>END
        ..S CHUNK=7
        ..S CHUNK=END-BLK+1 I CHUNK>7 S CHUNK=7
        ..U 63:(SIDE*CHUNK+1:CHUNK) V BLK:DISK
        ..F I=0:1:CHUNK-1 D
        ...U TAPE:(1024:1024*CHUNK*SIDE+(1024*I)) W *4
        ..S SIDE='SIDE
        U TAPE W *3,*3,*5
        Q
ERR     I $ZE["MTERR" D  Q
        I $ZE?1"<DK".E D  ZTRAP
        .U 0 W !,"Error reading near block #",A,!,"Stopping.",!
        U 0 W !,"$ze = ",$ZE
        ZTRAP  ;;with whatever error
NXTVOL  U TAPE W *3,*3,*5
        W !,"Out of space on this magtape,."
        w !,"After it rewinds, mount a new tape on unit ",TAPE-47
        W !,"and press RETURN  when it's ready             > " R X
        I X="^" W !,"Stopping"
        I X="" D TAPESTAT^JRNCOPY1 I 'OK G NXTVOL
        E  Q
        G NXTVOL
        .U TAPE S ZA=$ZA I ZA\1024#2 S $ZT="ERROR^JRNCOPY" D NXTVOL G A
        .W !,"Magtape error with $ZA = ",ZA
        .ZTRAP
ESC     U 0 W !,"Now on block # ",NXT Q
