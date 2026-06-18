SYSTAB1 ;1-May-86 ;DSM ;3.2 ;TABLE ;KFD
        W !?5,*7,"This subroutine should be run using the ^SYSTAB utility.",!,*7 Q
START   F I=1:1 S T=$T(ST+I) Q:T=""  D NEWSA W:'(I#10) "."
        G START^SYSTAB15
NEWSA   S SA=+T,T=$P(T,";;",2)
        F J=1:1 S P=$P(T,";;",J) Q:P=""  S ^SYSTAB(SA)=P,SA=SA+P
        Q
ST      ;
128     ;;DDBTAB,Pointer to device descriptor blocks
116     ;;KEXEC,Kernel Executive
120     ;;DISK,Disk Driver
120     ;;EMT,Emulator Traps
132     ;;KIOD,Terminal I/O Handler
126     ;;DSMXDT,Executive Debugging Tool
134     ;;MTD,Magnetic tape handler
124     ;;EBCDIC,EBCDIC conversion table
122     ;;JRNL,Journal handler
136     ;;SPOOL,Spooling handler
138     ;;SDP,Sequential Disk Processor
140     ;;DMC,DMC handler
142     ;;JOBCOM,Inter-job communications handler
144     ;;DDP,Distributed Database Processor
146     ;;USRDRV,User written driver
148     ;;SYSEND,End of executable code
130     ;;CONFIG,Pointer to autoconfigure module
150     ;;BOOTDK,Pointer to 1st of 3 boot modules (DK+DL+DU)
152     ;;DD$$,Pointer to TU58 driver module
154     ;;DY$$,Pointer to RX02 driver module
156     ;;XJ$$,Pointer to BISYNC driver module
158     ;;ENDSYS,End of system image
160     ;;CMDREF,Command reference number for disk
162     ;;UDAERR,Holds code for last error on UDA controller
164     ;;MTS    MTCS1   TSBA    RKDS    RKCS1   R-CS1   RLCS    PSW
166     ;;MTC    MTWC    TSSR    RKER    RKWC    R-WC    RLBA    R0
168     ;;MTBRC  MTBA    MSG-HDR RKCS    RKBA    R-BA    RLDA    R1
170     ;;MTCMA  MTFC    12.     RKWC    RKDA    R-DA    RLMP    R2
172     ;;MTD    MTCS2   RES-CNT RKBA    RKCS2   R-CS2   ....    R3
174     ;;MTRD   MTDS    XSTAT0  RKDA    RKDS    R-DS    ....    R4
176     ;;....   MTER    XSTAT1  ....    RKER    R-ER1   ....    R5
178     ;;....   MTAS    XSTAT2  RKDB    RKAS    R-AS    ....    K-SP
180     ;;....   MTCC    XSTAT3  ....    RKDC    R-LA    ....    U-SP
182     ;;....   MTDB    ....    ....    ....    R-DB    ....    PSW
184     ;;....   MTMR    ....    ....    RKDB    R-MR1   ....    PC
186     ;;....   MTDT    ....    ....    RKMR1   R-DT    ....    PAR5K
188     ;;....   MTCN    ....    ....    RKECPS  R-SN    ....    PAR6K
190     ;;....   MTTC    ....    ....    RKMR2   R-OF    ....    PAR5U
192     ;;....   ....    ....    ....    RKER2   R-DC    ....    PAR6U
194     ;;....   ....    ....    ....    RKMR3   R-HR    ....    PAR7U
196     ;;....   ....    ....    ....    ....    R-MR2   ....    CPU-ERR
198     ;;....   ....    ....    ....    ....    R-ER2   ....    MEM-ERR
200     ;;....   ....    ....    ....    ....    R-EC1   ....    LOWADD
202     ;;....   ....    ....    ....    ....    R-EC2   ....    HIADD
204     ;;DKMPMS,Contains Hi byte of DSM block number of,block with errors (Low byte = Log status)
206     ;;      ,The next two lower bytes of DSM block number,of block with errors
208     ;;$ERDEV,Error device type name (ascii)
210     ;;$ERUNT,Unit number of error drive (binary),,1
211     ;;$ERCNT,Number of retries on error device,,1
212     ;;$ERCSR,Contains initial CSR address,for error device
214     ;;$ERNMB,Contains number of CSR status,words to print
