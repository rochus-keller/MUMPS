%LIB    ;FDN;DSM Utilities;Top level menu;11-JUN-80
        D:$D(^UTILITY("MENU",$J,"MENU")) PUSH^%MENU S ^UTILITY("MENU",$J,"MENU")="^%MENU(""LIB"")" D %STT^%MENU
        S %NOPAUSE=1 Q
