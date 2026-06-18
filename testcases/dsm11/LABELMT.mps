LABELMT ; DSM-11 Utilities ; Copyright 1980 DEC
START   C 63 O 63::3 E  W !,"View Buffer busy.",! Q
        U 0 W !,"Inspect a DSM-11 Label",!
LBENT   S ST=$V(44),DVT=$V(ST+8)
S2      S UU=-1,QUES="MTQ",DEF="" X ^%Q("ASK") G DONE:ANS=""!%A
        I ANS'?1N!(ANS>3) G S2
        I $V(DVT+47+ANS)#256=255 W !,"** NOT IN CONFIGURATION.",! G S2
        S UU=ANS+47 O UU:"B":2 E  W !,"** IN USE BY ANOTHER JOB",! G S2
        U UU W *5,*6 S ZA=$ZA,ZB=$ZB U 0
        I ZA\64#2=0 W !," ** OFF-LINE",! G DONE
        I ZA\16384#2 G NOLAB
        I ZA>127 W !," ** TAPE-ERROR",! G NOLAB
        I ZB'=512 G NOLAB
CKLAB   S OF=370,SZ=16 D GET I M'?1"DSM11 ".E G NOLAB
        S OF=304,SZ=22 D QGET S %LB=M
        D QGET S ML=M S OF=357,SZ=9 D GET S BDA=M
        S SZ=2 D GET S DD=M S VN=$V(368,0)#256
        W !,"  Label =  ",%LB,!
        W "  Backup volume # ",VN," of ",DD," Master:  ",ML,!
        W "  Backup performed  ",BDA,!!
        G DONE
NOLAB   W !," ** THERE IS NO DSM11 LABEL ON THIS MAGTAPE",!
        W ?4,"(No Backup has been done onto it)",!!
DONE    C:UU>0 UU C 63
        K UU,ST,DVT,ANS,%A,%QMK,%LB,M,ML,C,SZ,OF,DD,VN
        K %A2,%LBL,%YN,DEF,QUES
        Q
QGET    D GET S M=""""_M_"""" Q
GET     S M="" F I=0:1:SZ-1 S C=$V(OF+I,0)#128 Q:'C  S M=M_$C(C)
        S OF=OF+SZ Q
MTQ     W !,"Which Magtape Unit (0, 1, 2, or 3)" Q
MTQH    W !,"You can not place a Label onto a magtape with this program -- "
        W "only inspect.",!
        W "The only way to get a DSM11 Label onto a Magtape is by doing a "
        W "Backup",!
        W "onto the magtape.",!!
        W "If you do not wish to inspect a magtape label, type  ""^""",! Q
