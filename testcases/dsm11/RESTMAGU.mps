RESTMAGU        Q  ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
MAGASK  ;
        S DT=$V(ST+8),%FAIL=0
WHICH   S UU=-1,QUES="MGQ",DEF="" X ^%Q("ASK") S:ANS="" %A=1 Q:%A
        I ANS'?1N!(ANS>3) D MGQH G WHICH
        I $V(DT+47+ANS)#256=255 D NCONFIG G WHICH
        S UU=ANS+47,BDEN="TB" C UU O UU:BDEN:3 E  D NAVAIL G WHICH
MSAY    S QUES="MNTQ" X ^%Q("EN") I %A C UU G WHICH
        I ANS'="" D MNTQH G MSAY
        U UU W *5 S ZA=$ZA U 0
        I ZA\64#2=0 W !,"! OFF-LINE !",! C UU G WHICH
CHECK   U 63:(1:1),UU:(512:512) W *6,*10 S ZA=$ZA U 0 G OK:ZA<128&(ZA>63) S ZA1=ZA
        U UU:"B"
        U UU:(512:512) W *6 S ZA=$ZA U 0 G OK:ZA<128&(ZA>63)
        W !!,"** ERRORS TRYING TO READ TAPE LABEL BLOCK:",!
        W "TRYING TO READ AT 800  BPI, $ZA = ",ZA1," (DECIMAL)",!
        W "TRYING TO READ AT 1600 BPI, $ZA = ",ZA,!
        C UU G WHICH
OK      S VL=1 D NM^RESTDOMG Q:%FAIL
        S MAPS=$V(902,0),IU=$V(881,0),FAC=$V(898,0),BF=FAC+IU
        S STSA=$V(ST) V ST::STSA\2048#2=0*2048+STSA
        C UU
        C 63 S ZE=$ZT,$ZT="AWFUL" O 63:BF:2 S $ZT=ZE
TRYMOR  C 63 I BF+FAC<($V(ST+32)-5),BF+FAC<64 O 63:BF+FAC:2 I  S BF=BF+FAC G TRYMOR
        O 63:BF I BF'<(FAC*2)&('IU) S:BDEN["T" BDEN=$P(BDEN,"T",2) O UU:"C"_BDEN
        E  O UU:BDEN
        V ST::STSA
        U 63:(1:1),UU:(1024:0) W *6,*10 S ZA=$ZA U 0
        I ZA>127!(ZA<64) W !,"TAPE ERROR!" G UNPRO
        K BDEN,ANS,%YN,%QMK,DT,STSA,ZE
        Q
MGQ     W !,"Which Magtape Unit (0, 1, 2, or 3) " Q
MGQH    W !,"Enter the Unit# of the Magtape drive that will hold the tape "
        W "you will"
        W !,"be restoring *from*.",!
        W !,"(If you do not wish to restore from Magtape, enter  ""^"" )",!!
        Q
NCONFIG ;
        W !,"There is no Magtape Unit# ",ANS," in the configuration that is "
        W "currently",!,"running.",! Q
NAVAIL  ;
        W !,"Magtape Unit# ",ANS," is in use by another job.",! Q
MNTQ    W !,"Please mount the Backup tape to be restored *from*, on Magtape "
        W "Unit# ",UU-47,!
        W "  then type  <CR> " Q
MNTQH   W !,"(If you have changed your mind and do not wish to restore from "
        W "this Magtape",!
        W "Unit, enter  ""^"" )",! Q
AWFUL   S $ZT=ZE V ST::STSA
        W !!,"** THERE ARE NOT ENOUGH VIEW-BUFFERS AVAILABLE TO HANDLE THE "
        W "BLOCKING-",!
        W "FACTOR OF ",FAC," FOR THIS TAPE.  AT LEAST ",FAC+IU," BUFFERS "
        W "WOULD BE NEEDED."
UNPRO   W !," -- UNABLE TO PROCEED",!
        W " -- STOPPING." S %FAIL=1 Q
