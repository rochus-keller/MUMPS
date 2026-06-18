BSC     ;21-Sep-82 ;UTILITY ;BSC ;BSC UTILITY OVERVIEW ;JHM
        The following utilities exist to help debug and use the
        BSC driver
        BSCBIT
        This utility will display the meaning of all status bits returned
        via $ZA.  It is intended only for interactive use with the driver
        to help analyze the error conditions returned.
        input:  ZA = $ZA
        output: terminal listing of the meaning of all bits set
        BSCMON
        This utility will display all characters received and transmitted
        across a specified BSC port.  Note that the terminal speed of the
        monitoring device must be greater than that of the BSC port.
        A <CR> <LF> is issued to the monitor after every line protocol
        turnaround.  The transmitted messages and protocol responses are
        always precede by a set of SYN characters (^V) and whereas received
        messages will have the synch characters stripped.
        The " character precedes all messages until CTS (clear-to-send) is
        present.
        The monitor routine must be started after the device to be monitored
        has been OPENed.
        BSC PROTOCOL EMULATOR ROUTINES
        These are a group of very generalized routines provided as an example
        of 2780/3780 protocol emulation utilizing the BSC driver.  The spoolers
        operate as full duplex (send and receive files), background emulators
        which will communicate to remote hosts.
        A BSC protocol emulator spooler is started by running ^BSCPE and
        selecting the "start" menu option.  A series of questions about
        how the emulator is to operate must then be answered.  The spoolers
        can be stopped by running ^BSCPE and selecting the "halt" menu option.
        There are three components to the background BSC spooler.
        ^BSCPEB
        This routine is the main control program for the spooler.  On startup,
        it collects the startup parameters passed in ^BSCDAT from the startup
        routine ^BSCSTR, opens the device and issues the startup message to
        the logging device.
        ^BSCPEB monitors the line for incoming traffic and logs any errors
        encountered in ^BSCDAT.  If data is received, ^BSCRCV is overlayed
        to receive and store the file.  If queued data is found in ^BSCDAT,
        ^BSCPEB overlays ^BSCXMT to transmit the file.
        ^BSCRCV is responsible for receiving data from a remote system.  When
        a file is received, an entry is made in ^BSCDAT pointing to the global
        index at which the file will be stored.  Then each record of the file
        is stored in the global.  When an EOT is received, control is returned
        to ^BSCPEB.
        ^BSCXMT is responsible for transmitting data to a remote system.  When
        an entry in the "SEND" queue is detected, ^BSCXMT will pack the
        transmitter buffer with data from the queued global.  The format for
        packing the buffer is dependent on how the emulator was configured at
        startup.  When the file has been successfully sent, the index is removed
        from the "SEND" queue and moved to the "SENT" queue, an EOT is sent to
        the remote system and control is returned to ^BSCPEB.
        ^BSCPER
        This utility will setup a set of symbols that may be used by a routine
        to test for error conditions on a BSC IO sequence.  The symbols are
        bit mask commands intended for indirect conditional testing.
        IF @%ENDSR GOTO NODSR
        ^BSCSTR
        This routine will interactively start the BSC protocol emulator spooler
        as a background job (^BSCPEB).
        ^BSCHLT
        This routine will interactively stop a BSC protocol emulator spooler.
        ^BSCSTA
        This routine will display the status of a BSC spooler
        ^BSCQUE
        This routine provides an interactive means of inserting a
        valid global reference into the send queue of any selected
        BSC PE spooler.
        ^BSCDAT
        This is a global containing all the spooler configuration information,
        error logging data, and data files received or sent.
        ^BSCDAT= device number currently being started for spooling
        ^BSCDAT (DEVICENUM) = current status for spooler attached to this device
        List of received data files:
                          ,"RCVD") = next index number (RCVNUM)
                          ,"RCVD",RCVNUM) = global reference pointer (GREF)
        List of sent data files:
                          ,"SENT") = next index number (SNTNUM)
                          ,"SENT",SNTNUM) = global reference pointer (GREF)
        List of data waiting to be sent:
                          ,"SEND") = next index number (SNDNUM)
                          ,"SEND",SNDNUM) = global reference pointer (GREF)
        List of data files dequeued because of errors
                          ,"ERROR") = next index number (ERRNUM)
                          ,"ERROR",ERRNUM) = global reference pointer (GREF)
        Startup configuration information
                          ,"STARTUP","CSET") = character set identifer (E,A,T)
                          ,"STARTUP","CUPOL") = control unit poll address
                          ,"STARTUP","CUSEL") = control unit selecet address
                          ,"STARTUP","EMUL") = emulator mode (1,2,3)
                          ,"STARTUP","GIN")  = global ref. for received data
                          ,"STARTUP","LMOD") = line mode (S,L)
                          ,"STARTUP","LOG")  = message logging device (L,S,T)
                          ,"STARTUP","NMOD") = network mode (P,M)
                          ,"STARTUP","REC")  = record length of transmitted data
                          ,"STARTUP","TRN")  = terminal # for logging messages
        Status information:
                          ,"STATUS","%ENDSR") = number data set ready failures
                          ,"STATUS","%ENCXR") = number of carrier detect failures
                          ,"STATUS","%EENQX") = number of ENQ thresholds exceeded
                          ,"STATUS","%ENAKX") = number of NAK thresholds exceeded
                          ,"STATUS","%ETIMO") = number of physical IO timeouts
                          ,"STATUS","%ENCTS") = number of clear-to-send failures
        Data is stored in ^BSCDAT indexed by an arbitrary index number stored
        at the "DATA" subscript level and incremented each time a new file
        is created within the ^BSCDAT "DATA" level.
        ^BSCDAT("DATA") = next available index level for data
        ^BSCDAT("DATA",DATNUM) = file type (transparent/nontransparent)
                                 and destination (printer/punch)
        ^BSCDAT("DATA",DATNUM,1) = 1st data record for data file number DATNUM
                              .
                              .
                              .
        ^BSCDAT("DATA",DATNUM,n) = last data record for data file number DATNUM
