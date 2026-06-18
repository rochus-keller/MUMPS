%GRT    ;27-Feb-85;Driver for Routines/Globals transfer between systems; DSM V3.1 ;DMW
        S MOD=""
DIR     S QUES="DIRQ",DEF="" X ^%Q("EN"),^%Q("SGCNV") Q:"^"[ANS  S DIR=$E(ANS) G:"SR"'[DIR DIR
MOD     I MOD="" S DEF="",QUES="MODQ" X ^%Q("EN"),^%Q("SGCNV") G:"^"[ANS DIR S MOD=$E(ANS) G:"GR"'[MOD MOD
DSP     S DEF="",QUES="DSPQ" X ^%Q("ASKYN"),^%Q("SGCNV") G:"^"[ANS MOD S DSP="Y"[$E(ANS)
DEV     S %QTY=101+(DIR="S") W !!,"Enter port (terminal number) for transfer."
        D ^%IOS G:'$D(%DTY) DSP S DEV=%IOD I %DTY'="TRM" W !!,"NOT A TERMINAL DEVICE." G DEV
        C:DEV'=$I DEV O DEV:(0::::512+1) U DEV S MDM=$ZA\8#2 U 0
SEL     K ^UTILITY($J) I DIR="S" D @("^%"_MOD_"SEL") G:$O(^UTILITY($J,""))="" DEV
INI     W !! D ^%GRTINI
        W !,"Type <RET> when ",$S(MDM:"phone is dialed and ",1:""),$S(DIR="S":"Receiv",1:"Send") R "er is ready:",Z G:Z="^" DEV
        S $ZT=DIR_"CHECK^%GRT"_DIR
        W !! D @(DIR_"^%GRT"_DIR)
        U 0 C:DEV'=$I DEV Q
DIRQ    W !,"Are you [S]ending or [R]eceiving" Q
DIRQH   W !,"Enter 'S' or 'R'",! Q
MODQ    W !,"Are you ",$S(DIR="R":"Receiv",1:"Send"),"ing [G]lobals or [R]outines" Q
MODQH   W !,"Enter 'G' or 'R'",! Q
DSPQ    W !,"Do you wish to display the data" Q
DSPQH   W !,"Enter 'Y' or 'N' indicating whether you wish the data displayed here",!
        W "as it ",$S(DIR="S":"go",1:"com"),"es across",! Q
DEVQ    W !,"Enter the port (terminal number) for the transfer" Q
DEVQH   W !,"The asynchronous line should be entered as a terminal device number",! Q
ROU     S MOD="R" G DIR
GLO     S MOD="G" G DIR
