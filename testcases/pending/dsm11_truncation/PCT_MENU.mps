%MENU   ;FDN;DSM Utilities;Menu driver;11-JUN-80
CRT     W !,"Create a menu Entry",!
        F SUB=1:1 D  I ANS=""!(ANS="^") G CRTDN:SUB<0 G:ANS="^" CRT Q
        .W !,"Enter menu level ",SUB," name: " W:$D(SUB(SUB)) "<",SUB(SUB) R "> ",ANS
        .I ANS="^" S SUB=SUB-2 Q
        .I ANS="",$D(SUB(SUB)) S ANS=SUB(SUB)
        .E  I ANS="" Q:SUB>1  S SUB=SUB-2 Q
        .S SUB(SUB)=ANS S SB="^%MENU("_""""_SUB(1)_"""" F I=2:1:SUB S SB=SB_","_""""_SUB(I)_""""
        .S SB=SB_")" I '$D(@SB) W "  -   Menu level not currently defined"
        S (ROU,HLP)=""
YN      I $D(@SB)#2 S ROU=$P(@SB,"]"),HLP=$P(@SB,"]",2) W !!,@SB,! R !,"Delete this entry ? [Y/N] ",ANS G:ANS="^" CRT G:(ANS=""!("YN
"'[ANS)) YN I ANS="Y" K @SB W "  -  deleted"  G CRT
RQ      W !,"Routine to call " W:ROU'="" "<",ROU R "> ",ANS
        I ANS="^" G CRT
        S:ANS="" ANS=ROU S ROU=ANS
HQ      W !,"Help text " W:HLP'="" "<",HLP R "> ",ANS I ANS="" G:HLP="" CRT G HQSET
        I ANS=""!(ANS="^") G RQ
        S HLP=ANS
HQSET   S @SB=ROU_"]"_HLP
A0      R !,"Is this a menu sub level ? [Y/N] >",ANS G CRT:ANS'="Y"
A1      R !,"Enter Menu Header > ",HD G:HD="^" A0
A2      R !,"Enter Menu option string > ",OP G:OP="^" A1
A3      R !,"Enter Menu post condition > ",PC G:PC="^" A2
        S @SB=@SB_"]"_HD_"]"_OP_"]"_PC G CRT
CRTDN   Q
%STT    I '$D(^UTILITY("MENU",$J,"CLR")) D ^%CURSOR S ^UTILITY("MENU",$J,"CLR")=%CUR("HOME")_","_%CUR("EES"),^("TYPE")=%CUR("TYPE"),
^("Y")=%CUR("Y") K %CUR
        S %I=@^UTILITY("MENU",$J,"MENU"),%PREACT=$P(%I,"]",5) X:'(%PREACT="") %PREACT
%STT1   S %T=$P(%I,"]",3)_":",%P=""""_$P(%I,"]",4)_" >""",%PREACT=$P(%I,"]",5),%POSTACT=$P(%I,"]",6),%H=0
        D FULLREF G:%X="" END D LISTOPT
