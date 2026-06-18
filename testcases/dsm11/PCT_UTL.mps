%UTL    ;DB;DSM Utilities;Top level menu;11-NOV-80
        S $ZT="ERR^%UTL"
        K ^UTILITY("MENU",$J) D:'$D(%UCN) ^%GUCI
        S ^UTILITY("MENU",$J,"MENU")="^%MENU("_$S(%UCN=1:"""UTL"")",1:"""LIB"")") K %UCI,%UCN D %STT^%MENU
        Q
ERR     K %E,%H,%I,%P,%POSTACT,%PREACT,%X,%Z,%O,%T,^UTILITY("MENU",$J)
        S $ZT="" Q
