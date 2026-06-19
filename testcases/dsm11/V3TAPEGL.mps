V3TAPEGL        ;20-May-83 ;UTILITIES ;DEVELOPMENT SUPPORT ;SAVE GLOBALS ;JBH
V2TAPEGL        Q
        ;;Invoked by ^V3UTILS
        ;;
PUTG    U 0 S %ERR=0,G=0,COL=1
        W !!,"TRANSFER SYSTEM GLOBALS"
NEXG    U U W:PR # U 0 S G=G+1 ;;OFFSET FROM LINE "GLOBS" OF NEXT GLOBAL
        S CUR=$P($T(GLOBS+G),";;",2),NEW=$P($T(GLOBS+G),";;",3)
        G DONE:CUR="" S:NEW="" NEW=CUR
        W:COL=1 ! W ?COL,NEW S COL=COL+10#80
        S NEW="^"_NEW
        S NOW="^"_CUR_"("""")"
        U U W NEW,!,@("^"_CUR),! G:'SDP WER:$ZA>127!($ZA<64) I SDP,$ZA>LAST D MOUNT^MAKESDP
        ;;S NEW=NEW_"("
        I NEW'["(" S NEW=NEW_"("
        E  S NEW=$P(NEW,"(")_"("
        ;; .END fix
        F I=1:1 S NOW=$ZO(@NOW) Q:NOW=""  W NEW_$P(NOW,"(",2,99),!,@NOW,! I 'PR G:'SDP WER:$ZA>127!($ZA<64) I SDP,$ZA>LAST D MOUNT^MAKESDP
        U 0 G NEXG
        ;;
PRGLOB  S PR=1 G PUTG
        ;;
DONE    U 0 W ! Q
        ;;
        ;;
WER     U 0 W !,"! TAPE ERROR - STOPPING.",! S %ERR=1 Q
SER     U 0 W !,"! SDP ERROR - STOPPING.",! S %ERR=1 Q
        ;;
        ;; 1st field = current name, 2nd = name to save & restore with, if dif.
GLOBS   ;;
        ;;PATCH;;SYS(0,"PATCH")
        ;;%
        ;;%EDI
        ;;%EDIHELP
        ;;%HELP11
        ;;%MENU
        ;;%Q
        ;;
