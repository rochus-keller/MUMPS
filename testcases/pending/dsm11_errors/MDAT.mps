MDAT    ;RLW; SET UP ^SYS(ID) WITH DATE AND TIME AND OPERATOR INITIALS FOR LAST UPDATE
        I '$D(ID) W !?5,*7,"This is not an interactive subroutine.",!,*7 Q
DATE    I +$H<1000 D ^DAT,STARTUP^TIM
        D INT^%D,INT^%T
        S ^SYS(ID,"ALTERED","DATE")=%DAT1,^("TIME")=%TIM
BY      W !!,"Please enter your initials > " R BY
        G:BY="^" DATE I BY="?" D HLP3 G BY
        I $L(BY)<2!($L(BY)>22) D IV G BY
        I BY'?.U D IV G BY
        S ^SYS(ID,"ALTERED","BY")=BY
COMMENT W !!,"Enter comment (max. 200 chars.) > " R COMMENT I $L(COMMENT)>200 D IV G COMMENT
        G:COMMENT="^" BY I COMMENT="?" W !?5,"Enter free text.  Cannot exceed 200 characters in length.",!?5,"Enter <CR> for no comm
ent, ^ to return to previous question." G COMMENT
        F I=1:1 I '($D(^SYS(ID,"ALTERED","COMMENT",I))) S ^(I)=COMMENT_";"_%DAT1_";"_%TIM_";"_BY Q
EXIT    K %DAT,%DAT1,%TIM,%TIM1,BY,COMMENT,I B 1 Q
IV      W !?5,*7,"Incorrect response - Enter '?' for more information" Q
HLP3    W !?5,*7,"Enter your initials.  Response must be upper case alpha characters,"
        W !?5,"2-22 characters in length." Q
