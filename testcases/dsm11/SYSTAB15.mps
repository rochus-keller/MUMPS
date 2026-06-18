SYSTAB15        ;CONTINUATION OF SYSTAB0 ;; FDN
        W !?5,*7,"This subroutine should be run using the ^SYSTAB utility.",!,*7 Q
START   F I=1:1 S T=$T(ST+I) Q:T=""  D NEWSA W:'(I#10) "."
        G START^SYSTAB2
NEWSA   S SA=+T,T=$P(T,";;",2)
        F J=1:1 S P=$P(T,";;",J) Q:P=""  S ^SYSTAB(SA)=P,SA=SA+P
        Q
ST      ;
216     ;;MAPSIZ,Size in bytes of mapped routine area
218     ;;TTYCNT,KIOD Character cnt- output low 16 bits
220     ;;TTYCNT,KIOD Character cnt- output high 8 bits,,1
221     ;;TTYCNT,KIOD Character cnt- input high 8 bits,,1
222     ;;TTYCNT,KIOD Character cnt- input low 16 bits
224     ;;DSKLNK,Points to Disk Configuration table
226     ;;LCKPNT,Contains Lock Table list head
228     ;;OFTPNT,Pointer to spooling's open file table
230     ;;SPLDEV,Points to the DDB address,of the default spool device
232     ;;SDPSIZ,Contains size of the SDP DDB's
234     ;;ROUREF,Contains number of Routine loads
236     ;;GLOREF,Contains number of Global references
238     ;;GLOREF,High order byte of GLOREF,,1
239     ;;LOGRD,High order byte of LOGRD,,1
240     ;;LOGRD,Contains number of logical block references
242     ;;PHYRD,Contains number of physical block reads,due to Globals or Routines
244     ;;PHYRD,High order byte of PHYRD,,1
245     ;;PHYWT,High order byte of PHYWT,,1
246     ;;PHYWT,Contains total number of physical disk writes
248     ;;GLOSET,Contains number of,Global SETs and KILLs
250     ;;GLOSET,high byte,,1
251     ;;LOGWT,high byte,,1
252     ;;LOGWT,Contains number of logical global writes
254     ;;TOTRD,Contains total number of physical reads
256     ;;TOTRD,high byte,,1
257     ;;WTSYNC,high byte,,1
258     ;;WTSYNC,Contains number of synchronous disk writes
260     ;;       ,Pointer to Global module patch point for RTHIST
262     ;;JCRING,Ring Buffer size for JOBCOM device channels,,1
263     ;;PAGSIZ,Maximum value for $Y,,1
264     ;;DIVSIG,Significant digits for division,,1
265     ;;MAXDIG,Maximum digits in numbers,,1
266     ;;GLOSTK,Number of additional stack bytes,required for GLOBAL seize
268     ;;REFSIZ,Max. allowable local or global,reference size (123. absolute max.),1
269     ;;SUBSIZ,Max. allowable local or global,subscript size (63. absolute max.),1
270     ;;TRYLST,Searchlast attempts low 16 bits
272     ;;TRYLST,Searchlast attempts high 8 bits,,1
273     ;;TRYLST,Searchlast success high bits,,1
274     ;;TRYLST,Searchlast success low 16 bits
280     ;;ROUCNT,Count of mapped routine reference low 16 bits
282     ;;ROUCNT,Count of mapped routine reference high 8 bits,,1
283     ;;LOGTIM,Delay in partition disconnect,,1
272     ;;,
284     ;;STUADR,Points to address for STU,to start a partition
286     ;;JCURDB,Contains the current journal DDB
288     ;;JMTDDB,Contains the next-to-write,journal DDB (for magtape)
290     ;;LASBLK,Contains the last block allocated,to Disk Journal space (3 bytes)
292     ;;,,,1
293     ;;GBLDEF,Default global characteristics,,1
294     ;;CURBLK,Contains the current block allocated,to Disk Journal space (3 bytes)
296     ;;,,,1
297     ;;JRNWAT,Contains number of journal buffers,waiting to be output,1
298     ;;MTLNTH,Contains size of the magtape,Device Descriptor Blocks (Bytes)
300     ;;JCMSIZ,Contains size of JOBCOM,Device Descriptor Blocks (Bytes)
302     ;;JRNSIZ,Contains the size of Journal,Device Descriptor Blocks (Bytes)
304     ;;NUMAC,Numeric argument high order
306     ;;NUMAC,Numeric argument low order
308     ;;VWDDB,Points to the 1st VIEW BDB
310     ;;VWSW,VIEW Status word
312     ;;VWSIZE,Contains number of contiguous,VIEW buffers
314     ;;XFRST,Contains offset of current,VIEW transfer BDB
316     ;;XFRXT,Contains number of buffers,in current transfer
318     ;;$PGMS,Tied Routine table (7 entries max)
320     ;;,
322     ;;,
324     ;;,
326     ;;,
328     ;;,
330     ;;,
332     ;;,
334     ;;,
336     ;;,
338     ;;,
340     ;;,
342     ;;,
344     ;;,
