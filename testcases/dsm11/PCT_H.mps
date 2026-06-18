%H      ; GEF/MB/DMW ; DSM UTILITIES ; DATE & TIME CONVERTER
        W !,"This is not an interactive routine,",!,"and should be called only at its appropriate entry points.",! Q
%CDS    ;
        I %DT'?1N.N K %DAT Q
        S %A=$S(%DT<21915:0,1:%DT-21914\36524+1),%A=%DT+%A-(%A+2\4),%B=%A#1461
        S %F=$E(%B*.00273785,1),%Y=%A\1461*4+1841+%F
        S %M=101,%D=%B-(%F*365) I %D=0 S %M=112,%Y=%Y-1,%D=31 G %CDSX
        F %I=31,$S(%Y#100:%Y#4=0,1:%Y#400=0)+28,31,30,31,30,31,31,30,31,30 Q:%I'<%D  S %M=%M+1,%D=%D-%I
%CDSX   S %DAT1=%D_"-"_$P("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"," ",(%M-100))_"-"_$E(%Y,3,4)
        S %DAT=+$E(%M,2,3)_"/"_+$E(%D+100,2,3)_"/"_%Y K %A,%B,%D,%F,%I,%M,%Y Q
%CDN    ;
        I %DT'?1N.N1"-"3A1"-"2N,%DT'?1N.N1"-"3A1"-"4N,%DT'?1N.N1"/"1N.N1"/"2N,%DT'?1N.N1"/"1N.N1"/"4N K %DAT Q
        S %M=$P(%DT,"/",1),%D=$P(%DT,"/",2),%Y=$P(%DT,"/",3)
        I %DT["-" S %D=+%DT,%Y=$P(%DT,"-",3),%M=$P(%DT,"-",2)
        I %M?3A F %B=1,2,3 S %M=$E(%M,1,%B-1)_$C($A(%M,%B)#32+64)_$E(%M,%B+1,3)
        S:%M?3A %M=$F("JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC ",%M)\4 I (+%M=0)!(+%D=0) K %DAT G %CDNX
        S:%Y<100 %Y=%Y+1900 S %B=%Y-1841 I %B<0 K %DAT Q
        I %D>$P("31,"_(28+$S(%Y#100:%Y#4=0,1:%Y#400=0))_",31,30,31,30,31,31,30,31,30,31",",",%M) K %DAT G %CDNX
        S %DAT=%B*365+(%B\4)-(%B+40\100)+(%B+240\400)+$P("0,31,59,90,120,151,181,212,243,273,304,334",",",%M)+%D
        I %M>2 S %DAT=%DAT+$S(%Y#100:%Y#4=0,1:%Y\100#4=0)
%CDNX   K %B,%M,%D,%Y Q
%CTS    ;
        I %TM'?1N.N!(%TM>86399) K %TIM Q
        S %M=%TM#3600\60,%S=%TM#60,%TIM=%TM\3600_":"_(%M\10)_(%M#10)
        S %TIM1=%TIM,%A=$S(%TM<43200:"AM",1:"PM") I $P(%TIM,":",1)>12 S %TIM1=$P(%TIM,":",1)-12_":"_$P(%TIM,":",2,99)
        S %TIM1=%TIM1_" "_%A
        K %A,%M,%S Q
        Q
%CTN    ;
        D:%TM["AM"!(%TM["PM") %CH
        I %TM'?1N.N1":"2N.":".N!(%TM>23)!($P(%TM,":",2)>59)!($P(%TM,":",3)>59) K %TIM Q
        S %TIM=%TM*60+$P(%TM,":",2)*60+$P(%TM,":",3)
        Q
%CH     I %TM'?1N.N1":"2N.":".N." "1"AM",%TM'?1N.N1":"2N.":".N." "1"PM" S %TM="" Q
        S %T1=$P(%TM,":",1),%LTM=$L(%TM),%AP=$E(%TM,%LTM-1,%LTM)
        S %T2=$P($P($E(%TM,1,%LTM-2)," ",1),":",2,3) I %T2'[":" S %T2=%T2_":00"
        S:(%AP="PM")&(%T1<12) %T1=%T1+12 S:(%AP="AM")&(%T1=12) %T1=0 S %TM=%T1_":"_%T2
        K %AP,%LTM,%T1,%T2 Q
