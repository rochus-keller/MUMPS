NEWT ;Test NEW command scoping
 S X=100,Y=200,Z=300
 W "Before DO: X=",X," Y=",Y," Z=",Z,!
 D NEWSUB
 W "After DO: X=",X," Y=",Y," Z=",Z,!
 W !,"*** Extrinsic function test",!
 S RESULT=$$ADD(3,4)
 W "$$ADD(3,4) = ",RESULT,!
 S RESULT=$$FACT(5)
 W "$$FACT(5) = ",RESULT,!
 W !,"Done",!
 Q
NEWSUB ;
 N X,Y
 W "In NEWSUB before SET: X=[",$G(X),"] Y=[",$G(Y),"] Z=",Z,!
 S X=999,Y=888
 W "In NEWSUB after SET: X=",X," Y=",Y," Z=",Z,!
 Q
ADD(A,B) ;Extrinsic function: add two numbers
 Q A+B
FACT(N) ;Recursive factorial
 I N<2 Q 1
 Q N*$$FACT(N-1)
