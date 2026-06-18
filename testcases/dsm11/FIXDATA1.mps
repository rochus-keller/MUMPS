FIXDATA1        ;ASSEMBLE, FIND GLOBAL REFERENCE IN BLOCK @SMB@
        -
G       K G W !,W R " Global ^",R Q:"^"[R  I R="?" D HELP G G
        G OFFSET:R?1"+".E S N=$P(R,"(",1) G ER:N'=GL
        S G=$L(N)+1 F I=1:1:$L(N) S X=I<$L(N),G(I+1)=$A(N,I)*2+X
        G FIND:R'["(" S R=$P(R,"(",2,999) G ER:$E(R,$L(R))'=")"
        K X S R=$E(R,1,$L(R)-1),L="",P=0,X(" ")=""
P       S C=$E(R,1),R=$E(R,2,999) I ","[C,'P G S
        G ER:C="" S L=L_C
        I C="""" S I=$F(R,C) G ER:'I S L=L_$E(R,1,I-1),R=$E(R,I,999) G P
        I C="(" S P=P+1 G P
        G P:C'=")" S P=P-1 G ER:P<0,P
        -
HELP1   W " Enter a valid routine name, please." Q
        -
S       S @("L="_L) G ER:L="",ER:$L(L)>32 I $V(1021,0)\128#2 D EIGHTB G NT
        I NUMCOL,$N(X(L))=" ",L'=-1 S G=G+1,G(G)=$S(L:$L($P(L,".",1))*2+1,1:1)
        F I=1:1:$L(L) S G=G+1,G(G)=I<$L(L)+($A(L,I)*2)
NT      S L="" G P:C]""
FIND    S (P,R)=0,O=$V(1022,0),R1=2
F1      S BYT=P,L=R1 G NF:P'<O S R=$V(P,0)#256,U=$V(P+1,0)#256
        G F3:R+2>R1 I R+2<R1 S R1=R+2 G NF
        S X=P-R,A=R+1+U
F2      S C=$V(X+R1,0)#256 G NF:C>G(R1),F3:C<G(R1) S R1=R1+1
        I R1>G G NF:R1'>A G FOUND
        G F2:R1'>A
F3      S P=P+U+2,P=P+($V(P,0)#256+1) G F1
        -
NF      I W'="Insert" W " Not found" G G
        S R2=R1-2,R1=L-2 Q
FOUND   I W="Insert" W " Already in block" G G
        Q
        -
HELP    W !,"Type in a full global reference, all full of quotes, commas, and parens."
        Q:W="Insert"
        W !,"Or, type + followed by the address in the block where the global starts"
        W !,"(the number printed by the display option)"
        Q
DIS     S BYT=1018,O=$V(1022,0) D GETPTR
        W !!,"BLOCK ",BLK,":",STRNO,!!,"OFFSET: ",O,?25,"RIGHT LINK POINTER: ",PTR,":",STRNO
        S (P,A)=0
DIS1    W !,$J(P,4),": " G Q:P=O I P>O W !,"Illegal offset!! Should be ",P,"." G Q
        S BYT=P,R=$V(P,0)#256,U=$V(P+1,0)#256
        S A=R+U+1,X=P-R,P=P+U+2 F I=R+2:1:A S A(I)=$V(X+I,0)#256
        S (L,F)=0 I $V(1021,0)\128#2 D WRT
        E  F I=2:1:A D W
        W " = """ F I=1:1:$V(P,0)#256 S P=P+1,X=$V(P,0)#256 D W1
        W """" S P=P+1 G DIS1
        -
W1      I X=34 W """""" Q
        I X>31 W $C(X) Q
        W """_$C(",X,")_""" Q
        -
W       S:'$D(A(I)) A(I)=127 I A(I)<64!(A(I)>253) Q:A(I)<64&'F  S F=1 W """_$C(",A(I)\2,")"
        E  W:F=1 "_""" S F=2 W *A(I)\2 W:A(I)\2=34 """"
        Q:A(I)#2  W:F-1&L """" I A=I W:L ")" Q
        S F=0 I L W ",""" Q
        S L=1 W "(""" Q
        -
WRT     F I=2:1 W $C(A(I)\2) Q:'(A(I)#2)
        Q:I'<A  W "("""
G1      S I=I+1,NEGSUB=0 I (A(I)'<2)&(A(I)'>127) S NEGSUB=1 W "-"
G2      S I=I+1 I NEGSUB I A(I)=254 S I=I+1
        I I'<A W """)" Q
        I 'A(I) W """,""" G G1
        I 'NEGSUB!($C(A(I))=".") W $C(A(I)) G G2
        W (9-$C(A(I))) G G2
GETPTR  I BYT#2 S PTR=$V(BYT+1,0)*256+($V(BYT,0)#256) Q
        S PTR=$V(BYT+2,0)#256*65536+$V(BYT,0) Q
        -
ER      W *7," ??" G G
        -
OFFSET  G ER:W="Insert" S O=$V(1022,0),R=$E(R,2,999) G ER:+R'=R,ER:R'<O,ER:R<0
        S G=R,P=0,A=0
O1      G NF:P'<O S BYT=P,R=$V(P,0)#256,U=$V(P+1,0)#256
        S A=R+U+1,X=P-R,P=P+U+2,P=P+($V(P,0)#256+1) F I=R+2:1:A S A(I)=$V(X+I,0)#256
        G O1:BYT<G,NF:BYT>G S (L,F)=0 W " "
        I $V(1021,0)\128#2 D WRT
        E  F I=2:1:A D W
        F I=2:1:A S G(I)=A(I)
Q       K A Q
EIGHTB  I 'NUMCOL S PREFIX=254 G SET
        I L?1"-"1N.N!(L?1"-".N1".".N) D NEGSUB Q
        I L'?.N&(L'?.N1".".N) S PREFIX=254 G SET
        I $E(L)=0 S PREFIX=254 G SET
        S PREFIX=129+$L($P(L,".",1)) S:L=0 PREFIX=128
SET     S G=G+1,G(G)=PREFIX F I=1:1:$L(L) S G=G+1,G(G)=$A(L,I)
        S G=G+1,G(G)=0 Q
NEGSUB  S L=$E(L,2,999),G=G+1,G(G)=127-$L($P(L,".",1))
        F I=1:1:$L(L) S G=G+1,CR=$E(L,I),G(G)=$A(9-CR) S:CR="." G(G)=$A(CR)
        S G(G+1)=254,G(G+2)=0,G=G+2 Q
