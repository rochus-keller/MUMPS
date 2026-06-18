BOOTCOPY        ;21-Jan-86 ;UTILITIES ;SYSTEM IMAGE MAINTENANCE ;COPY TAPE BOOT ;JBH
        W !,"Ready to copy boot block from tape unit 47 to DL0..." R X W !
        C 63 O 63 V 1:"DL0"
        O 47:"B" U 47:(512:512) W *5 F I=1:1:10 W *6 G:($V(512,0)=160) GOTIT
        U 0 W !,"Can't find the boot on tape unit 47.",! C 47,63 Q
GOTIT   V -1:"DL0" C 47,63
        U 0 W !,"Boot copied to disk." Q
        U 0 I $V(0,0)'=160 W !,"Boot not on block 5 of tape.",! Q
