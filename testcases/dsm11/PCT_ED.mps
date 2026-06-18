%ED     ;TLW;%EDIT,DSM-11 UTILITIES;29-AUG-78;ROUTINE EDITOR
        W !,"You must load the editor by 'D LOAD^%ED' - Then 'X ^%'" Q
%       X ^%(98) F %I=0:0 S %E=0 R !,"LINE> ",%T X:%T="." ^(99) Q:'$D(%T)  X:%T="?" ^(100),^(101),^(102) I %T'="?" X:%T=";" ^(6) I %
T'=";" X:%T?1";".E ^(20) I %T'?1";".E X ^(0) S %E=%E!(%_%2+%O<0) X:%E ^(103) I '%E S:%1'="" %O=0 X ^(1),^(2) I '%E X ^(3)
0       S %=$S(%T["-":"-",%T["+":"+",1:""),%1=%T,%2="" S:%'="" %1=$P(%T,%,1),%2=$P(%T,%,2,255) S %E='(%1?1"%".AN!(%1?.AN)) Q:%E  S:%
=""&(%2="") %="+",%2=0 S:%2=""&(%'="") %2=1 S %E=(%'=""&(%2'?1N.N))
1       S %O=(%_%2+%O) S:%1'="" %L=%1
2       S @("%0=$T("_%L_"+"_%O_")") S:%0'="" %X=%0 I %0="" S %E=1,%O=0 X ^(97)
3       W:%T="" %L_"+"_%O F %J=0:0 R "  r ",% W:%="" !,%X Q:%=""  X ^(4) W:%E "  Substring not found" I '%E R "  w ",% S %E=$L($E(%X
,1,%1))+$L(%)+$L($E(%X,%2,255))>255 W:%E "  Too long" I '%E X ^(5) W:%E "   Invalid MUMPS line" I '%E
4       S %E=0,(%1,%2)=-1 S:%="END" (%1,%2)=256 Q:%="END"  S:%X[% %2=$F(%X,%),%1=%2-$L(%)-1 Q:%X[%  S %E=%'["..."!(%="...") Q:%E  S
%0=$P(%,"...",1),%3=$F(%X,%0),%1=%3-$L(%0)-1,%0=$P(%,"...",2),%E=%3=0 S:%0="" %2=256 Q:%0=""  S %2=$F(%X,%0,%3),%E='%2!'%3
5       S %5=$E(%X,1,%1)_%_$E(%X,%2,255),%E=%5'[" " I '%E S %X=%5 X "ZI %X:"_%L_"+"_%O_" ZR "_%L_"+"_%O
6       S %TS=%T R !,"Change every> ",%EV S:%EV="" %T=%TS I %EV'="" S %S=1 X ^(10) I '%E S %S=2 X ^(10) I '%E R !,"Change to> ",%TO
X ^(14) S %T=%TS,%X=%6
10      F %J=0:0 W !,$P("From\To","\",%S)," line> " R %T W:%T="" $P("First\Last","\",%S) S:%T="" %T=$S(%S=2:"+999",1:"+") X:%T="?" ^
(104) I %T'="?" X ^(0) S:%="-" %E=1 X:%E ^(103) I '%E X:%S=1 ^(11) I '%E X:%S=2 ^(12) I '%E Q
11      S:%1="" (%3,%5)=%2 Q:%1=""  X ^(13) I '%E F %K=1:1 Q:$T(+%K)=""  I $P($T(+%K)," ",1)=%1 S %3=%K+%2,%5=%K Q
12      S %4=%3 S:%1="" %4=%2 Q:%1=""  X ^(13) I '%E F %K=%5:1 Q:$T(+%K)=""  I $P($T(+%K)," ",1)=%1 S %4=%K+%2 Q
13      S @("%E=$T("_%1_"+"_%2_")="_""""_"""") I %E X ^(97)
14      S %6=%X F %K=%3:1:%4 Q:$T(+%K)=""  S %X=$T(+%K),%=%EV X ^(16) X:%TO'=""""&%S ^(15) I %S W !,%K,"==> ",%X
15      X "ZI %X:"_"+"_%K_" ZR "_"+"_%K
16      S %S=0,%2=1 F %M=0:1 Q:'$F(%X,%,%2)  S:%TO'="""" %2=$F(%X,%,%2),%1=%2-$L(%)-1,%X=$E(%X,1,%1)_%TO_$E(%X,%2,255),%2=%1+$L(%TO)
+1,%E='(%X?1"%".AN1" ".E!(%X?.AN1" ".E)),%S=1 I %TO="""" S %S=1 Q
20      W ! X $P(%T,";",2,$L(%T,";"))
97      W "   Line not found"
98      X ^(99) S (%L,%X)="",%O=0
99      K %,%1,%2,%E,%J,%I,%L,%O,%X,%0,%3,%4,%5,%6,%TS,%S,%TO,%EV,%K,%M,%T
100     W !!,"LINE entry:",!,"'.' to exit",!,"<CR> to edit the same line again",!,"';' to change every occurrence",!,"';' followed b
y a string of MUMPS code",!,"'TAG' OR 'TAG+/-Offset'",!,"'+/-Offset'",!
101     W !!,"REPLACE entry:",!,"Substring of line to be edited",!,"'END' to add onto end of line",!,"'substring1...substring2' to s
pecify a long string",!,"<CR> to display the line",!
102     W !!,"WITH entry:",!,"Can be anything",!
103     W "  Incorrect response - Enter '?' for help"
104     W ?14,"Enter a line number, line number + offset,",!?14,"or <CR> to take the default of the ",$P("first\last","\",%S)," line
 of text"
END     Q
LOAD    W:$V(149,$J)'=1 !,"Not UCI #1" Q:$V(149,$J)'=1  K ^% S ^%=$P($T(%)," ",2,255)
        F I=1:1 Q:$T(%+I)="END Q"  I $P($T(%+I)," ",2)'?1";".E S ^%($P($T(%+I)," ",1))=$P($T(%+I)," ",2,256)
        W !,"The ^% Global has been created.",! Q
ED      W !!,"To execute ""%"" editor, type ""X ^%"""
        W !!,"Available commands while executing ""%"" editor:" X ^%(100),^%(101),^%(102) Q
EDI     W !!,"To create a new program, type ""ZR"", then ""X ^%EDI"""
        W !!,"To edit an existing program, ZL ""program"", then ""X ^%EDI"""
        W !!,"While executing %EDI, you can type H[ELP] [str] to get help text for commands",!!
        F I=38002:1:38012 W ^%EDIHELP(I),!
        Q
