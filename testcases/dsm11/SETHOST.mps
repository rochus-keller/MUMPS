SETHOST ;4-Jul-85 ;UTILITIES ;MISC. ;TERMINAL ROUTE-THROUGH ;JBH
        S ST=$V(44),MAXTTY=$V(ST+462)#256,RTAB=$V(ST+426)+32
SELECT  W !,"What is the line number you wish to route through ? > "
        R SLAVE,! I SLAVE="^"!(SLAVE="") Q
        I SLAVE="?" G HELP
        I SLAVE'?1.3N W !,"Please enter numbers only",! G SELECT
        I SLAVE=$I!(SLAVE<3) G HELP
        I SLAVE>20,SLAVE<63 G HELP
        I SLAVE>MAXTTY G HELP
        C SLAVE O SLAVE:(::::512):0 I '$T G BUSY
        U SLAVE W $C(0) U 0
        S DEV=SLAVE D GETDDB S DDBS=DDB
        S DEV=$I D GETDDB S DDBM=DDB
        F RTAB=RTAB:4 G:$V(RTAB)=65535 NOROOM I '$V(RTAB) Q
DIAL    W !!,"1 - Line is already connected"
        W !,"2 - Auto-dial using DEC DF03 or DF02 modem"
        W !!,"Select connection method > "
        R DTYP I DTYP="^" C SLAVE Q
        I DTYP="?" G DTHELP
        I DTYP'?1N!(DTYP<1)!(DTYP>2) W "...not valid" G DIAL
        I DTYP=2 S DTYP="DF02"
        I DTYP=1 G CONNECT
        W !,"Number please > " R %NO I %NO="" G DIAL
        S DILER=SLAVE,ROD=SLAVE D ^%DIAL
        I BD'=0 C SLAVE W !!,"Auto-dial failed.",! G SELECT
CONNECT U 0 W !!,"Route-through session now started."
        W !,"Strike control-A to stop route-through...",!!
        S $ZT="DSCON" F I=1:1 R A:0 I '$T Q
        V RTAB::DDBM,RTAB+2::DDBS,DDBS+2::$V(DDBS+2)#4096+4096+8192,DDBM+2::$V(DDBM+2)#4096+4096
        R *A
END     V DDBS+2::$V(DDBS+2)#4096,DDBM+2::$V(DDBM+2)#4096
        V RTAB::0,RTAB+2::0 W !!!,"End of route-through session.",!!
        S $ZT="" C SLAVE
        Q
BUSY    W !,"Device ",SLAVE," is busy.",! G SELECT
DTHELP  W !!,"If your device is not connected to a switched line, select option 1."
        W !,"If your modem can auto-dial compatibly with DF02/03, select option"
        W !,"2 and proceed to the next query to specify the telephone number."
        W !,"If you must manually dial, you can do that now, then select option 1."
        W !,"This routine turns on the DTR signal as soon as you specify the device number.",!!
        G DIAL
DSCON   V DDBS+2::$V(DDBS+2)#4096,DDBM+2::$V(DDBM+2)#4096
        U 0 W !!,"Error: ",$ZE,!! G END
HELP    W !,"You can only route through an existing terminal line.  Enter"
        W !,"a device number that is currently legal.",! G SELECT
GETDDB  I DEV<64 S DDB=DEV-1*$V(ST+68)+$V(ST+10)+4 Q
        S DDB=DEV-64*$V(ST+68)+$V(ST+20)+4 Q
