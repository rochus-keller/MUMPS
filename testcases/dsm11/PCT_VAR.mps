%VAR    ;22-Apr-84 ;UTILITIES ;DEBUGGING AIDS ;GET SYMTAB FROM ANOTHER JOB ;JBH
        G ASK
O       S P=P+1 F A=0:1:L S L(A)=L(A)-1
        Q
LEV     S L=L+1 I L>1 S N=N_$S(L=2:"(""",1:",""")
        S L(L)=$V(P,J) D O,O
        S X=$V(P,J)#256 F I=1:1:X#128 D O S N=N_$C($V(P,J)#256)
        I L>1 S N=N_""""
        S N(L)=N
        D O I X>127 D:P#2 O G LEV
        S X=$V(P,J)#256 D O S Z=$V(P,J)#256
        S D="" F I=1:1:Z D O S D=D_$C($V(P,J)#256)
        S S=N_$S(L=1:"",1:")"),^(S)=D
        F I=1:1:X-Z+2 D O
        I P#2 D O
        I L(L) G LEV
        F I=1:1 S L=L-1,N=N(L) G:L(L) LEV I 'L Q
CLRJOB  V ST+74::$V(ST+74)#256 Q
SET     ;
        K  S %ARDVARK="" F %APTERYX=1:1 S %ARDVARK=$O(^(%ARDVARK)) Q:%ARDVARK=""  S @%ARDVARK=^(%ARDVARK)
        K %ARDVARK,%APTERYX Q
ASK     W !!,"Load symbol table from another job into this partition:",!
ASK1    R !!,"Job number: ",%JN Q:%JN=""  I %JN="?" W "Enter $J of any running job" G ASK1
        I %JN'?1.2N W "  not a valid job number" G ASK1
        I %JN=$J W "  that's your own job number",! G ASK1
        D ENT G SET
ENT     S J=%JN,ST=$V(44),$ZT="CLKJOB^%VAR"
        V ST+74::$J*512+($V(ST+74)#256)
        S SBEG=$V(138,J)-40960,PTOP=$V(396,J)-40960
        I SBEG<0!(SBEG>16382) W " not a running job" G CLRJOB
        H 1 I $V(SBEG,J)'=43690 W "  partition changing too fast, can't load" G CLRJOB
        S L=0,N="",N(0)=N K ^UTILITY($J,"%VAR",%JN) I $D(^(%JN,0))
        S P=SBEG+2,L(0)=PTOP-P I 'L(0) W "  symbol table is empty" G CLRJOB
        G LEV
