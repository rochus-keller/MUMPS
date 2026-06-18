SGPART  ;4-May-83 ;UTILITIES ;SYSGEN ;DEFINE PARTITIONS ;
        Q
START   W !,"PART 10:",?10,"JOB PARTITION DEFINITION",!,"--------",!
        S JOBMAX=$V($V(ST+6)+1)\2
        S MEMLEFT=MEMTOT-MEMUSE("BUFFERS")
        S ^SYS(ID,"MEM.ALLOC","UNUSED")=MEMLEFT#1024,MEMLEFT=MEMLEFT-^("UNUSED")
        W !,"PARTITIONs are allocated in 1024 byte increments.",!
        W !,"The following PARTITIONs have been defined:",!
        I ^SYS(ID,"OPTIONS","JRNL")="Y" S MEMLEFT=MEMLEFT-1024 W !,"JOURNAL system job",?50,"1 KB"
        W !,"GARBAGE COLLECTOR system job",?50,"1 KB"
        W !,"Job #1 (to guarantee one 9 K byte PARTITION)",?50,"9 KB",!
        S ^SYS(ID,"PARTITION","1")=9216
        S MEMLEFT=MEMLEFT-10240 D:'SOFT SHOMEM
        F I=2:1 Q:'($D(^SYS(ID,"PARTITION",I)))  K ^SYS(ID,"PARTITION",I)
PARSZ   S DEF=9,QUES="PARDEF" X:EXTH ^%Q("EXTH")
        I SOFT W !,"Default partition size:",?50,$J(DEF,6)," K Bytes",! S ANS=DEF G SETDEF
        I $D(^SYS(ID,"PARTITION","DEFAULT")) S DEF=^SYS(ID,"PARTITION","DEFAULT")\1024
PARSZ2  X ^%Q("SGEN") G:%A RETURN I ANS'?1N.N!(ANS<1)!(ANS>16) D IV G PARSZ
SETDEF  S ^SYS(ID,"PARTITION","DEFAULT")=(ANS*1024)
NONSTD  S QUES="FIXPAR" X:EXTH ^%Q("EXTH") I SOFT G DONE
        W !!,"10.2",?6,"Enter fixed PARTITION sizes (in increments) and the number of each."
        W !?6,"A <CR> in the size field will terminate the session."
        W !!,"PARTITION size",?20,"number of each",!,"______________",?20,"____________________",! S ANS=1
PART    R ?6,SZ G DONE:SZ="",START:SZ="^" I SZ="?" X ^%Q("QUERYH") G PART
        I SZ'?1N.N!(SZ<1)!(SZ>16) D IV G PART
        R ?28,NR I NR=""!(NR=0) W ! G PART
        I NR="?" X ^%Q("QUERYH") G PART
        I NR'?1N.N D IV G PART
        I NR>(JOBMAX-ANS) W !!,ANS+NR," Partitions defined, ",JOBMAX," is the maximum, please try again.",!! G PART
        S TMEM=MEMLEFT-(SZ*1024*NR)
        I TMEM<0 W !?6,"Memory exceeded by ",$J(-TMEM/1024,6,2)," K bytes. Please try again.",!! G PART
        S MEMLEFT=TMEM D SHOMEM F I=1:1:NR S ANS=ANS+1,^SYS(ID,"PARTITION",ANS)=SZ*1024
        G:MEMLEFT>1023 PART
DONE    D SHOMEM W !,"The remainder of memory is assigned to the DYNAMIC PARTITION POOL",!
        S ^SYS(ID,"PARTITION","POOL")=MEMLEFT
        K HLP,MEMLEFT,XMEM,NR,SZ,TMEM
        S DMB="D" D SYSGEN^MBP G:%A START D ^MDAT
        W !!,"The system global ^SYS has been built by SYSGEN.",!
        W "^SYS is a reserved global and should not be altered.",!!
        I '$D(^SYS(ID,"STARTUP")) S QUES="HELPM" X ^%Q("QUERYH")
        I '$D(^SYS(0,"DEFAULT")) S ^SYS(0,"DEFAULT")=ID
        S %A=0 ZT "EXIT"
SHOMEM  W !,"Space remaining for PARTITION allocation:",?50,$J(MEMLEFT/1024,6,2)," K bytes",! Q
RETURN  Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
PARDEF  ;;1;;10.1;;1
        ;;Enter the default PARTITION SIZE in 1 K Byte increments
PARDEFH ;;4
        ;;Default-sized PARTITIONs will be used for logins and JOB commands that
        ;;do not specify PARTITION size.   The size of a partition is expressed
        ;;in 1 K Byte increments.
        ;;
FIXPARH ;;8
        ;;PARTITIONS are allocated in 1024 byte increments. The minimum
        ;;usable size is 1 K Bytes and the maximum is 16 K Bytes.
        ;;Fixed-size partitions may be defined, if desired.  However, the system
        ;;can automatically allocate space for a new partition from the DYNAMIC
        ;;PARTITION POOL whenever a job is started by login or JOB command.
        ;;
        ;;The maximum number of partitions that may be defined in the system is 63.
        ;;
HELPMH  ;;14
        ;;
        ;;If you wish to customize your new configuration by modifying:
        ;;
        ;;      . Terminal speed settings or other parameters
        ;;      . Magnetic tape default format
        ;;      . UCI's or database VOLUME SETS
        ;;      . TIED TERMINAL table
        ;;      . UCI translation table
        ;;      . Default GLOBAL CHARACTERISTICS/PLACEMENT
        ;;      . Routine maps
        ;;
        ;;then login to the manager's UCI and type "D ^SYSDEF"
        ;;
