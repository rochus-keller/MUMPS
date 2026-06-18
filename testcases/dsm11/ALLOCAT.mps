ALLOCAT ;ALLOCATE SPACE FOR JOURNAL, SDP, AND SPOOL
        W !,*7,"This subroutine cannot be invoked directly.",*7,! Q
ALLOC   S CODE=$S(FUNC="JOURNAL":13107,FUNC="SDP":43690,FUNC="SPOOL":56173)
        W !,"Ready to allocate contiguous disk maps for ",FUNC,!!
ALLOC1  D ENTER I MAP=-1 G QUIT
        C 63 O 63::1 E  W !,"View buffer busy, can't proceed." G QUIT
        B 0 D CHECK I MAP=-1 B 1 C 63 G ALLOC1
        G EXIT
HELP    W ! D SHOW^%STRTAB W !
ENTER   R !,"Do you wish a fast disk-block tally [Y/N] ? > ",Y,!
        G:Y="^" QUIT G:Y=""!(Y?1"N".E) ENTER1 I Y?1"Y".E D NOCLS^FASTDBT
ENTER1  S M=1 D TYPES^DPBEGIN
        W !,"Enter the disk type, unit number, and starting map number in "
        W "format:",!
        W !?5,"DDU:M",!!
        W ?5,"where  DD  =  Disk type (",TYPES,")",!
        W ?5,"        U  =  Unit number (0 to 7)",!
        W ?5,"        M  =  Map number on that unit (1st map on",!
        W ?5,"              unit is map number 0)",!!
INPUT   R "Enter  >  ",ANS,! I ANS="?" D HELP G INPUT
        I ANS="^"!(ANS="") S MAP=-1 G ENTER
        I ANS'?2A1N1":"1N.N W " ... bad syntax",!! G INPUT
        S TYPE=$E(ANS,1,2),UNIT=$E(ANS,3),MAP=$P(ANS,":",2),DDU=TYPE_UNIT
        D %DDU^DPBEGIN
        I '$D(%D) W " ...no such disk unit." G HELP
        S TYU=$P(%D," ",4)*8+UNIT
        I $V(%DT)<16384 W " ...no disk mounted in ",DDU G HELP
        I $V(%DT)<32768 W " ...mounted for VIEW ONLY." G HELP
        I MAP'<$V(%DT+2) W " ...disk has only ",$V(%DT+2)," maps.",!! G INPUT1
INPUT1  R !,"How many maps in a row ? > ",MAPS I MAPS="?" D HELP G INPUT1
        I MAPS="^" G ENTER1
        I MAPS<1!(MAPS'=+MAPS) D HELP1 G INPUT1
        I MAPS+MAP>$V(%DT+2) W " ...only ",$V(%DT+2)," maps on ",DDU,!! G INPUT1
        I MAPS>1023 W " ... can't specify more than 1023 in a row." G INPUT1
        Q
CHECK   V $V(44)::8192
        F MP=0:1:MAPS-1 V MAP+MP*400+399:DDU D ALL I MAP=-1 V $V(44)::0 G CKDONE
        F MP=0:1:MAPS-1 V MAP+MP*400+399:DDU D  V -(MAP+MP*400+399):DDU
        .V 1008:0:CODE,1010:0:65535-CODE,1022:0:0
        V $V(44)::0 I '$D(^SYS(0,FUNC_" SPACE","INDEX")) S ^("INDEX")=1
        S INX=^("INDEX"),^("INDEX")=INX+1
        S ^(INX,"DISK")=DDU,^("START")=MAP*400+(MAP=0),^("END")=MAP+MAPS*400-1
        W !,"Disk space allocation for ",FUNC," space #",INX," has been completed."
CKDONE  Q
ALL     I '($V(1008,0)=21845&($V(1010,0)=43690)&($V(1022,0)=(399-(MAP+MP=0))))
        I  W !?5,"Map ",MP+MAP," is not available.",!! S MAP=-1
        Q
QUIT    S MAP=-1 C 63 B 1 K INX
EXIT    K DSK,TYPES,TYPE,UNIT,ANS,ERR,CODE,I,MP Q
HELP1   W !,"Not a valid number, type ""?"" for help." Q
