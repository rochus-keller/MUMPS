JRNSTART        ;
        I ^SYS(^SYS(0,"RUNNING"),"OPTIONS","JRNL")'="Y" W !,"Journal option was not selected during SYSGEN.  Cannot proceed.",! Q
        D CHKSYS^SYSROU Q:%A
        S %ST=$V(44),%RUNJ=%ST+410,%DVT=$V(%ST+8),%RECOV=0
        S %START=2,%JSP="JOURNAL SPACE"
        I $V(%RUNJ) W !,"Journaling is already active - Start-up aborted." G DONE
        I $V(%DVT+47)#256=255 W !,"No magnetic tapes in this configuration, so Journaling will be to disk.",!
ASKDT   G NOMAG:$V(%DVT+47)#256=255
        R !,"Do you want to Journal to disk or to tape ? (D or T)  : ",%DT,!
        G DONE:%DT=""!(%DT="^"),TAPE:%DT?1"T".E,DISK:%DT?1"D".E
        D DTHLP G ASKDT
TAPE    D TAPGET G ASKDT:%FAIL,START
NOMAG   ;
DISK    D GETST^JRNGETST G DONE:%FAIL
START   H 2 V %RUNJ::%START
        W "* Journaling has been started *",!
DONE    K %RUNJ,%JSP,%ST,%RECOV,%DVM,%UCN,%DT,%START,%MT,%FAIL,%DVT Q
TAPGET  S %FAIL=1 R !,"Which magnetic tape unit (0,1,2, or 3) ?  > ",%MT,!
        Q:%MT=""  G TPHLP:%MT'?1N!(%MT>3)
        S %MT=%MT+47,%DVM=$V($V(44)+8)+%MT
        I $V(%DVM)#256=255 W !,"** Not in this configuration **",! G TPHLP
        O %MT:"DS":3 G GOTMT:$T
        W !,"** Magnetic tape unit ",%MT-47," is currently owned by Job # "
        W $V(%DVM)#256\2," **",! G TPHLP
GOTMT   U %MT S ZA=$ZA U 0
        I ZA\64#2=0 C %MT W !,"! Tape is off line !",! G TPHLP
        I ZA\4#2 C %MT W !,"! Tape is write-locked !",! G TPHLP
        G GIV:ZA\32#2
ASKRW   R "  Rewind  [Y or N]  ?  >  ",Y,! G TAPGET:Y="^"!(Y="")
        G GIV:Y?1"N".E,ASKRW:Y'?1"Y".E U %MT W *5 U 0
GIV     D GIVMT^JRNRECOV
        V %ST+54::$V(%ST+55)*256+%MT
        S %FAIL=0 Q
TPHLP   W !,"Enter <CR> if you do not wish to Journal to magnetic tape",! G TAPGET
DTHLP   W !,"If you answer 'T' you will be asked which magnetic tape unit to use"
        W !,"for Journaling.",!
        W !,"If you answer 'D' you will be asked to enter the starting DSM block #"
        W !,"of the desired disk Journal space.  You will be given an opportunity to"
        W !,"display all currently defined Journal spaces, and to allocate new ones,"
        W !,"or de-allocate old ones."
        W !!,"If you do not wish to Journal, enter '^' or <CR>.",! Q
