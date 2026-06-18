%DIAL   ;15-Sep-80;DIAL; DIALER ROUTINE FOR DF02 AND VADIC ;JHM
        O ROD::2 E  S BD=2 G QUIT
DIAL    D HGUP
        O DILER::2 E  S BD=3 G QUIT
        G @DTYP
DF02    U DILER:(::::512) F I=0:0 R *A:0 Q:'$T
        W *2,%NO
        R *A:60 I '$T!(A'=65) S BD=1 G QUIT
        S BD=0 G QUIT
VADIC   U DILER W *1 R *A:30 I '$T!(A'=66) S BD=1 G QUIT
        H 1 W *2,%NO,*15,*3 U ROD:(::::512)
        U DILER R *A:180 I '$T!(A'=65) W *1 S BD=1 G QUIT
        S BD=0 G QUIT
HGUP    ZU ROD:(:::::512) S BD=($ZA\512#2) Q
QUIT    I DILER'=ROD C DILER
        Q
