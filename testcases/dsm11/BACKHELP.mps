BACKHELP        ;DSM11 Utilities;Copyright 1980 DEC
ASKO    S %DEF=0,%QTY=2,%I=$I D ^%IOS I '$D(%IOD) Q
        S $ZT="ERR^BACKHELP"
        I "SC,TRM,LP"'[%DTY U 0 W !,?5,"*Improper device selection",! G ASKO
        U %IOD W:%DTY="LP" # W:%DTY="TRM" !!
        F L=1:1 S TX=$T(BH+L) Q:TX=""  S TX=$P(TX,";;",2,99) D:TX="*CR*" WAIT W:TX'="*CR*" TX,!
        D CONTIN^BACKHELA
        W:%DTY="TRM" !! W:%DTY="LP" #
        U 0 G END
ERR     U 0 W !,$ZE,!
END     W !! I $D(%IOD) C:%IOD'=$I %IOD
        Q
WAIT    I %IOD=%I R ?55,"Type <CR> to continue",P
        W ! Q
BH      ;;
        ;;Backups are performed in DSM11 V3 by a two-step process:
        ;;  1. Create a "Backup Command File",
        ;;  2. Execute it.
        ;;Either of these steps may be invoked by   D ^BACKUP.
        ;;
        ;;When you create a Backup-Command-File, you give it a name (up to 12 characters)
        ;;by which you later refer to it.  You refer to this name when you wish to edit
        ;;that file, or examine it, or delete it, or execute it.
        ;;
        ;;When you execute the Backup-Command-File, it performs all the backups you have
        ;;specified.  For each backup to be performed, you have told it (1) the drive
        ;;that will contain the Master disk to be backed up, (2) what that disk's Master
        ;;Label will be, and (3) which disk (or magtape) drive will contain the Backup
        ;;volume.  If the information being backed up doesn't fit on one Backup disk or
        ;;magtape, you will be asked to mount a second, and so on.
        ;;You may specify up to 9 disks to be backed up in one Backup Command File.
        ;;*CR*
        ;;
        ;;Following is a short summary of how the disk drives are manipulated by DSM
        ;;while you are doing a Backup:
        ;;
        ;;  1. Running the Baseline System
        ;;
        ;;When running the Baseline System, the only disk you may back up is the
        ;;System disk.  If you wish to back up any other disk, you must be running
        ;;some configuration other than the Baseline configuration at the time you
        ;;execute the Backup-Command-File.
        ;;
        ;;  2.  Not running the Baseline System  (Running any other configuration)
        ;;
        ;;In this case, for each Backup specified in your command file, you may declare
        ;;any disk drive in your hardware configuration to be the drive that will hold
        ;;the Master disk to be backed up, and any (other) drive to be the one that
        ;;will hold the Backup.  This is true even if one, or both, drives are "Resident"
        ;;in the configuration you are running.  The operating system acts intelligently,
        ;;as follows:
        ;;
        ;;*CR*
        ;;If neither drive is "Resident" in the configuration you are running (that is,
        ;;neither drive is required to contain a disk in order to run that configuration)
        ;;then the system simply issues Mount messages at the appropriate times, and
        ;;you mount your disks, and the Backup proceeds without otherwise affecting
        ;;system operation.  Other users who are logged on will continue to run,
        ;;probably without knowledge that the Backup is in progress.
        ;;
        ;;If the drive that you said would hold the Master disk is "Resident", then
        ;;the system will read the label of the disk already mounted there, and if
        ;;the disk already there is the disk to be backed up, it will proceed to back
        ;;up that disk.  If that is *not* the disk to be backed up, the system will
        ;;at an appropriate time, ask you to Dismount the "Resident" disk from that
        ;;drive, and mount the disk that is to be backed up.  At the termination of
        ;;the Backup, it will remind you to re-mount the "Resident" disk.  At each
        ;;of these steps, the system will be checking the Labels, to make sure you
        ;;don't inadvertently mount an incorrect disk.
        ;;
        ;;If the drive that will hold the Backup disk is "Resident" in the config-
        ;;uration you are running, you will similarly be told, at the appropriate
        ;;time, to dismount the "Resident" disk from the drive, and mount the Backup
        ;;disk.  (And you will be reminded to re-mount the Resident disk at the
        ;;termination of the Backup.)
        ;;
