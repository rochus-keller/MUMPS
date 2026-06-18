BSCPE   ;31-Dec-40 ;UTILITY ;BSC ;STARTUP THE 2780/3780 EMULATOR ;JHM
STRT    W !!,"2780/3780 Protocol Emulator",!
        F %I=1:1:$P($T(MENU)," ",2) W !?3,$P($T(MENU+%I),"^",2)
Q1      W !!,"Enter option > " R %A G EXIT:%A=""!(%A="^")
        F %I=1:1:$P($T(MENU)," ",2) G DOPT:%A=$E($P($T(MENU+%I),"^",2),1,$L(%A))
        W !,"Invalid option selection" G Q1
DOPT    D @($P($T(MENU+%I),"^",3,4)) G STRT
MENU    5
        ^S = Startup 2780/3780 Emulator^START^BSCSTR
        ^H = Halt 2780/3780 Emulator^START^BSCHLT
        ^Q = Queue a Global to transmit^^BSCQUE
        ^D = Display Spooler Status^^BSCSTA
        ^M = Monitor Spooler IO^^BSCMON
EXIT    K %I,%A Q
