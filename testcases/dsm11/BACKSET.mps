BACKSET ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
SETUP   ;
        S MM=$V(ST+86)
        S IU=^SYS(0,"BACKUP",NM,"DISK "_N,"MODE")'="ALL"
        S DDU=^("FROM","UNIT") D SETBF K %D
        S FD=$E(DDU,1,2),FU=$E(DDU,3)
        S FT=$F(TYPES,FD)\3-1,FDE=$V(ST+224)+(FT*8+FU*4),FS=$V(FDE)#16384
        D RESD S FR=RFLG
        S FL=^("MASTER LABEL")
        S FB=0
        S VL=1
        S ME=^SYS(0,"BACKUP",NM,"DISK "_N,"TO")="M"
        G TOTAP:ME
        S VE=^SYS(0,"BACKUP",NM,"DISK "_N,"VERIFY")="Y"
        V ST+70::$V(ST+70)#H+(VE*H)
        S DDU=^("TO","UNIT"),TD=$E(DDU,1,2),TU=$E(DDU,3) D SETBF
        S TCOD=$P(%D," "),TBMAX=$P(%D," ",12) K %D
        S TT=$F(TYPES,TD)\3-1,TDE=$V(ST+224)+(TT*8+TU*4),TS=$V(TDE)#16384
        D RESD S TR=RFLG
        S TB=0
        K MD,MF
        G BSTRT
TOTAP   S MD=3 I ^("TO","MAGTAPE DENSITY")=1600 S MD=4
        I ^("MAGTAPE DENSITY")=6250 S MD=5
        S MF=^("MAGTAPE BLOCK FACTOR")
        S TR=0
        I BF-IU'<('IU*MF+MF) G OKBLFAC
        S LF=MF,MF=BF-IU-(BF-IU\2*'IU)
        G:$D(UNATTN) ERROR S QUES="LOWB" X ^%Q("ASKN") I ANS="N"!%A S E=1,FR=0 G BACFAIL^BACKUPDO
        S NAKED=$D(^SYS(0,"BACKUP",NM,"DISK "_N,"TO","MAGTAPE UNIT"))
OKBLFAC S MFS=MF*1024,P=BF-IU\MF*MF
        U 63:(1:BF),0 C UU S MLST=^("MAGTAPE UNIT"),UU=$P(MLST,";",MTCNT)+47 O UU:"BT"_MD_$S(IU:"",1:"C")
BSTRT   S $ZT="FIXUP^BACKUPDO"
        W:'$D(UNATTN) !!,"  ** BEGIN BACKUP # ",N,"   DISK ",FD,FU,"     LABEL = ",FL,!
        S FM=FM(N)
        S SA=%STSAV
        I QU S:SA\8192#2=0 SA=SA+8192
        I FM!TR S:SA\16384#2=0 SA=SA+16384
MNTIF   G MNTIF^BACKMNT
RESD    S TY=$F(TYPES,$E(DDU,1,2))\3-1,DTE=$V($V(44)+224)+(TY*8+$E(DDU,3)*4)
        S MOU=$V(DTE)\16384,RFLG=(MOU>1)
        Q
SETBF   D %DDU^DPBEGIN
        I $P(%D," ",13),$P(%D," ",13)<BF S BF=$P(%D," ",13)
        Q
ERROR   S MSG="NOT ENOUGH BUFFERS AVAILABLE TO USE A BLOCKING-FACTOR OF "_LF_"."
        D HD^BACKUP G BACFAIL^BACKUPDO
LOWB    W !,"There are not enough buffers available to use a Blocking-Factor "
        W "of ",LF,".",!
        W "OK to proceed using a Magtape-Blocking-Factor of ",MF," " Q
LOWBH   W !,"When creating this Backup-Command-File, you specified that ",MF
        W " DSM",!
        W "disk blocks were to be written together in each physical magtape "
        W "block.",!
        W "Present system resources make this impossible at this time -- "
        W "more",!
        W "Disk-Tape buffers would be needed.",!
        W "You may answer 'N' to the question, then try again later; or you "
        W "may",!
        W "answer 'Y', to proceed using the smaller Blocking-Factor.",!! Q
