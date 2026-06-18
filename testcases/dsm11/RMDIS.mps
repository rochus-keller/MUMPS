RMDIS   ;30-Jun-83 ;UTILITY ;ROUTINE MAP ;DISABLES/ENABLES ROUTINE MAP ;JHM
EN      D CHKRM^RMBLD G EXIT:%A
        S ROUMAP=$V(ST+38),EXTH=0
        I $V(0,ROUMAP)=0 W !,"There are no Routine Sets in memory",! G EXIT
        W !,"Enable/Disable Mapped routines and sets",!
EN1     S SETNAM="" D GETNAM^RMBLD G EXIT:%A
        I SETNAM="*" G DISALL
        I '$D(^SYS(0,"ROUTINE MAP",SETNAM)) W !,SETNAM," is not defined",! G EN1
        S RNUM=$P(^SYS(0,"ROUTINE MAP",SETNAM),","),%UCI=$P(^(SETNAM),",",2),%SYS=$P(^(SETNAM),",",3)
        W !,"Routine Set, ",SETNAM," exists for ",%UCI,",",%SYS
        D GETUCN^RMBLD G EN1:'UCN
        F ENT=0:8 G:'$V(ENT,ROUMAP) NOFND Q:$V(ENT,ROUMAP)#256=UCN
        I $V(ENT+1,ROUMAP) W " - currently disabled",! G Q3
        W " - currently enabled",!
Q2      S QUES="WANA",DEF="" X ^%Q("SGASKYN") G:ANS=""!%A Q3 G:ANS["N" Q4
        V ENT:ROUMAP:$V(ENT,ROUMAP)#256*256+($V(ENT,ROUMAP)#256)
        W !,SETNAM," disabled",! G EXIT
Q3      S QUES="ENABL",DEF="" X ^%Q("SGASKYN") G:ANS=""!%A EN1 G:ANS["N" EN1
        V ENT:ROUMAP:$V(ENT,ROUMAP)#256
        W !,"Routine Set for ",%UCI,",",%SYS,", is enabled.",! G EXIT
Q4      S QUES="ROUT",DEF="" X ^%Q("SGEN") G:ANS=""!%A EXIT
        I ANS'?1"%"0.7NA,ANS'?1A0.7NA D IV G Q4
        S RNAM=$E(ANS,1,8)
        F I=$L(RNAM):1:8 S RNAM=RNAM_$C(255)
        S MMNAM=$V(ENT+6,ROUMAP),RNUM=$V(ENT+2,ROUMAP),MMADR=$V(ENT+4,ROUMAP)
        F RN=0:1:RNUM-1 F I=1:1:9 G RFND:I=9 I $V(RN*8+I-1,MMNAM)#256'=$A(RNAM,I) Q
        W !,"Routine, ",RNAM,", could not be found in memory",! G Q4
RFND    I $V(RN*2,MMADR)=0 W !,"Routine, ",RNAM,", is already disabled.",! G Q4
        V RN*2:MMADR:0 W !,"Routine, ",RNAM,", disabled.",! G Q4
EXIT    Q
        -
DISALL  W !,"This will irreversably disable all routine sets now loaded."
        W !,"You can load new routine sets when all jobs using mapped"
        W !,"routines have logged out.",!
OK      R !,"OK to turn off all mapped routine sets? N => ",R
        S R=$E(R) I "^N"[R W " (no action taken)" Q
        I R'="Y" W *7," ??? Y or N, please" G OK
SURE    R !,"Are you Sure: N => ",R
        S R=$E(R) I "^N"[R W " (no action taken)" Q
        I R'="Y" W *7," ??? Y or N, please" G SURE
        V 0:ROUMAP:0,4:ROUMAP:8+ROUMAP W !,"OK, Routine mapping shut down." Q
IV      W !,"Invalid response - Type ? for help",! Q
NOFND   W !,"Can not find a routine set for ",%UCI,",",%SYS,! G EN1
WANA    ;;1
        ;;DISABLE the entire ROUTINE SET
WANAH   ;;21
        ;;This utility will allow you to control the usage of routines
        ;;which have been loaded into memory.
        ;;
        ;;Specifically, you may:
        ;;
        ;;      Disable the usage of an entire MAPPED ROUTINE SET
        ;;      Reenable the usage of an entire MAPPED ROUTINE SET
        ;;      which has been disabled.
        ;;
        ;;      or, Disable a specific routine in a MAPPED ROUTINE SET
        ;;
        ;; Answer Y to this question if you wish to  DISABLE
        ;; the entire MAPPED ROUTINE SET.
        ;;
        ;;Once the routine or ROUTINE SET has been disabled, any calls
        ;;to the routine will require that the routine to be loaded into
        ;;the job's partition.
        ;;
        ;; Answer N if you wish to disable a single routine in the
        ;; selected MAPPED ROUTINE SET.
        ;;
ROUT    ;;1
        ;;Enter the name of the routine to disable
ROUTH   ;;5
        ;;Enter the name of the routine in the specified ROUTINE SET
        ;;that you wish to disable.  Once the routine is disable in
        ;;memory, program calls will retrieve a copy of the routine
        ;;from disk.
        ;;
ENABL   ;;1
        ;;ENABLE Mapping of this ROUTINE SET
ENABLH  ;;2
        ;;Type Y to reenable shared mapping of this ROUTINE SET.
        ;;
