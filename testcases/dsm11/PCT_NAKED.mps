%NAKED  ;17-Jan-86 ;UTILITIES ;LIBRARY ;DECODE GLOBAL VECTOR ;SMB
        -
INT     ;
        I $V(265,%JN)\2#2=0 G SEVEN
        S %4OF=40960
        S %4N="^",%4STRT=$V(256,%JN)-%4OF,%4END=$V(258,%JN)-%4OF
        I %4STRT<0 S %4N="(none)" G K
        F %4I=%4STRT:1 S %4X=$V(%4I,%JN)#256,%4N=%4N_$C(%4X\2) Q:%4X#2=0
        S %4I=%4I+1
        G K:%4I'<%4END
        S %4N=%4N_"("""
        F %4I=%4I+1:1:%4END-1 D SUB
        S %4N=$E(%4N,1,$L(%4N)-2)_")"
K       K %4STRT,%4END,%4I,%4OF,%4X Q
        -
SUB     S %4X=$V(%4I,%JN)#256
        I %4X=0 S %4N=%4N_""",""",%4I=%4I+1 Q
        S %4N=%4N_$C(%4X) Q
        -
SEVEN   S %4N="^",%4E=$V(258,%JN)-40960
        F %4E=%4E-1:-1:3 Q:$V(%4E,%JN)#2=0
        S (%4F,%4L)=0 F %4I=4:1:%4E D W
        K %4E,%4F,%4I,%4L,%4X Q
        -
W       S %4X=$V(%4I,%JN)#256
        I %4X<64!(%4X>253) Q:%4X<64&'%4F  S %4F=1,%4N=%4N_"""_$C("_(%4X\2)_")"
        E  S:%4F=1 %4N=%4N_"_""" S %4F=2,%4N=%4N_$C(%4X\2) S:%4X\2=34 %4N=%4N_""""
        Q:%4X#2  S:%4F-1&%4L %4N=%4N_"""" I %4I=%4E S:%4L %4N=%4N_")" Q
        S %4F=0 I %4L S %4N=%4N_",""" Q
        S %4L=1,%4N=%4N_"(""" Q
        -
