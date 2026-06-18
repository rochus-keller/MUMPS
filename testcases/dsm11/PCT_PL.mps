%PL     ;23-Feb-81;Vax-11 DSM Utility; Program First Line List; TFM
        S %PD=$I,%QTY=2 D ^%IOS I '$D(%IOD) K %PD D %DONE Q
        D ^%PSEL G:'%GO %PL
        O ".DAT":NEW U ".DAT" S DIR=$P($ZIO,"]",1)_"]" C ".DAT":DELETE
        U %IOD W #,!,"First Line List of ",DIR,"   on    "
        D ^%D W ?18 D ^%T W !! S I=-1
%GO     S I=$N(%UTILITY(I)) I I<0 D %DONE G %PL
        S %F="SRC$:"_I O %F:READ U %F R L C %F U %IOD W !,I,?15,$P(L,$C(9),1),?27,$P(L,$C(9),2,999)
        G %GO
%DONE   U 0 K I,%DTY,%UTILITY,%GO I $D(%IOD) C:(%IOD'=%PD) %IOD
        Q
