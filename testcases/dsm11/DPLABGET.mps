DPLABGET        ;
        U 0 W !,"To inspect or modify a disk's label, type:    D ^LABEL",!
QUIT    Q
COPENT  ;
TAPENT  ;
DISKENT D START I '%ER S $ZT=%LABEL X %LOAD
        W !,"Can't read block 0 of ",DDU," installation aborted.",!
H       B 0 G H
START   C 63 O 63:2:1 E  W !,"Waiting for VIEW buffer..." O 63:2 W "got it!,",!
        U 63:(1:1),0
        S OF=512,BOF=OF,MPOF=OF+300,VEROF=OF+370,IDOF=OF+472
        D READZE I %ER G DONE
        I '%UPG S (%LB,MLB,DA,DAB,MTY)="" G DONE
        S OF=VEROF,S="VER",SZ=16 D GET
        S OF=MPOF+2,S="MB",SZ=1 D GET
        S OF=OF+1
        S S="%LB",SZ=22 D GET
        S S="MLB" D GET
        S S="DA",SZ=9 D GET
        S S="DAB" D GET
        S VN=$V(OF+2,0)#256,S="MTY",SZ=2 D GET S:'VN MLB=""
        I %UPG=3 S CODE=$V(BOF+392,0) S OF=BOF+394,SZ=3 D GET S VOLNAM=S
DONE    K SZ,S,F,NOT Q
GET     S @S=""
        F J=0:1:SZ-1 S CH=$V(OF+J,0)#128 Q:'CH  S @(S_"="_S_"_$C(CH)")
        S OF=OF+SZ Q
READZE  S %ER=0,NOT=0
RD1     B 0 U 63:(::"TZ") V 0:DDU I $ZA\64#2
        U 63:(::"C"),0 E  B 1 Q
        S NOT=NOT+1 G RD1:NOT<10 S %ER=1 B 1 Q
LBLBB   ;
LBLMAP  ;
