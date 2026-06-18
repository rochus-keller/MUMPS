%DH     ;12-Dec-84 ;  ; ; ;
        I '$D(%DH) S %DH=0 Q
        I '(%DH?.N) S %DH="*" Q
        Q:%DH=0
        S %N=%DH,%DH=""
L       I %N'=0 S %D=%N#16,%N=%N\16 D EVAL S %DH=%D_%DH G L
K       K %N,%D
        Q
EVAL    ;
        Q:%D<10  S %D=$C($A("A")+%D-10)
        Q
