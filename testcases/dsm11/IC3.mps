IC3     ;CHECK ROUTINE DIRECTORY @SMB@
        D INIT Q:ER]""
LEV     S B=L(LEV),PE=L(LEV-1),T=2 S:LEV=1 T=16 S:LEV=2 T=6
B       S M=0 C 63 H 0 O 63:(3:1:1) V B:STRNO
        S C=0,A=$V(1,0)+1 F I=2:1:A S A(I)=$V(I,0)#256
        S C=A+1,O=$V(1022,0)
P       I C#2 S L=$V(C+1,0)*256+$V(C,0)
        E  S L=$V(C+2,0)#256*65536+$V(C,0)
        I LEV>1,L'=PE D PER
P1      S P=L U 63:(2:1) V P:STRNO I $V(1021,0)#128'=T G M1:LEV=1&(A=2) D TYER
        I LEV>1 S PE=$V(1020,0)#256*65536+$V(1018,0)
        I $V(0,0)#256 D NER
        I $V(1,0)+1'=A D NER
        F I=2:1:A I $V(I,0)#256'=A(I) D NER Q
M       U 63:(3:1) I P<S!(P>M) S M=P\400*400+399,S=M-399 V M:STRNO
        I $V(P-S*2,0)#256#90'=UCI D MER
M1      U 63:(1:1) S C=C+3 G:C'<O NX S R=$V(C,0)#256,U=$V(C+1,0)#256
        I R<GL!(R'<A) D RER
        I 'U D UER
        I R+1<A,$V(C+2,0)#256'>A(R+2) D COLER
        S A=R+U+1,X=C-R F I=R+2:1:A S A(I)=$V(X+I,0)#256
        S C=C+U+2 G P
NX      I C'=O D OER
        S OLD=B,B=$V(1020,0)#256*65536+$V(1018,0) G B:B
        S LEV=LEV-1 G LEV:LEV C 63 Q
        -
INIT    C 63 O 63:(3) S G=" ",A(0)=0,A(1)=$L(G) F I=1:1:$L(G)-1 S A(I+1)=$A(G,I)*2+1
        K T S T=0,$ZE="TRAP^IC4",B=0,ER="",A($L(G)+1)=$A(G,$L(G))*2
INIT1   V P:STRNO S T(T)=P F I=0:1:$L(G)+1 I $V(I,0)#256'=A(I) G INITER1
        S X=$V(1021,0)#128 I B G INIT2:X=16 G INITER
        I X'=2 G INITER:X'=6 S B=1
        S T=T+1,P=$V(I+3,0)#256*256+($V(I+2,0)#256)*256+($V(I+1,0)#256) G INIT1
        -
INIT2   S DEP=T F I=0:1:DEP S L(I)=T(T-I)
        K T S LEV=DEP,GL=$L(G),M=0,S=0,OLD=0 Q
TYER    S ER="Block type: expected "_T_" t "_($V(1021,0)#128) G ERP
PER     S ER="Right pointer: expected "_L_" got "_PE G ERP
MER     I $V(P-S*2,0) S ER="Illegal map block entry "_$V(P-S*2,0) G ERP
        S ER="In structure and free" G PER
RER     S ER="Bad repeat count" G ER
UER     S ER="Unique char. count=0" G ERB
COLER   S ER="Collating sequence out of order" G ERB
OER     S ER="Bad offset" G ERB
NER     S ER="Bad first node" G ERP
INITER  S ER="Bad block type on left edge" G ERP
INITER1 S ER="Bad left edge node" G ERP
        -
ERP     I ER["left edge" S ER="ERROR in block "_P_": "_ER G ER
        S ER="ERROR in block "_P_" (pointed to by "_B_"): "_ER G ER
ERB     S ER="ERROR in block "_B_" on node at byte "_C_": "_ER
ER      S ^IC=^IC+1,^IC(^IC)=ER Q
