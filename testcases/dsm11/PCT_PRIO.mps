%PRIO   ;20-Apr-84 ;UTILITY ;LIBRARY UTILITY ;CHANGE A JOB'S PRIORITY ;JHM
        ;; ENTER AT %PC WITH:
        ;;    %PRIO= priority value for job (0-3)
        ;;    %JOB= job number to change priority
        ;;
STRT    W !,"Change job Priority",!
Q1      S DEF="",QUES="JOB" X ^%Q("EN") G:ANS=""!%A EXIT
        I ANS'?1N.N D IV G Q1
        I ANS<1!(ANS>63) D IV G Q1
        I $V(0,ANS)="" W !,"Job #",ANS," is not logged in",! G Q1
        S %JOB=ANS
        W !,"Job #",%JOB,"'s current priority is ",$V(2,%JOB)\512#4,!
Q2      S DEF="",QUES="PRI" X ^%Q("EN") G:ANS=""!%A Q1
        I ANS'?1N.N D IV G Q2
        I ANS<0!(ANS>3) D IV G Q2
        S %PRIO=ANS D %PC W !," - priority changed ",! G Q1
IV      W !,"Invalid response - Type ? for more Help",! Q
EXIT    K %PRIO,%JOB,ANS,QUES Q
%PC     Q:%JOB'?1N.N  I %JOB<1!(%JOB>63) Q
        I $V(2,%JOB)="" Q
        V 2:%JOB:$V(2,%JOB)\2048*2048+($V(2,%JOB)#512)+(%PRIO*512) Q
JOB     W !,"Job #" Q
JOBH    W !,"Enter the number of the job that you wish to change priority."
        W !,"Job's are numbered from 1 to 63",! Q
PRI     W !,"New Priority" Q
PRIH    W !,"Enter a job priority level for this job"
        W !,"Priorities are numbered from 0 to 3 and 0 is the highest"
        W !,"(default) priority",! Q
