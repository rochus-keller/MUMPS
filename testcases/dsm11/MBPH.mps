MBPH    ;4-May-83 ;UTILITIES ;SYSGEN ;HELP FRAMES FOR MBP ROUTINES ;JHM^
TEXT    S NO=$P($T(@TAG),";;",2) F I=1:1:NO W !,$P($T(@TAG+I),";;",2,255)
        Q
CHKH    ;;7
        ;;WRITE CHECK will cause DSM-11 to read every block it writes to disk
        ;;immediately following the write to see if the block was written
        ;;correctly and attempt to correct any errors detect.  The system will
        ;;inform the system manager if there was an error.  Selecting this
        ;;feature will give you immediate information on the status of disk
        ;;writes, however, it does increase disk IO overhead.
        ;;
DKFULH  ;;16
        ;;Allocation of disk blocks to global arrays may occur during any
        ;;global SET command.  If the disk is entirely full, attempts to
        ;;allocate a block during the SET operation will fail and the SET
        ;;may not complete, possibly causing a degradation of the database.
        ;;
        ;;To avoid this problem, a certain number of disk blocks on the disk
        ;;volume should be held in reserve.  When all disk blocks in the
        ;;volume have been allocated, a block is allocated from the reserve,
        ;;the SET operation is completed, and <DKRES> error is given to the job
        ;;which caused the SET.  The SYSTEM MANAGER, must then provide additional
        ;;disk space.
        ;;
        ;;A maximum of 399 blocks may be reserved per VOLUME SET.  This system
        ;;wide value is used only on volume sets greater than 2 M Bytes.
        ;;A fixed value of 10 blocks is assigned to smaller volume sets.
        ;;
BIT8H   ;;11
        ;;Previous versions of DSM-11 provided support only for 7 bit subscripts.
        ;;7 bit format does not allow control codes or extended character set codes
        ;;to be used in global subscripts.
        ;;
        ;;8 Bit subscripts are currently supported and also allow collation of
        ;;negative subscripts under the ANS 82 MUMPS standard.  Programs requiring
        ;;compatibility with the previous collating scheme should choose the 7 bit
        ;;format subscript.
        ;;              Answer N to use 7 bit subscripts
        ;;              Answer Y to use 8 bit subscripts
        ;;
JRNDH   ;;5
        ;;      Answer Y if you want globals to be journaled by default
        ;;      Answer N if you do not want globals to be journaled by default
        ;;
        ;;This question only applies if you have selected the JOURNAL option.
        ;;
COLDH   ;;9
        ;;NUMERIC collating sequence will force all numeric (cononic) subscripts
        ;;to be collated before STRING subscripts.
        ;;
        ;;STRING collating sequence will force all STRING subscripts to be collated
        ;;before NUMERIC subscripts.
        ;;
        ;;Enter N to select NUMERIC collating as the default collating sequence.
        ;;Enter S to select STRING collating as the default collating sequence.
        ;;
DEFDSKH ;;5
        ;;Default global characteristics are applied to all newly created globals
        ;;on a system-wide basis.  While these are the default characteristics,
        ;;globals may still be created with different characteristics using
        ;;the utility, ^%GCH.
        ;;
