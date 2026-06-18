%PDEL   ;31-Jul-83 ;UTILITY ;GLOBAL EDITOR ;DELETES PROGRAMS ;
%PP     ;
        W !,"PROGRAM DELETE",!
        D ^%PSEL G:'%GO DN S %NAM=-1,%CT=0 W !
RL      S %NAM=$N(^UTILITY($J,%NAM)) G DN:%NAM=-1
        S T=$P($P(%NAM,".",2),";",1),N=$P(%NAM,".",1),PV=$P(%NAM,";",2)
        W:'(%CT#4) ! W ?(%CT#4*20),N_"."_T_";"_PV S %CT=%CT+1
        K ^PRG(T,N,PV) G RL
DN      K I,%NAM,T,N,V,PV,%GO,%CT,^UTILITY($J) Q