PROMPT  S %H=0 U 0 R !!,@%P,%O I (%O="")!(%O="^") G END
        I %O'?.ANP,%O'["?" D ERROR G PROMPT
        D MATCHOP G:%X="" PROMPT
        K %NOPAUSE D DOOPT,PAUSE S %I=@^UTILITY("MENU",$J,"MENU") G %STT1
MATCHOP G:(%O?.N) MATCHNUM I $D(^(%O)) S %X=%O Q
        S %X=$ZS(^(%O))
        G:'(%O=$E(%X,1,$L(%O))) HELP
CHAMB   S %A=$ZS(^(%X)) I '(%O=$E(%A,1,$L(%O))) W $E(%X,$L(%O)+1,$L(%X)),! Q
        W:$X>37 ! W ?40,"Ambiguous response",!!,"Enter one of the following:",!!,?8,%X,!,?8,%A S %X=""
LISTAMB S %A=$ZS(^(%A)) I '(%A="") I %O=$E(%A,1,$L(%O)) W !,?8,%A G LISTAMB
        Q
MATCHNUM        ;
        S %X="" F %I=1:1:%O S %X=$ZS(^(%X)) Q:%X=""
        I %X="" W ?40,"Invalid number",! Q
        W ".  ",%X,!
        Q
HELP    I %O=$E("HELP",1,$L(%O)) W $E("HELP",$L(%O)+1,$L("HELP")),! S %H=1,%X="" D LISTOPT Q
        I %O="?" S %H=1,%X="" D LISTOPT Q
        I $F(%O," ")>0 D HELPONE Q
ERROR   W:$X>37 ! W ?40,"Incorrect response - Enter '?' for help" S %X=""
        Q
LISTOPT W:^UTILITY("MENU",$J,"TYPE")["VT" # W @^UTILITY("MENU",$J,"CLR"),!,%T,!
        D FULLREF F %I=1:1 Q:%X=""  D LISTONE S %X=$ZS(^(%X))
        Q
LISTONE I ^UTILITY("MENU",$J,"TYPE")["VT" I $Y>(^UTILITY("MENU",$J,"Y")-4)&%H R !,?55,"Type <CR> to continue ",%R W #,@^UTILITY("MEN
U",$J,"CLR")
        W !,?5-$L(%I),%I,".",?8,%X S %Z=$P(@($E(^UTILITY("MENU",$J,"MENU"),1,$L(^("MENU"))-1)_","""_%X_""")"),"]",1) W:'(%Z="") "  "
,?40,"(",%Z,")" S %Z=$P(^(%X),"]",2) D:%H HELPT
        Q
HELPT   Q:%Z=""  F %K=1:1 S %L=$P(%Z,"\",%K) Q:%L=""  W !,?8,%L
        W ! Q
HELPONE D ERROR Q
DOOPT   S %E=^(%X) I $E(%E,1)="]" D PUSH S ^UTILITY("MENU",$J,"MENU")=$E(^UTILITY("MENU",$J,"MENU"),1,$L(^("MENU"))-1)_","""_%X_""")
" D %STT S %NOPAUSE=1 Q
        S %PREACT=$P(%E,"]",5),%POSTACT=$P(%E,"]",6)
        X:'(%PREACT="") %PREACT D @$P(%E,"]",1) I $D(%POSTACT) X:'(%POSTACT="") %POSTACT
        Q
PAUSE   Q:$D(%NOPAUSE)  U 0 W:$X>55 ! R ?60,"Type <CR> ",%I
        Q
FULLREF S %X=$ZS(@($E(^UTILITY("MENU",$J,"MENU"),1,$L(^("MENU"))-1)_","""")"))
        I %X="" U 0 W !,?10,"No options available at this level",!!
        Q
END     I '(%POSTACT="") X %POSTACT
        K %I,%K,%L,%H,%T,%P,%A,%O,%E,%X,%Z,%PREACT,%POSTACT,%NOPAUSE
        I '$D(^UTILITY("MENU",$J,"MLEVEL")) K ^("CLR"),^("MENU"),^("TYPE"),^("Y") Q
        D POP Q
PUSH    S:'$D(^UTILITY("MENU",$J,"MLEVEL")) ^("MLEVEL")=0 S ^("MLEVEL")=^("MLEVEL")+1,MLEVEL=^("MLEVEL"),^("MSTACK",MLEVEL)=^UTILITY
("MENU",$J,"MENU") K MLEVEL Q
POP     S MLEVEL=^UTILITY("MENU",$J,"MLEVEL"),^("MLEVEL")=^("MLEVEL")-1,^UTILITY("MENU",$J,"MENU")=^("MSTACK",MLEVEL) K MLEVEL I '^(
"MLEVEL") K ^("MLEVEL"),^("MSTACK")
        Q
