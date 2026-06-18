%EDIEDT ;9-Dec-81 ;UTILITY ;EDITOR ;EDITOR FUNCTIONS ;JEB
ADD     D INIT1 I $L(%L)+$L(%A)>255 S %E="LEN"
        E  S (^(%P),%L)=%L_%A D WRITE:%C="AP"
        Q
PF      ;
FIND    D INIT1,DOTS S %W="F"_%W
        F %I=1:1:%I Q:%E]""  F %T=0:0 D NEXT Q:%E]""  D @%W I %B D WRITIF Q
        Q
PL      ;
LOC     D INIT1,DOTS S %W="L"_%W,%B=0
        F %I=1:1:%I Q:%E]""  F %T=0:0 D NEXT:%B=0 Q:%E]""  D @%W I %B D WRITIF Q
        Q
CHNG    D INIT2,DOTS S %W="L"_%W,%U=$P(%L,"^",3,999)
        F %I=1:1:%I Q:%E]""  S %B=1 D @%W Q:'%B  D FIX,WRITIF:%E=""
        I '%B,%E="" S %E="NMAT"
        Q
FIX     S %G=$E(%U,0,%A),%H=$E(%U,%B,999) I $L(%G)+$L(%Z)+$L(%H)>245 S %E="LEN" Q
        S %B=$L(%G)+$L(%Z)+1,%U=%G_%Z_%H,(%L,^(%P))=$P(%L,"^",1,2)_"^"_%U Q
PA      S %I=99999
LC      D INIT2,DOTS S %W="L"_%W I %X="" S %E="ARG" Q
        S:'%P %I=%I-1 S:%P %P=$P(%L,"^",2),%L=^(%P)
        F %I=1:1:%I Q:%E]""  D NEXT Q:%E]""  D @%W I %B F %T=0:0 D FIX Q:%E]""  D @%W I '%B D WRITIF Q
        Q
SC      D INIT2,DOTS S %W="L"_%W
        S:%P %P=+%L,%L=^(%P)
        F %T=0:0 D NEXT Q:%E]""  D @%W I %B D FIX,WRITIF:%E="" Q
        I '%B,%E="" S %E="NMAT"
        Q
INIT1   S:%A?1" ".E %A=$E(%A,2,999)
        I %A="" R !,"String: ",%X Q
        S %X=%A Q
INIT2   S:%A?1" ".E %A=$E(%A,2,999)
        I %A="" R !,"Replace: ",%X," with: ",%Z Q
        S %Z=$E(%A,1),%X=$P(%A,%Z,2),%Z=$P(%A,%Z,3) Q
DOTS    S %W=$F(%X,"...") Q:'%W
        I %X="..." S %W=1 Q
        I %W=4 S %X=$E(%X,4,999),%W=2 Q
        I %W=($L(%X)+1) S %X=$E(%X,1,$L(%X)-3),%W=3 Q
        S %Y=$E(%X,%W,999),%X=$E(%X,1,%W-4),%W=4 Q
NEXT    I %L S %P=+%L,%L=^(%P),%U=$P(%L,"^",3,999),%B=1 Q
EOF     W !,"[EOF]" S %E=1 Q
WRITIF  Q:'%V
WRITE   W !,$P(%L,"^",3,999) Q
F0      S %B=$P(%U,%X,1)="" Q
F1      S %B=1 Q
F2      S %B=$F(%U,%X) Q
F3      S %B=$P(%U,%X,1)="" Q
F4      S %B=$P(%U,%X,1)=""&($F(%U,%Y,$L(%X)+1)) Q
L0      S %B=$F(%U,%X,%B),%A=%B-$L(%X)-1 Q
L1      S %B=$L(%U)+1,%A=0 Q
L2      S %B=$F(%U,%X,%B),%A=0 Q
L3      S %B=$F(%U,%X,%B) S:%B %A=%B-$L(%X)-1,%B=$L(%U)+1 Q
L4      S %B=$F(%U,%X,%B) S:%B %A=%B-$L(%X)-1,%B=$F(%U,%Y,%B) Q
