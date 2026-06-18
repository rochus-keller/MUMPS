LOAD    ;13-Jan-82 ;UTILITY ;LOADABLE DRIVERS ;SUBROUTINES TO INTERACTIVELY LOAD A DRIVER ;JHM
START   C 63 O 63::0 I '$T D NOVW G EXIT
        D INIT^LOADR S ID=^SYS(0,"RUNNING")
        I $V(ST+35) D NOTBAS G EXIT
        I 'USRMM D NODRV G EXIT
        D CHKSYS^SYSROU G EXIT:%A
Q1      R !,"Name of driver to load ? > ",DRV I DRV=""!(DRV="^") G EXIT
        I DRV="?" D Q1HLP G Q1
        F I=1:1:+DRVLST I $P(DRVLST,";",I+1)=DRV G GDRV
        D INVALID G Q1
GDRV    S %LOAD=1
        D FINDR^LOADR I CON=0 D NOFND G Q1
        D FINDR^UNLOAD I WORD D INMEM G EXIT
        I ^SYS(ID,"DRIVERS",DRV)'="Y" W !,DRV," driver not configured during SYSGEN, unable to load it",! G EXIT
        D GETDEF^LOADR
        S CONUM=""
GETDEV  K DEVNUM S CONUM=$O(DEV(CONUM)) G LOADIT:CONUM="" S DEVAS=$P(DEV(CONUM),",",4),UNI=+DEV(CONUM)
        F UNIT=1:1:UNI S DEVNUM=$P(DEVAS," ",UNIT) D Q6 G Q1:A="^"  S $P(DEVAS," ",UNIT)=DEVNUM
        S $P(DEV(CONUM),",",4)=DEVAS
        G GETDEV
LOADIT  W !,"Loading ",DRV," driver ..." D LOAD^LOADR G EXIT
Q6      W !,"Device number to access ",DRV," controller #",CONUM-1 W:UNI>1 " unit #",UNIT W " (51-58) " W:DEVNUM'="" "<",DEVNUM R ">
 ",A
        I A="" G Q6:DEVNUM="" Q
        Q:A="^"  I A="?"!(A<51)!(A>58) D Q6HLP G Q6
        I $V(DEVTAB+A)#256'=255,%LOAD D NODEV G Q6
        S DEVNUM=A Q
        Q
NOVW    W !,"Unable to proceed, view device 63 is unavailable" Q
NODRV   W !,"Unable to proceed, Loadable driver option not available in this configuration" Q
NOFND   W !!,DRV," driver is not available",! Q
INVALID W !!,"Not a valid driver name - Type ? for more help",! Q
NOTBAS  W !!,"Drivers can not be loaded in baseline mode",! Q
NODEV   W !!,"Device ",DEVNUM," is already assigned",! Q
INMEM   W !!,DRV," driver is already loaded",! Q
Q1HLP   W !!,"Enter the name of the driver you would like to load."
        W !,"The following drivers are available:",!
        F I=1:1:+DRVLST W !,$P(DRVLST,";",I+1)
        W !
        Q
Q6HLP   W !!,"Enter the DSM device number which will be used to access"
        W !,"this unit.  The device must in the range of 51 to 58",! Q
EXIT    C 63 D CLEANUP^LOADR Q
