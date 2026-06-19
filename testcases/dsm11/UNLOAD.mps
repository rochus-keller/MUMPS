UNLOAD  ;13-Jan-82 ;UTILITY ;LOADABLE DRIVERS ;INTERACTIVELY UNLOADS A DRIVER ;JHM
        O 63::0 G NOVW:'$T D INIT^LOADR
        G NOTBAS:$V(ST+35),NODRV:'USRMM
        D CHKSYS^SYSROU Q:%A
        S %LOAD=0
Q1      R !,"Enter name of driver to unload > ",DRV I DRV=""!(DRV="^") G EXIT
        I DRV="?" D Q1HLP G Q1
        F I=1:1:+DRVLST I $P(DRVLST,";",I+1)=DRV G GDRV
        D INVALID G Q1
GDRV    D FINDR^LOADR I CON=0 D INVALID G Q1
        D FINDR G Q1:'WORD
GOT     S DDBSTR=WORD+22,DDBSIZ=$V(WORD+5,USRMM),DEV=$V(WORD+4,USRMM)#256
        F %I=1:1:DEV S DEVNUM=$V(DDBSTR+8,USRMM)#256+51 S DDBSTR=DDBSTR+DDBSIZ I $V(DEVNUM+DEVTAB)#256'=0,$V(DEVNUM+DEVTAB)#256'=255 G INUSE
        S DDBSTR=WORD+22
        F %I=1:1:DEV S DEVNUM=$V(DDBSTR+8,USRMM)#256+51 S DDBSTR=DDBSTR+DDBSIZ,LINE=DEVNUM#2,TMP=$V(DEVTAB+DEVNUM-LINE) S:LINE TMP=TMP#256+65280 S:'LINE TMP=TMP\256*256+255 V DEVTAB+DEVNUM-LINE::TMP K ^SYS(0,"LOADED DRIVERS",DEVNUM)
        S SUM=0 V WORD+2:USRMM:0 S FRAG=$V(128,USRMM)
NXTSPC  I '$V(FRAG,USRMM) V:SUM HOLE:USRMM:SUM G DON
        I $V(FRAG+2,USRMM) V:SUM HOLE:USRMM:SUM S SUM=0
        E  S:'SUM HOLE=FRAG S SUM=SUM+$V(FRAG,USRMM)
        S FRAG=FRAG+$V(FRAG,USRMM) G NXTSPC
FINDR   S WORD=$V(128,USRMM)
        F %I=1:1 Q:'$V(WORD,USRMM)  G GOTDRV:($C($V(WORD+2,USRMM)#256)_$C($V(WORD+3,USRMM))=CON) S WORD=$V(WORD,USRMM)+WORD
        S WORD=0 W:'%LOAD !,DRV," driver is not currently loaded"
GOTDRV  Q
DON     W !,DRV," driver is unloaded" G EXIT
NOVW    W !,"Unable to proceed, view device 63 is unavailable" G EXIT
NODRV   W !,"Unable to proceed, Loadable driver option not available in this configuration"  G EXIT
INVALID W !,"Not a valid driver name - Type ? for more help" G EXIT
NOTBAS  W !,"Drivers can not be unloaded in baseline mode" G EXIT
INUSE   W !,"Unable to unload ",DRV,", driver is in use (device ",DEVNUM,")" G EXIT
Q1HLP   W !!,"Enter the name of the driver you would like to load."
        W !,"The following drivers are available:",!
        F I=1:1:+DRVLST W !,$P(DRVLST,";",I+1)
        W !
        Q
EXIT    C 63 D CLEANUP^LOADR Q
