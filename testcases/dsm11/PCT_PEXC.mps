%PEXC   ;9-Jan-81 ;UTILITY ;PROGRAM MAINTENANCE ;PROGRAM COMMAND EXPANDER; JHM
        K  U 0 W !!,"MUMPS Command Expander",!
DEV     S %QTY=2 D ^%IOS Q:'$D(%IOD)  W !
SEL     D ^%PSEL G DEV:'$D(%UTILITY)
        S ROU=-1
        F I=1:1:+$P($T(CMD),"/",2) S C=$P($T(CMD+I),"/",2),CMD(C)=$P($T(CMD+I),"/",3)
        F I=1:1:+$P($T(FUNC),"/",2) S F=$P($T(FUNC+I),"/",2),FUNC(F)=$P($T(FUNC+I),"/",3)
ROUT    S ROU=$N(%UTILITY(ROU)) G END:ROU=-1 U 0 W !!,ROU D SCAN G ROUT
END     C %IOD,%F G SEL
SCAN    ;
        S %F="SRC$:"_ROU O %F:READ U %F:DISCON
        F L=1:1 U %F R INLIN Q:INLIN=$C(26)  D PARS U %IOD W OTLIN,!
PARS    S P=0,FUN=0,TAG=1,COM=0,ARG=0,QUOT=0,OTLIN="",L=$L(INLIN)
P       S P=P+1 Q:P>L  S C=$E(INLIN,P),OTLIN=OTLIN_C
        I C=";"&'QUOT S OTLIN=OTLIN_$E(INLIN,P+1,255) Q
        I C=$C(9),TAG S TAG=0,COM=1 G P
        I C="""" D QUOT G P
        I QUOT G P
        I C=" " S ARG='ARG S:'ARG COM=1 G P
        I C="$",'QUOT S FUN=1 G P
        I FUN S FUN=0 D FUNCTION G P
        I COM G P:C'?1U S COM=0 D EXPAND
        G P
QUOT    I 'QUOT S QUOT=1 Q
        I $E(INLIN,P+1)="""" S P=P+1,OTLIN=OTLIN_"""" Q
        S QUOT=0 Q
        Q
EXPAND  Q:C'?1U  I C="Z" S P=P+1,OTLIN=OTLIN+$E(INLIN,P),C=C_$E(INLIN,P)
        I C'?2U,'$D(CMD(C)) Q
        S OTLIN=OTLIN_CMD(C)
        Q
FUNCTION        I C'?1U Q
        I C="Z" S P=P+1,OTLIN=OTLIN_$E(INLIN,P),C=C_$E(INLIN,P) I C'?2U Q
        I '$D(FUNC(C))!($E(INLIN,P+1)'="(") Q
        S OTLIN=OTLIN_FUNC(C)
        Q
CMD     /27
        /B/reak
        /C/lose
        /D/o
        /E/lse
        /F/or
        /G/oto
        /H/alt
        /H/ang
        /I/f
        /K/ill
        /L/ock
        /O/pen
        /P/rint
        /Q/uit
        /R/ead
        /S/et
        /U/se
        /V/iew
        /W/rite
        /X/exute
        /ZG/o
        /ZI/nsert
        /ZJ/ob
        /ZL/oad
        /ZR/emove
        /ZS/ave
        /ZU/se
FUNC    /14
        /A/scii
        /C/har
        /D/ata
        /E/xtract
        /F/ind
        /J/ustify
        /L/ength
        /N/ext
        /P/iece
        /R/andom
        /S/elect
        /T/ext
        /V/iew
        /ZS/ort
