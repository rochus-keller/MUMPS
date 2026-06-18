%MTCHK  ; MAGTAPE STATUS CHECK
        S %ZA=$ZA,%I=$I,%A=.5
        S %MTTYP=$V(62762)=""+($V(62800)=""*2)
        U 0 F %B=1:1:16 S %T=$T(BITS+%B),%A=%A*2,%T=$P(%T,";;",2) I %ZA\%A#2,%T'["-" W !,%T
        U %I K %A,%B,%I,%MTTYP,%T,%ZA Q
%SET    ;
        S %MTTYP=$V(62762)=""+($V(62800)=""*2)
        F %I=1:1:8 S %T=$T(TESTS+%I),@$P(%T," ",1)=$P(%T,";;",2)
        K %A,%T,%I Q
BITS    ;;
        ;;Logical error
        ;;Positioning in progress
        ;;Write locked
        ;;Settle down
        ;;Seven/Nine channel
        ;;Beginning of tape
        ;;Select remote
        ;;Nonexistent memory
        ;;Bad tape
        ;;Record length error
        ;;End of tape
        ;;Bus grant late
        ;;Parity error
        ;;Cyclical redundancy
        ;;End of file mark
        ;;Illegal condition
        ;;
TESTS   ;;
%MTLER  ;;$ZA#2;; LOGICAL ERROR
%MTPIP  ;;$ZA\2#2;; POSITIONING IN PROGRESS
%MTWLK  ;;$ZA\4#2;; WRITE LOCKED
%MTBOT  ;;$ZA\32#2;; BEGINNING OF TAPE
%MTON   ;;$ZA\64#2;; READY
%MTEOT  ;;$ZA\1024#2;; END OF TAPE
%MTTMK  ;;$ZA\16384#2;; END OF FILE MARK
%MTERR  ;;$ZA\32768#2;; ILLEGAL CONDITION
