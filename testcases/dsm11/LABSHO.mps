LABSHO  ;16-Mar-84 ;UTILITY ;LABEL ;SHOW'S THE CONTENTS OF A DISK LABEL ;JHM
STRT    K  C 63 O 63:2:2 I '$T W !,"VIEW BUFFER BUSY",! Q
GETU    S MAPS=0,M=1,PRM="Show label" D GETYU^DPBEGIN I '$D(%A) C 63 Q
        I %A=1 C 63 Q
GETPL   R !,"Physical or Logical block 0 ? [P/L] > ",A I A=""!(A="^") G GETU
        I "PL"[A U 63:(::$S(A="P":"Z",1:"C")),0 V 0:DDU
        E  W !,"Enter P or L" G GETPL
        F I=1:1 S T=$P($T(LABEL+I),";;",2) Q:T=""  D
        .S OF=$P(T,$C(9)),N=$P(T,$C(9),2),V=$P(T,$C(9),3),E=$P(T,$C(9),4)
        .W !,OF,?8
        .I V="A" S FLD="" F X=0:1:N-1 S FLD=FLD_$C($V(OF+X,0)#256)
        .E  S FLD=0,H=1 F X=0:1:N-1 S FLD=$V(OF+X,0)#256*H+FLD,H=H*256
        .W FLD,?8,?30,E
        G GETU
LABEL   ;
        ;;496   2       D       System image annex size
        ;;498   2       D       System image annex start
        ;;512   1       D       # of BAD blocks
        ;;812   2       D       MAXIMUM MAPS ON THIS VOLUME
        ;;814   1       A       M if master, B if backup disk
        ;;815   1       D       1 = Mountable Backup Set
        ;;816   22      A       Label field
        ;;838   22      A       Master's Label if this is a backup
        ;;860   9       A       Date label was changed
        ;;869   9       A       Date backup was performed
        ;;878   2       A       Master's device name
        ;;880   1       D       Volume # of backup
        ;;881   1       D       1 = IN-USE, 0 = ALL backup format
        ;;882   16      A       System Version
        ;;898   2       D       Magtape Blocking-factor (*512)
        ;;902   2       D       # of Maps that were on the master
        ;;904   2       D       $H#65536 AT DISKPREP TIME OF VOLUME 1 OF SET
        ;;906   3       A       Volume Set Name
        ;;909   1       A       Volume number within the set
        ;;910   3       D       If volume 1, UCI table ptr
        ;;913   1       D       If volume 1, number of volumes in volume set
        ;;914   1       D       If volume 1, disk code
        ;;915   1       D       Disk type (0-7)
        ;;916   2       D       # of maps on this volume (if 0 then defautl to 812)
        ;;918   1       D       Volume 2 disk code
        ;;919   1       D       Volume 2 disk type
        ;;920   2       D       # of maps on Volume 2
        ;;922   1       D       Volume 3 disk code
        ;;923   1       D       Volume 3 disk type
        ;;924   2       D       # of maps on Volume 3
        ;;926   1       D       Volume 4 disk code
        ;;927   1       D       Volume 4 disk type
        ;;928   2       D       # of maps on Volume 4
        ;;930   1       D       Volume 5 disk code
        ;;931   1       D       Volume 5 disk type
        ;;932   2       D       # of maps on Volume 5
        ;;934   1       D       Volume 6 disk code
        ;;935   1       D       Volume 6 disk type
        ;;936   2       D       # of maps on Volume 6
        ;;938   1       D       Volume 7 disk code
        ;;939   1       D       Volume 7 disk type
        ;;940   2       D       # of maps on Volume 7
        ;;942   1       D       Volume 8 disk code
        ;;943   1       D       Volume 8 disk type
        ;;944   2       D       # of maps on Volume 8
