SGBUFFH ;1-Aug-83 ;UTILITY ;SYSGEN ;HELP TEXT FOR BUFFER ALLOCATION OF SYSGEN ;JHM
TEXT    F I=1:1:$P($T(@TAG),";;",2) W !,$P($T(@TAG+I),";;",2,255)
        Q
DDPQH   ;;11
        ;;DDP buffers are used to hold incoming and outgoing DDP requests
        ;;and responses.  The default supplied will usually be more than
        ;;adequate to buffer DDP messages.  However, in very large DDP
        ;;networks, where a single node receives a majority of the DDP requests
        ;;(logical star network) and that node is exhibiting OUT-OF-BUFFER
        ;;conditions (as reported by the ^DDPLNK link status utility, it may
        ;;be necessary to raise the number of buffers.
        ;;
        ;;Note that DDP buffers compete for memory space with the number of
        ;;DISK buffers, and ring buffer space. Maximum number of buffers is 250.
        ;;
RBPH    ;;6
        ;;RING BUFFER POOL is the memory space from which terminal and JOBCOM RING
        ;;BUFFERS are allocated when a device is opened or logged into.  Space is
        ;;allocated in bytes, and the RING BUFFER pool must hold at least 2
        ;;default-sized RING BUFFERS.  Your system will require a total of 2 RING
        ;;BUFFERs for EACH active terminal and for each active JOBCOM channel.
        ;;
RBSH    ;;15
        ;;Each terminal requires two RING BUFFERS of 2 to 255 bytes.
        ;;RING BUFFERS are used for INPUT and OUTPUT intermediate storage for
        ;;data being transmitted and received.  When the RING BUFFER is filled,
        ;;the job transmitting the data must be placed in a wait Q until the
        ;;the terminal has received some of the data.  While it may be desireable
        ;;to maximize a job's IO throughput by increasing RING BUFFER size,  this
        ;;must be traded against memory space considerations.
        ;;
        ;;The default ring buffer size is the size of buffer acquired when a terminal
        ;;is first opened.  A different buffer size may be selected at open time via
        ;;an optionnal OPEN parameter. Memory will be most efficiently used if specified
        ;;in multiples of 32 bytes.
        ;;
        ;;RING BUFFER sizes may not be less than 32 bytes or exceed 255 bytes.
        ;;
CASH    ;;13
        ;;DISK-TAPE cache blocks are 1 KB block buffers used for DISK, TAPE, JOURNAL,
        ;;VIEW, DMC block mode, TU58, RX02, BISYNC, and all SEQUENTIAL disk operations.
        ;;Since disk operations where data is shared for global access is especially
        ;;optimized by large disk caches, it is advisable to allocate as much space as
        ;;possible for cache buffers.  Memory space considerations must be weighed
        ;;against the number of cache blocks.  Room for three partitions plus space for
        ;;a journal overhead (if Journal was selected) must be available.  Also, system
        ;;constraints require that total buffer allocation space does not exceed the
        ;;value shown above.
        ;;
        ;;You must allow for 7 cache blocks plus the number of buffers selected for
        ;;Journal.
        ;;
OVR18H  ;;8
        ;;The buffer space has overflowed the boundary for buffer allocations.  You must
        ;;reduce one of the following parameters:
        ;;
        ;;      Space allocated for RING BUFFERS
        ;;      Space allocated for Loadable drivers (if specified)
        ;;      Reduce the number of Software options selected
        ;;      DDP buffers (if any)
        ;;
OVRPARH ;;7
        ;;There is not enough memory left for the minimum partition allocation.  You must
        ;;reduce one of the following parameters:
        ;;
        ;;      Space allocated for DISK-TAPE, RING, or DDP BUFFERS
        ;;      Space allocated for Loadable drivers (if specified)
        ;;      Reduce the number of Software options selected
        ;;
WANTH   ;;11
        ;;Distributed Data Processing (DDP) is a facility that allows you to
        ;;access global arrays on another DSM-11 system connected via the DMC-11
        ;;communications device.  A routine can request data from the remote
        ;;system using an "extended" global reference syntax.
        ;;
        ;;DMC's can be used for DDP communications or as single line CPU-to-CPU
        ;;communications devices.
        ;;
        ;;Answer "Y" if you wish to use this DMC for DDP communications.
        ;;Answer "N" to use the DMC as a single line communication device.
        ;;
