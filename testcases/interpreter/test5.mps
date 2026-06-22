ADV ;Advanced tests: XECUTE, $SELECT, $DATA, $ORDER, globals
 W "*** XECUTE test",!
 X "W ""Hello from XECUTE"",!"
 S CMD="S XR=100 W ""XR="",XR,!"
 X CMD
 W !,"*** $SELECT test",!
 S VAL=2
 W "$S: ",$S(VAL=1:"one",VAL=2:"two",VAL=3:"three"),!
 W !,"*** $DATA/$ORDER test",!
 S A(1)="alpha"
 S A(2)="beta"
 S A(3)="gamma"
 W "$D(A)=",$D(A),!
 W "$D(A(1))=",$D(A(1)),!
 W "$D(A(99))=",$D(A(99)),!
 S KEY="" F  S KEY=$O(A(KEY)) Q:KEY=""  W "A(",KEY,")=",A(KEY),!
 W !,"*** Global test",!
 S ^DATA(1)="first"
 S ^DATA(2)="second"
 S ^DATA(3)="third"
 W "$D(^DATA)=",$D(^DATA),!
 S GK="" F  S GK=$O(^DATA(GK)) Q:GK=""  W "^DATA(",GK,")=",^DATA(GK),!
 K ^DATA
 W "$D(^DATA) after KILL=",$D(^DATA),!
 W !,"*** $TRANSLATE test",!
 W "$TR(""HELLO"",""HELO"",""helo"")=",$TR("HELLO","HELO","helo"),!
 W !,"*** Argumentless FOR with Q",!
 S COUNT=0
 F  S COUNT=COUNT+1 Q:COUNT>3  W "count=",COUNT,!
 W "Final count=",COUNT,!
 W !,"*** Integer divide/modulo",!
 W "17\5=",17\5,!
 W "17#5=",17#5,!
 W !,"*** Nested DO",!
 D OUTER
 W !,"*** Done",!
 Q
OUTER ;Outer sub
 W "In OUTER",!
 D INNER
 W "Back in OUTER",!
 Q
INNER ;Inner sub
 W "  In INNER",!
 Q
