DEJRNL  ;YZH;23-JUN-80;ENTRY ROUTINE TO DEJOURNAL FROM DISK AND MAGTAPE
        I $V($V(44)+410) W !!,"Journaling is still active !!!",!,"Shutdown Journaling or stop Journaling on global(s) to be Dejourna
led.",*7
%JGR    K  W !!,"Specify one of the following:"
        W !,"1. Dejournal from disk"
        W !,"2. Dejournal from magnetic tape"
%ENT    R !!,"Enter the number of your choice > ",%OPT I %OPT=""!(%OPT="^") Q
        I %OPT["?" D %Q1 G %ENT
        I %OPT'?1N!("12"'[%OPT) D %IV G %JGR
        I %OPT=2 G ^DEJRNL1
        I '$D(^SYS(0,"JOURNAL SPACE")) W !!,"No journaling to disk has been done",! G %JGR
        W !!,"Journal Global Restore from disk",!
        S %ST=$V(44),%DT=$V(%ST+8)
%JSP    K %ALL,JRNL S QUES="%JNMQ",DEF="" X ^%Q("ASK") G:ANS=""!%A %JGR
        D NOMSG^JRNLSHOW
        F %A=1:1:ND S JRNSP=ND(%A) I ^SYS(0,"JOURNAL SPACE",JRNSP,"NAME")=ANS G %UT
        D %Q3 G %JSP
%UT     R !!,"Enter SDP Unit # ? > ",%JIO I %JIO=""!(%JIO="^") G %JSP
        I %JIO="?" D %Q2 G %UT
        I %JIO'?1N.N!(%JIO<59)!(%JIO>62) D %IV G %UT
        S %T=$V($V($V(44)+8)+%JIO)#256 I %T=255 W "   Device not in system" G %UT
        I %T W "   Device unavailable" G %UT
%ST     S DKJRN="" G ^DEJRNL2
%Q1     W !!,"To restore Globals from Journal disk space, enter the number 1"
        W !,"To restore Globals from Journal magnetic tape, enter the number 2" Q
%Q2     W !!,"Enter a valid SDP device number (59-62)",!
        W "(This unit # will be used to read the Journal records from the disk)",! Q
%JNMQH  ;
%Q3     W !,"Enter a valid disk Journal Space name",!
        D ^JRNLSHOW Q
%JNMQ   W !,"Enter Journal Space name" Q
%IV     W !!,?5,"Incorrect response.  Enter '?' for help" Q
