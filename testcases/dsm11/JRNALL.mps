JRNALL  ;ALLOCATE SPACE FOR JOURNALLING (DISK ONLY)
GETNM   S QUES="NAMQ",DEF="" X ^%Q("ASK") G:ANS=""!%A EXIT
        I $L(ANS)>12!(ANS'?1A.ANP) D NAMQH G GETNM
        S JNAM=ANS D NOMSG^JRNLSHOW
        F I=1:1:ND I ^SYS(0,"JOURNAL SPACE",ND(I),"NAME")=JNAM G ALRED
        S FUNC="JOURNAL" D ALLOC^ALLOCAT I MAP=-1 G EXIT
        S ANS=JNAM_$C(0)_$C(0) V MAP*400+399:DDU
        F I=0:2:$L(JNAM) V 990+I:0:$A(ANS,I+2)*256+$A(ANS,I+1)
        V -(MAP*400+399):DDU S ^SYS(0,"JOURNAL SPACE",INX,"NAME")=JNAM
        D INIT^JRNINIT G EXIT
EXIT    K INX,ST,ND,J,I,FUNC,MAPBLK,ANS,JNAM
        Q
NAMQ    W !,"What would you like the name of this JOURNAL space to be" Q
NAMQH   W !,"Enter up to 12 characters, beginning with an alphabetic, A-Z "
        W " (no quotes).",!
        W "This is the name by which you will hereafter refer to this Journal "
        W "space.",! Q
ALRED   W !,"** A JOURNAL space named  '",JNAM,"'  already exists.",! G GETNM
