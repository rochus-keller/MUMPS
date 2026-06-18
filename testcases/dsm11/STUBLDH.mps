STUBLDH ;5-Jul-83 ;UTILITY ;STARTUP ;QUERY AND HELP TEXT FOR STUBLD ;JHM
PATCH   W "Apply patches to memory" Q
PATCHH  W !,"All defined patches from ^SYS global will be applied to memory",!! Q
JRNL    W "Start up the Journal" Q
JDEVH   ;
JNAMH   ;
JMAGH   ;
JRNLH   W !,"See your DSM-11 USER'S GUIDE for a description of the Journal.",!! Q
SPOOL   W "Enable the Spool device (device #2)" Q
SPOOLH  W !,"You must have spool space allocated in order for startup to"
        W !,"successfully enable the spool device.",!! Q
DSPLR   W "Start up the Despooler background job" Q
DSPLRH  W !,"The despooler background job requires a 2K-byte partition.",!! Q
DVHLP   W !,"The default spool device must an output-only terminal or a line printer.",!! Q
DDPJ    W "Startup Distributed Database Processing" Q
DDPJH   W !,"Distributed Data Processing startup involves enabling all"
        W !,"circuits and links to remote DSM systems and starting the DDP"
        W !,"server jobs to handle incoming requests from the remote systems."
        W !,"This will make DDP completely available for users.",!! Q
CTKR    W "Start the Caretaker background job" Q
CTKRH   W !,"The Caretaker logs device errors to the ^CTK global,"
        W !,"and prints messages on the device you select.",!! Q
USRDRV  W "Install LOADABLE DRIVERS on startup" Q
USRDRVH W !,"If you wish to have any or all of the loadable drivers selected during"
        W !,"Sysgen installed at startup, answer yes to this question",!! Q
DRIVER  W "Install the ",DRV," driver" Q
DRIVERH W !,"Answer YES to this question if you want the ",DRV," driver loaded on startup",!! Q
EDEVH   W !,"Select any terminal defined in your system, hard-copy if possible.",!! Q
ELOGG   W "Automatic logging of DSM errors" Q
ELOGGH  W !,"Automatic error logging will provide a facility to trap application"
        W !,"errors such as ""<UNDEF>"" , log the error, and save the"
        W !,"symbol table for debugging purposes.",!!
        Q
ELOGH1  D ELOGGH W "To enable auto logging, the Job Comm option must be selected during SYSGEN"
        W !,"and the Caretaker Background Job must be selected to run.",!
        I CTK'="Y" W !,"The Caretaker is not currently selected to run.",!
        I ^SYS(ID,"OPTIONS","JOBCOM")'="Y" W !,"The Job Comm option is not available in this configuration",!
        W ! Q
ELDH    W !,"Must be a valid Job Comm Transmitter, like 225,227,...,255",!! Q
ELD     W "  Enter the Job COMM device number to use for error logging" Q
STUDF   W "Make this the new startup file for configuration ",ID Q
STUDFH  D IDEFH Q
IDEF    W !,"Make ",ID," the new default configuration" Q
IDEFH   W !,"Enter 'Y' or 'N'.",!! Q
JDEV    W "  Journal to Disk or Magtape  [ D or M ]" Q
JNAM    W "  Journal Space name" Q
JMAG    W "  Mapgtape Unit  (0-3) " Q
DEFSPL  W "  Enter the default spool device number" Q
DEFSPLH W !,"Enter the device number for the device that will be used"
        W !,"for default spooler output.  The device must be configured as"
        W !,"an OUTPUT only device",!! Q
ERDEV   W "Enter the Printer Number for system error messages" Q
ERDEVH  W !,"Enter the device number that you would like to use"
        W !,"for any system error reporting",!! Q
UP      W !,"Type  ^  to return to the previous question",! Q
RMAP    W "Load Mapped Routine Sets on Startup" Q
RMAPH   W !,"If you want 1 or more of the defined Mapped Routine Sets"
        W !,"to be loaded on startup, type Y",!! Q
IMAP    W "Load Routine Set ",NAM Q
DISK    W "Enter Disk Unit to Mount Volume 1" Q
DISKH   W !,"Enter the disk type mnemonic and disk unit number in"
        W !,"the form DK0 (specifies RK05 unit 0)"
        W !!,"The following forms are supported:",!
        W !,TYPES,! Q
MNT     W "Mount additional disk volumes" Q
MNTH    W !,"If you wish to mount any additional disks besides"
        W !,"those in the System volume set, type Y.",!! Q
MOUNTH  W !,"This table allows you to inspect and change the list of disk"
        W !,"volumes and volume sets to be mounted or dismounted at startup time."
        W !!,"In the first column, DISK UNIT, enter the disk unit that holds"
        W !,"the volume to be mounted.  Use the form DDU (ex. DK0 = RK05 unit 0)."
        W !,"For multi-volume Volume sets, enter only the drive that holds"
        W !,"Volume 1 of the set. Use the form, -DDU to delete a disk unit from the"
        W !,"table.  A blank <RETURN>  in this table position will terminate the table."
        W !!,"In the second column, DISK VOLUME SET ?, enter Y if the disk being"
        W !,"mounted is a database volume set, enter N if the disk has been prepared"
        W !,"for use only as a SPOOLING, JOURNAL, or SDP volume (NON-UCI disk)."
        W !!,"In the third column, LABEL/VOLUME SET NAME, enter the disk LABEL"
        W !,"if the disk is a NON-UCI volume, or enter the VOLUME SET NAME, if the"
        W !,"disk is a volume set disk.  Note that LABELS may not exceed"
        W !,"22 characters and must be enclosed in quotes.  VOLUME SET NAMES, are"
        W !,"unique 3-character names given to the VOLUME SET at disk preparation"
        W !,"time.",! Q
ALAB    W !!,"Each mounted volume set must have a unique 3-character name when"
        W !,"mounted on the system.  At DISKPREP time, this volume set was given"
        W !,"a name, however, the STARTUP command file you are configuring requires"
        W !,"that 2 Volume Sets with identical names be mounted at Startup.  Consequently,"
        W !,"you must enter an alternate name to be used for mounting this "
        W !,"Volume Set.",! Q
