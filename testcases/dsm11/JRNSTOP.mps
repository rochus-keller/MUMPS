JRNSTOP ;
        I ^SYS(^SYS(0,"RUNNING"),"OPTIONS","JRNL")'="Y" W !,"JOURNAL OPTION "
        I  W "WAS NOT SELECTED DURING SYSGEN.  UTILITY ^JRNL ABORTED." Q
        D CHKSYS^SYSROU Q:%A
STOP    S %BRK=1 G ST2
BAKSTOP S %BRK=0
ST2     S %ST=$V(44),%RJ=%ST+410,%STP=4,%JSP="JOURNAL SPACE"
        I '$V(%RJ) W !,"Journaling is not active.",! K:%BRK ^SYS(0,%JSP,"CURRENT") G DONE
        S %HSTP=32,%OUSP=64,%MTER=128,%JDEV=%ST+54
        G DONE:$V(%RJ)\%MTER#2!($V(%RJ)\%OUSP#2)
        V %RJ::$V(%RJ)+($V(%RJ)\%STP#2=0*%STP) B %BRK
        F %I=1:1:6 H 1 D STEST G SDOWN:%SDOWN=1,DONE:%SDOWN=-1
        V %RJ::$V(%RJ)+($V(%RJ)\%STP#2=0*%STP)+($V(%RJ)\%HSTP#2=0*%HSTP)
        B %BRK H:'%BRK 2
SDOWN   S %MT=$V(%JDEV)#256 G SDISK:%MT=128 S %DVM=$V(%ST+8)+%MT
        D TCLOS^JRNRECOV C %MT
        G EXIT
SDISK   S %CUR=$V(%ST+296)#256*65536+$V(%ST+294)
        S %IX=^SYS(0,%JSP,"CURRENT")
        G:'%BRK EXIT
        S ^(%IX,"NEXT")=%CUR
        S:%CUR'<^("END") ^("NEXT")="FULL"
        S:%CUR=^("START") ^("NEXT")="EMPTY"
        K ^SYS(0,%JSP,"CURRENT")
EXIT    V %JDEV::$V(%JDEV+1)*256 B %BRK
        W !,"Journaling has been shut down.",!!
DONE    K %ST,%RJ,%STP,%OUSP,%MTER,%JSP,%JDEV
        K %I,%HSTP,%MT,%DVM,%SDOWN,%CUR,%IX,%BRK
        Q
STEST   I '$V(%RJ) S %SDOWN=1 Q
        I $V(%RJ)\%MTER#2!($V(%RJ)\%OUSP#2) S %SDOWN=-1 Q
        S %SDOWN=0 Q
