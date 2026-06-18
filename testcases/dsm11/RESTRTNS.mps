RESTRTNS        Q  ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
DRVCHK  S %FAIL=1,DDU=DD_DU I '($V(DE)#256) G NOTEX
        D START^%STRTAB S NXVOL=""
        F I=1:1 S NXVOL=$O(STR(0,NXVOL)) Q:NXVOL=""  I $P(STR(0,NXVOL),":",1)=DDU G RES
        S MBITS=$V(DE)\16384 I MBITS G MNTD
        S %FAIL=0
        Q
NOTEX   W !,"Your hardware configuration does not contain a drive """,DDU,""".",! Q
RES     W !,"Drive """,DDU,""" is resident in this configuration (",ID,").",!
        W "You may not do a RESTORE using a resident drive, unless you are "
        W "running",!
        W "the ""baseline"" system.  If there is not a non-resident drive "
        W "available",!
        W "for you to do this RESTORE, you will have to shut down your system "
        W "and boot",!
        W "the baseline system in order to perform this RESTORE.",!
        Q
MNTD    W !,"You must type  ""D ^DISMOUNT"" to dismount the disk in drive "
        W DDU,!
        W "before you can use this drive to do a RESTORE",!
        S %FAIL=-1 Q
