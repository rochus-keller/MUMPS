%HDR1   ; CALLED BY %HDR--NOT STAND ALONE : JEC ;  24-NOV-80  1:25 PM
        F %T8=1:1:8 W ! F %NX=1:1:%L9 S %CH=$E(STR,%NX),%PF=$P($T(@($F(%FS,%CH)-1+300)),";;",2,99) W $E(%PF,(%T8-1)*8+1,%T8*8) I %NX<%L9 W "    "
        Q
A1      ;;
301     ;; AAAAAA AA    AAAA    AAAAAAAAAAAAAAAAAAAA    AAAA    AAAA    AA
302     ;;BBBBBBB BB    BBBB    BBBBBBBBB BBBBBBB BB    BBBB    BBBBBBBBB
303     ;;CCCCCCCCCC      CC      CC      CC      CC      CC      CCCCCCCC
304     ;;DDDDDD  DD   DD DD    DDDD    DDDD    DDDD    DDDD   DD DDDDDD
305     ;;EEEEEEEEEE      EE      EEEEEE  EEEEEE  EE      EE      EEEEEEEE
306     ;;FFFFFFFFFF      FF      FFFFFF  FFFFFF  FF      FF      FF
307     ;;GGGGGGGGGG      GG      GG  GGGGGG  GGGGGG    GGGG    GGGGGGGGGG
308     ;;HH    HHHH    HHHH    HHHHHHHHHHHHHHHHHHHH    HHHH    HHHH    HH
309     ;;IIIIIIII   II      II      II      II      II      II   IIIIIIII
310     ;;JJJJJJJJ    JJ      JJ      JJ      JJ      JJ  JJ  JJ  JJJJJJ
311     ;;KK    KKKK   KK KK  KK  KKKK    KKKK    KK  KK  KK   KK KK    KK
312     ;;LL      LL      LL      LL      LL      LL      LL      LLLLLLLL
313     ;;MM    MMMMM  MMMM MMMM MMM MM MMMM    MMMM    MMMM    MMMM    MM
314     ;;N     NNNN    NNNNN   NNNN N  NNNN  N NNNN   NNNNN    NNNN     N
315     ;; OOOOOO OO    OOOO    OOOO    OOOO    OOOO    OOOO    OO OOOOOO
316     ;;PPPPPPP PP    PPPP    PPPPPPPPP PP      PP      PP      PP
317     ;; QQQQQQ QQ    QQQQ    QQQQ    QQQQ  Q QQQQ   Q Q QQQQQQ        Q
318     ;;RRRRRRR RR    RRRR    RRRRRRRRR RR RR   RR  RR  RR   RR RR    RR
319     ;;SSSSSSSSSS      SS      SSSSSSSSSSSSSSSS      SS      SSSSSSSSSS
320     ;;TTTTTTTT   TT      TT      TT      TT      TT      TT      TT
321     ;;UU    UUUU    UUUU    UUUU    UUUU    UUUU    UUUUUUUUUU UUUUUU
322     ;;VV    VVVV    VVVV    VVVV    VV VV  VV  VV  VV   VVVV     VV
323     ;;WW    WWWW    WWWW    WWWW    WWWW    WWWW WW WWWWW  WWWWW    WW
324     ;;XX    XXXX    XX XX  XX   XXXX     XX     XXXX   XX  XX XX    XX
325     ;;YY    YY YY  YY   Y  Y     YY      YY      YY      YY      YY
326     ;;ZZZZZZZZZZZZZZZZ     ZZ     ZZ    ZZ     ZZ     ZZZZZZZZZZZZZZZZ
327     ;;
328     ;;  0000 0 00  00 00   00000  0 0000 0  00000   00 00  00 0 0000
329     ;;   11     111    1111      11      11      11      11   11111111
330     ;;  2222   22  22 22    22      22    22    22     22     22222222
331     ;;3333333      33     33   33333       33       33     33 33333
332     ;;      44     444   44 44 44   44 4444444      44      44      44
333     ;;5555555555      55      5555555       55      55     55 555555
334     ;;   666   66  66 66      66      66 6666 666   66 66   66  6666
335     ;;77777777      77     77     77     77     77     77      77
336     ;;  8888   88  88  88  88   8888   88  88 88    88 88  88   8888
337     ;;  99999 99    9999    99 9999999      99      99     99   9999
338     ;;                                         ,,        ,      ,
339     ;;                        ----------------
340     ;;              //     //     //     //     //     //
341     ;;                                        ....    ....    ....
342     ;;   !!      !!      !!      !!      !!             ....    ....
343     ;;  #  #  ########  #  #  ########  #  #
344     ;;   '''     '''      '
345     ;;   $$   $$$$$$$$$$ $$   $$$$$$$$   $$ $$$$$$$$$$   $$
346     ;;   ((     ((     ((     ((      ((       ((       ((       ((
347     ;;   ))       ))       ))       ))      ))     ))     ))     ))
348     ;;*  **  * * ** *   ****  ********  ****   * ** * *  **  *
349     ;;           ++      ++   ++++++++++++++++   ++      ++
350     ;;  ???   ??   ??      ??     ??     ??      ??     ....    ....
351     ;;         \\       \\       \\       \\       \\       \\
352     ;;        ================        ================
353     ;;    ^      ^^^    ^^ ^^  ^^   ^^
354     ;; &&&    &   &   &   &    &&&  &  &&& && &   &&  &   &&   &&&  &
355     ;;  %    % % %  %   %  %      %      %      %  %   %  % % %    %
Z       P %HDR1 ZS %HDR1
