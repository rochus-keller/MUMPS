REPTAB  ;22-Jan-86 ;UTILITIES ;SYSGEN ;REPLICATION SCHEMA TABLE EDIT ;JBH
        S REPMAX=4,ST=$V(44) D ID^SYSROU Q:ID="^"
SHOW    F SC=1:1:REPMAX I $D(^SYS(ID,"REPSCHEMA",SC)) D
        .W !,"Schema ",SC,": ",^(SC)
EDIT    W !!,"Specify entry number (1 to ",REPMAX,") for edit > " R SC,!
        I SC="?" W "Enter a number from 1 to ",REPMAX G EDIT
        I SC=""!(SC="^") Q
        I SC'?1N!(SC<1)!(SC>REPMAX) W " -- not valid." G EDIT
REP     R "Schema string> ",SCHEMA,! I SCHEMA="?" D HELP G REP
        I SCHEMA="^" G SHOW
        I SCHEMA="" W " - no change made." G SHOW
        S P="1"""_SCHEMA_""".E" I "DELETE"?@P S SCHEMA="" G STORE
        I SCHEMA?3U1","3U G STORE
        I SCHEMA?3U1","3U1";"3U1","3U G STORE
        I SCHEMA?3U1","3U1";"3U1","3U1";"3U1","3U G STORE
        I SCHEMA?3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U G STORE
        I SCHEMA?3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U G STORE
        I SCHEMA?3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U G STORE
        I SCHEMA?3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U1";"3U1","3U G STORE
        W "Not valid.  Type '?' for help." G EDIT
STORE   S ^SYS(ID,"REPSCHEMA",SC)=SCHEMA D LOAD1 G SHOW
LOAD    S ID=^SYS(0,"RUNNING"),ST=$V(44) I '$D(^SYS(ID,"REPSCHEMA")) Q
        F SC=1:1:4 I $D(^SYS(ID,"REPSCHEMA",SC)) D LOAD1
        W !,"Replication schema table reloaded." Q
LOAD1   S TABADD=SC-1*32+2+$V(ST+474)
        F R=1:1:7 S UC=$P($P(^(SC),";",R),",",1),SY=$P($P(^(SC),";",R),",",2) S OFS=R-1*4+TABADD I SY'="" D GETUCN I BD W !,"Error - uci ",UC," does not exist on volume set ",SY,!
        Q
HELP    W !,"Each replication schema is a list of up to 7 UCI,VOL pairs,"
        W !,"separated by semicolons.  Example:  UUU,VVV;CCC,OOO;III,LLL"
        W !,"The example will cause 3 replications."
        W !,"Type any subset of the word 'DELETE' to make an empty schema.",! Q
GETUCN  S $ZT="NOTDEF",UCN=$ZU(UC,SY),W1=$P(UCN,",",2)*32+$P(UCN,",",1),W2=0 G VM
NOTDEF  I $ZE'["NOSYS",$ZE'["NOUCI" W !,"Error - ",$ZE ZQ
        I $ZE["NOSYS" D
        .S W1=$A(UC)-64*1024+($A(UC,2)-64*32)+$A(UC,3)-64*2
        .S W2=$A(SY)-64*1024+($A(SY,2)-64*32)+$A(SY,3)-64*2
        E  S BD=1 Q
VM      V OFS::W1,OFS+2::W2 S OFS=OFS+2,BD=0 Q
