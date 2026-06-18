JRNDKEND        ;
        Q
OUSP    W !
RESUME  I $D(^SYS(0,%JSP,"PAUSE")) G ASKO
        S %CUR=^SYS(0,"JOURNAL SPACE","CURRENT"),^(%CUR,"NEXT")="FULL"
        W !,"* Journal end of disk space *",!
ASKO    W !,"Your options are:",!!
        W "E  - Examine the list (locations and states) of all currently defined",!
        W ?5,"Journal spaces.",!
        W "D  - Switch to another Disk Journal Space which already exists.",!
        W "M  - Switch Journaling to magnetic tape.",!
        W "S  - Shut down Journaling immediately.",!
        W "P  - Pause (suspend Journal recovery) for the purpose of invoking",!
        W ?5,"some other utility (e.g., creation of more Journal space).",!
        W ?5,"If this option is used, all jobs that attempt to Journal during",!
        W ?5,"this time will be hung, and in order to resume Journal recovery",!
        W ?5,"you must type 'D RESUME^JRNRECOV', which will return to these options.",!!
OASK    ;
OPS     S %OPS="EDMSP" D GETOPT^JRNRECOV G OASK:%FAIL
PAUSE   I %OP="P" S ^SYS(0,%JSP,"PAUSE")="" K ^("CURRENT") G PAUSE^JRNRECOV
EXAM    I %OP="E" D ^JRNLSHOW K ND G OASK
HSTOP   I %OP="S" D SURE^JRNRECOV G OASK:%FAIL G HSTP2^JRNRECOV
MGTAP   I %OP="M" G TAPE
NWDSK   S %RECOV=1 D GETST^JRNGETST G OASK:%FAIL
        G RSTRT^JRNRECOV
TAPE    D TAPGET^JRNSTART G OASK:%FAIL
        K ^SYS(0,%JSP,"PAUSE")
        G RSTRT^JRNRECOV
