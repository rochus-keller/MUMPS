PEEK    ; MONITOR ANOTHER TERMINALS OUTPUT; RLW 4 MAR 80 ; COPYRIGHT DEC 1980
        S ST=$V(44),MAXTTY=$V(ST+462)#256
        W !,"<< Warning >>",!,"You should not monitor a device that runs at a higher speed than this one."
SHOW    R !!,"** Monitor device # > ",DEV G EXIT:DEV=""
        I DEV="?" D HELP G SHOW
        I DEV=$I!'(DEV=1!((DEV>2)&(DEV<20))!((DEV>63)&(DEV'>MAXTTY))) D IV G SHOW
        S DEVTAB=$V(ST+8) I $V(DEVTAB+DEV)#256=255 W !?5,*7,"Device not in system" G SHOW
        S I=$I D DDBADD G C
C       S LOC=$V(ST+426) F I=0:4 S LOCA=LOC+I Q:$V(LOCA)=(256*256-1)  Q:$V(LOCA)=0
        I $V(LOCA)'=0 U 0 W !?5,"** System surveillance table full **",! Q
        S ADD1=ADDR,I=DEV D DDBADD
        I $V(ADD1+6)\256\32#2=1 U 0 W !?5,"** Cannot monitor while being monitored **",! Q
        I $V(ADDR+6)\256\32#2=0 U 0 W ! V LOCA+2::ADD1,LOCA::ADDR,ADDR+6::$V(ADDR+6)+(32*256) B 0
        E  U 0 W !?5,"** Device is already under surveillance **",! Q
        R *X,! V ADDR+6::$V(ADDR+6)-(32*256),LOCA+2::0,LOCA::0 B 1 W !,"** Surveillance session ended. **" G SHOW
DDBADD  G MX:I>63 S ADDR=I-1*$V(ST+68)+$V(ST+10)+4 Q
MX      S ADDR=I-64*$V(ST+68)+$V(ST+20)+4 Q
IV      W !?5,*7,"Incorrect response - Enter '?' for more information" Q
HELP    W !?5,"Enter a valid terminal device number."
        W !?5,"The device must exist in the system, and cannot be your own device."
        W !,?5,"Strike any key to terminate the surveillance session.",! Q
EXIT    K ADD1,ADDR,DEV,DEVTAB,I,LOC,LOCA,X Q
