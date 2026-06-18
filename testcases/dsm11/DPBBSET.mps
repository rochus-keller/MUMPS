DPBBSET ;
        U 0 W !,"To inspect or modify a disk's bad-block table, type:",!
        W ?9,"D ^BBTAB",!,"To format, test, or initialize a disk, "
        W "type:",!,?9,"D ^DISKPREP",!
QUIT    Q
SDCENT  U 0 S SHOW=1 D START Q
COPENT  S SHOW=0 G DOIT
TAPENT  ;
DISKENT U 0 I %UPG G NXTP
        S SHOW=1
DOIT    D START I %ER W !,"Can't use ",DDU," -- stopping." G H
NXTP    K B1,BAD,SHOW S $ZT=%LABEL X %LOAD
H       B 0 G H
START   S %TY=$P(%D," ",4),%MP=$P(%D," ",5),%DPT=$P(%D," ",8)
        I $P(%D," ",7)="N" G PUTBB
        S BL=FMTSIZ-%DPT,J=0,B1=0
READBB  D READ I %ER S J=J+1,BL=BL+1 G READBB:J<4,RBBER
        F I=8:4 D MRGBB Q:BAD<1
PUTBB   F I=0:2:1022 V I:0:0
        V 512:0:%B S N=512+1 F M=1:1:%B D ADDBB
        Q
MRGBB   I $V(I,0)=65535 S BAD=-1 Q
        S BAD=$V(I,0)*$P(%D," ",9)+($V(I+2,0)\256)*%DPT*(%TY=4*2+2)+($V(I+2,0)#256)\(%TY=4*2+2)
        I BAD=0 S BAD=-1 Q
        F M=1:1:%B G NOMRG:%B(M)=BAD
        G S2:'SHOW,SECND:B1 S B1=1 W !,"Adding to DSM bad block table"
        W " the following blks from factory-written table:",!
SECND   W ?5,"DSM relative blk #  ",BAD,!
S2      I %MP*400+%B+1=BAD S %B=%B+1,%B(%B)=16777215
        S %B=%B+1,%B(%B)=BAD
NOMRG   S %ER=0 Q:%B'>$P(%D," ",12)  W !," *** bad block table is full ***",!
        S %ER=1 W !,%B," bad blocks found, can't use this disk.",! Q
ADDBB   S BAD=%B(M) I N#2 V N-1:0:$V(N-1,0)#256+(BAD#256*256),N+1:0:BAD\256
        E  V N:0:BAD#65536,N+2:0:BAD\65536
        S N=N+3 Q
READ    S %ER=0,NOT=0
RD1     B 0 U 63:(::"T") V BL:DDU U 63:(::"C")
        B 1 I $ZA\64#2=0 U 0 Q
        U 0 S NOT=NOT+1 G RD1:NOT<10 S %ER=1 Q
RBBER   W !,"Unable to read bad-block track" Q
