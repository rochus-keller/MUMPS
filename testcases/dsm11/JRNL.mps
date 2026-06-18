JRNL    ; FDN ; DSM Utilities ; Secondary level menu ; 23-Nov-80
        D:$D(^UTILITY("MENU",$J,"MENU")) PUSH^%MENU S ^UTILITY("MENU",$J,"MENU")="^%MENU(""SYS"",""JOURNAL"")" D %STT^%MENU
        S %NOPAUSE=1 Q
