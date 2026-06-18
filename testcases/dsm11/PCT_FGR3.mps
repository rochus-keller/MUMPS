%FGR3   ;23-Apr-85 ;DSM11 ;UTILITIES ;HELP TEXT FOR FAST GLOBAL OPERATIONS ;RWB
QM      W !
        S %QM="QM"_%QM_"+"
        F QMI=1:1 S QMJ="S QMJ=$T("_%QM_QMI_")" X QMJ Q:QMJ["STOP"  W !,$P(QMJ,";;",2)
        W !
        K %QM,QMI,QMJ
        Q
QM1     ;
        ;;Enter the tape drive number (0 - 3) for the drive containing
        ;;the tape on which to begin or continue the Fast Global Copy
        ;;or Fast Global Restore. If not already mounted, the tape can
        ;;be mounted now, before responding. To quit, type "Q". A "^"
        ;;will also be interpreted as a "Q". Quitting during a restore,
        ;;before the FINISHED signal is given, will cause an orderly
        ;;termination of the program, deallocating any allocated blocks.
        ;;STOP
QM2     ;
        ;;Enter either "800" or "1600" for the tape density, or type
        ;;<RETURN> for the default value of 800. A "^" will erase the
        ;;answer for the previous question, and cause it to be asked
        ;;again. This question will be repeated for an incorrect answer.
        ;;STOP
QM3     ;
        ;;The tape can be mounted before responding to this question.
        ;;If a <RETURN> is typed, the program will continue. A "Q" will
        ;;terminate the program in an orderly fashion. A "^" will erase
        ;;the answer given to the previous question, and cause that
        ;;question to be asked again. Answers other than "Q" and "^" will
        ;;have the same effect as <RETURN>.
        ;;STOP
QM4     ;
        ;;If "Y" or "y" is typed in response to this question, any number
        ;;of tape drives can be given now, at the beginning of the program,
        ;;and they will be used in the order they are given during the
        ;;execution of the program. In other words, instead of asking for
        ;;the next tape drive, a value from the list entered here will be
        ;;used. If a problem occurs when opening one of these drives during
        ;;execution, the user will be able to remount the tape or direct
        ;;the program to use an alternate drive.
        ;;STOP
QM5     ;
        ;;If "Y" or "y" is typed in response to this question, the tape
        ;;will be rewound, if possible, and tested again for error conditions
        ;;again, including not being at the beginning of the tape. If an
        ;;error is detected, another tape can be mounted, the problem corrected,
        ;;an alternate drive can be given, or the program terminated.
        ;;STOP
QM6     ;
        ;;Enter the next tape drive number for the list of tape drives to
        ;;be used during the execution of the routines (0 - 3). If a "Q"
        ;;is typed, the list will be terminated, and the program will proceed.
        ;;If a "^" is typed, the last entry on the list will be deleted, and
        ;;the question asked again. No other answer will be accepted.
        ;;STOP
QM7     ;
        ;;Enter either "800" or "1600" for the tape density, or type
        ;;<RETURN> for the default value of 800. A "^" will erase the
        ;;answer for the previous question, and cause it to be asked
        ;;again. This question will be repeated for an incorrect answer.
        ;;STOP
QM8     ;
        ;;Enter a name of a global to copy to tape, or type <RETURN> to
        ;;terminate the list of globals to be copied. As the previous
        ;;sentence implies, more than one global can be given, and the
        ;;entire list of globals will be copied out to one or more tapes.
        ;;STOP
QM9     ;
        ;;If "Y" or "y" is typed, the restore of the global will be begun.
        ;;Otherwise, further questions will be asked regarding the user's
        ;;intentions. Subsequent possibilities other than beginning the
        ;;restore include quitting altogether, moving ahead to the next
        ;;global on the tape, or beginning the restore at the current
        ;;tape position.
        ;;STOP
