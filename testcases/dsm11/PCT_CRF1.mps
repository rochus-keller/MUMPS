%CRF1   ;Parse routine lines : JEC ; 6-Jun-79  9:41 AM
        S A=0,Q=$C(34)
A1      S A=A+1,(U,M,P)=0 I $D(^UTILITY("CRF",%JB,%I,A)) S L=^(A),H=$F(L," ",1),W=0 D SB G A1
        K A,B,C,E,F,G,H,I,K,L,M,O,P,Q,R,S,T,U,V,W,X,Z
END     Q
SB      F I=1:1 Q:$E(L,H)'="."  S H=H+1
SB1     S X=$E(L,H),R=$E(L,H,H+2),H=H+1 G SB1:X=" " Q:X=";"!(X="")!(X'?1A)  F H=H:1 Q:$E(L,H)'?1A
        I $E(L,H)=":" S (F,Y)=1,M=X,(S,O,X,E)=0 S:M="X"&($E(L,H+1)'=Q) Y=0 D T3 S X=M,M=0
        G SB1:"Q"[X S B="WR"[X,G="BCFHIJKLNORSUVWX"[X,K="FKNORS"[X*2,M=X I X="V" S ^UTILITY("CRF1",%JB,%I,0,"VIEW")=""
        I (R="ZS ")!(R="ZL ")!(R="D ^")!(R="G ^") S G=G+4,K=(R="ZS "*4)+(R="ZL "*8)+(R="G ^"*16)+(R="D ^"*32)
        I R["ZJ" S G=4,K=64,X=$E(L,H+1,H+20),X=$P(X,"^",1) I X?1AN.AN S H=H+$L(X)
        S Y=1 I M="X",$E(L,H+1)'=Q S Y=0
S1      I M="D"!(M="G") S (G,K)=0,X=$E(L,H+1,H+20),X=$P(X,"^",1) I $E(L,H+1)="^"!(X?1AN.AN) S G=4,K=$S(M="D":32,1:16) S:X?1AN.AN H=H+$L(X)
S2      S O=B,F=G,S=K,(E,X)=0 I $E(L,H+1)'="@" D T2 G S3
        S E=H+1,F=1,(S,O)=0 D T2 S X=(R="D ^")!(R="G ^")!'G+G
        F O=1,4 I X=O!(X=5) S Z=M S:Z="Z" Z=$E(R,1,2) S IND=Z_" "_$E(L,E,H-1) S ^UTILITY("CRF1",%JB,%I,O,$E(IND,1,63))=IND
S3      G SB1:" ;"[C,S1
T1      G Q1:C=Q,W1:C?1A!(C="%"),N1:C?1N,F1:C="$",G1:C="^"
        I C="." F H=H+1:1 I $E(L,H)'?1A S C="?",O=0,H=H-1 Q
        G:'O V1:C="?" S:C="+"&'F F=1 S X=0 S:C=":" F=1
        I C="(" S:M="K"!(M="L")!(M="N") (K,S)=0 G T2:M="K"!(M="L")!(M="N") D T2 S X=1 S:"S"[M X=0
        G T2:C'="@"!E F J=H:-1:1 Q:$E(L,J)=" "
        F D=H:1:255 Q:$E(L,D)=" "
        S Z=M S:Z="Z" Z=$E(R,1,2) S IND=Z_" "_$E(L,J+1,D-1),^UTILITY("CRF1",%JB,%I,1,$E(IND,1,63))=IND
T2      S H=H+1
T3      S C=$E(L,H) G T1+X:" ),;"'[C&'P Q
Q1      I W,$E(L,H+1)'=Q S W=0,H=H+1,C=" " Q
        I Y,"X"[M S W=1,H=H+1,C=" " Q
Q2      D Q4 I W,$E(L,H-1)=Q,$E(L,H-2)=Q D Q4 I $E(L,H)=Q S H=H+1
        I $E(L,H)=Q,$E(L,H-1)=Q D Q4 G Q2:$E(L,H)=Q
Q3      S X=1,O=0 G T3
Q4      F H=H+1:1:255 Q:$E(L,H)=Q
        S H=H+1 Q
W1      S C=H D C1 S T="" I F=1 S T=$E(L,H)="("*3+1,T=T*S+T,S=0,T=$S(T=1:"V",T=3:"VS",T=4:"A",T=12:"AS",1:"")
        I F=4 S T=$S(R="ZS ":"PF",R="ZL ":"PL",R="G ^":"PO",R="D ^":"PC",R="ZJ ":"PJ",1:""),S=0,R=""
        D P1:T'="" G Q3:T'["A" S U=U+1,U(U)=P,P=0
W2      S X=0 D T2 G W2:")"'[C S P=U(U),U=U-1,X=1 G T2
N1      F H=H+1:1:255 G Q3:$E(L,H)'?1N
F1      S T=H,P=$E(L,H+1) F H=H+1:1 Q:$E(L,H)'?1A
        I P="T" F H=H+1:1 G Q3:$E(L,H)'?1AN
        I P="V" S ^UTILITY("CRF1",%JB,%I,0,"$VIEW")=""
        G F3:$E(L,H)'="(" S P=P="P" I P S S=0,H=H+1,C=$E(L,H) D T1 S P=0
F2      S X=0 D T2 G F2:")"'[C S X=1 G T2
F3      S H=T,F=1 G W1
G1      S F=1,C=H S:$E(L,C+1)="%" C=C+1 D C1 S:C["^" C=$P(C,"^",2)
        S T=$S(S=0:"G",S=2:"GS",S=16:"PO",S=32:"PC",S=64:"PJ",1:"")
        D P1:C'="" S S=0 G Q3:$E(L,H)'="(",F2:C'="" S ^UTILITY("CRF1",%JB,%I,0,"NAKED")="" G F2
C1      F H=C+1:1 Q:$E(L,H)'?1AN
        S C=$E(L,C,H-1) Q
V1      F H=H+1:1:255 D Q4:$E(L,H)=Q G Q3:$E(L,H)'?1AN,Q3:$E(L,H)="."
P1      Q:C'?1AP.E  S V="" I '$D(^UTILITY("CRF1",%JB,%I,C)) S ^UTILITY("CRF1",%JB,%I,C)=T Q
        S V=^UTILITY("CRF1",%JB,%I,C) I V="",T'="" S ^UTILITY("CRF1",%JB,%I,C)=T Q
        I V'="",T="" S ^UTILITY("CRF1",%JB,%I,C)=V Q
        I V'[T S ^UTILITY("CRF1",%JB,%I,C)=V_T
        Q
Z       P %CRF1 ZS %CRF1
