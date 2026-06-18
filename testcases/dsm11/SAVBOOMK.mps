SAVBOOMK        ;Temp. prog to create numbers for ^SAVBOOT
        Q
START   K  C 63 O 63::2 E  W "View buffer busy" Q
        S $ZT="ERR^SAVBOOMK"
        S ST=$V(44),%BL=1
        S SP(5)="",SP(4)="0",SP(3)="00",SP(2)="000",SP(1)="0000"
        V %BL:"S0"
        X "ZL SAVBOOT ZS SVBOOBAK"
        X "ZL SAVBOOT ZR 00000,00016,00032,00048,00064,00080,00096 F I=112:16:496 ZR @(""00""_I) ZS:I=496 SAVBOOT"
        X "ZL SAVBOOT ZR:$T(BOOCODE+1)="" ;;"" BOOCODE+1 ZR BOOCODE ZS SAVBOOT"
        X "ZL SAVBOOT ZI ""BOOCODE ;; Magtape Bootstrap  (these numbers are decimal, not octal!)"":-1 ZI "" ;;"":-1 ZS SAVBOOT"
        F J=0:16:511 D MKLIN W LINE,! X "ZL SAVBOOT ZI LINE:-1 ZS SAVBOOT"
        W !,"DONE"
FIN     C 63 Q
ERR     U 0 W !,"ERROR:  ",$ZE,! G FIN
MKLIN   S LINE=SP($L(J))_J_" ;;"
        F I=J:2:J+15 S II=$V(I+512,0),LINE=LINE_"  "_SP($L(II))_II
        Q
