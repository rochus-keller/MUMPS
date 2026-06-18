MUX1    Q  ;RLW,DMW; SET UP DDB PARAMETERS (CALLED BY ^MUX)
DEV     S ST=$V(44),MAXTTY=$V(ST+462)#256
        W ! F I=1:1:79 W "-"
        R !,DEV Q:DEV=""!(DEV="^")
        I DEV["?" D HLP G DEV
        I DEV'?.N&(DEV'?1N.N1":"1N.N) D IV G DEV
        I DEV[":" S RANGE="Y" G RANGE
        I DEV<1!(DEV>19&(DEV<64))!(DEV>MAXTTY)!(DEV=2) W !,"Not a terminal device number." G DEV
        S RANGE="N" G:DEV'<20 GT I '$D(^SYS(ID,"TTY",DEV)) D IVDEV G DEV
        I ^SYS(ID,"TTY",DEV,"CONTROLLER")="DMC11" D IVD G DEV
        S CNT="SINGLE" Q
GT      I '$D(^SYS(ID,"TTY",DEV)) D IVDEV G DEV
        S CNT=^SYS(ID,"TTY",DEV,"CONTROLLER") Q
RANGE   S START=$P(DEV,":",1),END=$P(DEV,":",2)
        I END<START!(START<3)!((START>20)&(START<64))!(END>MAXTTY)!((START<20)&(END>20)) D IV G DEV
        I '$D(^SYS(ID,"TTY",START))!'$D(^SYS(ID,"TTY",END)) D IVDEV G DEV
        G:END'<20 CT
        I ^SYS(ID,"TTY",START,"CONTROLLER")="DMC11"!(^SYS(ID,"TTY",END,"CONTROLLER")="DMC11") D IVD G DEV
        F I=START:1:END I ^SYS(ID,"TTY",I,"CONTROLLER")="LP11" D IV G DEV
        S CNT="SINGLE" Q
CT      I ^SYS(ID,"TTY",START,"CONTROLLER")'[^SYS(ID,"TTY",END,"CONTROLLER") W !,"Ranges may not cross controller types" G DEV
        S CNT=^SYS(ID,"TTY",START,"CONTROLLER") Q
IVDEV   W " -- Device not in configuration." Q
IV      W !!,"Incorrect response - enter ""?"" for more information." Q
HLP     W !,"If you have a group of terminals which you would like to declare as",!,"having identical characteristics, enter a range
 of device numbers.",!,"For example, enter ""64:79"" to select devices 64 through 79.",!
        W "If you want to establish characteristics on a device-by-device basis,",!,"then enter any terminal device number.",!
HDR     W !!,?4,"Parity",?11,"Auto",?23,"Modem",?30,"Output",?38,"Stall",?44,"Lower",!?7,"|",?11,"Baud",?23,"Cntrl",?31,"only",?38,"
Count",?44,"Case",!,?7,"|",?13,"|",?25,"|",?32,"|",?40,"|",?46,"|"
        W !,"Device | CRT | Rcvr Xmit | ZUSE | Login | Tab | Output Rtn  Edit",!,"Number |  |  | Spd  Spd  |",?29,"|",?32,"|",?36,"|
",?40,"|",?43,"|",?46,"|",?48,"Margin num Comment" Q
IV1     W !,"Enter ""Y"" or ""N"" or <CR>. <CR> gives the default.",! Q
IV2     W !,"Enter ""E"", ""O"" or ""N"". Enter <CR> to take the default.",! Q
IV3     W !,"Receive and transmit rates are as follows:",!?5,$P($T(@$S(CNT["DZ":"BAUD",CNT="DH11":"BAUD1",1:"BAUD2")),";;",2),!,"Ent
er one of the above, or <CR> to take the default.",! Q
IV4     W !,"Enter a number between 0 and 255, or <CR> to take the default.",!,"The value 0 causes there to be no margin.",! Q
IV5     W !,"Enter a number between 0 and 7 or <CR> to take the default.",!,"The number 0 causes there to be no routine tied to this
 terminal.",! Q
IV6     W !,"Enter the number (0-99) of pad characters required after control functions",!,"for this terminal. The number 0 causes n
o padding.",! Q
IV7     W !,"Enter Y to edit comment associated with this terminal, N to leave it alone",!,"or <CR> to take the default (N).",! Q
BAUD2   ;;75,110,134.5,150,300,600,1200,1800,2000,2400,4800,9600,19200
BAUD1   ;;0,50,75,110,134.5,150,200,300,600,1200,1800,2400,4800,9600
BAUD    ;;50,75,110,134.5,150,300,600,1200,1800,2000,2400,3600,4800,7200,9600
IVD     W ?8,"Can't change characteristics for DMC-11 devices." Q
