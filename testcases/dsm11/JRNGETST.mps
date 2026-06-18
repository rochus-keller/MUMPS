JRNGETST        ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
        Q
GETST   W !,"Enter the name of the space into which you wish to journal."
        W !,"Enter '*' for a listing of the currently defined Journal spaces."
        W !,"Enter '?' for help.   > "
        R %STR,! G STHLP:%STR="?" I %STR="*" D ^JRNLSHOW G GETST
        S %FAIL=0 I %STR=""!(%STR="^") S %FAIL=1 G DONE
        D NOMSG^JRNLSHOW
        F %I=1:1:ND S %IX=ND(%I) G IX:^SYS(0,%JSP,%IX,"NAME")=%STR
        W !,"No space with that name.",! G GETST
IX      G AOK:^("NEXT")="EMPTY"
        W !,"This space has already been used for Journaling.",!
        I ^("NEXT")="FULL" W "It is full.",! G STHLP
        G STHLP:%RECOV
        W ^("END")-^("NEXT")," blocks are still available in this space, however.",!
        W "Are you absolutely sure that you wish to Journal into this space,",!
        W "beginning at DSM block # ",^("NEXT")," ?",!
        W "(Answer 'N' or <CR> to this question if what you meant to do was to",!
        W "re-initialize this space, then Journal into it from the beginning)"
ASKSU   R !," **  Are you sure  [Y/N]  ?  <N> ",%Y,!
        G GETST:%Y=""!(%Y="^")!(%Y?1"N".E),ASKSU:"YN"'[$E(%Y,1)
        S %CR=^("NEXT")+(^("NEXT")#400=399) G AOK2
AOK     S %CR=^("START")
AOK2    D SYSPUT
DONE    K ND,%Y,%CR,%LS,%STR,%I,%IX
        Q
SYSPUT  S %LS=^("END")-1,TYU=$F("KMRBLU",$E(^("DISK"),2))-2*8+$E(^("DISK"),3)*4
        B 0
        V %ST+290::%LS#65536,%ST+292::$V(%ST+293)*256+(%LS\65536)
        V %ST+294::%CR#65536,%ST+296::$V(%ST+297)*256+(%CR\65536)
        V %ST+266::$V(267)*256+TYU,%ST+54::$V(%ST+55)*256+128
        B 1
        S ^SYS(0,%JSP,"CURRENT")=%IX,^(%IX,"NEXT")="CURRENT"
        K ^SYS(0,%JSP,"PAUSE")
        Q
STHLP   W !,"1. You cannot Journal into a space which is already full.",!
        W ?3,"You must first initialize the space.",!
        W ?3,"This will erase the Journal records currently stored in that space.",!
        W "2. You *can* Journal starting at the next available block of a",!
        W ?3,"partially full space.",!
        W "3. Exception:  You *cannot* Journal into a partially full space if you are",!
        W ?3,"recovering from an out-of-space or end-of-tape condition.",!
        W ?3,"In this case, you may only Journal to an empty (intialized) space",!?3,"or to a magnetic tape.",!
        W !,"If you have changed your mind and do not wish to enter the name of a",!
        W "Journal space at this time, enter <CR>" G GETST
