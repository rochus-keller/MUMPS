JRNRECOV        ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
RESUME  S %ST=$V(44),%JDEV=%ST+54,%MT=$V(%JDEV)#256,%DSK=%MT=128
        S:'%DSK %MTA=%MT-47*$V(%ST+298)+$V(%ST+22)+4,%BL=$V(%ST+412)
        S:'%DSK %DVM=$V(%ST+8)+%MT
        S %OUSP=64,%MTER=128,%WAK=16,%WAT=256,%RUNJ=%ST+410
        S %STP=4,%HSTP=32,%RSTRT=512,%ONL=64
        S %JSP="JOURNAL SPACE" G:$D(^SYS(0,%JSP,"PAUSE")) RESUME^JRNDKEND
        G OUSP:$V(%RUNJ)\%OUSP#2
        G MTER:$V(%RUNJ)\%MTER#2
        W !,"* Nothing to recover from, or recovery already completed *",!! Q
MTER    I $V(%MTA)\%ONL#2=0 S %E="offline" G ASKRE
        E  S %E="Error writing Journal block # "_(%BL+1)
ASKRE   W !,"Magnetic tape unit ",%MT-47,"  --  ",%E,!
        W "Your options are:",!
        W "R  - Retry",!
        W "T  - " W:%BL "Close this tape and "
        W "Mount a different tape",!
        W "D  - " W:%BL "Close this tape and "
        W "Journal to disk from now on",!
        W "S  - Shut down Journaling",!!
        S %OPS="RTDS" D GETOPT G ASKRE:%FAIL K %E
        I %OP="S" D HSTOP G ASKRE:%FAIL,DONE
        G RETRY:%OP="R" D TCLOS G NWTAP:%OP="T",SWDSK
RETRY   S %ON=$V(%RUNJ)\%WAK#2=0*%WAK-%WAT
        D BITCHANG
REGO    W !,"Journaling has been resumed.",!! G DONE
HSTOP   W !,"Shut down Journaling -- " D SURE Q:%FAIL
HSTP2   S %ON=$V(%RUNJ)\%STP#2=0*%STP+($V(%RUNJ)\%HSTP#2=0*%HSTP) D BITCHANG
        I '%DSK D TCLOS C %MT
        K ^SYS(0,%JSP,"CURRENT"),^SYS(0,%JSP,"PAUSE")
        V %JDEV::$V(%JDEV+1)*256 B 1
        W !,"Journaling has been stopped.  To restart Journaling later, use ^JRNL.",!!
        Q
NWTAP   W !,"(",%BL," blocks were written to present Journal tape)",!!
        D GIVMT
        W "Please dismount this tape and mount new tape, then type  <CR>  "
        R %FAIL,!
RSTRT   S %ON=%RSTRT D BITCHANG G REGO
OUSP    G:%DSK OUSP^JRNDKEND
        D TCLOS W !,"* Journal end of tape *",!!
ASKOU   W "Your options are:",!
        W "M  - Mount a new tape and continue Journaling",!
        W "D  - Journal to disk from now on",!
        W "S  - Shut down Journaling",!!
        S %OPS="MDS" D GETOPT G ASKOU:%FAIL
        I %OP="S" D HSTOP G ASKOU:%FAIL,DONE
        G NWTAP:%OP="M"
SWDSK   S %RECOV=1 D GETST^JRNGETST G ASKOU:%FAIL
        C %MT G RSTRT
TAKMT   ;
        I %DVM#2 V %DVM-1::$V(%DVM-1)#256+($J*2*256)
        E  V %DVM::$V(%DVM+1)*256+($J*2)
        B 1 Q
GIVMT   S %JJOB=$V(%ST+55)
        I %DVM#2 V %DVM-1::$V(%DVM-1)#256+(%JJOB*256)
        E  V %DVM::$V(%DVM+1)*256+%JJOB
        B 1 K %JJOB Q
BITCHANG        ;
        V %RUNJ::$V(%RUNJ)-($V(%RUNJ)\%MTER#2*%MTER)
        V %RUNJ::$V(%RUNJ)-($V(%RUNJ)\%OUSP#2*%OUSP)
        V %RUNJ::$V(%RUNJ)+%ON B 1 Q
SURE    R "Are you sure [Y/N] ?  > ",%FAIL,!
        G SURE:"YN"'[$E(%FAIL,1) S %FAIL='($E(%FAIL,1)="Y") Q
GETOPT  W "Enter single letter of option desired:  > "
        R %OP,! S %FAIL=0 Q:%OP'="?"&($L(%OP)=1)&(%OPS[%OP)
        S %FAIL=1 W !,"You must select one of the given options",! Q
TCLOS   D TAKMT U %MT W *3,*3,*5 U 0 Q
PAUSE   ;
DONE    K %ST,%JDEV,%MT,%MTA,%DSK,%BL,%DVM,%RUNJ
        K %STP,%WAK,%HSTP,%OUSP,%MTER,%WAT,%RSTRT
        K %E,%OP,%OPS,%ON,%FAIL,%CUR,%RECOV,%ONL
        Q
