SWREG   ;FDN;18-JUN-80;DISPLAY CONTENTS OF SWITCH REGISTERS
STT     R !!,"Display, Set, or Clear switches ? (D, S, or C) > ",ANS G:ANS=""!(ANS="^") EXIT G:ANS="?" HELP
        S ST=$V(44),%SWI=$V(ST),%SWP=$V(65400),%SW=%SWI
        G @$S(ANS="S":"SET",ANS="C":"CLEAR",ANS="D":"DSPLY",1:"BAD")
DSPLY   I '%SWI,'%SWP W !?5,"** No switches are set **" G SWREG
        I %SWI W !!,"Internal switch register:" D WRITE
        I %SWP W !,"Hardware switch register:" S %SW=%SWP D WRITE
        G STT
WRITE   W !!,"The following switches are set:",!
        I %SW\16#2 W !,?5,$P($T(TEXT+1),";;",2)
        I %SW\32#2 W !,?5,$P($T(TEXT+2),";;",2)
        I %SW\64#2 W !,?5,$P($T(TEXT+3),";;",2)
        Q
HELP    W !?5,"Enter 'D' to display the DSM and PDP-11 switch registers",!?8,"or 'S' to set the DSM internal switch register"
        W !?8,"or 'C' to clear the DSM internal switch register."
        D QUE G STT
SET     R !,"Enter switch number > ",ANS G:ANS=""!(ANS="^") STT G:ANS="?" HELP1
        I '(ANS=4!(ANS=5)!(ANS=6)) D IV G SET
        I ANS=4&('(%SW\16#2)) S %SWI=%SWI+16 G BIT
        I ANS=5&('(%SW\32#2)) S %SWI=%SWI+32 G BIT
        I ANS=6&('(%SW\64#2)) S %SWI=%SWI+64 G BIT
BIT     V ST::%SWI G SET
CLEAR   V ST::0 W !?5,"** Switches cleared **" G STT
IV      W !?5,*7,"Incorrect response - Enter '?' for more information." Q
QUE     W !?5,"Enter <CR> or ^ to return to previous question" Q
BAD     W !?5,"Incorrect response, Enter '?' for help." G STT
HELP1   W !!,"The following is a description of the switches which may be set:",!
        F I=1:1:4 W !,?5,$P($T(TEXT+I),";;",2)
        W !!,"Enter one of the above switch numbers."
        G SET
TEXT    ;;DESCRIPTION OF SWITCHES IN SWITCH REGISTER
        ;;Switch 4    Free error-log after printing
        ;;Switch 5    Print error-log on console terminal
        ;;Switch 6    Disable log-in and partition grants
        ;;
EXIT    K ANS,%SW,%SWP,%SWI,I Q
