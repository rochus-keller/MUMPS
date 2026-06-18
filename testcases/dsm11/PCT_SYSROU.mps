%SYSROU ;DSM11 V2 UTILITIES; COPYRIGHT 1980 DEC
        Q
ZGLAST  S %MAXJ=$V($V($V(44)+6)+1)/2
        F %I=1:1:%MAXJ I $V(0,%I)'="" V 264:%I:$V(264,%I)#8192+8192
        S %MM=$V($V(44)+468)
        F %I=32:32:%MAXJ*32 V %I+14:%MM:$V(%I+14,%MM)#8192+8192
        S %MM=$V($V(44)+450)
        I '%MM G DONE
        F %I=4:64:8191 V %I+14:%MM:$V(%I+14,%MM)#8192+8192,%I+44:%MM:$V(%I+44,%MM)#8192+8192
DONE    K %I,%MM,%MAXJ Q
VALID   W !,"Valid answers are:"
        W !,"  Y",?8,"- yes",!,"  N",?8,"- no",!
        W "  ?",?8,"- get help",!,"  ^",?8
        W "- go back to previous question",!," <CR>",?8
        W "- accept default value",!! Q
