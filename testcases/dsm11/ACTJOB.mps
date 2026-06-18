ACTJOB  ; GEF ; DSM UTILITIES ; COUNTS ACTIVE JOBS
        S %JT=$V($V(44)+4),%PT=$V($V(44)+6),%F=$V(%JT-14),%S=%F#256,%F=%F\256#256,%NPAR=$V(%JT)\256#256
        F %I=2:2:%NPAR*2 S %ACT(%I)=$V(%JT+%I)
        S %PAV="" I '%S G %FIX
%GO     S %PAV=%PAV_"^"_%S
        G:'%S %FIX S %S=%ACT(%S)#256 I %S=%F S %PAV=%PAV_"^"_%S_"^" G %FIX
        G %GO
%FIX    S %ACTIVE=""
        F %I=2:2:%NPAR*2 I %PAV'[("^"_%I_"^") S %ACTIVE=%ACTIVE_"^"_(%I\2)
        F %I=%NPAR*2+2:2:126 I $V(%PT+%I) S %ACTIVE=%ACTIVE_"^"_(%I\2)
        S %ACTIVE=%ACTIVE_"^" K %ACT,%PAV,%I,%NPAR,%S,%F,%JT,%PT Q
