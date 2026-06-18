BSCMON  ;12-Mar-80 ;SYSTEM ;UTILITIES ;BSC MONITOR ROUTINE ;JHM
S2      O 63::1 E  U 0 W !,"*** Waiting for View device ***" R %X:2 G:$T SHOW G S2
        D INIT^LOADR W !! C 63
SHOW    S %QRY="** Monitor device" D GETDEV^BSCSTR G EXIT:%DEV="^"
        O %DEV::1 I $T W !,"Device not currently spooled" C %DEV G SHOW
        S %DEVTAB=$V(ST+8),%I=$I D DDBADD
        W !!,"Press any key to terminate trace"
        W !,"Begin trace...",!!
        S DDBSTR=$V(%DEV-51*16+14,USRMM)-32768
        V DDBSTR+8:USRMM:ADDR C 63 R *X,!
        V DDBSTR+8:USRMM:0 W !,"Trace complete" G BSCMON
DDBADD  G MX:%I>63 S ADDR=%I-1*$V(ST+68)+$V(ST+10)+4 Q
MX      S ADDR=%I-64*$V(ST+68)+$V(ST+20)+4 Q
EXIT    K ADD1,ADDR,%DEV,%DEVTAB,I,LOC,LOCA,X Q
