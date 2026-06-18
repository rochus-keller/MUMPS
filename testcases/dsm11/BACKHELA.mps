BACKHELA        ;DSM11 Utilities;Copyright 1980 DEC
        Q
CONTIN  F L=1:1 S TX=$T(BH2+L) Q:TX=""  S TX=$P(TX,";;",2,99) D:TX="*CR*" WAIT W:TX'="*CR*" TX,!
        Q
WAIT    I %IOD=%I R ?55,"Type <CR> to continue",P
        W ! Q
BH2     ;;
        ;;*CR*
        ;;Note this: When a Backup requires you to dismount a Resident disk, that
        ;;Backup will automatically be performed with "Database Reads and Writes
        ;;disabled" -- any job that attempts to read or write a disk block will
        ;;automatically be hung until that Backup completes and the Resident disks
        ;;have been re-mounted successfully.
        ;;When a Backup does not require dismounting any Resident disks, but the
        ;;Master being backed up *is* a Resident disk, that Backup will be performed
        ;;with "Database Writes disabled".  This means users may access the disks
        ;;for reading (such as obtaining the value of a global, or loading a routine),
        ;;but any user who attempts to write (such as to set or kill a global, save
        ;;a routine, write output to an SDP area, or write Spool output) will auto-
        ;;matically be hung, until that Backup is complete.  This is to prevent
        ;;the Master disk changing while it is in the process of being backed up.
        ;;
        ;;*CR*
        ;;
        ;;Additional Information
        ;;
        ;;Each disk to be backed up must contain a DSM11 V3 Master Label, before the
        ;;Backup begins.  You initially put a label on a disk by means of the Disk
        ;;Preparation programs (type "D ^DISKPREP", or boot the Distribution Magtape),
        ;;and you may inspect or change the label by typing "D ^LABEL".
        ;;Each disk to be used as a Backup disk must have a DSM11 V3 Backup Label on
        ;;it.
        ;;
        ;;When you are asked to mount a Backup disk, you may mount any disk with a
        ;;Backup Label on it.  The label will be displayed for you, and you will be
        ;;asked if it is ok to proceed, using that disk.  If you answer no, you will
        ;;be given an opportunity to dismount that disk and mount a different one.
        ;;
        ;;*CR*
        ;;
        ;;IN-USE Backup
        ;;
        ;;Normally you will back up ALL the DSM blocks from a disk, but you may choose,
        ;;if you wish, to back up only those blocks which are "in use" according to
        ;;the Map blocks on the disk.  The blocks which are not in use will not be
        ;;backed up.  Choosing this option will rarely save you time, but it can
        ;;save considerable space on the backup disk or tape, since only those
        ;;blocks that are in use will be written.  Also, when you choose the in-use
        ;;option, the Backup medium, if disk, need not be the same type of disk as
        ;;the Master.  For example you can back up an RK06 to RK05 or RL01 -- if you
        ;;choose the in-use option.
        ;;
        ;;*CR*
        ;;
        ;;Interaction with Journaling
        ;;
        ;;You are permitted to specify one of the following when creating a Backup-
        ;;Command-File:
        ;;  1. You don't care whether journaling is running when the Backup is
        ;;     performed -- journaling will continue normally in this case, if it
        ;;     is running;;
        ;;  2. You want to hang journaling (and all jobs that attempt to journal)
        ;;     while the Backups are in progress.  At final termination, if all the
        ;;     Backups specified in the command file completed successfully, you
        ;;     want to shut down the old journal and start a fresh journal (because
        ;;     you don't need the old journal any more;; if you need to restore your
        ;;     database, you can do it from the Backups):
        ;;  3. You want to unconditionally STOP the current journal before beginning
        ;;     the Backups, then start a fresh journal upon completion, whether
        ;;     successful or not.  (As in case 2 above, all jobs that attempt to"
        ;;     journal will automatically be hung, until the new journal is started.)
        ;;
        ;;*CR*
        ;;
        ;;Restoring Disks
        ;;
        ;;To Restore the information from a Backup Disk back to a Master, you
        ;;must have a Master disk with the correct label (that is, a disk with
        ;;Master Label the same as the label the original Master had when you
        ;;backed it up).  You type "D ^Rest" to begin the Restore.
        ;;
