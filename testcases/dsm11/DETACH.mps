DETACH  ;4-Jul-83 ;UTILITIES ;MISC. ;Disconnect from job and let job run in background. ;JBH
        W !,"What do you want to leave as principal device <",$I,"> ? " R %dd
        I %dd="^" Q
        I %dd="" S %dd=$I
        I %dd="?" W !,"Enter the device number that will become this jobs principal device",! G DETACH
        ZU %dd U 0
        V 2:$J:$V(2,$J)\2*2
        V 146:$J:$V(146,$J)\256*256+%dd
        W !!,"Now detaching device ",$I," from job ",$J,"." K %dd
        W !,"Exit",! C $I
        K $ZB ZB OFF ZG
