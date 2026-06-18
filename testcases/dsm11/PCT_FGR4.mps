%FGR4   ;23-Apr-85 ;DSM11 ;UTILITIES ;ON LINE HELP ;RWB
%FGR3   ;
QM      W !
        S %QM="QM"_%QM_"+"
        F QMI=1:1 S QMJ="S QMJ=$T("_%QM_QMI_")" X QMJ Q:QMJ["STOP"  W !,$P(QMJ,";;",2)
        W !
        K %QM,QMI,QMJ
        Q
QM10    ;
        ;;If "Y" or "y" is typed in response, the Fast Global Copy program
        ;;will terminate in an orderly fashion, and the global will not
        ;;be restored. There is no provision for interleaving the blocks
        ;;for one global with those of another. The program automatically
        ;;senses EOT and allows for continuation on another tape. A "^"
        ;;will cause the previous question to be asked again. Any answer
        ;;but "Y" or "^" will cause an additional option to be given, which
        ;;if declined, will cause the preceeding question to be asked again.
        ;;STOP
QM11    ;
        ;;A "Y" or "y" answer will cause the program to skip the blocks
        ;;following the header just printed, and look ahead for the next
        ;;global on the tape, or allow another tape to be examined if no
        ;;additional globals are found. A "^" will cause the previous
        ;;question to be asked. Any other answer will cause this cycle
        ;;of three questions, of which this is the third, to begin again.
        ;;STOP
QM12    ;
        ;;A "Y" OR "y" will cause the restoration to terminate in an
        ;;orderly manner. Any other answer will cause a new tape to be
        ;;asked for.
        ;;STOP
QM13    ;
        ;;The answer to this prompt has the general format:
        ;;
        ;;        Integer"/"Option
        ;;
        ;;where: Integer is an integer greater than 1 and Option is
        ;;       one of the characters "D", "S", "N", "B", or "Q".
        ;;
        ;;The integer specifies the number of blocks on the tape to
        ;;be processed by the option, e.g. a response of "100/N"
        ;;will cause 100 blocks of the tape to be read, but not
        ;;displayed, and the prompt reissued with the tape positioned at
        ;;the 101st block following the current tape position.
        ;;
        ;;The following options are supported:
        ;;
        ;;D - Display the block in full. During the display, a CNTRL C
        ;;    given while the data contained in the block is being printed
        ;;    will stop the display of that block, and the program will
        ;;    move on either to the next block, or give the prompt again.
        ;;
        ;;B - Back up. Depending on the value of the integer, the tape
        ;;    will be backed up one or more blocks.
        ;;
        ;;S - Short Display. Only a small amount of information within
        ;;    the block, but none of the actual data which it contains,
        ;;    will be displayed.
        ;;
        ;;N - No Display. This is essentially a fast forward. The block
        ;;    is skipped altogether.
        ;;
        ;;Q - The program is terminated, and the tape rewound.
        ;;
        ;;
        ;;Various defaults are allowed for. In general, if one part of
        ;;the two part response is omitted, the previous value is used.
        ;;However, after a fast forward with the "N" option, the option
        ;;default becomes "D", and the integer default becomes 1. A
        ;;<RETURN> can also be used to pick up both defaults. If only
        ;;one part of the command is given, the "/" should not be included.
        ;;STOP
QM14    ;
        ;;A "Y" or "y" answer will cause the restoration to proceed from
        ;;the current tape position. Any other answer will elicit another
        ;;question as to whether the restoration should be terminated.
        ;;STOP
