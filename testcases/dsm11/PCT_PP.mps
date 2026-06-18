%PP     ;31-Oct-79 ;UTILITY ;PROGRAM MAINTENANCE ;PROGRAM PURGE ;JHM
        W !,"PROGRAM PURGE",!
        D ^%PSEL G:'%GO DN
Q1      W !,"Continue, Are you sure ? <N> " R A
        I A="?" W !,"Type Y if you want the programs selected to be purged",! G Q1
        I A'="Y" G %PP
        W !!,"Programs Deleted as of: " D ^%D W " " D ^%T W !!
        S %NAM=""
RL      S %NAM=$O(^UTILITY($J,%NAM)) G DN:%NAM=""
        S T=$P($P(%NAM,".",2),";",1),N=$P(%NAM,".",1),PV=""
RN      S PV=$O(^PRG(T,N,PV)) I PV=""!(PV'<$P(%NAM,";",2))!($O(^PRG(T,N,PV))="") G RL
        W ?$X+14\15*15,N_"."_T_";"_PV W:$X>70 !
        K ^PRG(T,N,PV)
        G RN
DN      K I,%NAM,T,N,V,PV,%GO,%CT,^UTILITY($J) Q
