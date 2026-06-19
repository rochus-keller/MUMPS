BSCSTR  ;31-Dec-40 ;UTILITY ;BSC ;CONTROL 2780/3780 EMULATOR BACKGROUND JOB ;JHM
START   W !!
Q1      S %QRY="Start spooler for device" D GETDEV G EXIT:%DEV="^"
        O %DEV::1 I '$T W !,"Device ",%DEV," is already assigned",! G Q1
        C %DEV D SETDEF
Q2      S %QRY="EBCDIC, ASCII, or TRANSPARENT Data [E/A/T]",%DEF=^("CSET"),%HLP="Q2H"
        D QRY G Q1:%ANS="^" I "AET"'[%A D INVOPT G Q2
        S ^("CSET")=%A
Q3      S %QRY="2780 or 3780 emulation [1 = 2780/2 =3780]",%DEF=^("EMUL"),%HLP="Q3H"
        D QRY G Q2:%ANS="^" I %ANS<1!(%ANS>2) D INVOPT G Q3
        S ^("EMUL")=%ANS
Q4      S %QRY="Switched or Leased line [S/L]",%HLP="Q4H",%DEF=^("LMOD")
        D QRY G Q3:%ANS="^" I "SL"'[%A D INVOPT G Q4
        S ^("LMOD")=%A I %A="S" S ^("NMOD")="P" G Q6
        S ^("LMOD")="L"
Q5      S %QRY="Multipoint or Point-to-Point [M/P]",%DEF=^("NMOD"),%HLP="Q5H"
        D QRY G Q4:%ANS="^" I "PM"'[%A D INVOPT G Q5
        S ^("NMOD")=%A G Q6:%A="P"
Q5A     S %QRY=$S(^("CSET")="A":"ASCII",1:"EBCDIC")_" decimal control Unit "_$S(^("NMOD")=2:"Poll ",1:"")_"Address",%DEF=^("CUPOL"),%HLP="Q5AH"
        D QRY G Q5:%ANS="^" I %ANS'?1N.N!(%ANS>256)!(%ANS<0) D INVOPT G Q5A
        S ^("CUPOL")=%ANS I ^("EMUL")=1 S ^("CUPOL")=%ANS G Q6
Q5B     S %QRY=$S(^("CSET")="A":"ASCII",1:"EBCDIC")_" decimal control Unit "_$S(^("NMOD")=2:"Select ",1:"")_"Address",%DEF=^("CUSEL"),%HLP="Q5BH"
        D QRY G Q5A:%ANS="^" I %ANS'?1N.N!(%ANS>256)!(%ANS<0) D INVOPT G Q5B
        S ^("CUSEL")=%ANS
Q6      S %QRY="Maximum  size for transmitted records",%DEF=^("REC"),%HLP="Q6H"
        D QRY G Q4:%ANS="^" I %ANS>120!(%ANS<80) D INVOPT G Q6
        S ^("REC")=%ANS
Q7      S %QRY="Output messages to Terminal, Log file, or Suppress [T/L/S]",%DEF=^("LOG"),%HLP="Q7H"
        D QRY G Q6:%ANS="^" I "TLS"'[%A D INVOPT G Q7
        S ^("LOG")=%A G Q9:%A'="T"
Q8      S %QRY="Terminal number to output message",%DEF=^("TRN"),%HLP="Q8H"
        D QRY G Q7:%ANS="^" I %ANS'?1N.N D INVOPT G Q8
        S ^("TRN")=%ANS
Q9      S %QRY="Global to receive incoming data files",%DEF=^BSCDAT(%DEV,"STARTUP","GIN"),%HLP="Q9H"
        D QRY G Q8:%ANS="^" S NOD="GIN" D CHKREF G:%A Q9 G Q10
Q10     I ^("LMOD")="L" G STREML
        S %QRY="Automatic Signon [Y/N]",%DEF="N",%HLP="Q10H"
        D QRY G Q9:%ANS="^" I %A="N" S ^BSCDAT(%DEV,"STARTUP","SIGNON")="" G STREML
        I %A'="Y" D IVOPT G Q10
Q11     S %QRY="Global containing Signon file",%DEF=^BSCDAT(%DEV,"STARTUP","SIGNON"),%HLP="Q11H"
        D QRY G Q10:%ANS="^" S NOD="SIGNON" D CHKREF G Q11:%A
