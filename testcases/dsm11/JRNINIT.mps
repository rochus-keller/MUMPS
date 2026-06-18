JRNINIT ; INITIALIZE JOURNAL SPACE FOR DISK TO ALL ZEROS
        D NOMSG^JRNLSHOW
        I 'ND W !!,"JOURNAL space has not been allocated." G KRET
        S $ZT="ERR" C 63 O 63::0 E  G VBUSY
ENT     R !,"Enter name of space to be initialized  > ",SBLK,!
        Q:SBLK=""  I SBLK="?" D HELP G ENT
        F I=1:1:ND S INX=ND(I) G:^SYS(0,"JOURNAL SPACE",INX,"NAME")=SBLK GOTSP
        W !,"No defined JOURNAL space with that name.",! G KRET
GOTSP   I ^("NEXT")="CURRENT" W !,"!! Currently JOURNALING into this "
        I  W "space !!",! G KRET
        G INIT:^("NEXT")="EMPTY" W !,"This space contains previously "
        W "JOURNALED records.  Are you absolutely",!
        W "sure you want to re-initialize this space  [Y/N] ?  >  "
        R I,! G KRET:I'?1"Y".E
INIT    S BF=$V($V(44)+32)-$V($V(44)+414)-6 S:BF<1 BF=1 S:BF>63 BF=63
I2      C 63 O 63:BF:1 E  S BF=BF+1\2 G I2:BF>1 C 63 O 63::3 E  G VBUSY
JRNENT  S $ZT="ERR",BL=^SYS(0,"JOURNAL SPACE",INX,"START"),MAPS=^("END")-BL\400+1
        S DDU=^("DISK")
        W !,"  ...now initializing..." F I=0:2:1022 V I:0:0
        U 63:(1:1) V -BL:DDU F I=2:1:BF U 63:(I:1) V BL:DDU
        F II=1:1:MAPS U 63:(1:BF) S BL=BL+1,N=399-(BL#400) D ZMAP
        S ^("NEXT")="EMPTY"
        U 0 W !,"JOURNAL space has been initialized.",!
KRET    C 63 K ND,INX,I,BL,END,%UCN,SBLK,II,N
        Q
ERR     U 0 W !,"Unexpected error -- ",$ZE,! G KRET
VBUSY   W !,"View buffer is busy" G KRET
ZMAP    I N'<BF V -BL:DDU S BL=BL+BF,N=N-BF G ZMAP
        Q:'N  U 63:(1:N) V -BL:DDU S BL=BL+N Q
        NOTE: BL IS INCR'D AGAIN IN LOOP, AND SO WILL SKIP MAP BLOCK.
HELP    W !,"If you are not sure of the name of the JOURNAL space "
        W "you wish to",!,"initialize, answer <CR> to this question, and "
        W "Select option ""SHOW"" from",!,"routine ^JRNL",!
        Q
