%RDX    ;6-Jul-83 ;UTILITY ;GENERAL UTILITIES ;EXTENDED ROUTINE DIRECTORY ;JHM
%EN     W !,"Extended Routine Directory" S %OUT="TRM,SC,LP"
%Q1     S %QTY=2,%DEF=0 D ^%IOS G DONE:'$D(%IOD)
        I %OUT'[%DTY W !,"Output device must be a terminal, printer, or console" G %Q1
        U 0 I %IOD'=$I W !,"Directory started: " D ^%T
        S %TD=12,%TT=24,%TS=36,%TB=53
        U %IOD S %FF=$S(%DTY="LP":"%HDR1",1:"NOP") D %HDR
        S %NAM=""
        F I=0:1 S %NAM=$O(^ (%NAM)) Q:%NAM=""  D:'($Y#58) @%FF D
        .S %NP="",%A=^(%NAM),%DT=+%A,%TM=$P(%A,",",2),%BYT=$P(%A,",",3),%BLK=$P(%A,",",4)
        .D CVT^%D S %NP="" D CVT^%T
        .W %NAM,?%TD,%DAT1,?%TT,%TIM1,?%TS,$J(%BYT,8),?%TB,$J(%BLK,8),!
        G DONE
%HDR1   W #
%HDR    W !!,?11,"Extended Routine Directory",?40 D ^%D,^%GUCI W !,?25,"of ",%UCI,?40 D ^%T W !
        W !,"Routine",?%TD,"Date",?%TT,"Time",?%TS,"Size (bytes)",?%TB,"Block Number"
        W !,"--------",?%TD,"----",?%TT,"----",?%TS,"-----------",?%TB,"----- ------",!!
NOP     Q
DONE    K %NAM,%TD,%DAT1,%TT,%TIM,%TS,%BYT,%BLK,%TB,%A,%DTY,%DEF,%OUT
        U 0 I $D(%IOD) C:%IOD'=$I %IOD K %IOD W !,"Directory completed: " D ^%T
        Q
