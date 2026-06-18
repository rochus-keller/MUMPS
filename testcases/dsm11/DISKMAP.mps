DISKMAP ;28-Dec-83 ;UTILITIES ;SYSTEM REPORTS ;DISPLAYS CONTENTS OF THE DISKMAP TABLE ;JHM
START   K  S TPOFF=8,NAMOFF=15,MAPOFF=21,BBOFF=27,MNTOFF=38
        S ST=$V(44),DSKMAP=$V(ST+224)
        D START^%STRTAB
        S (S,V)="" D
S1      .S S=$O(STR(S)) Q:S=""
S2      .S V=$O(STR(S,V)) G S1:V="" S COD($P(STR(S,V),":"))=V_":"_STR(S) G S2
        K STR
        D CODE^DPBEGIN
        D DKNAM^DPBEGIN
        W !?20,"DSM-11 DISK TABLE",!
        W !,"Device",?TPOFF,"Type",?NAMOFF,"Name",?MAPOFF,"Maps",?BBOFF,"BBTAB Add",?MNTOFF,"Mount Status"
        W !,"------",?TPOFF,"----",?NAMOFF,"----",?MAPOFF,"----",?BBOFF,"---------",?MNTOFF,"------------",!
LOOP    F TYP=0:1:7 S T=TYP*32 F UNI=0:1:7 S U=UNI*4 I $V(DSKMAP+T+U) D
        .S O=DSKMAP+T+U,NAM=$P(CODE($V(O)#256),",",2),DDU=$P(DKNAM(NAM)," ",3)_UNI W !,DDU
        .W ?TPOFF+2,TYP,?NAMOFF,NAM,?MAPOFF,$J($V(O+2),4),?BBOFF,$J($V(O+1)#64+$V(ST+86),7)
        .S MOU=$V(O)\16384 W ?MNTOFF
        .I 'MOU W "Not mounted" Q
        .I MOU=1 W "Mounted for view only" Q
        .I MOU=2 W "Mounted as a Non-UCI volume" Q
        .W "Mounted as volume ",$P(COD(DDU),":")," of Volume Set ",$P(COD(DDU),":",2)
EXIT    W !! K  Q
