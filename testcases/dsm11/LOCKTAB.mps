LOCKTAB ;FDN;13-JUN-80;DISPLAY LOCK TABLE
        S SYSTAB=$V(44),LCKTAB=$V(SYSTAB+64)
        W !!,"Contents of Lock Table (",$V(SYSTAB+66)," bytes allocated)"
        I '$V(0,LCKTAB)#8192 W !,"The Lock Table is empty.",! G EXIT
        W !!,"      Owner   Owner     Reference    Reference"
        W !,"Mode  Job #   Node       UCI,VOL      Name",!
        S (ENTRY,FREE)=0
NEXT    I '$V(ENTRY,LCKTAB) W ! G DONE
        S NEXT=ENTRY+4,JOB=$V(NEXT,LCKTAB)#256\2 I 'JOB G FREE
        I $V(ENTRY+2,LCKTAB)=0 S NOD=$P($ZU(1,0),",",2)
        E  S N=$V(ENTRY+2,LCKTAB),NOD=$C(N\2048#32+64)_$C(N\64#32+64)_$C(N\2#32+64)
        S COUNT=$V(NEXT+2,LCKTAB)#128,TYPE=$V(NEXT+2,LCKTAB)\128#2
        S MODE="LOCK" I $V(NEXT+1,LCKTAB)#2 S MODE="ZA"
        S UCI="",SYS="",NEXT=NEXT+3 D:TYPE GLOBAL
        W !,MODE,?4,$J(JOB,5),"     ",NOD,"        ",UCI,",",SYS,"       ",$S('TYPE:" ",TYPE:"^")
        S NAM=$V(NEXT,LCKTAB)#256
        F I=1:1:NAM W $C($V(NEXT+I,LCKTAB)#256)
        S COUNT=COUNT-NAM-1 G:'COUNT ENTRY
        W "(" S NEXT=NEXT+NAM+1,SUB=$V(NEXT,LCKTAB)#256
SUB     F I=1:1:SUB W $C($V(NEXT+I,LCKTAB)#256)
        S COUNT=COUNT-SUB-1
        I 'COUNT W ")" G ENTRY
        W "," S NEXT=NEXT+SUB+1,SUB=$V(NEXT,LCKTAB)#256
        G SUB
FREE    S FREE=$V(ENTRY,LCKTAB)#8192-ENTRY+FREE
ENTRY   S ENTRY=$V(ENTRY,LCKTAB)#8192 G NEXT
GLOBAL  ;
        S UCI=$V(NEXT+1,LCKTAB)#256*256+($V(NEXT,LCKTAB)#256)
        S SYS=$V(NEXT+3,LCKTAB)#256*256+($V(NEXT+2,LCKTAB)#256)
        I SYS S UCI=$C(UCI\2048+64,UCI\64#32+64,UCI\2#32+64),SYS=$S('SYS:"",SYS:$C(SYS\2048+64,SYS\64#32+64,SYS\2#32+64))
        E  D GETUCN
        S NEXT=NEXT+4,COUNT=COUNT-4
        Q
DONE    W !,$V(SYSTAB+66)-ENTRY+FREE," bytes available",!
EXIT    K FREE,PREV,COUNT,ENTRY,I,JOB,LCKTAB,NAM,NEXT,SYS,SYSTAB,TYPE,UCI Q
GETUCN  S $ZT="NOUCN",UCI=$ZU(UCI#32,UCI\32),SYS=$P(UCI,",",2),UCI=$P(UCI,",",1) Q
NOUCN   I $ZE["NOUCI"!($ZE["NOSYS") S (SYS,UCI)="@@@" Q
        ZQ
