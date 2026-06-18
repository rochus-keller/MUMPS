SGDISK  ;22-Apr-83 ;UTILITIES ;SYSGEN ;GET DISK INFO ;JHM
        Q
START   W !,"PART 2: ",?10,"DISK INFORMATION",!,"-------",!
        D DKNAM^DPBEGIN
        I 'EDIT W !,"Disk information supplied by AUTOCONFIGURE",! G DONE
        S QUES="DISK" X ^%Q("QUERYH") S QUES="GDISK",DEF=""
        I $D(^SYS(ID,"DISKTYPE")) D LSTDKS
DLP     X ^%Q("SGEN") G RETURN:%A,DONE:ANS="" I ANS="*" D SHODKS G DLP
        I ANS="L"!(ANS="^L") D LSTDKS G DLP
        I ANS'?1.3U2N1"="1N D IV G DLP
        S DKNAM=$P(ANS,"="),NO=$P(ANS,"=",2)
        I '$D(DKNAM(DKNAM)) W !,DKNAM," is not supported, type * to get a list of supported devices",! G DLP
        I NO>8 W !,"The number of disk drive units may not exceed 8",!
        I 'NO K ^SYS(ID,"DISKTYPE",DKNAM) G DLP
        S ^SYS(ID,"DISKTYPE",DKNAM)=NO G DLP
DONE    S DK="A",SAT=0,TOT=0 F I=0:1 S DK=$O(^SYS(ID,"DISKTYPE",DK)) Q:DK=""  D
        .S TOT=TOT+^(DK),MAPS=$P(DKNAM(DK)," ",5),SAT=MAPS+16+511\512*64*^(DK)+SAT
        S ^SYS(ID,"MEM.ALLOC","BBTAB")=TOT*192,^("SATMAP")=SAT
        I 'TOT W !,"  No disks defined - cannot continue SYSGEN",! S EDIT=1 G START
        K TY,TOT,SAT,DKNAM,MAPS,NO,SV1,SYV,WORDS,SUB
        D START^SGMAGT I %A G:EDIT START
RETURN  K DKNAM Q
LSTDKS  W !!,"The following disks are found in your configuration:",!!
        S DK="A" F I=0:15 S DK=$O(^SYS(ID,"DISKTYPE",DK)) Q:DK=""  W ?I,DK,"=",^(DK) I I>45 W ! S I=-15
        W:$X ! Q
SHODKS  W !!,"The following disk drives are supported:",!!
        S DKNAM="" F I=0:10 S DKNAM=$O(DKNAM(DKNAM)) Q:DKNAM=""  W ?I,DKNAM I I>60 W ! S I=-10
        W:$X ! Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
DISKH   ;;6
        ;;Please enter all the disk drives in your system using the form:
        ;;
        ;;               DRIVETYPE=NUMBER OF DRIVES
        ;;
        ;;              Press RETURN to end the list
        ;;
GDISKH  ;;15
        ;;You must enter all the names and numbers of the disk drives on the
        ;;system you are configuring. For example, if your system has 2 RL01's
        ;;and 1 RL02 enter:
        ;;
        ;;      DISK DRIVES >  RL01=2
        ;;      DISK DRIVES >  RL02=1
        ;;      DISK DRIVES >  <RETURN>
        ;;
        ;;To delete a drive from the list enter:
        ;;
        ;;      DRIVETYPE=0
        ;;
        ;;Type "*" to get a list of supported drives
        ;;Type "L" to get a list of devices already entered
        ;;
GDISK   ;;1;;2.1;;1
        ;;      DISK DRIVE
