%RD     ;GEF; DSM UTILITIES ; ROUTINE DIRECTORY
        S %LST=0
%ST     I '%LST W !,?21,"Routine Directory",?40 D ^%D,^%GUCI W !,?25,"of ",%UCI,",",%SYS,?40 D ^%T W !
%ST1    S %NAM="",$ZT="%ER^%RD"
        F I=0:1 S %NAM=$O(^[%UCI,%SYS] (%NAM)) Q:%NAM=""  W:'(I#8) ! W %NAM F J=1:1:9-$L(%NAM) W " "
        I '%LST W !,?5,I," Routines"
DONE    K:%LST'>1 %UCI,%SYS K %LST,%NAM S $ZT=""
        Q
%ER     I $ZE["INRPT" W !,"*** Interrupt ***" G DONE
        W !,$ZE G DONE
%LST    S %LST=1 W ! G %ST
%RSEL   S %LST=2 G %ST1
