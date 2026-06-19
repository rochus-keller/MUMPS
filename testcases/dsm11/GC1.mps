GC1     ;22-Jul-83 ;UTILITIES ;GLOBALS ;PART 2 OF GLOBAL COPY UTILITY ;JHM
        W !,"This routine should be called from ^GC",! Q
START   D ^%GSEL G:'$D(%GO) EXIT W ! S GL="" I $O(^UTILITY($J,GL))="" G EXIT
        W !,"Global copy started: " D ^%T
GET     S GL=$O(^UTILITY($J,GL)) G:GL="" DONE S GLSUB=^(GL)
        S GLREF="^["_""""_FUCI_""""_","_""""_FSYS_""""_"]"_GL
        I GLSUB'="" S I=1 S:$E(GLSUB,$L(GLSUB)-1)="," I=2 S GLREF=GLREF_"("_$E(GLSUB,1,$L(GLSUB)-I)_")"
        S X=$D(@GLREF),INREF=$ZR
        S OUTREF="^["_""""_TUCI_""""_","_""""_TSYS_""""_"]"
        W !!,"Copying ",INREF," to ",TUCI,",",TSYS,! S J="]"
        I $E(INREF,2)'="[" S J="^"
        S $ZT="OUTERR" I $D(@INREF)
        S $ZT="INERR" I $D(@(OUTREF_GL))
        S $ZT="COPERR"
        I $E(INREF,$L(INREF))=")" G SUBTRE
ALLG    I $D(@INREF)#10 S @(OUTREF_GL)=@$ZR
        S INREF=INREF_"("""")"
        F I=1:1 S INREF=$ZO(@INREF) Q:INREF=""  S @(OUTREF_$E(INREF,$F(INREF,J),$L(INREF)))=@INREF W:%LIST !,INREF
        G GET
SUBTRE  I $D(@INREF)#10 S @(OUTREF_$E(INREF,$F(INREF,J),$L(INREF)))=@$ZR
        S MAXREF=$E(INREF,1,$L(INREF)-1)_","
        F I=1:1 S INREF=$ZO(@INREF) Q:$E(INREF,1,$L(MAXREF))'=MAXREF  S @(OUTREF_$E(INREF,$F(INREF,J),$L(INREF)))=@$ZR W:%LIST !,INREF
        G GET
OUTERR  W !,"Error referencing global for output" G ZQ
INERR   W !,"Error referencing global for input" G ZQ
COPERR  W !,"Error while copying global"
ZQ      S GL=$ZR ZQ
DONE    W !,"Global copy completed: " D ^%T
EXIT    K INREF,GLREF,X,OUTREF Q
