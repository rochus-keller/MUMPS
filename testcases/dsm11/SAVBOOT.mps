SAVBOOT ;DSM-11 Utilities;Copyright 1980 DEC
        ;;This program will place a copy of the DSM11-V2 Magtape Bootstrap,
        ;;onto a DSM11-V3 system disk, in DSM Relative Blk #1.
        ;;DSM11-V3 Distribution Disks, and all DSM11-V3 system disks created
        ;;by DISKPREP, will already have a copy of this tape bootstrap at
        ;;Blk #1, however this program may be used to re-create it, in the
        ;;event Blk #1 is overwritten.  Normally, users will have no use for
        ;;this program.
        ;;Whenever a bootable magtape copy of the system is created from a
        ;;system disk (using the routine ^SYTOTAPE), the bootstrap for the
        ;;magtape is copied from DSM Relative Blk #1 of the system disk.
        ;;The system image is then copied from DSM Relative Blks # 2-91.
        ;;Then the first 37. blocks of the "annex" are copied, so that the
        ;;total system image size is 127 kb maximum.
START   K  C 63 O 63::2 E  W "View buffer busy" Q
        S $ZT="ERROR^SAVBOOT",%ST=$V(44)
        S SPC(3)="00",SPC(2)="000",SPC(1)="0000"
        K %QUERY S PRM="Save Magtape boot onto DSM BLK #1",M=1,MAPS=2
        D GETYU^DPBEGIN G DONE:'$D(%A),DONE:%A
        I VER'["3.1"!(MB'="M") W !,"Selected disk is not a DSM11 V 3.1 system disk" G DONE
        S %BL=1 V %BL+398:DDU
        I $V(1008,0)'=21845!($V(2,0)'=65535) W *7,!,"** DOESN'T APPEAR TO BE A SYSTEM DISK",*7
        S QUES="SUR" X ^%Q("ASKN") G:ANS="N" DONE
        V %BL:DDU
        F L=0:16:511 S LI=SPC($L(L))_L,LINE=$T(@LI) D VIEWIN
        V -%BL:DDU
        W !,"DONE"
DONE    C 63 K  Q
ERROR   U 0 W !,"ERROR:  ",$ZE,! G DONE
VIEWIN  ;
        S LINE=$P(LINE,";;",2,99)
        F I=L:2:L+15 S N=+$E(LINE,3,7),LINE=$E(LINE,8,255) V I+512:0:N
        Q
SUR     W !,"Disk ",DDU,"  - are you sure" Q
BOOCODE ;; Magtape Bootstrap  (these numbers are decimal, not octal!)
        ;;
00000   ;;  00160  00262  00154  00224  49156  00000  00000  00512
00016   ;;  04407  65518  04215  00142  05574  01024  02551  00002
00032   ;;  00321  05599  12512  65534  05572  62688  05573  62656
00048   ;;  02560  04116  05589  32518  26048  00128  08471  62702
00064   ;;  33784  05604  03968  02719  65402  02565  05572  49152
00080   ;;  04447  62700  03020  34565  26053  00032  08535  03968
00096   ;;  34807  04420  03205  03205  03205  07616  00052  08197
00112   ;;  34562  04416  02752  05571  00004  58820  00008  04383
00128   ;;  62698  05572  40960  24846  03028  05004  04358  03028
00144   ;;  05332  08407  00512  34812  00135  22006  00001  00002
00160   ;;  00002  00254  05569  62802  08279  57344  33606  00161
00176   ;;  03017  34627  06084  00002  58820  00016  00161  03020
00192   ;;  34620  08983  19795  00569  06082  62698  02564  00161
00208   ;;  03138  03138  03138  03138  03138  03140  03138  03140
00224   ;;  04407  65312  04407  65316  26050  00002  04279  65306
00240   ;;  26050  00014  04279  65290  26050  65528  13762  00003
00256   ;;  00767  20738  04163  04259  35785  33022  05623  49153
00272   ;;  65270  02615  65268  02615  65266  04235  35785  33022
00288   ;;  03017  33279  28151  65254  65248  34306  02743  65244
00304   ;;  02752  00755  38341  00001  00309  05569  62752  05570
00320   ;;  00057  00161  22001  00032  00008  34575  05617  65024
00336   ;;  00006  05617  65280  00002  20617  35785  33022  03017
00352   ;;  33279  02752  00755  02565  00285  05569  62802  05570
00368   ;;  24579  02609  00004  34785  13809  00001  65534  01020
00384   ;;  05617  65024  00002  20617  05571  00025  02755  00766
00400   ;;  13809  00001  65534  01020  03017  33279  02752  00752
00416   ;;  38341  65535  06084  00044  37236  00082  00095  00252
00432   ;;  00000  00000  00000  00000  00000  00000  00000  00000
00448   ;;  00000  00000  00000  00000  00000  00000  00000  00000
00464   ;;  00000  00000  00000  00000  00000  00000  00000  00000
00480   ;;  00000  00000  00000  00000  00000  00000  00000  00000
00496   ;;  00000  00000  00000  00000  00000  00000  00000  00000
