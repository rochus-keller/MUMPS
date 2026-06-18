BCS     ; GEF ; DSM UTILITIES ; BROADCASTER
        S ST=$V(44),DEVT=$V(ST+8),MAXTTY=$V(ST+462)#256
GETM    R !,"Enter message > ",X I X=""!(X="^") Q
        I X="?" W " Enter up to 255 characters of free text.",! G GETM
        S MSG=X
ASK     R !,"Output to terminal(s) ? > ",X I X=""!(X="^") G GETM
        S (TRM,TRMN)=0,ALL=1 I X?1N.NP S TRM=1 G TRM
        I X="?" W !,?5,"Enter terminal numbers separated by commas,",!?5,"or 'ALL' to broadcast to all terminals",! G ASK
        I X'="ALL" D IV G ASK
ALL     S TRMN=TRMN+1
        I "2,20"[TRMN S TRMN=$S(TRMN=2:3,1:63) G ALL
        I TRMN>MAXTTY G GETM
        I TRMN=$V($V(ST+230)) G ALL
        G OUT
TRM     S SW=0 F I=1:1 Q:$P(X,",",I,999)=""  S T=$P(X,",",I) I T'=1&(T<4!(T>19))&(T<64!(T>MAXTTY)) S SW=1 Q
        I SW D IV G ASK
        S T=0,IN=X
T1      S T=T+1,TRMN=$P(IN,",",T) I TRMN="" G ASK
OUT     S DEV=$V(DEVT+TRMN)#256 I DEV=255 G RET
        ZU TRMN G:$ZA\2#2!($ZA\8192#2) RET ZU TRMN:(:::::32) W *7,!!,MSG,!!
RET     U 0 I TRM G T1
        G ALL
IV      W !,?5,"Incorrect response - Enter '?' for more information" Q
EXIT    K ALL,DEV,DEVT,I,IN,MSG,SW,T,TRM,TRMN,X W ! Q
