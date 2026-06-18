FASTGTO ;17-Jul-83 ;UTILITY ;GLOBALS ;FAST SAVE TO TAPE ;JBH
        D ^%GSEL
        D ^%IOS
        S NEXT=""
NEXT    S NEXT=$O(^UTILITY($J,NEXT)) I NEXT="" G DONE
        U 0 W !,NEXT," at ",$H U %IOD I $D(@("^"_NEXT))
        S $ZT="EOG" W @$ZR,$ZR F I=1:1 W $ZO,$ZR
EOG     I $ZE["<MTERR>" S ZA=$ZA U %IOD D ^%MTCHK Q
        I $ZE["<UNDEF>" W *1,*1,*3 G NEXT
        E  U 0 W !,"Unexpected error ",$ZE
DONE    U 0 W !,$H
