RMSHO   ;30-Jun-83 ;UTILITY ;ROUTINE MAPPING ;SHOWS ROUTINES CURRENTLY MAPPED ;JHM
        D CHKRM^RMBLD G EXIT:%A
        S ROUMAP=$V(ST+38) I '$V(0,ROUMAP) W !,"There are no Routine Sets in Memory",! G EXIT
        W !,"The following routines are mapped into Memory"
        W !,"(* = disabled routine)",!
        F ENT=0:8 S UCN=$V(ENT,ROUMAP)#256 Q:'UCN  D:UCN'=255
        .S RNUM=$V(ENT+2,ROUMAP),MMNAM=$V(ENT+6,ROUMAP),MMADR=$V(ENT+4,ROUMAP)
        .S $ZT="NOUCN",UC=0 W !,"Routines Mapped for UCI and Volume Set: ",$ZU(UCN#32,UCN\32) S UC=1,$ZT=""
        .I $V(ENT+1,ROUMAP) W " *** DISABLED ***"
NOUCN   .I 'UC W "*** UCI not currently loaded ***"
        .W !!
        .F RN=0:1:RNUM-1 W:$X>60 ! I $V(RN*8,MMNAM)'=255 W ?$X+9\10*10 W:'$V(RN*2,MMADR) "*" F I=0:1:7 Q:$V(RN*8+I,MMNAM)#256=255  W $C($V(RN*8+I,MMNAM)#256)
        .W:$X !
EXIT    Q
