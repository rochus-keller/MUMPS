SGDATA  ;3-May-83 ;UTILITIES ;SYSGEN ;ALLOCATES SPACE FOR SYSTEM DATA STRUCTURES ;JHM
        Q
START   W !,"PART 9:",?10,"SYSTEM DATA STRUCTURES",!,"-------",!
        S MEMLEFT=MEMTOT-MEMUSE(18),PARDEF=PARMIN,MEMUSE=MEMUSE(18)
        S POOL=^SYS(ID,"MEM.ALLOC","SATMAP")+63\64*64+(^("BBTAB")+63\64*64)
        S POOL=^("DISK-TAPE BUFFER POOL")\1024+1*4+63\64*64*4+POOL
        D ROOM^SGBUFF G:%A RETURN
        W !,"Space allocated for DISK-MAP and BAD BLOCK TABLE:",?50,$J(POOL,6)," Bytes",!
        S POOL=^SYS(ID,"MEM.ALLOC","TRANSLATION TABLE")
        I POOL D MOD64,ROOM^SGBUFF G:%A RETURN W "Space allocated to UCI TRANSLATION TABLE:",?50,$J(POOL,6)," Bytes",!
        S POOL=4096 D ROOM^SGBUFF G:%A RETURN W "Space allocated to GLOBAL VECTOR TABLE:",?50,$J(POOL,6)," Bytes",!
        I ^SYS(ID,"OPTIONS","DDP")="Y" S POOL=^SYS(ID,"MEM.ALLOC","DDP BUFFERS")\512+63\64*64+^("RV TABLE")+(64*128) D ROOM^SGBUFF G
:%A RETURN W "Space allocated to DDP structures:",?50,$J(POOL,6)," Bytes",!
        I 'SOFT W "Space remaining for Data Structures + Partitions:",?50,$J(MEMLEFT/1024,6,2)," K Bytes",!
LOCK    S DEF=512,QUES="LCK" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF W !,"Space allocated to the LOCK TABLE:",?50,$J(ANS,6)," Bytes",! G SETLOK
        I $D(^SYS(ID,"MEM.ALLOC","LOCK TABLE SIZE")) S DEF=^("LOCK TABLE SIZE")
        X ^%Q("SGEN") G:%A RETURN I ANS'?1N.N!(ANS<64)!(ANS>8192) D IV G LOCK
SETLOK  S POOL=ANS D MOD64,ROOM^SGBUFF G:%A START S ^SYS(ID,"MEM.ALLOC","LOCK TABLE SIZE")=POOL
        I ^SYS(ID,"OPTIONS","MOUNT")="N" S ANS=0 G SETMNT
MOUNT   S DEF=^SYS(ID,"MEM.ALLOC","UCITAB")\1024-1,QUES="STR" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF W !,"Number of mountable DATABASE VOLUME SETS:",?50,$J(ANS,6),! G SETMNT
        X ^%Q("SGEN") G:%A START I ANS'?1N.N!(ANS>7) D IV G MOUNT
SETMNT  S POOL=ANS+1*1024 D MOD64,ROOM^SGBUFF G:%A START S ^SYS(ID,"MEM.ALLOC","UCITAB")=POOL
TTAB    ;
RMAP    I ^SYS(ID,"OPTIONS","RMAP")="N" G DONE
RMAP2   S DEF=^SYS(ID,"MEM.ALLOC","ROUTINE MAP"),QUES="RTMAP" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF W !,"Space allocated to ROUTINE MAP:",?50,$J(ANS/1024,6,2)," K Bytes",! G SETMAP
        X ^%Q("SGEN") G:%A START I ANS'?1N.N D IV G RMAP2
SETMAP  S POOL=ANS D MOD64,ROOM^SGBUFF G:%A START S ^SYS(ID,"MEM.ALLOC","ROUTINE MAP")=POOL
DONE    K POOL S MEMUSE("BUFFERS")=MEMUSE
        D START^SGPART G:%A START
RETURN  Q
MOD64   I POOL#64 S POOL=POOL+63\64*64 W "Space adjusted to ",POOL," Bytes",!
        Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
LCKH    ;;8
        ;;The LOCK TABLE is the system data structure which holds the list
        ;;of all data elements that have been locked via the LOCK and
        ;;ZALLOCATE commands.  A job requesting a LOCK must wait for
        ;;space in the LOCK TABLE if the LOCK TABLE is full.  Allocation of
        ;;of memory to the LOCK TABLE should be made as a tradeoff between
        ;;remaining memory space and the number of data elements expected to
        ;;be concurrently LOCKED.
        ;;
STRH    ;;15
        ;;Your system is allowed up to 8 concurrently mounted database volume
        ;;sets.  Each volume set appears as a single logical database
        ;;and may consist of one or more disks.  Volume Set 0, (S0) of which
        ;;the system disk is the first volume, remains mounted at all times.
        ;;Up to 7 additional volumes sets, however, may be mounted and
        ;;dismounted as SETS 1 through 3 (S1-S3). You may specify that space
        ;;be reserved for one, two or three additional UCI tables.  The only
        ;;reason for not specifying the maximum is to save memory (1024
        ;;bytes/UCI table), at the cost of limiting the number of concurrently
        ;;mounted volume sets.  Notice that this limitation does not
        ;;apply to the mounting of disks for VIEW-only (as is required to
        ;;prepare new volumes for backup, etc.), because disks mounted
        ;;for VIEW-only are not database structures, and no global or routine
        ;;access is allowed to or from those disks.
        ;;
RTMAPH  ;;7
        ;;MAPPED ROUTINES allow you to lock a set of DSM-11 routines into memory
        ;;thereby reducing the system overhead required to load a routine into
        ;;a user's partition when the routine is called.  This can greatly increase
        ;;system performance in situations in which application users are sharing
        ;;the same routines.  However, there is a tradeoff that must be made between
        ;;space allocated to mapped routines and space required for job partitions.
        ;;
TRANH   ;;9
        ;;The overhead incurred by UCI TRANSLATION appears in both memory space
        ;;and system processing needed to resolve a UCI TRANSLATION.  Processing
        ;;overhead can become appreciable if there is a large number of entries
        ;;in the table.  The intent of UCI TRANSLATION is to allow a convenient way
        ;;to reassign UCI or SYSTEM names for global references on an OCCASIONAL
        ;;basis.  Consequently, you should allocate as much space as needed for
        ;;these occasional uses, but it is a good idea to maintain only a small
        ;;number of entries in the table.  Each entry requires 18 bytes.
        ;;
LCK     ;;1;;9.1;;1
        ;;Enter the number of bytes to allocate to the LOCK TABLE
STR     ;;1;;9.2;;1
        ;;Enter the number of ADDITIONAL mountable VOLUME SETS
TRAN    ;;2;;9.3;;1
        ;;Enter the number of bytes to
        ;;allocate to the UCI TRANSLATION TABLE
RTMAP   ;;1;;9.4;;1
        ;;Enter the number of bytes to allocate to MAPPED ROUTINES
