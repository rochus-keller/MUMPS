SPLREM  ;REMOVE SPOOL SPACE
        I ^SYS(0,"STARTUP","SPOOLING")="Y" W !!,"SPOOL space cannot be removed while SPOOLING is enabled." Q
        I '$D(^SYS(0,"SPOOL SPACE",1)) W !!,"There is no SPOOL space allocated." Q
        S INX=1,FUNC="SPOOL" D RETURN^JRNDEALL
        S ^SYS(0,"SPOOL SPACE","INDEX")=1
        K (LEGOPT) Q
