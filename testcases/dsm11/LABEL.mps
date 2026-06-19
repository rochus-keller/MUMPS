LABEL   ; DSM-11 Utilities ; Copyright 1980 DEC
        U 0 C 63 O 63::1 E  W !,"Waiting for View buffer..." O 63 W "got it!",!
        W !,"Inspect or change a DSM11 disk volume label",!!
        D CHKTAP G:%A S3
S2      S QUES="DORT",DEF="D" X ^%Q("ASK") Q:%A
        G LBENT^LABELMT:$E(ANS,1)="M",S2:$E(ANS,1)'="D"
S3      S PRM="Show label",MAPS=0,M=1 D GETYU^DPBEGIN I '$D(%A) G DONE
        I %A=1 G DONE
        S %UPG=1 D START^DPLABGET
        D SHOW D:%WRT START^DPNEWL G DONE
        W !,DDU," does not have a DSM11 volume label. You must D ^DISKPREP",!
        W "to create a DSM-11 disk volume."
DONE    C 63 Q
COPENT  S MB="M",%LB="DSM11 V"_$P($ZV," ",3)_"BL"_$P($ZV," ",6)_" DISTRIB"
        S VOLNAM="INS",CODE=$P($H,",",2)#65536,%SIZ=%MP
        G NXTP
DISKENT ;
TAPENT  I %UPG'=3,%UPG'=2 D GETNEW S %LB=A
        S %SIZ=%MP
        I %UPG'=3 D VOLNAM
NXTP    S $ZT=%LABEL X %LOAD
VOLNAM  W !,"What 3-character uppercase name do you wish to give this volume set ? " R VOLNAM
        I VOLNAM'?3U W !,"This name will be written into the label of each disk volume of the set.",!,"The volume set name must be 3 uppercase alphabetics." G VOLNAM
        S CODE=$P($H,",",2)#65536
        Q
SIZ     S %SIZ=%MP Q
        I %MP'>$V(ST+234) S %SIZ=%MP Q
        W !!,"How many maps (1 map=400 kbytes) do you wish to include in ",VOLNAM," <",%MP,"> ? "
        R %SIZ I %SIZ?.N,%SIZ'<$V(ST+234) Q
        I %SIZ="" S %SIZ=%MP Q
        W !!,"You can specify that only part of your disk be used for your first"
        W !,"volume set.  You can change your mind later and extend the volume"
        W !,"further into the disk. The default value is the maximum number of"
        W !,"maps on the disk, and the minimum is ",$V(ST+234)," maps.  A map is a segment"
        W !,"of disk space 400 blocks in length, equal to 0.4 megabytes."
        G SIZ
START   D GETNEW S %LB=A Q
SHOW    S %WRT=0
        W ! W:MB="M" "Master" W:MB'="M" "Backup"
        W " label placed on this disk ",DA," is:  """,%LB,"""",!
        G NBAK:MLB=""!(MB="M")
        W "It is backup vol # ",VN," of ",MTY," master:    ",MLB,!
        W "(backup performed ",DAB,")",!
NBAK    S QUES="QNEW" D ASKYN Q:'Y  S QUES="MORB"
ASKMB   D ASK S M=$E(A,1) G NWMA:M="M",OK:M="B"
        W "Type '?' for more information",! G NBAK
NWMA    G OK:MLB=""!(MB="M")
        I $V(881,0) W !,*7,"*** An in-use Backup cannot be made a Master ***",!,"*** Please use ^DISKPREP for this purpose. ***",! G NBAK
        S QUES="SURE" D ASKYN G NBAK:'Y
OK      D GETNEW
LEGL    G NBAK:'L
        S %LB=A,MB=M,%WRT=1
        Q
CHKTAP  S %A=$V($V($V(44)+8)+47)=225 Q
NOTAP   S %A=1 Q:$ZE["NODEV"  ZQ
PUTV2   W "We will now put a DSM11 label on the disk",!!
MORB    W "Will this be a ""Master"" label or a ""Backup "" label  "
        W "[ M or B ] " Q
PUTV2H  ;
MORBH   W "1.  Place a Backup label on the disk if you plan to use this disk "
        W "to",!,"back up information from other disks, using the DSM11 "
        W """BACKUP"" utility.",!
        W "2.  Place a Master label on the disk if you are now using this "
        W "disk,",!,"or are planning to use it, as part of your DSM11 "
        W "operating system.",!
        W "3.  You may place a Backup label on any disk you are not "
        W "currently",!," using (containing no important data, in other "
        W "words), for",!,"identification purposes.",!
        W "4.  Do *NOT* place *ANY* DSM11 label on the disk if it "
        W "contains",!,"important data you wish to preserve, but it is not "
        W "a DSM11 disk",!,"-- The label is written in physical block #1 of"
        W " the disk, and may",!,"destroy important information if it is "
        W "a non-DSM11 disk.",! Q
GETNEW  S QUES="NEWL" D ASK S L=$L(A),A=$P(A,"""",2) I $L(A)+2'=L D HELP G GETNEW
        I $L(A)>22 D HELP G GETNEW
        Q
NEWL    W "What would you like the new label of this disk to be ?",!
        W "(up to 22 characters, enclosed in quotes)  " Q
NEWLH   W "  Like this:   ""THE NEW LABEL""" Q
QNEW    W "Do you wish to change the label on this disk" Q
SURE    W !,"  You wish to use this Backup as a Master ?",!
        W "  are you sure " Q
DORT    W !,"Disk or Magtape  [ D or M ] " Q
DORTH   W "Do you wish to inspect the label that is on a disk or a magtape?",!
        Q
ASKYN   W ! D @QUES R " ? [Y/N]  > ",Y,!
        I "YN"[$E(Y,1)&$L(Y) S Y=$E(Y,1)="Y" Q
        D HELP G ASKYN
ASK     W ! D @QUES R " ?  > ",A,! Q:A'="?"  D HELP G ASK
HELP    S HROU=QUES_"H" D:$L($T(@HROU)) @HROU Q
