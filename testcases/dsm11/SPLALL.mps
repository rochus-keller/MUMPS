SPLALL  ;ALLOCATE SPOOLING AREA
        I '$D(^SYS(0,"SPOOL SPACE","INDEX")) S ^SYS(0,"SPOOL SPACE","INDEX")=1
        I ^SYS(0,"SPOOL SPACE","INDEX")>1 W !,"You already have Spool "
        I  W "space in your system.  You cannot allocate new",!
        I  W "Spool space until you deallocate the old.",! Q
        S FUNC="SPOOL",MODE="" D ALLOC^ALLOCAT
        I MAP'=-1 D INIT^SPLINI
        C 63 B 1 K (LEGOPT) Q
