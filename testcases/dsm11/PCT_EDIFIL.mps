%EDIFIL ;9-Dec-81 ;UTILITY ;EDITOR ;EDI EDITOR FUNCTIONS ;JEB
        S:'$D(%PR) %PR="File"
READ    W !!,%PR," > " R %X:30 I "^"[%X!'$T S (%FN,%GL)="" Q
        I %X="?" F %X=0:1 S %Y=$T(QUES+%X) G READ:%Y="" W !,$P(%Y,":",2,99)
        S %FN=%X D CK I %GL="" W " illegal global name" G READ
        I $D(@(%GL_"0)")) G TITLE:^(2)="" W "  ",^(2),! Q
NEW     W !,%FN," does not exist.  Initialize? <Y> " R %X:30 S:'$T %X="N" S:%X="" %X="Y"
        S %X=$E(%X,1),%X=$C($A(%X)-(%X?1L*32))
        I "YN"'[%X W " enter Yes or No" G NEW
        G READ:%X="N" D INIT W !
TITLE   R !,"Title > ",%X:30 I %X="?" W " enter descriptive title of text file" G TITLE
        S ^(2)=%X W ! Q
CK      S %GL=$P(%FN,".",1) I %GL'?1U.UN S %GL="" Q
        S %GL="^"_%GL_"(" F %X=2:1 S %Y=$P(%FN,".",%X) Q:%Y=""  S %GL=%GL_""""_%Y_""","
        Q
INIT    S %X=$E(%GL,1,$L(%GL)-1)_$S(%GL[",":")",1:"")
        S %Y=0 S:$D(@%X)#10 %Y=1_@%X K @%X S:%Y @%X=$E(%Y,2,999)
        S @(%GL_"0)")="0^0",^(1)="3,4,5,6,7,8,9,^10",^(2)="" Q
QUES    :Enter a text file name with optional modifiers, e.g.:
        :    MYFILE    JACK.REPORT.1    GENESIS.III
