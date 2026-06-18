RTHELP  ;HELP TEXT FOR STATISTICS PACKAGE
        W !,"Help text for statistics package"
DEV     S %DEF=0 D ^%IOS Q:'$D(%IOD)  U %IOD W $C(12)
        F I=0:1 Q:$T(TEXT+I)=""  W $P($T(TEXT+I),";;",2,255),!
        U 0 C:%IOD'=$I %IOD Q
TEXT    ;;Help text for statistics package.
        ;;
        ;;The statistics package consists of four routines:
        ;;
        ;;  1. RTHELP (this routine) prints help text only.
        ;;
        ;;  2. RTHIST is the routine you use to log statistics data.
        ;;     Two kinds of data will be logged.  First, there are statistics
        ;;     accumulated by the system, using registers in the System Table.
        ;;     In addition, there are statistics on disk, queue, global, and
        ;;     routine usage that require a statistics-gathering job partition.
        ;;     When RTHIST is running in a job's partition, the system uses the
        ;;     partition memory space as its data logging area, and will log
        ;;     data at .1 second intervals, and also at the time of each global
        ;;     reference.
        ;;
        ;;  3. RTHIST1 will actually log the histogram sessions, by zeroing
        ;;     the counts, activating the global-module and line-clock logging
        ;;     routines, then waiting for the time interval you specify, using
        ;;     the HANG command. When RTHIST1 wakes up again, it de-activates
        ;;     logging, then stores the statistics in global ^RTH, under
        ;;     the appropriate "session" number. If you asked for more than
        ;;     one session, RTHIST1 repeats itself by zeroing the data registers
        ;;     and re-activating logging. When all the sessions have been logged
        ;;     or you have set ^RTH = 0, RTHIST1 simply halts.  You should NOT
        ;;     use ^RJD to terminate RTHIST1, because the global and line-clock
        ;;     logging routines will continue updating the partition space forever.
        ;;     When you set ^RTH=0, however, RTHIST1 stops at the end of its next
        ;;     session.  You CAN use ^SSD to terminate RTHIST1, since the continued
        ;;     statistics logging will also be terminated when the system halts.
        ;;
        ;;  4. RTHISTP is the routine you use to print statistics reports from
        ;;     the data logged in global ^RTH. These reports require 132 column
        ;;     paper, and each report has 6 sections. The first section shows
        ;;     the average number of jobs in various wait queues, as well as
        ;;     the average number of jobs concurrently accessing the global code.
        ;;
        ;;     The second section shows the average events per second for sev-
        ;;     eral input-output and database-related activities:
        ;;
        ;;     SWAPINS -- job-to-job context switches
        ;;     MAPROU  -- accesses to routines mapped into memory.
        ;;     ROUREF -- all references to routines on disk
        ;;     GLOREF -- all global references (includes DDP)
        ;;     GLOSET -- only global sets and kills
        ;;     LOGRD  -- "logical" block requests (from the disk cache)
        ;;     READS  -- actual physical disk reads into cache
        ;;     TOTRD  -- reads into cache, as well as reads for VIEW and SDP
        ;;     LOGWT  -- requests to write disk cache blocks
        ;;     WRITES -- actual physical disk writes from the disk cache
        ;;     WTSYNC -- disk writes from VIEW, SDP, etc.
        ;;     TRYLAST -- attempts by Global to bypass searching the directory
        ;;                and pointer levels, and find needed data in the last-
        ;;                previously-referenced block for that job.
        ;;     GOTLAST -- successful TRYLAST attempts.
        ;;     TTYOUT  -- characters output to terminals and line printers.
        ;;     TTYIN   -- characters input from terminal lines.
        ;;     DDPOUTx -- outgoing DDP requests for line x
        ;;     DDPINx  -- incoming DDP requests for line x
        ;;
        ;;     The third section is a selection of ratios computed from the
        ;;     database events in the second section.
        ;;
        ;;     The fourth section shows the average "busy" time for each disk
        ;;     drive, as a percentage of the total run time of session. This
        ;;     table does not show the NUMBER of accesses, but how much time
        ;;     on the average, the unit was actually active.
        ;;
        ;;     The fifth section starts a new report page, and shows the time,
        ;;     as a percentage of the total run time of the session, that each
        ;;     UCI spent running each routine. You can control the number of
        ;;     groups shown on this section of the report. RTHISTP will
        ;;     ask you to specify the number of characters that defines a
        ;;     routine group. If you specify "8", each routine will appear
        ;;     separately. If you specify "1", all routines within a UCI with
        ;;     the same first letter will be added together. If you specify
        ;;     "0", the histogram will show only one line per UCI.
        ;;
        ;;     The sixth section starts another new report page, and shows the
        ;;     average number of accesses per second for all globals accessed
        ;;     during the session.
