VER     ;9-Jan-86 ;DSM ;V 3.2 ;Tape read ;kfd
        O 63:(31):2 I '$T W !,"Not enough buffers in system" Q
TU      R !,"Tape unit (47-50) <47> ",TAPE S:TAPE="" TAPE=47 I TAPE="^" C 63  Q
        I TAPE<47!(TAPE>50) W *7 G TU
DT      R !,"Density <800> ",DEN S:DEN="" DEN=800 G:DEN="^" TU
        I DEN'=800&(DEN'=1600) W *7 G DT
        O TAPE:("B"_(DEN/800+2)):2 I '$T W !,"Tape is not available" G C
RTY     U TAPE W *5 S $ZT="ERR"
        D %SET^%MTCHK U TAPE W *10
        I @(%MTON_"=0") U 0 R !,"Place online please ... <> ",*T S $ZT="" G RTY
        U TAPE F I=1:1 W *6
C       C TAPE,63
        Q
ERR     I @%MTTMK W *6 I @%MTTMK W *5 U 0 W !,"Verify is finished" G C
        U 0 I $ZE["MTE" W !," Stopping, try backup again using another tape "
        W !,$ZE
        S $ZT="" U TAPE W *5
        G C
