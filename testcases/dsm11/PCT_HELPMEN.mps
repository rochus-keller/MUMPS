%HELPMEN        ;DSM-11 Utilities ; HELP driver
        ZBREAK OFF
        S %B=1
        I '$D(@%HELP) U 0 W !,"Sorry, no help available at this level",! Q
        ;
        ; Main loop of HELP: list options, prompt , execute options, back to list or prompt
START   D LISTOPT
PROMPT  ;prompt for option
        S %I=@%HELP,%P=""""_$P(%I,"\",2)_" >""" D FULLREF
        U 0 R !!,@%P,%O D CONVERT G:(%O="")!(%O="^") END
        D MATCHOP I %M=0 D ERROR G PROMPT
        I %M>1 G PROMPT
        S %X=%C(1) D DOOPT G PROMPT
        ;
CONVERT ;change lower case to upper case
        S %R=%O
        S %O=""
        F %V=1:1 S %W=$E(%R,%V) Q:%W=""  D
        .S %U=$A(%W)
        .I (%U'<97)&(%U'>122) S %O=%O_$C(%U-32)
        .E  S %O=%O_%W
        Q
MATCHOP ;match option
        ; input = %O = option string
        ; output =      %M = number of matches
        ;               %C() array of matches
        S %M=0 K %C G:%O="*" WILD
        S $ZT="MATERR^%HELPMEN"
        I $D(^(%O)) S %X=%O D DSPTEXT
        S %X=$ZS(^(%O)) F %I=0:0 Q:%X=""  Q:'(%O=$E(%X,1,$L(%O)))  D DSPTEXT S %X=$ZS(^(%X))
        Q
MATERR  S %ZE=$ZE,$ZE="" I %ZE["INVSUBSCR" S %M=0 Q
        ZQUIT
WILD    ;wild card
        S %X="" F %I=0:0 S %X=$ZS(^(%X)) Q:%X=""  D DSPTEXT
        Q
ERROR   ;display error message
        S %B=1
        I %O="?" W:$X>30 ! W ?32,"Enter * for all options,",!,?32,"or one of the following:",! D LISTOPT Q
        W:$X>30 ! W ?32,"Incorrect response.",!,?32,"Enter ? for more information",! S %X=""
        D LISTOPT
        S %B=1
        Q
LISTOPT ;list all options
        S %I=@%HELP,%T=$P(%I,"\",1)_":" D FULLREF
        I %B>18 D CONT
        W !!,%T,!!
        S %B=%B+4
        F %I=1:1 Q:%X=""  D LISTONE S %X=$ZS(^(%X))
        Q
LISTONE ;given %X, display it
        I $X=0 W:'(%X?.N) %X Q
        S %MARG=$X+16\16*16 I (%MARG+$L(%X))>80 S %B=%B+1 D:%B#23=0 OPCONT W:'(%X?.N) !,%X Q
        W:'(%X?.N) ?%MARG,%X
        Q
DOOPT   ;execute option
        S %E=^(%X) I '($P(%E,"\",1)="")&'((%F="N")!(%F="n")) D PUSH S %HELP=$E(%HELP,1,$L(%HELP)-1)_","""_%X_""")" D %HELPMEN+3
        E  S %F="Y"
        Q
DSPTEXT ;Display text
        ; input = %X = current node
        ; output: displays text and increments %M
        ;        and stores it in array %C
        S %B=3
        S %F="Y"
        Q:%X?.N
        S %E=^(%X),%M=%M+1,%C(%M)=%X
        W !!,%X,!
        S %S=$E(%HELP,1,$L(%HELP)-1)_","""_%X_""","
        S %E=""""""
        S %E=$O(@(%S_%E_")"))
        I %E="" W ! Q
        S:'(%E?.N) %E=$O(@(%S_""""_%E_""")"))
        F %K=0:0 Q:%E=""  Q:'(%E?.N)  D
        .S %E=""""_%E_""""
        .W !,?4,@(%S_%E_")")
        .S %B=%B+1
        .I %B#23=0 D CONT
        .S %E=$O(@(%S_%E_")"))
        .S:(%F="N")!(%F="n") %E=""
        W !
        S %S=$E(%S,1,$L(%S)-1)_")"
        S %E=@%S
        Q
FULLREF ;perform a full reference to current HELP option list
        I '$D(@%HELP) S %X=""
        E  S %X=$ZS(@($E(%HELP,1,$L(%HELP)-1)_","""")"))
        Q
END     ;clean up and quit
        K %C,%S,%U,%R,%W,%V,%I,%K,%L,%M,%T,%P,%A,%O,%E,%X,%H,%MARG
        I '$D(%HLEVEL) K %HELP,%B,%F Q
        D POP
        Q
PUSH    ;push context for recursion
        S:'$D(%HLEVEL) %HLEVEL=0 S %HLEVEL=%HLEVEL+1,%HSTACK(%HLEVEL)=%HELP
        Q
POP     ;pop context for recursion
        S %HELP=%HSTACK(%HLEVEL),%HLEVEL=%HLEVEL-1
        I %HLEVEL=0 K %HLEVEL,%HSTACK
        Q
CONT    ;continue message
        R !,!,"Press <RETURN> to continue ...    N to quit   ",%F
        G FINI
OPCONT  R !,!,"Press <RETURN> to continue ...  ",%F
FINI    W !
        S %B=1
        Q