STREML  W !!,"Starting BSC PE for device ",%DEV,!! S ^BSCDAT(%DEV)="Starting"
        ZA ^BSCDAT(%DEV) S ^BSCDAT=%DEV ZJ:'$D(%NOBACK) ^BSCPEB ZD ^BSCDAT(%DEV)
EXIT    K %DEF,%HLP,%QRY,%DEV Q
INVOPT  W !,"Invalid option selection - type ? for help" Q
CHKREF  S %A=0 S:$E(%ANS)'="^" %ANS="^"_%ANS S $ZT="BADREF",X=$D(@%ANS),^BSCDAT(%DEV,"STARTUP",NOD)=%ANS Q
BADREF  W !,"Illegal global syntax" S %A=1 Q
QRY     W !,%QRY," " W:%DEF'="" "<",%DEF R "> ",%ANS
        I %ANS="" S %ANS=%DEF G QR1:%ANS'="" S %ANS="^" Q
        I %ANS="?" D @%HLP G QRY
QR1     S %A=$E(%ANS,1) Q
GETH    W !!,"Enter the device number which is associated with the device"
        W !,"controller that will be used to communicate with remote system",! Q
Q2H     W !!,"Enter E to use the EBCDIC the character set when transmitting"
        W !,"and receiving data.",!
        W !,"Enter A to use the ASCII character set",!
        W !,"Enter T to transmit transparent (binary) data.  The EBCDIC"
        W !,"character set will be used for all protocol characters",! Q
Q4H     W !!,"Enter S if the communications line is a dial-up or switched"
        W !,"network configuration",!
        W !,"Enter L if the line is a leased or direct connection.",! Q
Q5H     W !!,"Enter M if this device is part of a multipoint network where"
        W !,"multiple communications devices are connected to a single"
        W !,"communication link",!
        W !,"Enter P if this device is connected to only 1 other device"
        W !,"in a contention mode",!
        Q
Q5AH    W !!,"Enter the IBM 2780 or 3780 Control Unit address that the spooler"
        W !,"will recognize as a poll from the master unit."
        Q
Q3H     W !!,"Enter 1 for IBM 2780 protocol emulation"
        W !,"Enter 2 for IBM 3780 protocol emulation",!
        Q
Q5BH    W !!,"Enter the IBM 2780 or 3780 Control Unit address that the spooler"
        W !,"will recognize as a select from the master unit.",!
        Q
Q6H     W !!,"Enter the maximum number of bytes allowed in a transmitted"
        W !,"record.  A record may not exceed 120 bytes or be less than 80.",!
        Q
Q7H     W !!,"Enter T to output spooler messages to a TERMINAL"
        W !,"Enter L to output spooler messages to a GLOBAL"
        W !,"Enter S to suppress spooler messages",! Q
        Q
Q8H     W !!,"Enter the terminal to receive the spooler messages",!!
        Q
Q9H     W !!,"Enter the name of the global or global subtree which is to receive"
        W !,"incoming data.  The syntax used must be a full and legal syntax "
        W !,"including quoted subscripts and closed parentheses."
        W !!,"The spooler will save each received file at the next lowest subscript"
        W !,"level.",!
        Q
Q10H    W !!,"Type Y if you would like the spooler to transmit a SIGNON"
        W !,"record every time a new connection is made to the host system.",! Q
Q11H    W !!,"Enter a complete global reference for the global name and"
        W !,"subtree which contains the SIGNON information.",! Q
GETDEV  W !,%QRY," [51:58] > " R %DEV
        I %DEV="^"!(%DEV="") S %DEV="^" Q
        I %DEV="?" D GETH G GETDEV
        I %DEV<51!(%DEV>58) D INVOPT G GETDEV
        I $V($V($V(44)+8)+%DEV)#256=255 W !,"Device ",%DEV," is not currently configured",! G GETDEV
        Q
SETDEF  S ^BSCDAT(%DEV,"STARTUP","CSET")="E",^("LMOD")="L"
        S ^("NMOD")="P",^("EMUL")=1,(^("CUPOL"),^("CUSEL"))=193
        S ^("LOG")="T",^("TRN")=1,^("GIN")="^BSCDAT(""DATA"")",^("REC")=80
        S ^("SIGNON")="^SIGNON" Q
