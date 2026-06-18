%SYR    ;28-Jun-85 ;UTILITIES ;SYSTEM STATUS ;REMOTE SYSTEM STATUS REPORT ;JHM
        W !,"Remote System Status",!
START   D CHKDDP^DDPCIR G:%A EXIT
GETNOD  D GETNOD^DDPCIR G:%A EXIT G:'RV GETNOD
        I NODE="*" W !,"Multiple node status not supported",! G GETNOD
        S $ZT="ERR^%SYR"
        ZA ^["MGR",NODE]%Q("STATUS","REQUEST"):15
        E  W !,"Status not available at this time",! G ZDEAL
        S ^["MGR",NODE]%Q("STATUS","REQUEST")=$P($ZU(0),",",2)
        ZA ^["MGR",NODE]%Q("STATUS","%SY"):15
        S ^("%SY")=""
        ZD ^["MGR",NODE]%Q("STATUS","%SY")
        J ZJ^%SY["MGR",NODE]
        E  W !,"No partitions available on remote node",! G ZDEAL
        F I=1:1:30 G:^["MGR",NODE]%Q("STATUS","%SY")["STARTED" WAIT H 1
        G NOCOMP
WAIT    ZA ^["MGR",NODE]%Q("STATUS","%SY"):30 E  G NOCOMP
        I ^["MGR",NODE]%Q("STATUS","%SY")'["COMPLETE" G NOCOMP
GETDAT  S J="" K JT,JD S %ACT=^["MGR",NODE]%Q("STATUS","JOB")
        F I=1:1 S J=$O(^["MGR",NODE]%Q("STATUS","JOB",J)) Q:J=""  S JT(J)=^(J)
        F I=1:1 S J=$O(^["MGR",NODE]%Q("STATUS","DEVICE",J)) Q:J=""  S JD(J)=^(J)
        D REMOTE^%SY W ! G ZDEAL
ERR     I $ZE["NOSYS" W !,NODE," is not currently available",! G ZDEAL
        I $ZE["NOUCI" W !,NODE," does not have a Manager's UCI named MGR",! G ZDEAL
        I $ZE["INRPT" W !,"*** Interrupt ***",! G ZDEAL
        I $ZE["DSTDB" W !,"Error accessing DDP link"
        W !,"Error encountered: ",$ZE
NOCOMP  W !,"Status on remote node could not complete",!
ZDEAL   S $ZT="ZDTRAP" ZD
ZDTRAP  G GETNOD
EXIT    K NODE
        Q
