BSCEBC  ;2-Mar-84 ;UTILITY ;BSC ;CONVERT ASCII TO/FROM EBCDIC ;JHM
        ;; Enter with %ASC = to ASCII char to convert to EBCDIC
        ;;
ASCEBC  S %ASC=$V($V($V(44)+124)+%ASC)#256 Q
        ;;
        ;; Enter with %EBC = to EBCDIC character to convert to ASCII
        ;;
EBCASC  S %EBC=$V($V($V(44)+124)+%EBC+256)#256 Q
