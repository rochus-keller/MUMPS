%HELPED ;22-Apr-85 ;DSM11 ;UTILITIES ;EDITOR FOR THE HELP GLOBAL ;RWB
        W !,"Help text is available - type H to get it."
        W !,"It will take awhile to load %HELP11 into a temporary variable ..."
        W !
        S %G="^%HELP11"
        S %N="^%TEMP"
        D ENT
        D T1
NEXT    R !,"*",%NC
        G:'(%NC?1A) BADC
        I "fuodrlmchixensbt"[%NC S %NC=$C($A(%NC)-32)
        I "FUODRLMCHIXENSBT"[%NC D @(%NC_"1") G:%NC="B" END G NEXT
BADC    W !,"INVALID COMMAND",! G NEXT
M1      R !,": ",%ST
        Q:'((%ST?1A1N)!(%ST?1A2N))
        S %RT=$E(%ST)
        I "fudrl"[%RT S %RT=$C($A(%RT)-32)
        I "UDRL"[%RT F %QT=1:1:$E(%ST,2,$L(%ST)) D @(%RT_"1")
        I "F"[%RT D F1 F %QT=2:1:$E(%ST,2,$L(%ST)) D F2
        Q
H1      D ^%HELPH
        Q
F1      ;
        I %I<2 W !,"CAN'T FORMAT AT THIS LEVEL" Q
        R !,"LEFT AND RIGHT MARGINS: ",%LM,"   : ",%RM
F2      S %RL=$P($P(%CURNODE,",",%I),")",1)
        Q:'(%RL?.N)  S %NXT=$P(%CURNODE,",",1,%I-1)_","_(%RL+1)_")"
        Q:$D(@%NXT)=0  Q:@%NXT=""  S %L=@%CURNODE D TRIM S @%CURNODE=%L
        S %L=@%NXT D TRIM D LEFTM
F3      I $L(@%CURNODE)>%RM G F4
        I $L(@%CURNODE)=%RM S @%NXT=%L G F10
        I $L(@%CURNODE)<%RM G F5
F4      F %P=1:1 Q:$L($P(@%CURNODE," ",1,%P))>%RM
        S %QQ=1 S %J="N" D O2
        S @%NXT=$P(@%CURNODE," ",%P,255) S @%CURNODE=$P(@%CURNODE," ",1,%P-1) G F6
F5      Q:%L=""
        F %P=1:1 Q:$P(%L," ",1)=""  Q:$L(@%CURNODE)+1+$L($P(%L," ",1))>%RM  D
        .S @%CURNODE=@%CURNODE_" "_$P(%L," ",1)
        .S %L=$P(%L," ",2,255)
        I %L="" S %QQ=1 S %J="Y" D O2 G F2
        S @%NXT=%L
F6      S %P=1 S %GG=". "
F7      I $L(@%CURNODE)=%RM G F10
        S %P=$F(@%CURNODE,%GG,%P) I (%P=0)&(%GG=", ") G FB
        I %P=0 S %GG=", " S %P=1 G F7
        S @%CURNODE=$E(@%CURNODE,1,%P-1)_" "_$E(@%CURNODE,%P,$L(@%CURNODE))
        G F7
FB      S %QQ=5
F8      S %QQ=%QQ-1 S %P=%LM+1 I %QQ'>0 G FB
F9      I $L(@%CURNODE)=%RM G F10
        S %P=$F(@%CURNODE," ",%P) I %P=0 G F8
        I %P#%QQ=0 S @%CURNODE=$E(@%CURNODE,1,%P-1)_" "_$E(@%CURNODE,%P,$L(@%CURNODE))
LP      I $E(@%CURNODE,%P)'=" " G ELP
        S %P=%P+1 G LP
ELP     G F9
LEFTM   F %P=1:1:%LM S @%CURNODE=" "_@%CURNODE
        Q
TRIM    F %P=1:1 Q:$E(%L,1)'=" "  S %L=$E(%L,2,$L(%L))
        F %P=1:1 Q:$E(%L,$L(%L))'=" "  S %L=$E(%L,1,$L(%L)-1)
FC      S %P=$F(%L,"  ",1) I %P'=0 S %L=$E(%L,1,%P-2)_$E(%L,%P,$L(%L)) G FC
        Q
F10     S %CURNODE=%NXT S %STACK(%I)=%CURNODE D LEFTM D E1
        Q
O1      R !,": ",%QQ
        R !,"DELETE? ",%J
        Q:%I<2
        Q:'(%QQ?.N)
O2      S %SS=$P($P(%CURNODE,",",%I),")",1)
        Q:'(%SS?.N)
        S %RR=$P(%CURNODE,",",1,%I-1)_","
        F %K=%SS+1:1 S %A=%RR_%K_")" Q:$D(@%A)=0
        S %K=%K-1
        G:(%J="Y")!(%J="y") O1DEL
        G:%K=%SS NEWFILL
        F %C=%K:-1:%SS+1 S @(%RR_(%C+%QQ)_")")=@(%RR_%C_")")
NEWFILL F %K=%SS+1:1:%QQ+%SS S @(%RR_%K_")")="X"
        G O1END
O1DEL   G:%K=%SS O1END
        F %C=%SS+1:1:%SS+%QQ K @(%RR_%C_")")
        F %C=%SS+%QQ+1:1 S %A=%RR_%C_")" Q:$D(@%A)=0  S @(%RR_(%C-%QQ)_")")=@%A K @%A
O1END   Q
U1      S:%I'=0 %I=%I-1
        S %CURNODE=%STACK(%I)
        D E1
        Q
D1      I %I=0 D  Q
        .S %TNODE=$ZO(^%TEMP(""))
        .I %TNODE'="" D
        ..S %I=%I+1
        ..S %STACK(%I)=%TNODE
        ..S %CURNODE=%TNODE
        .D E1 Q
        S %TNODE=$ZO(@%CURNODE)
        I $F(%CURNODE,",")=0 D  Q
        .I $F(%TNODE,",")'=0 D DOWNSTK Q
        .E  D E1 Q
        I $P($P(%TNODE,",",%I+1),")",1)'="" D DOWNSTK Q
        E  D E1 Q
DOWNSTK ;
        S %I=%I+1
        S %STACK(%I)=%TNODE
        S %CURNODE=%TNODE
        D E1
        Q
R1      I %I=0 D E1 Q
        S %TNODE=$O(@%CURNODE)
        I %TNODE'="" D
        .S:'(%TNODE?.N) %TNODE=""""_%TNODE_""""
        .I $F(%CURNODE,",")=0 S %CURNODE=$P(%CURNODE,"(",1)_"("_%TNODE_")"
        .E  S %CURNODE=$P(%CURNODE,",",1,%I-1)_","_%TNODE_")"
        S %STACK(%I)=%CURNODE
        D E1
        Q
L1      ;
        I %I=0 D E1 Q
        S %TNODE=%STACK(%I-1)
        I $F(%TNODE,",")=0 S %NXTNODE=$ZO(^%TEMP(""))
        E  S %NXTNODE=$ZO(@%TNODE)
        F K=0:0 Q:($P(%NXTNODE,",",%I+1)="")&($P(%NXTNODE,",",%I)'="")&($P(%NXTNODE,",",%I-1)=$P(%CURNODE,",",%I-1))  D
        .S %NXTNODE=$ZO(@%NXTNODE)
        I %NXTNODE=%CURNODE D E1 Q
        F K=0:0 Q:%NXTNODE=%CURNODE  D
        .S %TNODE=%NXTNODE
        .S %A=$O(@%TNODE)
        .S:'(%A?.N) %A=""""_%A_""""
        .I $F(%CURNODE,",")'=0 S %NXTNODE=$P(%CURNODE,",",1,%I-1)_","_%A_")"
        .E  S %NXTNODE=$P(%CURNODE,"(",1)_"("_%A_")"
        S %CURNODE=%TNODE S %STACK(%I)=%CURNODE D E1 Q
        Q
E1      W !,"NODE: ",%CURNODE,!,"CONTENTS: ",@%CURNODE
        Q
C1      ;
        R !,": ",%C
        I '(%C?.E1"??".E) W !,"TRY AGAIN" G C1
        S %SEP=$P(%C,"??",1)
        S @%CURNODE=$P(@%CURNODE,%SEP,1)_$P(%C,"??",2)_$P(@%CURNODE,%SEP,2,255)
        S:@%CURNODE="" @%CURNODE="X"
        W !,@%CURNODE
        Q
I1      R !,": ",%C
        S:%C="" %C="X"
        S @%CURNODE=%C
        Q
T1      S %I=0
        S %STACK(%I)="^%TEMP"
        S %CURNODE="^%TEMP"
        Q
X1      I %I=0 W !,"CAN'T KILL THE ENTIRE GLOBAL" Q
        S %A=$P($P(%CURNODE,",",%I),")",1)
        I (%A?.N)&(%I>1)&(%A'=1) W !,"USE ONE" Q
        W !,"KILL ",%CURNODE," ? " R %A
        I (%A'="Y")&(%A'="y") Q
        K @%CURNODE
        S %I=%I-1
        S %CURNODE=%STACK(%I)
        Q
N1      R !,": ",%A
        S:'(%A?.N) %A=""""_%A_""""
        S %NEWNODE=$E(%CURNODE,1,$L(%CURNODE)-1)_","_%A_")"
        W !,"NEW NODE WILL BE : ",%NEWNODE," OK? " R %A
        I (%A'="Y")&(%A'="y") Q
        R !,": ",%A
        S @%NEWNODE=%A
        S %I=%I+1
        S %STACK(%I)=%NEWNODE
        S %CURNODE=%NEWNODE
        Q
S1      S %G="^%TEMP"
        S %N="^%HELP11"
        K ^%HELP11
        D ENT
        Q
B1      K %G,%J,%QQ,%SS,%RR,K,%N,%NEWNODE,%CURNODE,%TNODE,%A,%I,%C,%SEP
        K %K,%STACK,%I,^%TEMP,%RJ,%RM,%RI,%RL,%H,%NXT,%P,%U,%LM,%ST,%RT,%QT,%GG,%T
        Q
ENT     S @%N=@%G
        S %G=%G_"("""")"
LOOP    S %G=$ZO(@%G) G:%G="" ENDGC
        S %X=%N_"("_$P(%G,"(",2,25)
        S @%X=@%G
        G LOOP
ENDGC   K %X
        Q
END     K %NC
        Q
