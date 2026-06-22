FLOW ;Test flow control: DO, GOTO, NEW, FOR
 W "*** DO test",!
 D SUB1
 W "Back from SUB1",!
 D SUB2(10,20)
 W "Back from SUB2",!
 W !,"*** GOTO test",!
 G SKIP
 W "This should not print",!
SKIP S Z=99
 W "After GOTO, Z=",Z,!
 W !,"*** Dot block test",!
 S N=3
 F I=1:1:N D
 . W "  dot block I=",I,!
 . I I=2 W "  (special: I is 2)",!
 W "After dot block",!
 W !,"*** $PIECE test",!
 S LINE="one^two^three^four"
 W "$P(LINE,^,1)=",$P(LINE,"^",1),!
 W "$P(LINE,^,3)=",$P(LINE,"^",3),!
 W "$L(LINE,^)=",$L(LINE,"^"),!
 W !,"*** $ASCII/$CHAR test",!
 W "$A(""A"")=",$A("A"),!
 W "$C(65)=",$C(65),!
 W !,"*** Comparison ops",!
 I 5>3 W "5>3 is true",!
 I 3'<3 W "3'<3 is true (not less)",!
 I "abc"["b" W """abc""[""b"" is true",!
 I "def"]"abc" W """def""]""abc"" is true (follows)",!
 W !,"*** $FIND test",!
 W "$F(""ABCDE"",""CD"")=",$F("ABCDE","CD"),!
 W !,"*** $JUSTIFY test",!
 W "$J(42,6)=[",$J(42,6),"]",!
 W "$J(3.14159,8,2)=[",$J(3.14159,8,2),"]",!
 W !,"*** Done",!
 Q
SUB1 ;Simple subroutine
 W "In SUB1",!
 Q
SUB2(A,B) ;Parameterized subroutine
 N C
 S C=A+B
 W "In SUB2: A=",A," B=",B," C=",C,!
 Q
