DTEST ;$DATA completeness test
 S X=1
 W "$D(X)=",$D(X),!
 S X(1)=2
 W "$D(X)=",$D(X),!
 W "$D(X(1))=",$D(X(1)),!
 W "$D(X(2))=",$D(X(2)),!
 ;
 W !,"*** Multiple FOR ranges",!
 F I=1,3,5,7 W I," ",!
 W !
 F I=1:2:10 W I," ",!
 W !
 ;
 W !,"*** SET $E test",!
 S STR="ABCDE"
 S $E(STR,2,3)="XX"
 W "After SET $E(STR,2,3)=""XX"": ",STR,!
 ;
 W !,"*** SET $P test",!
 S REC="one^two^three"
 S $P(REC,"^",2)="TWO"
 W "After SET $P: ",REC,!
 ;
 W !,"*** Postcondition test",!
 S X=5
 W:X>3 "X>3 postcond passed",!
 W:X>10 "This should not print",!
 ;
 W !,"Done",!
 Q
