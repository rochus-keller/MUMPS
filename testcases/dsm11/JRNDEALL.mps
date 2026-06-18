JRNDEALL        ;DEALLOCATE A JOURNAL SPACE
        D NOMSG^JRNLSHOW I 'ND W !,"No JOURNAL spaces currently defined",!
        I  W " -- operation aborted",! K ND Q
        S FUNC="JOURNAL"
ENT     W !,"Enter name of the space you wish to delete  >: "
        R SBLK,! G DONE:SBLK=""!(SBLK="^"),HELP:SBLK="?"
GOTN    F I=1:1:ND S INX=ND(I) G GOTS:^SYS(0,"JOURNAL SPACE",INX,"NAME")=SBLK
HELP    W !,"If you do not know the name of the space you wish to "
        W "de-allocate",!,"(return to the system to use for normal "
        W "database storage), type <CR>",!,"in response to this question, "
        W "then select option 'SHOW JOURNAL SPACES'.",!
        G ENT
GOTS    I ^("NEXT")="CURRENT" W !,"! System is currently JOURNALING into "
        I  W "this space !",!,"-- cannot de-allocate.  Operation aborted.",!
        I  G DONE
        W !,"De-allocate JOURNAL space...",! S IX=INX D SHOW1^JRNLSHOW
        R !,"Are you sure [Y/N] ?  > ",Y,!
        I Y'?1"Y".E W !,"Operation aborted.",! G DONE
        D RETURN
DONE    K INX,Y,I,ND,SBLK,FUNC
        Q
RETURN  ;
        O 63::1 E  W !,"View buffer busy, can't proceed.",! Q
        S BEGNO=^SYS(0,FUNC_" SPACE",INX,"START"),ENDNO=^("END"),DDU=^("DISK")
        K ^SYS(0,FUNC_" SPACE",INX)
        F I=0:2:1022 V I:0:0
        V 798:0:65535,1006:0:65535,1008:0:21845,1010:0:43690,1012:0:32769
        V 1022:0:399 I BEGNO=1 V 1022:0:398,0:0:65535 S BEGNO=0
        F I=BEGNO+399:400:ENDNO V -I:DDU,0:0:0,1022:0:399
        D MAP^%STRTAB I '$D(MAP) G EXIT
        S MM=$V($V($V(44)+34)#256*$P(STU,",")+$V($V(44)+12)+4)
        S MP=BEGNO\400+MAP,WOF=2,BIT=1
        F I=1:1:MP S BIT=BIT*2 S:BIT>32768 BIT=1,WOF=WOF+2
        F I=BEGNO:400:ENDNO V:$V(WOF,MM)\BIT#2=0 WOF:MM:$V(WOF,MM)+BIT S BIT=BIT*2 S:BIT>32768 BIT=1,WOF=WOF+2
EXIT    W !,FUNC," space #",INX," has been de-allocated."
        C 63 B 1 K BEGNO,ENDNO,I,WOF,BIT,MM,DDU,MAP,STU,JDSK,MP Q
