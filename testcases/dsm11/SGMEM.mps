SGMEM   ;12-May-83 ;UTILITIES ;SYSGEN ;FIGURE OUT MEMORY SIZE FOR EXEC ;JHM
        Q
START   S CCEND=$V(ST+28)*64,INBLK=0,LINKTAB=ST+128
        S ADR=LINKTAB D GETWRD S MODSTRT=CON
        S KERSIZ=MODSTRT-8192,DDBSIZ=0
        S LIST="TTY;MAGTAPE;SPOOL;SDP;DMC;JOBCOM;DDP;USRDRV"
        S LINKTAB=ST+134
        F I=1:1:$L(LIST,";") S MOD=$P(LIST,";",I) D  S LINKTAB=LINKTAB+2
        .I ^SYS(ID,"OPTIONS",MOD)="N" Q
        .S ADR=LINKTAB D GETWRD S KERSIZ=CON*64+KERSIZ
        .D @(MOD_"I")
        S ADR=ST+128 D GETWRD S DDBMIN=CON
        S ADR=ST+130 D GETWRD S DDBMIN=CON-DDBMIN+63\64*64
        S DDBSIZ=DDBSIZ+63\64*64 I DDBSIZ<DDBMIN S DDBSIZ=DDBMIN
        S ^SYS(ID,"MEM.ALLOC","KERNEL")=KERSIZ,^("USER AND COMMON")=CCEND,^("DDB'S")=DDBSIZ
        S KERSIZ=KERSIZ+DDBSIZ
        W !,"Total System Exec size:",?50,$J(KERSIZ+CCEND/1024,6,2)," K Bytes",!
        K MOD,LINKTAB,SETDEF,OPT,INBLK,ADR,MODSTRT,CON,LIST,TAB,LOAD,USRADR,NAME,NEED,MODSUB,OPTSHO,DDBSIZ,DRVLN,SIZ,HLP,DDBSIZ,DDBMIN
        D START^SGBUFF
RETURN  Q
TTYI    S DDBSIZ=2+^SYS(ID,"CONTROLLER","SINGLE")+(^("DH11")*16)+(^("DHU11")*16)+(^("DHV11")*8)+(^("DZ11")*8)+(^("DZV11")*4)*$V(ST+68)+DDBSIZ
MAGTAPEI        S DDBSIZ=$V(ST+298)*^SYS(ID,"MT")+DDBSIZ Q
JRNLI   S DDBSIZ=$V(ST+302)*^SYS(ID,"MEM.ALLOC","JOURNAL BUFFERS")+DDBSIZ Q
SPOOLI  Q
SDPI    S DDBSIZ=$V(ST+232)*4+DDBSIZ Q
DMCI    Q
JOBCOMI S KERSIZ=$V(ST+300)*^SYS(ID,"JOBCOM","CHANNELS")+KERSIZ Q
DDPI    S DDBSIZ=$V(ST+384)*^SYS(ID,"DDP","LINES")+DDBSIZ Q
USRDRVI S KERSIZ=^SYS(ID,"MEM.ALLOC","USRDRV")+63\64*64+KERSIZ+2 Q
GETWRD  I ADR\1024+2'=INBLK S INBLK=ADR\1024+2 V INBLK:"S0"
        S CON=$V(ADR#1024,0) Q
TEXT    F I=1:1:$P($T(@TAG),";;",2) W !,$P($T(@TAG+I),";;",2,255)
        Q
CHANSH  ;;7
        ;;Each JOBCOM channel is a pair of pseudo-devices that communicate
        ;;via a single RING BUFFER.  There are 32 device numbers (224-255)
        ;;reserved for a total of 16 channels. Each pair consists of an
        ;;even numbered device (the receiver), and the following odd
        ;;numbered device (the transmitter).
        ;;
        ;;
RINGH   ;;13
        ;;Each JOBCOM channel requires a RING BUFFER of 2 to 255 bytes.
        ;;RING BUFFERS are INPUT/OUTPUT intermediate storage buffers for data being
        ;;transferred from one job to another.  When the RING BUFFER is filled,
        ;;the job transmitting the data must be placed in a wait Q until the
        ;;receiving job has removed some of the data.  While it may be desireable
        ;;to increase communications speed by increasing RING BUFFER size,  this
        ;;must be traded against memory space considerations.
        ;;
        ;;Enter the default size you would like for JOBCOM ring buffers.
        ;;RING BUFFERS will use memory most efficiently if specified in
        ;;multiples of 64 bytes.
        ;;
        ;;
JBSH    ;;15
        ;;The JOURNAL facility requires in-memory 1 KBYTE buffers to hold records
        ;;of each database WRITE transaction.  When a buffer is full, the JOURNAL
        ;;job marks the buffer to be written to the selected output device.  If
        ;;more than 1 buffer has been allocated to the JOURNAL, JOURNAL immediately
        ;;begins filling the next free allocated buffer with database transactions.
        ;;If no allocated buffers are free, jobs attempting to JOURNAL transactions
        ;;are put into a WAIT Q until a buffer becomes free.
        ;;
        ;;Allocating more than 1 buffer to JOURNAL can increase JOURNALLING
        ;;efficiency by "streaming" blocks to the output device.  However, the
        ;;block buffers are allocated directly from the system disk buffer cache,
        ;;so that memory space and disk efficiency must be traded again JOURNALLING
        ;;requirements.
        ;;
        ;;
