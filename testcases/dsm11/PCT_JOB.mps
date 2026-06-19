%JOB    ;Examine a job's partition : JEC ; 23-Sep-80 11:06 AM
        S %JM=$V($V($V(44)+6)+1)\2
        S $ZT="",%VR=0 R !!,"Job number: ",%JN Q:%JN=""  I %JN?1"?".E D HELP G %JOB
        I %JN="STA" W !! D ^%SY G %JOB
        I %JN?1N.N1"V" S %VR=1,%JN=+%JN
        I %JN?1N.N1"*" S %VR=2,%JN=+%JN
        I %JN?1N.N1"P" S %JN=+%JN G LOAD
        I %JN'?1N.N!(%JN<1)!(%JN>%JM) W *7,*7,"  Illegal job number" G %JOB
        I $V(149,%JN)="" W *7,"  Job number ",%JN," is not available" G %JOB
        W !!,"Job: ",%JN,"   Uci: ",$V(149,%JN)#32,"=",$ZU($V(149,%JN)#32,$V(149,%JN)\32),"  Routine: "
        F %I=126:1 S %X=$V(%I,%JN)#256 Q:%X>127  Q:'%X  W $C(%X)
        S DT=$V($V(44)+8),%OF=40960 W "  Devices: "
A1      F %I=DT:1:DT+190 S %X=$V(%I)#256\2 I %X-%JN=0 W %I-DT," "
        W !,"Principal device: ",$V(146,%JN)#256
        S %MM=%JN I $V(250,%JN) S %MM=$V(250,%JN),%PT=0
        S:'$V(250,%JN) %PT=$V(240,%JN)-%OF W !! S %AD=%PT D LN
A2      D INT^%NAKED W !,"Last Global Reference: ",%4N,!
        I $V(230,%JN)'=65535 W !,$V(230,%JN)," seconds to timeout."
        S %AD=-1,%CU=$V(238,%JN)-$S($V(250,%JN):57344,1:40960) I %CU>0 F %AD=%CU:-1 Q:%AD-1<%PT  Q:$V(%AD-1,%MM)#256=255
        E  W *7,!!,"  ***Job inactive***",! G A3A
A3      I %AD'<0 S %LB=$V(%AD,%MM)#16,%LN=$V(%AD+%LB+1,%MM)#256,%NX=%AD+%LB+%LN+3
        I %CU>(%AD-1),%CU<%NX G A4
        S %AD=%NX I $V(%AD,%MM)#256\16 W *7,!,"  ***Job inactive***",! G %JOB
A3A     D DMP:%VR=1,ENT^%VAR:%VR=2 G SET^%VAR:%VR=2,%JOB
A4      W ! D LN W !,$C(9),?$X+%CU-%AD-%LB-2,"^",!
        I %VR=1 D DMP S $ZT=""
        I %VR=2 D ENT^%VAR,SET^%VAR S $ZT="" Q
        W !!,"Continue? <Yes> " R %X,! G A2:"Y"[$E(%X,1),%JOB
LN      Q:%AD<0  Q:($V(%AD,%MM)#256=255)  S %LB=$V(%AD,%MM)#16
        F %I=%AD+1:1:%AD+%LB W $C($V(%I,%MM)#128)
        S %LN=$V(%I+1,%MM)#256 W ?8
        F %I=%AD+%LB+2:1:%AD+%LB+%LN+1 S %X=$V(%I,%MM)#256 Q:%X=255!(%X>127)  W $C(%X)
        Q
DMP     S $ZT="ERR^%JOB",PS=$V($V($V(44)+6)+(%JN*2))#16+1*1024,P=$V(138,%JN)-40960+2,TO=$V(396,%JN)-40960-1,FR=P+14 W !,"Symbol table:",!
        I FR>PS W *7,"No variables in symbol table" Q
        D ENT^%VAR S L="" F I=1:1 S L=$O(^(L)) Q:L=""  W !,L,"=",^(L)
        W ! Q
D1      S LV=1,DL="(",NM=""
D2      S O(LV)=$V(P,%JN) D O,O S X=$V(P,%JN)#256,PV=X\64,N=X#64
        F I=1:1:N D O S X=$C($V(P,%JN)#128) S NM=NM_X
        G D3:'(PV#2) W NM W:LV>1 ")" W "=",$C(34)
        D O S EX=$V(P,%JN)#256 D O S N=$V(P,%JN)#256 F I=1:1:N D O W $C($V(P,%JN)#128)
        F I=1:1:EX-N+1 D O
        W $C(34),!
D3      I '(P#2) D O
        D O I PV\2 S LV=LV+1,NM=NM_DL,DL="," G D2
D4      I LV>1,O(LV-1)=0 S LV=LV-1 G D4
        I LV=2 S NM=$P(NM,"(",1)_"(" G D2:LV>1,D1:P'>TO Q
        S NM=$P(NM,",",1,LV-2)_"," G D2:LV>1,D1:P'>TO Q
O       S P=P+1 F J=1:1:LV S O(J)=O(J)-1
        Q
LOAD    I '$D(^UTILITY($J,"VAR",%JN)) W *7,!!,"  Previous symbol table data does not exist for job number ",%JN G %JOB
        W !!,"Loading previous symbol table data" K (%JN) S %SBSCR=-1 F %INDEX=1:1 S %SBSCR=$N(^UTILITY($J,"VAR",%JN,%SBSCR)) Q:%SBSCR=-1  S @(%SBSCR_"=^(%SBSCR)")
        K %INDEX,%SBSCR W !,"Done",! Q
ERR     I $ZE'["INRPT" W !!,"**Error detected**",!,$ZE,! W  Q
        W *7,!,"  ***Interrupt***" S $ZT="" Q
HELP    W !!,"Enter one of the following responses:",!,"  1.  A job number to get a look at what line is currently being executed."
        W !,"  2.  A job number followed by 'V' to get a look at what line is currently"
        W !,"        being executed and a look at the symbol table for that job.",!,"  3.  A job number followed by '*' to get a look at what line is currently"
        W !,"        being executed and to load the variables from that job into the",!,"        current partition."
        W !,"  4.  A job number followed by 'P' to load previous symbol table data."
        W !,"  5.  Enter 'STA' to get a system status.",!,"  6.  Enter a '?' to get this help text.",!
        Q
