RTHIST  W !!,"System performance statistics:",!!
        W "1. Log data",!!,"2. Print reports",!!,"3. Show help text",!!
        R "Option > ",ANS,! I ANS="^"!(ANS="") Q
        D @$S(ANS=1:"START",ANS=2:"^RTHISTP",ANS=3:"^RTHELP",1:"ERROR")
        G RTHIST
ERR     U 0 I $D(%IOD),%IOD'=$I C %IOD
        W !,"Unexpected error -- ",$ZE,! Q
ERROR   W ?5,"not valid" Q
START   S ST=$V(44)
        I $V(ST+278) W !,"Statistics logging already in progress.",! G RTHIST
        S RTHIST1=$P(^ ("RTHIST1"),",",3)+1024+63\64*64
        S SZ=$V(2*($J-($J>63*128))+$V(ST+6))
        S MM=SZ\16*16,SZ=SZ#16*1024
        S MM=RTHIST1\64+MM
        S SZ=SZ-RTHIST1-1024
        I SZ<1024 W !,"PARTITION TOO SMALL, MUST BE AT LEAST ",RTHIST1+2048," BYTES",! Q
        I SZ>8192 S SZ=8192
        W !!,"LOG SYSTEM PERFORMANCE STATISTICS",!
TIMS    W !,"How many logging sessions do you wish <1> ? " R TIMS I TIMS="" S TIMS=1
        I TIMS="^" Q
        I TIMS'?.N!('TIMS) W !?5,"Enter a positive integer.",! G TIMS
TIM     W !,"How long, in minutes, do you wish each logging session to last ? "
        R TIM I TIM="^" G TIMS
        S TIM=+TIM I TIM'>0!(TIM>480) W !?5,"Enter a time of up to 480 minutes.",! G TIM
        S SUB=0 F I=1:1 Q:$O(^RTH(SUB))=""  S SUB=$O(^RTH(SUB))
LAB     W !,"Enter Label field: " R LAB,! G:LAB="^" TIM
        I LAB="?" W !,"The label field will be printed with the histogram report at the top.",!,"Press <RETURN> if you do not want a
label field.",! G LAB
        W !,"The first session will be filed as #",SUB+1
READY   R !,"Ready to proceed <Y> ",ANS G:ANS="^"!(ANS="N") LAB I ANS'="",ANS'="Y" G READY
        S CONF=$ZV_", "_^SYS(0,"RUNNING")
        W !!,"Job #",$J," now detaching from terminal and running as background job."
        W !,"Node ^RTH holds in-progress session number, or zero if done."
        W !,"Set ^RTH=0 to signal the statistics logger to stop after its next session."
        W !,"Exit",! C $I G START^RTHIST1
