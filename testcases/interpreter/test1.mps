TEST ;Basic interpreter test
 W "Hello, MUMPS!",!
 S X=42
 W "X = ",X,!
 S Y=X+8
 W "Y = X+8 = ",Y,!
 S A="Hello"
 S B=" World"
 W A_B,!
 W "Length of A = ",$L(A),!
 W "Extract(A,2,4) = ",$E(A,2,4),!
 I X>40 W "X is greater than 40",!
 I X<10 W "This should not print",!
 E  W "Else branch: X >= 10",!
 S I="" F I=1:1:5 W "Loop ",I,!
 W "$H = ",$H,!
 I "123"?1N.N W "123 matches ?1N.N",!
 I "abc"?1N.N W "This should not print",!
 E  W "abc does not match ?1N.N",!
 W "Done!",!
 Q
