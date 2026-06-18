DDPCON  ;9-Oct-84 ;UTILITIES ;DDP ;CONFIGURE DDP LINES ;JHM
        S ST=$V(44)
        I '$V(ST+444) W !,"DDP is not included in the current configuration",! Q
        S ID=^SYS(0,"RUNNING")
        W !,"Modify Circuit Information",!
MOD     S CHNG=0,DEL=0
M0      D GETNOD^DDPCIR G:%A EXIT I NODE="*" D CIRSTA^DDPCIR G M0
        W ! I RV D CIRSTA^DDPCIR S STA=$V(26,RV) W !! G M2
M1      S QUES="ADD" X ^%Q("ASKY") G:%A MOD G:ANS="N" MOD
        S (LNK,ADDR,VOL)="",STA=0 G M4
M2      S QUES="EDI" X ^%Q("ASKY") G:%A MOD
        I ANS="Y" G M4
M3      S QUES="REM" X ^%Q("ASK") G:%A M2 G:ANS="" M3 G:ANS="N" MOD
        D REMOV S CHNG=1,DEL=1 G M8
M4      S QUES="DDPL",DEF=LNK X ^%Q("EN") G:%A MOD
        I ANS'?1N D IV G M4
        I '$D(^SYS(ID,"DDP","LINES",ANS)) W !,"DDP link ",ANS," is not in this configuration.",!! G M4
        I LNK'=ANS S LNK=ANS,CHNG=1
        S DDB=$V(ST+422)+4 F I=0:1:LNK-1 Q:'DDB  S DDB=$V(DDB+2)
        I '(STA\4#2) I '($V(DDB+4)\128#2)!($V(DDB+4)\8#2) S STA=STA+4
M5      S QUES="VOLS",DEF=$P(VOL,",",2,8) X ^%Q("EN") G:%A M4
        I ANS="-" S ANS="" S I=0
        E  F I=1:1 Q:$P(ANS,",",I)=""  I $P(ANS,",",I)'?3U W !,$P(ANS,",",I)," is an invalid Volume set name",!! G M5
        I I>8 W !,"Only 7 mounted volume sets may be entered for each NODE.",!! G M5
        S ANS=NODE_","_ANS I VOL'=ANS S VOL=ANS,CHNG=1
        I ^SYS(ID,"DDP","LINES",LNK,"CONTROLLER")["DM" S ADDR="" G M7
M6      S DEF=ADDR,QUES="ADDR" X ^%Q("EN") G:%A M5
        I ANS'?2UN1"-"2UN1"-"2UN1"-"2UN1"-"2UN1"-"2UN D IV G M6
        I ADDR'=ANS S ADDR=ANS,CHNG=1
M7      G:'CHNG MOD D INSRT
M8      G:'CHNG MOD S QUES="PERM" X ^%Q("ASKN") G:%A M5 G:ANS="N" MOD
        I DEL K ^SYS(ID,"DDP","NODES",NODE)
        E  S ^SYS(ID,"DDP","NODES",NODE,"ADDRESS")=ADDR,^("LINE")=LNK,^("VOLUMES")=VOL
        W !,"Node ",NODE," permanent database updated",!! G MOD
EXIT    K LNK,ADDR,ADDRS,RV,VOL,NODE,QUES,DEF,LNKSTA,STA,RTY,RCV,OOS,SNT,VER,ANS,DEL,DEV,ID,INIT,LRV,REMOV,CHNG
        S %NOPAUSE=1 Q
STU     S NODE="" I $O(^SYS(ID,"DDP","NODES",""))="" Q
        W !,"Building DDP Circuit table",! S ST=$V(44)
T1      S NODE=$O(^SYS(ID,"DDP","NODES",NODE)) I NODE="" W ! Q
        S ADDR=^(NODE,"ADDRESS"),LNK=^("LINE"),VOL=^("VOLUMES"),STA=0
        D INSRT G T1
REMOV   S N=$C(32,LNK,0,0)_"ID" G UPD
INSRT   S N=$C(32,LNK,0,0)_"IS"
UPD     I ADDR="" F I=1:1:6 S N=N_$C(0)
        E  F I=1:1:6 S %HD=$P(ADDR,"-",I) D ^%HD S N=N_$C(%HD)
        F I=1:1:8 S C=$P(VOL,",",I) D  S N=N_$C(C#256,C\256)
        .I C="" S C=0 Q
        .S C=$A(C)-64*32+$A(C,2)-64*32+$A(C,3)-64*2
        S N=N_$C(STA) D PROCON^DDPSRV Q
ADD     W "Add ",NODE," to DDP circuit table" Q
ADDH    W !,"Answer Y if you wish to add this NODE to the DDP circuit table.",!! Q
EDI     W "Edit node ",NODE," circuit information" Q
EDIH    W !,"Answer Y if you wish to edit the current circuit information"
        W !,"for this node",!
        W !,"Answer N if you wish to remove this node from the DDP circuit table",!! Q
REM     W "Remove ",NODE," from the DDP circuit table" Q
REMH    W !,"Answer Y if you wish to remove this node from the DDP circuit",!! Q
DDPL    W "DDP Link #" Q
DDPLH   W !,"Enter the DDP Link # to which this node is connected.  The following"
        W !,"Link assignments exist:",!
        F I=0:1:^SYS(ID,"DDP","LINES")-1 W !?5,"Link #",I,?20,^SYS(ID,"DDP","LINES",I,"CONTROLLER"),"-",^("CONTROLLER NUMBER")
        W !! Q
VOLS    W "Mounted Volume Sets" Q
VOLSH   W !,"Enter the names of all mounted Volume Sets on this node other"
        W !,"than the System Volume Set.  Separate the names by commas."
        W !,"Only 7 additionnal Volume Sets may be specified for each node.",!
        W !,"Enter '-' if you wish to completely delete the current list",!! Q
        Q
PERM    W !,"Update the permanent database" Q
PERMH   W !,"Circuit table changes have already been made to the in-memory"
        W !,"circuit table",!
        W !,"Answer Y if you wish to have this modification saved in ^SYS"
        W !,"and loaded each time the system starts up. The permanent database"
        W !,"does not need to contain any information about V 3.1 DDP nodes"
        W !,"since network configuration information about these nodes is"
        W !,"updated automatically.",!
        W !,"Information about V 3.0 nodes should be saved, since these nodes"
        W !,"never provide automatic network configuration information.",!! Q
IV      W !,"Invalid response - Type ? for more help",!! Q
ADDR    W "Ethernet Physical Node Address" Q
ADDRH   W !,"Enter the Physical Node Address that this node's"
        W !,"Ethernet controller has been assigned.  The addresses consist of"
        W !,"6 pairs of hex digits separated by hyphens with the lowest"
        W !,"order byte represented as the leftmost hex pair.",!
        W !,"The LINK STATUS utility will provide the address for all"
        W !,"ethernet controllers on this system.",!! Q
