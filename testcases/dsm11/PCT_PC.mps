%PC     ;2-Dec-81 ;UTILITY ;PROGRAM MAINTENANCE ;BATCH PROGRAM COMPILE ;JHM
        U 0 W !,"PROGRAM COMPILE"
Q1      K LIB D ^%PSEL Q:'%GO
Q2      K LIB
        W !,"MACRO(S) <COM> " R MAC
        I MAC="^"!($ZB#256=27) G Q1
        I MAC="?" D MACH G Q2
        S ERR=0
        S I=-1 F J=1:1 S C=$P(MAC,",",J) Q:C=""  S:C?1U.NU LIB(J)=C I C'?1U.NU!($L(C)>3) D NOTM S ERR=1 Q
        I ERR G Q2
        S LIB(J)="COM"
        W !,"Macro libraries selected: "
        S A=-1 F I=0:0 S A=$N(LIB(A)) Q:A<0  W !,LIB(A)
        S %CT=0,PNAM=0,PCFLG=""
        U 0 W !,"Compiling programs: ",!
NR      S PNAM=$N(^UTILITY($J,PNAM)) I PNAM<0 G EXIT
        W:'(%CT#4) ! W ?(%CT#4*20),PNAM S %CT=%CT+1
        S FILE="SRC$:"_PNAM G ^%PCOMP
PCRETN  I BD S %CT=0
        G NR
NOTM    U 0 W !,"Invalid macro name : ",C Q
NOTS    U 0 W !,"Invalid source type : ",PN Q
MACH    U 0 W !,"Enter the macro library name (extension) of each library"
        U 0 W !,"you wish to have searched separated by commas in the order"
        U 0 W !,"in which you want to have them searched.  NOTE: "
        U 0 W !,"The COM library will always be included last by default."
        Q
EXIT    K PNAM,LIB,CL,MAC,FL,%CT
        Q
