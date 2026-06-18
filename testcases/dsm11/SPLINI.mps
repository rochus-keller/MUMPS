SPLINI  ;TLW;SPLINI,DSM-11 UTILITIES;24-AUG-78;SPOOL AREA INIT.
        I ^SYS(0,"STARTUP","SPOOLING")="Y" W !,"Cannot initialize Spool "
        I  W "space while Spooling is in progress.",! Q
SETUP   R !,"Initialize spool file ? <N> ",X Q:X="^"
        I X=$E("NO",1,$L(X)) G QUIT
        I X'=$E("YES",1,$L(X)) G IQ:X="?" D IR G SETUP
INIT    I '$D(^SYS(0,"SPOOL SPACE",1)) G NOTALL
        S DIR=^(1,"START"),MAP=DIR\400,MAPS=^("END")-DIR+2\400,DDU=^("DISK")
        C 63 F BF=100,80,50,40,25,20 O 63:BF:0 I  Q
        E  W !,"Can't get VIEW buffer of at least 20 blocks." S %FAIL=1 Q
        W !,"Now initializing SPOOL space"
        S BL=DIR#2,OFF=DIR-BL
        F I=0:2:1022 V I:0:0
        V -DIR:DDU
        F I=1024:1024:BF*1024-2 V I:0:0:0:1024
        I DIR#2 U 63:(2:BF-1) D
        .F I=0:1:BF-2 V I*1024:0:BL+I+1
        .V -(OFF+BL):DDU S BL=BL+BF-1 U 63:(1:BF)
        F MP=MAP:1:MAP+MAPS-1 U 0 W ":" D
        .F J=BL:BF:BL\400*400+399-BF D
        ..F I=0:1:BF-1 V I*1024:0:BL+I+1
        ..V -(BL+OFF):DDU S BL=BL+BF U 0 W "."
        .U 63:(2:BF-1) D
        ..F I=0:1:BF-3 V I*1024:0:BL+I+1
        ..V BF-2*1024:0:BL+BF*(MP'=(MAP+MAPS-1))
        ..V -(BL+OFF):DDU S BL=BL+BF U 63:(1:BF),0 W "."
        U 63:(1:1) V 0:0:DIR#2+1 V -DIR:DDU C 63
        U 0 W !,"Spool file has been initialized."
QUIT    Q
IQ      W !!,"Enter 'N'O, '^' or hit 'RETURN' key to quit; 'Y'ES to initialize spool space." G SETUP
NOTALL  U 0 W !,"No spool space has been allocated.",! Q
IR      W !,"Incorrect response - enter '?' for more information." Q
