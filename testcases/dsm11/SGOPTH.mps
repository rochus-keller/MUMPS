SGOPTH  ;29-Apr-83 ;UTILITIES ;SYSGEN ;HELP FOR SGOPTS ;JHM
TEXT    F I=1:1:$P($T(@TAG),";;",2) W !,$P($T(@TAG+I),";;",2,255)
        Q
SDPH    ;;3
        ;;SEQUENTIAL DISK PROCESSOR (SDP) is a facility which provides access to
        ;;disk storage as a sequential medium for storing and retrieving data.
        ;;
JRNLH   ;;4
        ;;JOURNAL provides an on-line trace of all database writes which, when
        ;;coupled with the BACKUP utility can provide total database recovery
        ;;in the event of a system failure.
        ;;
JOBCOMH ;;3
        ;;INTERJOB COMMUNICATIONS (JOBCOM) allows two DSM-11 jobs to communicate
        ;;via assigned JOBCOM channels using MUMPS READ/WRITE commands.
        ;;
EBCDICH ;;4
        ;;The EBCDIC translation tables provide translation of ASCII characters
        ;;to EBCDIC characters and ASCII to EBCDIC conversion.  MAGTAPE, RX02,
        ;;and TU58 can utilize the table.  The BISYNC driver requires this table.
        ;;
XDTH    ;;5
        ;;The EXECUTIVE DEBUGGING TOOL (XDT) allows you to use the console terminal
        ;;to interrupt the system and directly access any location in memory, set
        ;;break points within the DSM-11 executive, show machine registers, stacks,
        ;;and status locations.
        ;;
USRDRVH ;;7
        ;;LOADABLE DRIVERS provide space for device drivers which may be loaded
        ;;or unloaded dynamically while the system is running.  It may also
        ;;be used for your own special purposes.
        ;;
        ;;TU58, RX02, and BISYNC drivers are all provided as LOADABLE DRIVERS.
        ;;If you plan to use these devices, you must select this option.
        ;;
DRVH    ;;12
        ;;The space set aside for LOADABLE drivers may be increased or decreased
        ;;depending on the requirements of the particular installation.  If system
        ;;memory space is limited, and several loadable drivers have been selected,
        ;;this space can be reduced to free up system memory.  Reducing LOADABLE
        ;;driver space may limit your ability to LOAD all required LOADABLE drivers in
        ;;memory at the same time.  You will, however, be able to LOAD a driver, use
        ;;the device, then unload it, and load another.
        ;;
        ;;You may want to increase LOADABLE driver space if some special requirement
        ;;exists for memory space within the SYSTEM IMAGE.
        ;;
        ;;
RMAPH   ;;7
        ;;MAPPED ROUTINES allow you to lock a set of DSM-11 routines into memory
        ;;thereby reducing the system overhead required to load a routine into
        ;;a user's partition when the routine is called.  This can greatly increase
        ;;system performance in situations in which application users are sharing
        ;;the same routines.  However, you must reserve memory space in which to
        ;;load these mapped routines.
        ;;
TRANTABH        ;;7
        ;;The UCI TRANSLATION TABLES provide a flexible way to logically change
        ;;the UCI and SYSTEM names for one or more specific global arrays
        ;;without changing application code.  A translation table entry can be
        ;;built which assigns a new UCI and SYSTEM name to any global.
        ;;Each reference to that global will be made through the translation table,
        ;;and the new UCI and SYSTEM name will be applied.
        ;;
MOUNTH  ;;6
        ;;DSM-11 allows up to seven MOUNTABLE VOLUME SETS to be resident on the
        ;;system at any one time. These volume sets are complete and independent
        ;;databases.  A VOLUME SET may consist of one or more disk packs, and
        ;;may have 1 or more UCI's.  There is always at least one volume set,
        ;;the SYSTEM VOLUME SET (S0) mounted on a DSM-11 system.
        ;;
SPOOLH  ;;3
        ;;Spooling is a facility which allows multiple jobs to simultaneously
        ;;
