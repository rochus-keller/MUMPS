SDP     ;SDP ALLOCATE AND DEALLOCATE
        I $V($V(44)+35) W !,"SDP is not available in baseline mode",! Q
        D CHKSYS^SYSROU Q:%A
        I ^SYS(^SYS(0,"RUNNING"),"OPTIONS","SDP")'="Y" W !,"The SDP option is not configured into this system." Q
        S FUNC="SDP"
AORD    R !!,"Allocate, deallocate, or show SDP spaces [A, D, or S] ? >  ",ANS,!
        I ANS=""!(ANS="^") C 63 Q
        G ALL:ANS="A",DEALL:ANS="D",SHOW:ANS="S",HELP
ALL     D ALLOC^ALLOCAT
        I MAP'=-1 D SDVAL^MAPMOUNT
        G DONE
DEALL   R "Enter the index number of the SDP space you wish to de-allocate > ",INX,!
        I INX="^" G AORD
        I INX'?1N.N G INXHLP
        I '$D(^SYS(0,"SDP SPACE",INX)) W !,"No such SDP space is mounted." G INXHLP
        F I=59:1:62 O I::1 E  C 59,60,61 W !,"Can't delete SDP space while SDP is in use.",! G AORD
        O 63::1 E  W !,"View buffer busy, can't proceed.",! G DONE
        S S=^SYS(0,"SDP SPACE",INX,"START"),MAP=$P(S,":")\400,DDU=^("DISK")
        D TYPES^DPBEGIN
        S TYU=$F(TYPES,$E(DDU,1,2))\3-1*8+$E(DDU,3)
        S VALTBL=$V($V(44)+138)
        F I=0:4:63 I $V(I+2,VALTBL)=MAP,$V(I,VALTBL)\1024=TYU V I:VALTBL:0,I+2:VALTBL:0 Q
        D RETURN^JRNDEALL
DONE    C 59,60,61,62 K TY,U,TYPES,MAP,MAPS,TYU,INX,I G AORD
SHOW    I '$D(^SYS(0,"SDP SPACE")) W !,"There are no SDP spaces currently mounted.",! Q
        D TYPES^SYSROU
        W !,"Space",?8,"Starting",?18,"Ending",?28,"Disk",?34,"First",?41,"#",!
        W "index",?8,"DSM blk",?18,"DSM blk",?28,"unit",?34,"map",?41,"maps",!
        W "-----",?8,"--------",?18,"-------",?28,"----",?34,"-----",?41,"----"
        S NXT=-1 F I=1:0 S NXT=$N(^SYS(0,"SDP SPACE",NXT)) Q:(NXT=-1)!('+NXT)  D DISPLAY
        W !! K NXT,I G AORD
DISPLAY W !?3,$J(NXT,2),?8,$J(^SYS(0,"SDP SPACE",NXT,"START"),8),?17,$J(^("END"),8),?28,^("DISK")
        W ?34,$J(^("START")\400,4),?41,$J(^("END")-^("START")+1+(^("START")=1)\400,4)
        Q
INXHLP  W !,"Use the 'SHOW' option to find the index numbers of"
        W !,"the SDP spaces on the currently mounted disks.",! G DEALL
HELP    W !,"Type 'A' to allocate SDP space on one of your disks."
        W !,"Type 'D' to return already-allocated SDP space to FREE space."
        W !,"Type 'S' to display the currently mounted SDP spaces.",! G AORD
EXIT    K ANS,FUNC,MODE,MAPBLK,ST,Y Q
