MBP1H   ;4-May-83 ;UTILITIES ;SYSGEN ;HELP FRAMES FOR MBP ROUTINES ;JHM^
TEXT    S NO=$P($T(@TAG),";;",2) F I=1:1:NO W !,$P($T(@TAG+I),";;",2,255)
        Q
UDAQH   ;;7
        ;;DUAL-PORTING allows two CPUs to dynamically interleave requests to
        ;;the same disk.  UDA disks that are dual ported require a flag in
        ;;memory so that the disk driver knows whether to release control of
        ;;a particular unit after its disk transfer has completed.  Your answer
        ;;should be a series of unit numbers, separated by commas, or the word
        ;;"NONE".
        ;;
VPROTH  ;;4
        ;;VIEW PROTECTION will allow the use of the VIEW command only from
        ;;the SYSTEM MANAGER account and LIBRARY UTILITIES (routines with names
        ;;that begin with the % character).
        ;;
ZPROTH  ;;4
        ;;ZUSE PROTECTION will allow the use of the ZUSE command only from
        ;;the SYSTEM MANAGER account and LIBRARY UTILITIES with names that
        ;;begin with the % character.
        ;;
DTRAPH  ;;15
        ;;The APPLICATION INTERRUPT key, when enabled, will cause an <INTRPT>
        ;;error to occur.  The error may then be trapped with an error processor
        ;;and handled as a special event.
        ;;
        ;;When a terminal device is first OPENED it is given the system-wide
        ;;default APPLICATION INTERRUPT key.  An OPEN command parameter allows
        ;;you to define 1 or more INTERRUPT keys for that specific terminal.
        ;;
        ;;The APPLICATION INTERRUPT key may also be used to LOG in to a
        ;;non-AUTOBAUDED terminal.  The RETURN key may be used to LOG
        ;;in to any terminal.
        ;;
        ;;The key must be a control character with a decimal value between
        ;;0 and 31.
        ;;
DABRTH  ;;9
        ;;The PROGRAMMER ABORT key is available only to programmers logged
        ;;into DSM-11 in DIRECT mode.  When pressed, the key will cause
        ;;an <ABORT> error to occur.  Any error processing routines will
        ;;be bypassed and the execution of any application code will be
        ;;terminated.
        ;;
        ;;The key must be a control character with a decimal value between
        ;;0 and 31.
        ;;
DPWRH   ;;12
        ;;DSM-11 will restart automatically when power is restored
        ;;following a power outage, if memory is still intact. If the power
        ;;outage is more than momentary, however, main memory will be
        ;;erased unless it is either core or supported by batteries.
        ;;Often, however, machines without either of these features can
        ;;recover because the outage did not destroy memory. The time
        ;;delay is necessary to allow disk drives to become ready. If you
        ;;wish to restart under operator control, set the time to 0.
        ;;Otherwise enter a time interval up to 500 seconds.
        ;;Note that if power-fail restart occurs while magtape journaling
        ;;is in progress, operator intervention will be demanded.
        ;;
DPARH   ;;6
        ;;The TELEPHONE DISCONNECT DELAY allows a time delay between logout
        ;;and telephone line disconnect.  This is very useful in dial-up
        ;;environments where it is necessary to log out of one UCI and into
        ;;another.  If the DELAY is set to 0, DSM-11 will disconnect the
        ;;telephone line immediately following logout. The maximum allowed
        ;;value is 250 seconds.
        ;;
DLOGH   ;;3
        ;;LOGIN SEQUENCE ECHO will cause all characters typed during login
        ;;to be echoed on the terminal.
        ;;
DFREQH  ;;4
        ;;The FREQUENCY of the computer's POWER SOURCE is either 50 HZ or 60 HZ
        ;;The information about frequency is used by DSM-11 to accurately keep
        ;;the time.
        ;;
PACH    ;;5
        ;;Enter the 3-character password that will let users enter Programmer Mode.
        ;;Use of control characters (ASCII value < 32), while allowable, could,
        ;;conflict with the meaning of those characters to the system.
        ;;(See your User's Guide for more information on these special characters.)
        ;;
DIVH    ;;9
        ;;The number of significant digits returned from a division operation
        ;;will affect both accuracy and speed of computation
        ;;
        ;;Increasing the number of significant digits will increase the degree
        ;;of accuracy, but will also require more processor time.
        ;;
        ;;DSM-11 supports computations which yield between 10 and 31 significant
        ;;digits.
        ;;
