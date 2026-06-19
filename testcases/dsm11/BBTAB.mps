BBTAB   ; FDN; 17-JUN-80; BAD BLOCK TABLE INFORMATION
        K  C 63 O 63::2 G GO:$T W !?5,*7,"View Buffer busy" Q
GO      W !!,"Inspect/Modify the Bad Block Table for a DSM-11 disk volume.",!!
GETU    S MAPS=0,M=1,PRM="Show BBTAB" D GETYU^DPBEGIN I '$D(%A) C 63 G DONE
        I %A=1 C 63 G DONE
        I VER'["DSM11" W !,DDU," does not contain a DSM-11 disk." G GETU
        S %UPG=1,ST=$V(44)
        D START^DPLABGET
        S %MP=$V(812,0)
        D START C 63 Q
TAPENT  ;
DISKENT D START
COPENT  ;
NXTP    S $ZT=%LABEL X %LOAD
START   S %B=0,POS=512+1 F I=1:1:$V(512,0)#256 D
        .I POS#2 S BL=$V(POS+1,0)*256+$V(POS,0)
        .E  S BL=$V(POS+2,0)#256*65536+$V(POS,0)
        .S %B=%B+1,%B(%B)=BL S POS=POS+3
ENTER   S FMTSIZ=$P(%D," ",8)*$P(%D," ",9)*$P(%D," ",10)
        S REMAP=%MP*400
        W !!!,$P(%D," ",2)," Unit ",$E(DDU,3),"  "
        G NOL:'%UPG W:MB="M" "[ Master" W:MB'="M" "[ Backup"
        W " Label = """,%LB,"""  (",DA,") ]   ",!
NOL     W "Bad Block Table",!!
        I '%B W "The Bad Block Table is empty",! G ASKM
        F J=1:1:%B D LIST
ASKM    S QUES="ADQ" D ASKYNB G ENTER:Y="^",DONE:'Y
        D BLKQ G ASKM:'BL
ASKM1   F I=1:1:%B I BL=%B(I) W "* Already in table *",! R !,"Do you want to put the spare block in the bad block table also? ",X GASKM:X'?1"Y".E S BL=400*%MP+I G ASKM1
        I '%UPG G ADBL
        U 63:(2:1:"CT")
        S MAPB=BL\400*400+399
        I MAPB=BL S BT="M" G RPT
        S I=BL-(FMTSIZ\400*400-1) I I>0 S BT=$S(%B<I:0,1:"R") G RPT
        V MAPB:DDU
        S BT=$S($ZA\64#2:"",1:$V(BL#400*2,0))
RPT     F I=0:2:1022 V I:0:0
        F I=1:1:300 V BL:DDU Q:'($ZA\64#2)
        S P=$ZA
        I BT="" U 0 W !,"Block use is Unknown" G E1
        U 0 W !,"Block is ",$S(BT!(BT'?.N):"",1:"not "),"in use" I BT!(BT'?.N) W " as a ",$S(BT="M":"Map",BT="R":"Spare Remapping",BT=65535:"System",BT=65534:"V1.0 Bad",1:"Data or Routine")," block."
E1      U 0 W !,"Current Contents are ",$S(P\64#2:"not ",1:""),"readable",!
        K P,I,MAPB,BT
ADBL    S %B=%B+1,%B(%B)=BL I REMAP+%B=BL S %B(%B)=16777215
        U 63:(1:1:"CZ") U 0 S POS=$V(512,0)#256*3+1
        S %BLA=%B(%B) I $V(%DT+2)'=0 D
        .S %MM=$V(%DT+1)#64+$V(ST+86)
        .S OFF=0 D INSRT
        S OFF=512,POS=POS+OFF,%MM=0 D INSRT G ADBL:%BLA=16777215
        I %UPG U 63:(2:1),0 V -BL:DDU U 63:(1:1),0 V -16777216:DDU
        W " -- added to table",! G ASKM:%B<$P(%D," ",12)
        W !,"** Table is now full **",!
        G DONE
INSRT   I POS#2 V POS-1:%MM:$V(POS-1,%MM)#256+(%BLA#256*256),POS+1:%MM:%BLA\256
        E  V POS:%MM:%BLA#65536,POS+2:%MM:%BLA\65536
        V OFF:%MM:$V(OFF,%MM)+1
        Q
LIST    W:J=1 "DSM relative block #" W ?22,%B(J),! Q
ASKYNB  W ! D @QUES R " ? [Y/N]  > ",Y,! S:Y="" Y="^" Q:Y="^"
        I "YN"[$E(Y,1) S Y=$E(Y,1)="Y" Q
        D HELP G ASKYNB
ASK     W ! D @QUES R " ?  > ",A,! Q:A'="?"  D HELP G ASK
HELP    S HROU=QUES_"H" D:$L($T(@HROU)) @HROU Q
ADQ     W "Do you know of any other bad blocks on this disk" Q
ADQH    W !,"Answer 'Y' if you know the locations of any additional bad-"
        W "blocks.",!
        W "Otherwise answer 'N'."
        Q
BLKQ    W !,"What is the block number of the bad block"
        R " :  ",A,! S BL=A Q:A>0&(A<FMTSIZ)  S BL=0 Q:A=""!(A="^")
        I A>0,A<FMTSIZ Q
BLKQH   W !?5,"Block # for an ",$P(%D," ",2)," must be in the range  1-",FMTSIZ-1
        W !?5,"The relative block # of the 1st DSM block (1024-byte block) on a disk is 0"
        W !?5,"The relative block # of the next 1024-byte block is 1, etc."
        W !?5,"Enter DSM relative block number (1-",FMTSIZ-1,")"
        W !?5,"Enter  ^  to leave question.",! G BLKQ
DONE    K BY,P,POS,REMAP,M,NM,OFS,MA,J,%BLA,Y Q
