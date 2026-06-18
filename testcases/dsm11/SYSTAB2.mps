SYSTAB2 ;CONTINUATION OF SYSTAB1 ;
        W !?5,*7,"This subroutine should be run using the ^SYSTAB utility.",!,*7 Q
START   F I=1:1 S T=$T(ST+I) Q:T=""  D NEWSA W:'(I#10) "."
        Q
NEWSA   S SA=+T,T=$P(T,";;",2)
        F J=1:1 S P=$P(T,";;",J) Q:P=""  S ^SYSTAB(SA)=P,SA=SA+P
        Q
ST      ;;
346     ;;ERRDEV,Message printing device for ^CTK and ^DDP,,1
347     ;;VWUSR,Bits set to indicate loadable drivers using View,1
348     ;;SSPACE,Minumum partition space required for, string stack to prevent <STORE>
350     ;;JOBS,Count of currently active jobs
352     ;;GBLMIN,Address of lowest BDB available for allocation
354     :
356     ;;DEMTIM,Write Demon timer (ticks)
358     ;;JCMDDB,Points to start of JOBCOM,Device Descriptor Block
360     ;;ERRMON,Error flag word for system monitor routine
362     ;;CLKCSR,Set by cold start to clock CSR,(KW11L or KW11P)
364     ;;GARTRA,Garbage Collector status word
366     ;;GARNEX,Low 16 bits of garnex
368     ;;GARNEX,High byte of GARNEX,,1
369     ;;GARNEX,UCN for GARNEX,,1
370     ;;GARCUR,Contains block number of the garbage tree,currently being collected
372     ;;GARCUR,High byte of GARCUR,,1
373     ;;GARCUR,UCN for GARCUR,,1
374     ;;PARFRE,Points to Partition Pool free space
376     ;;$PAR$,Points to start of Partition Pool
378     ;;$PARL$,Contains size of the Partition Pool (MM)
380     ;;RUNWR,Contains job number of the current BDB,(cache buffer) being written by Write Demon
382     ;;ZVTXT,Pointer to $ZV text
384     ;;DDPSIZ,Contains the size of the DDP DDB's
386     ;;SYS$J,Lowest defined $J above 63,,1
387     ;;ZUPRT,Bit 0=1 if ZUSE is restricted to UCI #1 or % routine,,1
388     ;;DZTIM,Low byte is timer,Hi byte is reset value (ticks)
390     ;;DZMDM,Contains address of DDB of,1st DZ11 with modem-control
392     ;;DMCINT,Points to DMC interrupt entry
394     ;;SATSIZ,Contains size (in bytes) of SATTBL
396     ;;DMCBUF,MM address of 1st DMC11 768. byte buffer
398     ;;CCHBUF,Points to Disk Cache Buffer pool (*64)
400     ;;RBSTD,Contains standard Ring Buffer size (bytes)
402     ;;JRNDDB,Points to 1st Journal,Device Descriptor Block
404     ;;D$BUF,Points to 1st DDP buffer
406     ;;MTACT,Contains magtape status (Job# & Unit)
408     ;;SDPTAB,Points to SDP's Device Descriptor Blocks
410     ;;RUNJRN,Contains Journal status
412     ;;JRNCNT,Contains next disk block number,for journaling
414     ;;JRNDBS,Contains number of buffers,dedicated to Journaling
416     ;;PAVL,Contains JOBTAB offset to,Partition Available Q for startup
418     ;;PHYEND,Contains memory size (/64)
420     ;;PWRTIM,Wait (in clock ticks) for,power-fail auto-restart
422     ;;D$PTR,Points to Distributed,Data Base table
424     ;;D$INT,Points to DDP interrupt entry
426     ;;MON$$,Points to Peek table in Kernel space
438     ;;ALLOCB, low 16 bits of global block allocation
440     ;;ALLOCB, high 8 bits ,,1
441     ;;DEALLB, High 8 bits of global block deallocations,,1
442     ;;DEALLB, Low 16 bits cont.
