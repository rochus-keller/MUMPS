%GEDIT  ;GLOBAL EDITOR @SMB@
ED      S %GIOD=0,%RET="^%GEDIT" D ^%G1 I "^"'[% S %("X")="I %DF#10 G EDIT^%GEDIT" D GO^%G G ED
        K %Y,%Z G KQ^%G
        -
EDIT    W !,%G," =",!,%D,!
E0      R " r ",%X G EA:%X="" I %X="END" S %Y=$L(%D)+1,%X=0 G E1
        I %X="..." S %Y=$L(%D)+1,%X=$L(%D) G E1
        I %X["...",$P(%X,"...",2,999)="" S %X=$E(%X,1,$L(%X)-3) G EE:%D'[%X S %Y=$L(%D)+1,%X=%Y-$F(%D,%X)+$L(%X) G E1
        I %X["..." S %Z=$F(%D,$P(%X,"...",1)),%Y=$F(%D,$P(%X,"...",2,999),%Z) G EE:%Y*%Z=0 S %X=%Y-%Z+$L($P(%X,"...",1)) G E1
        G EE:%D'[%X S %Y=$F(%D,%X),%X=$L(%X)
E1      R " w ",%Z I $L(%Z)+$L(%D)-%X>255 W *7," too long" G E0
        S %D=$E(%D,1,%Y-%X-1)_%Z_$E(%D,%Y,999),@%G=%D G E0
        -
EE      W " ? " G E0
        -
EA      I %D]""!(%G'["(") W !,%D G EA1
EA0     R !,"KILL? <N> ",%X S %X=$E(%X,1) G EA1:"N"[%X
        I %X="Y" K @%G W " (KILLED)" G EA1
        W !,"Type Y to kill this node, or N to leave it" G EA0
EA1     R !,"Re-edit/Quit/Continue: <C> ",%X,! S %X=$E(%X,1) Q:"C"[%X
        G E0:%X="R" I %X="Q" S %Q=1 Q
        W !,"Type R to re-edit this node, Q to leave the editor,"
        W !,"or C to go on tho the next node." G EA1
