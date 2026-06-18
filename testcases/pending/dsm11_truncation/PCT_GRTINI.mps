%GRTINI ;27-Feb-85;Initializes vbls for %GRT routines; DSM V3 ;DMW
        S RET=$C(13),ACK="(%)ACK(%)",NAK="(%)NAK(%)",SYNC="(%)SYNC(%)",ETX="(%)ETX(%)",EOT="(%)EOT(%)",MAX=500,T1=10,T2=10,TRIES=64,
ME=0,ENQ="(%)ENQ(%)"
        S BUFLUSH="F BB=1:1 R *BF:0 Q:'$T"
        S (B,ERROR)=0,NOLINK="Unable to set up link.",NOSYNC="Communcations got out of sync or lost link.",GOOD="Successful Transfer
.",DSCON="Modem connection broken."
        S WX="U ME W:DEV'=$I X,! U DEV",DSP2=" X RB",(DSP1,DSP4)="",DSP3=" X END" S:DSP DSP1=" X WX",DSP4=" "_DSP1,(DSP2,DSP3)=""
