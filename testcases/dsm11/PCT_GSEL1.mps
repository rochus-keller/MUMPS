%GSEL1  ;FDN;5-JUN-80;SUBROUTINE OF GLOBAL SELECT ROUTINE (%GSEL)
        W !,*7,"This subroutine should be run using the Global Select routine %GSEL.",*7,! Q
%START  S %X1=$P(%X,"(",1),%X2=$P(%X,"(",2)
        I '(%X1?1A.AN!(%X1?1"%".AN)) D %IV Q
        I '$D(%PGC) S %DCF=$D(@("^"_%X1)) W:'%DCF !,*7,?8,"No such global" Q:'%DCF
        I $D(%PGC) S %DCF=$D(@("^"_"["_""""_FUCI_""""_","_""""_FSYS_""""_"]"_%X1)) W:'%DCF !,*7,?8,"No such global" Q:'%DCF
        S F=0 K %FLG F I=1:1 S F=$F(%X2,",",F) G:'F %CK S %PIE=$P(%X2,",",I) D %W1 Q:$D(%FLG)
        Q
%W1     ;
        Q
%CK     S %PIE=$P(%X2,",",I) I %PIE=")"&(I=1) D %IV Q
        I %PIE=""!(%PIE=")") G %FD
        I $E(%PIE,$L(%PIE))=")" S %PIE=$E(%PIE,1,$L(%PIE)-1)
        D %W1 I $D(%FLG) Q
%FD     I $E(%X2,$L(%X2))=")" G %SD
        I $E(%X2,$L(%X2))="," S ^UTILITY($J,%X1)=%X2 Q
        S ^UTILITY($J,%X1)=%X2_"," Q
%SD     I $E(%X2,$L(%X2)-1)="," S ^UTILITY($J,%X1)=%X2 Q
        S ^UTILITY($J,%X1)=$E(%X2,1,$L(%X2)-1)_","_")" Q
%IV     W !,?5,"Incorrect response - Enter '?' for more information" Q
