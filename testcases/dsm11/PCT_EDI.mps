%EDI    ;9-Dec-81 ;UTILITY ;EDITOR ;EDI PROGRAM EDITOR ;JEB
INIT    S %CR=13,%ES=27,%V=1,%CC="&"
        I $D(%FN) D CK^%EDIFIL:'$D(%GL),INIT^%EDIFIL:'$D(@(%GL_"0)")) G START
FILE    L  S %PR="Edit file" D ^%EDIFIL K %PR G QUIT:%FN=""
        L @(%GL_"0)"):0 E  W !,%FN," is being editted by another user" G READ
START   S %P=0,%L=@(%GL_"0)"),%NC=$S(%L:"",1:"I")
NC      G POP:%NC'=""
READ    U 0 W !,"*" R %NC S %X=$ZB#256 I %NC="" G CR:%X=%CR,ES:%X=%ES
        I %NC?1"MA".E!(%NC?1"ma".E)!(%NC?.N1"<".E) S %C=%NC,%NC="" G DISP
POP     S %C=$P(%NC,%CC,1),%NC=$P(%NC,%CC,2,99)
DISP    S %E="",%I="" I %C?1"*".E S %I=99999,%C=$E(%C,2,999)
        E  F %X=1:1 I $E(%C,%X)'?1N S %I=$E(%C,1,%X-1),%C=$E(%C,%X,999) Q
        F %X=1:1 I $E(%C,%X)'?1A S %A=$E(%C,%X,999),%C=$E(%C,1,%X-1) Q
        I %C="" S %Z=",1IM^%EDIMAC" G GO:%A?1"<".E W !,$P($T(SYN),":",2) G READ
        S %Z=%C D UC S %C=%Y,%Z=$T(@$E(%C,1))
        I %Z]"" S %X=%Z F %Y=2:1 S %Z=$P(%X,":",%Y) Q:%Z=""!($P($P(%Z,",",1),%C,1)="")
        I %Z="" W !,$P($T(COM),":",2) G READ
        I %I'="",'$P(%Z,",",2) W !,$P($T(REP),":",2) G READ
GO      S:%I="" %I=1 D @$E($P(%Z,",",2),2,999) I %E]"" W:'%E !,$P($T(@%E),":",2) S %NC=""
        G NC:%C'?1"EX",FILE:%FN'=""
QUIT    K %CR,%ES,%NC,%CC,%L,%V,%T,%P,%I,%C,%A,%M,%W,%X,%Y,%Z,%B,%U,%S,%E,%FN,%GL,%H Q
A       :ADD,0ADD^%EDIEDT:AP,0ADD^%EDIEDT
B       :BEGIN,0BEG:BOTTOM,0END
C       :CHANGE,1CHNG^%EDIEDT:CC,0CC:COMPILE,1COM^%E
D       :DELETE,0DEL^%EDIINS:DP,0DEL^%EDIINS
E       :END,0END:EXIT,0EX
F       :FIND,1FIND^%EDIEDT
H       :HELP,0HELP
I       :INSERT,0INS^%EDIINS
K       :KIL,0COMER:KILL,0KILL^%EDIINS
L       :LOCATE,1LOC^%EDIEDT:LIST,0LIST^%EDILST:LC,1LC^%EDIEDT
M       :M,1MX^%EDIMAC:MACR,0COMER:MACRO,0MAC^%EDIMAC:MCALL,0MC^%EDIMAC:MSAVE,0MS^%EDIMAC
N       :NEXT,0NEXT^%EDILST:NP,0NEXT^%EDILST:NV,0VERS
O       :OVERLAY,0OVER^%EDIINS
P       :PRINT,0PRINT^%EDILST:PF,1PF^%EDIEDT:PL,1PL^%EDIEDT:PASTE,0PA^%EDIEDT
R       :RETYPE,0RETYP^%EDIINS
S       :S,0COMER:SAVE,0SAV^%EDIINS:SC,0SC^%EDIEDT:SM,1MARG
T       :TOP,0BEG:TYPE,0TYPE^%EDILST
U       :UN,0COMER:UNSAVE,0UNS^%EDIINS
V       :VERIFY,0VER
X       :XECUTE,1XEC
Z       :ZLOAD,1LOAD^%EDIINS
CR      I +%L S %P=+%L,%L=^(%P) W !,$P(%L,"^",3,999)
        E  W !,"[EOF]"
        G READ
ES      W "$" I %P S %P=$P(%L,"^",2),%L=^(%P) W !,$P(%L,"^",3,999)
        E  W !,"[TOF]"
        G READ
BEG     S %P=0,%L=^(0) Q
END     S %P=$P(^(0),"^",2),%L=^(%P) W:%V !,$P(%L,"^",3,999) Q
CC      D STRIP I $L(%A)>1 S %E="ARG" Q
        S %CC=%A S:%CC="" %CC="~" Q
EX      W !,"[Exit]" Q
VER     D STRIP S %Z=%A D UC S %X=$S(%Y=""!(%Y="ON"):1,%Y="OFF":0,1:"")
        I %X="" S %E="ARG"
        E  S %V=%X
        Q
XEC     D STRIP S %II=%I W ! F %II=1:1:%II X %A W "."
        I '$D(@(%GL_"0)")) S %E="NOFIL",%C="EX"
        Q
VERS    I %GL'["^PRG" W !,"[Supported for Program Editor only]" Q
        S %I=^PRG(EXT,RNAME)+1,%A="" F %J=0:0 S %A=$ZS(^PRG(EXT,RNAME,VR,%A)) Q:%A=""  S ^PRG(EXT,RNAME,%I,%A)=^(%A)
        S (VR,^PRG(EXT,RNAME))=%I D INIGL^%E W !,"Created: ",RNAME,".",EXT,";",VR,!,@(%GL_"2)") D BEG Q
MARG    D STRIP Q:%A=""
        U $I:%A
        Q
COMER   S %E="COM" Q
HELP    D STRIP S:%A="" %A="HELP" I '$D(^%EHELP(1)) W " no HELP file present"
        E  X ^(1)
        Q:$D(@(%GL_"0)"))
UC      S %Y="" F %X=1:1:$L(%Z) S %W=$E(%Z,%X) S %Y=%Y_$C($A(%W)-(%W?1L*32))
        Q
STRIP   F %X=1:1 I $E(%A,%X)'=" " S %A=$E(%A,%X,999) Q
        Q
ARG     :[illegal argument]
COM     :[illegal command]
REP     :[illegal repeat count]
NUM     :[illegal number]
NOMAC   :[macro not defined]
MACARG  :[macro argument undefined]
NMAT    :[no match]
SYN     :[syntax error]
LEN     :[line too long]
FLN     :[illegal file name]
BDFIL   :[input file corrupted]
NOFIL   :[no such file]
