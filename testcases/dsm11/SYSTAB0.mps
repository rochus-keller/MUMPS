SYSTAB0 ;UPDATED FOR DSM V3 ;;
        W !?5,*7,"This subroutine should be run using the ^SYSTAB utility.",!,*7 Q
START   K ^SYSTAB S ^SYSTAB=$ZV_" DSM-11 System Table"
        W !,"Creating Global ^SYSTAB"
        F I=1:1 S T=$T(ST+I) Q:T=""  D NEWSA W:'(I#10) "."
        D START^SYSTAB1 K I,J,P,SA,T W ! Q
NEWSA   S SA=+T,T=$P(T,";;",2)
        F J=1:1 S P=$P(T,";;",J) Q:P=""  S ^SYSTAB(SA)=P,SA=SA+P
        Q
ST      ;
0       ;;SOFTSW,DSM Switch Register
2       ;;LNKTBL,Pointer to Linkage Table,for selectable modules
4       ;;JOBTAB,Pointer to Job Table
6       ;;PARTAB,Pointer to Partition Table
8       ;;DEVTAB,Pointer to Device Table
10      ;;DDBBEG,Pointer to start of single line,TTY Device Descriptor Blocks
12      ;;STRTAB,Pointer to mounted volume set table
14      ;;BDBLHT,Pointer to table of listheads for BDB lists
16      ;;$MBP$,Pointer to Ring Buffer Pool (*64)
18      ;;$MBPL$,Contains size of the Ring Buffer Pool (*64)
20      ;;MLXBEG,Contains address of Device #64,Device Descriptor Block
22      ;;MTDDB,Pointer to start of magtape,Device Descriptor Blocks (last MUX DDB +1)
24      ;;DSKLOK,Holds job number of current disk user,,1
25      ;;DSKACT,Holds 1 if normal disk interrupt pending,Holds >1 if power fail is restarting the disk,1
26      ;;MMUSE,Pointer to User code (*64)
28      ;;MMKER,Pointer to Kernel code (*64)
30      ;;GBFBDB,Contains address of the first,Global Buffer Descriptor Block
32      ;;GBFNUM,Contains number of Global buffers,set by start-up code
34      ;;STRSIZ,Holds size of STRTAB entries,,1
35      ;;BASLIN,Bit 0=1 if running baseline system
36      ;;TICKS,Contains number of clock ticks,left in current tenth/second,1
37      ;;NUMTPS,Contains number of clock ticks,per tenth/second,1
38      ;;ROUMAP,Contains mm address of mapped routine directory
40      ;;NUMTTS,Contains number of ticks,in a standard time slice,1
41      ;;HITIME,Contains high order time,,1
42      ;;TIME,Contains low order time
44      ;;DATE,Contains count of days
46      ;;SPBASE,Points to top of User stack
48      ;;KSPBAS,Points to top of Kernel stack
50      ;;LOWSTK,Points to bottom of User stack
52      ;;not used
54      ;;JRNDEV,Current journaling device,128=disk  47-50=magtape,1
55      ;;JRNJBN,Contains system internal job #,for journal
56      ;;SYSDSK,System Disk device code,Type (Bits 5-7) Unit (Bits 2-4),1
57      ;;not used
58      ;;TASCII,Pointer to bit-mask table for pattern match
60      ;;ASTPNT,Pointer to asynchronous timer table
62      ;;RBFRE,Ring Buffer Pool free space listhead,(M M Block No.)
64      ;;LCKTAB,Points to Lock Table (/64)
66      ;;LCKSIZ,Contains size of Lock Table,in bytes (20000 octal max.)
68      ;;TTYSIZ,Contains size of TTY,Device Descriptor Block (in bytes)
70      ;;NECHO,=1 if no echo on login,,1
71      ;;WRTCHK,Write checks disks if non-zero,,1
72      ;;XSHRTQ,Contains extended reference for,SHORTQ offset from JOBTAB
74      ;;WAKJOB,Contains job*2 set by utility ^RJD,,1
75      ;;ONEJOB,Job*2 of single-user job,,1
76      ;;PAC,1st character of Programmer Access Code is,@$C(PT),1
77      ;;      ,2nd character of Programmer Access Code is,@$C(PT),1
78      ;;      ,3rd character of Programmer Access Code is,@$C(PT),1
79      ;;      ,Unused,,1
80      ;;INGLOB,Counter of jobs currently in Global Module
82      ;;GLOCK,Job*2 seizing global code,,1
83      ;;INTKEY,Alternate interrupt key (Init to CTRL-C),Will only work for CTRL keys (ASCII 0-37),1
84      ;;REQWR,If =1 a disk buffer has requested to be written,,1
85      ;;IDLEWR,When set the idle loop should start Write Demon,,1
86      ;;BBTAB,MM address of base of bad block table
88      ;;not used
90      ;;not used
92      ;;VECTOR,Common interrupt vectors and stack
94      ;;SYSTAB,System Table
96      ;;EXEC,Common Executive
98      ;;MUMPS,Common MUMPS routines
100     ;;PATCH,Patch space
102     ;;INTERP,MUMPS Interpreter
104     ;;SUBRS,Miscellaneous subroutines
106     ;;EVAL,Expression Evaluator
108     ;;SYMBOL,Symbol Table Manager
110     ;;GLOBAL,Global Database Manager
112     ;;ALLOC,Disk Allocation module
114     ;;ZCALL,ZCALL module
