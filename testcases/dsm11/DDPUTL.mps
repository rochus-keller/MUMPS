DDPUTL  ;DISTRIBUTED DATA BASE CONTROL AND STATUS; HAM; 23-JAN-81
        W !,"DDP Control Utility" D CHKDDP G:%A EXIT D CHKSYS^SYSROU Q:%A
LOOP    ;
        W !!,"[S]tatus  [E]nable  [D]isable  [V]erify  [U]pdate",!
OPTION  W !,"Option > " R A
        I (A="")!(A="^") G EXIT
        I A="?" G HELP
        S A=$S(A="S":"STATUS",A="E":"E1^DDPCIR",A="D":"D1^DDPCIR",A="V":"VERIF",A="U":"UPDATE",1:"ERROR")
        D @A G LOOP
HELP    W !!,"Status  : displays the status of all DDP circuits."
        W !,"Enable  : enable a DDP circuit."
        W !,"Disable : disable a DDP circuit."
        W !,"Verify  : will determine if a DDP node is reachable."
        W !,"Update  : will force an automatic circuit table update."
        W ! G LOOP
ERROR   W " ...no such option..." Q
UPDATE  W !! S SCM="SWS" D ALINKS^DDPSRV W "Update complete" Q
VERIF   D GETNOD^DDPCIR Q:%A  G:'RV VERIF I RV>0 W ! D CHECK G VERIF
        W ! S RV=$V(0,$V(ST+444)) F ND=1:1 Q:'RV  D CHECK S RV=$V(0,RV)
        G VERIF
CHECK   D GETCIR^DDPCIR S $ZT="CHKERR" ZA ^["MGR",NODE]SYS ZD
        W "Node ",NODE," is up and reachable",! Q
CHKERR  I $ZE["<DSTDB>" W "Node ",NODE," does not respond to DDP requests" D
        .D GETCIR^DDPCIR W !!,"Link status: ",LNKSTA,!,"Circuit Status: ",STA
        E  I $ZE["<NOSYS>" D
        .W "The local circuit table entry for node ",NODE," is incorrect"
        .W !!,NODE," is NOT the name of the DSM system connected through DDP link #",LNK
        .I ADDR'="" W !,"with Ethernet address: ",ADDR
        E  D
        .W "Node ",NODE," is connected via DDP, but the following error"
        .W !,"was encountered while attempting to access it:",!,$ZE
        S $ZE="" W ! S $ZT="ERREND" ZD
ERREND  Q
STATUS  W !!,"DDP Circuit Status" I $V(ST+459) W ?30,$V(ST+459)," DDP server" W:$V(ST+459)'=1 "s" W " running",!
        S RV=-1 D CIRSTA^DDPCIR Q
STOP    W !,"DDP Shutdown",! D CHKDDP G:%A EXIT
        S DEF="",QUES="ARS" X ^%Q("ASKN") G:%A EXIT G:ANS="N" EXIT
        D STPDDP^DDPLNK G EXIT
START   W !,"Startup DDP",!! D CHKDDP G:%A EXIT
        I $V(ST+459) W !,"DDP is already started",! G EXIT
T1      S DEF=^SYS(ID,"DDP","SERVERS"),QUES="SERV" X ^%Q("EN") G:%A EXIT
        I ANS'?1N.N D IV W ! G T1
        S DDP=ANS D STRDDP^DDPLNK G EXIT
EXIT    K LNK,DEF,ID,DEV,ANS,ADDR,NODE,OOS,QUES,NODE,RTY,RV,SNT,ST,STA,VER,VOL,A,LNKSTA,RCV,%YN,%QMK,%DH,%A2,%A
        Q
IV      W !,"Invalid response - Type ? for more help",! Q
ARS     W !,"Ready to shutdown" Q
ARSH    W !,"Answer Y if you wish to completely disable all DDP circuits"
        W !,"and links and stop all DDP servers.  Any jobs which are currently"
        W !,"accessing the DDP links will encounter <DSTDB> errors.",! Q
SERV    W "Enter the number of DDP servers to start" Q
SERVH   W !,"DDP servers are DSM-11 jobs which receive requests for"
        W !,"DDP database access and locks from remote nodes and service"
        W !,"the requests on behalf of the remote job.  You should configure"
        W !,"at least one DDP server per DDP link and extra DDP servers for"
        W !,"each very active DDP circuit.  Since each server consumes an 8Kb"
        W !,"partition, the number of servers must be traded against the amount"
        W !,"of available partition space.",!! Q
CHKDDP  S ID=^SYS(0,"RUNNING"),ST=$V(44),%A=1 I ID=""!$V(ST+35) W !,"DDP is not available in the baseline system",! Q
        S %A=$V(ST+144)=0 I %A W !,"DDP is not available in this configuration" Q
        D CHKSYS^SYSROU Q
