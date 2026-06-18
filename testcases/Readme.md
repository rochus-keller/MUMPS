## Testcase collection

For the purpose of testing/validating the MUMPS-76 parser, the following sources/projects have been found on the internet.
This is a complete list of all downloaded files. Not all must be present in the repository.

### DSM-11 V3.3 System Routines (Bitsavers Disk Image)

**Downloaded from**: `https://bitsavers.org/bits/DEC/pdp11/dsm-11/dsm_working_rl.dsk` (RL01 format, booted via SIMH PDP-11/83 emulator)

The SIMH terminal emulation wraps output at 132 columns. Lines longer than 132 characters are truncated in the extracted files. This affects 119 of 376 files (but most truncated lines are in routines that still parse correctly,only 63 files have parse failures attributable to truncation).

| Category | Count | Description |
|----------|-------|-------------|
| `PCT_*` (system utilities) | 124 | `%` prefix DSM-11 standard utilities renamed to `PCT_`: `%GD` (global directory), `%RS` (routine save), `%ED` (editor, dated 29-Aug-78), `%G` (global lister), `%SY` (system status), `%MENU` (menu driver), `%JOB` (job inspector), `%HELP` (help system), `%SUM` (routine summary), `%CRF` (cross-reference), `%FGC`/`%FGR` (fast global copy/restore), etc. |
| `BACK*` (backup system) | 23 | Scheduled backup: create, verify, journal, restore. Many carry "DSM11 Utilities; Copyright 1980 DEC". |
| `BSC*` (bisync communications) | 13 | IBM 2780/3780 BSC protocol emulator and spooler (JHM, Sep–Oct 1982). |
| `DDP*` (distributed data) | 6 | DECnet DDP networking utilities,link status, circuit info, configuration (JHM, Feb 1985). |
| `JRN*` (journaling) | 11 | Journal start/stop, disk-to-tape offload, recovery, de-journaling (DRS, 1983). |
| `CTK*` (caretaker) | 6 | Background caretaker process,error logging for disk/tape errors (DB, Nov–Dec 1980). |
| `IC*` (integrity checker) | 6 | Global and routine directory integrity verification (SMB). |
| `SG*` / `SYSGEN` | 12 | System generation,buffer allocation, disk layout, partition definition, software options (JHM, 1983). Copyright 1980 DEC. |
| `STU*` (startup) | 12 | System startup and startup command file builder (JBH, Jun–Jul 1980). |
| `DP*` (disk/tape utilities) | 10 | Disk formatting, labeling, system image copy, test utilities. |
| `AUPAT*` (autopatch) | 4 | Automated patching system. |
| `MBP*` (multi-block print) | 5 | Multi-block print utilities. |
| Miscellaneous system | ~64 | `ACTJOB` (active jobs), `ALLOCAT` (allocation), `CONFIG` (autoconfigure, JHM 1983), `DISKMAP`, `MOUNT`/`DISMOUNT`, `SYSGEN`, `V3UTILS` (V3 installation kit, JBH 1983), `LOAD`/`UNLOAD`, `MAKESDP`, `LOCKTAB`, `PEEK`, `PATCH`, `TRANTAB` (translation tables), `UCI*` (UCI management), etc. |

**Copyright/License**: The routines are part of the DSM-11 system software distributed by Digital Equipment Corporation. 16 files carry explicit "Copyright 1980 DEC". The remaining routines were written by DEC employees or contractors as part of the DSM-11 product. The disk image is archived on Bitsavers as historical preservation; no open-source license applies.

---

### DECUS MUMPS SIG Tape (1990), Games

**Downloaded from**: `advenetc.zoo` from `http://www.digiater.nl/openvms/decus/lt90a/mumpssig/games/advenetc.zoo`

| File | Size | Description |
|------|------|-------------|
| adventure.rou | 29K | Colossal Cave Adventure,translated to MUMPS by Fred Hiltz (InterSystems) in 1983, modified by PRx Inc 1988-89 |
| adventure.glo | 117K | Adventure game global data (^ADV) |
| adv.glo | 128K | Additional Adventure data |
| startrek.rou | 25K | Star Trek game,Copyright 1986 COMP MARK, Inc. |
| kubic.rou | 8K | Qubic 3D Tic-Tac-Toe,Michael McIntyre, PRx Inc, August 1986 |
| eights.rou | 5K | Crazy Eights card game,PRx Inc, 1986-87 |
| hobbit.rou | 4K | Hobbit game,Michael McIntyre, PRx Inc, 1986-88 |

**Copyright/License**:
- Adventure: "Copyright (c) 1989 PRx, Inc.",original translation by Fred Hiltz (InterSystems, 1983)
- Star Trek: "COPYRIGHT 1986 COMP MARK, Inc.,This program may be freely copied for non-commercial use ONLY"
- Eights, Hobbit, Kubic: "(c) Copyright 1986,1987 PRx, Inc. Concord, MA"

---

### DECUS MUMPS SIG Tape (1990), VA FileMan V17.7

**Downloaded from**: `http://www.digiater.nl/openvms/decus/lt90a/mumpssig/fileman/fman.zoo`

| File | Size | Description |
|------|------|-------------|
| fm.rou | 385K | DI* FileMan core routines |
| fminit.rou | 143K | DINI* initialization routines |
| fmmgr.rou | 177K | Manager routines (most MUMPS implementations) |
| fmvaxmgr.rou | 38K | Manager routines (VAX DSM only) |
| user.doc | 156K | User documentation |
| program.doc | 83K | Programmer documentation |

**Copyright/License**: VA FileMan is a US Government work (Veterans Administration), therefore public domain in the US. Distributed freely via MUMPS Users' Group and DECUS.

---

### DECUS MUMPS SIG Tape (1990), Kermit for DSM

**Downloaded from**: `http://www.digiater.nl/openvms/decus/lt90a/mumpssig/tools/kermit.zoo`

| File | Size | Description |
|------|------|-------------|
| kermit.rou | 70K | Kermit routines (DSM-11/VAX version by PRx Inc) |
| kermit.glo | 58K | Kermit reference global |
| kermit.txt | 19K | Documentation |

**Copyright/License**: Routines include "(c) Copyright 1986,1987 PRx, Inc. Concord, MA" and "(c) Copyright 1986,1987 Ben Bishop". This is the Ben Bishop DSM-11 adaptation mentioned in mpker.bwr. Kermit Project overall is now 3-clause BSD license (since 2011). PRx portions may have separate terms.

---

### DECUS MUMPS SIG Tape (1990), UCD MUMPS

**Downloaded from**: `http://www.digiater.nl/openvms/decus/lt90a/mumpssig/ucdmumps/mumps.zoo`

Includes a complete MUMPS implementation for PC-DOS with routines, globals, documentation. Contains MUMPS routines in `routines.dat` (133K, packed format) and globals in `globals.dat` (22K).

**Copyright/License**: University of California Davis. The `aareadme.txt` references redistribution via DECUS. The related MDC page at `http://71.174.62.16/MDC/` states it's freely downloadable.

---

### Columbia Kermit-M Archive (Original M/11 Version)

**Downloaded from** (via Wayback Machine):
- `https://web.archive.org/web/2020/https://www.columbia.edu/kermit/ftp/mumps/mpker.rou`
- `https://web.archive.org/web/2020/https://www.columbia.edu/kermit/ftp/mumps/mpker.glo`
- `https://web.archive.org/web/2020/https://www.columbia.edu/kermit/ftp/mumps/mpker.bwr`
- `https://web.archive.org/web/2020/https://www.columbia.edu/kermit/ftp/mumps/mpker.msg`


| File | Size | Description |
|------|------|-------------|
| mpker.rou | 43K | ~20 MUMPS routines (ZKR, ZKRC, ZKRT20, ZKRS, etc.) in %RO/%RI format |
| mpker.glo | 57K | ^ZKRX reference global with help text, version info, parameters |
| mpker.bwr | 5K | Bug reports and notes from Ben Bishop (The MUMPS Collaborative) |
| mpker.msg | 1K | Description and contact info |
| mpkerdoc.txt | 19K | Full documentation |

**Copyright/License**: "Copyright (c) 1984 New York State College of Veterinary Medicine" (David Rossiter). The Kermit Project has been under **3-clause BSD license** since 2011 (see `https://kermitproject.org/ck10license.html`): "All other software in the Kermit archive to which Columbia University holds the copyright should be considered to have the Revised 3-Clause BSD License."

---

### GitHub m-adventure

**Downloaded from**: `https://github.com/whitten/m-adventure`

David Whitten's 2016 modernization of the DECUS Adventure game, modified to use VA FileMan data structures and VistA SACC routines. Original MUMPS translation by Fred Hiltz (InterSystems, 1983).

**Copyright/License**: License file says "NOASSERTION". README requests help contacting original authors for license clarity. Original: Fred Hiltz (InterSystems, 1983), modifications by PRx Inc (1988-89), David Whitten (2016).

---

### Z80-MUMPS / MicroMUMPS (CP/M)

**Downloaded from**: `http://www.retroarchive.org/cpm/lang/Z80-MUMP.ZIP`

Contains:

- System utilities: %EDIT (editor, (c) 1980 J.J.Althouse), %EDITH, %IS (input/output setup), %DIR, %DATE, %NAMES, %ZBU/%ZBV (backup/restore), %ZRS, %ZEDT (editor variants), %MG/%MGR/%MGS (global manager), %MR* (routine manager)
- Applications: MOPT.MMP (mailing list package driver, Dec 1980), MEDIT.MMP (mailing list editor), MPRT.MMP (mailing list printer), MFLG.MMP (flag editor), MLOOK.MMP (lookup), FORMI.MMP (forms input demo), FORMD.MMP/FORME.MMP/FORMO.MMP (forms system), LEXICON.MMP (sorted dictionary creator), MCLABEL.MMP (mailing labels)
- Application packages: BRKEVN.CAL (break-even calculator), BUDGET.CAL, DENSITY.SGL
- MUMPS interpreter: Z8022.COM (Z-80 MUMPS executable), INSTALL.* (installer)

**Copyright/License**: %EDIT is "(c) 1980 J.J.Althouse & Assoc." MOPT/MEDIT are by "JEB" (December 1980). The package was distributed via retroarchive.org as freeware/abandonware from the CP/M era. No formal open-source license exists; treat as historical software with unclear redistribution rights.

---

### MUMPS-SR (8080 MUMPS Interpreter Source)

**Downloaded from**: `http://www.retroarchive.org/cpm/lang/MUMPS-SR.ZIP`

Contains:
- **Disk 1**: `MUMPS1.ASM`,8080 assembly source code for the MUMPS interpreter (version 2.62)
- **Disk 2**: MUMPS utility routines (.MMP files) + `MUMPS2.ASM` (continuation of interpreter source) + application examples (KWIC, LEXICON, MEDIT, MOPT, MPRT, MLOOK, MFLG, BIBENTRY, HEAPSORT, STOPWORD)

This is the source code of a MUMPS implementation itself, plus MUMPS application routines.

**Copyright/License**: The interpreter header says "8080 MUMPS VERSION 2.62". No explicit license visible in the files. Distributed as CP/M freeware via retroarchive.org. Historical software.

---

### UCD MUMPS 5.23 (CP/M)

**Downloaded from**: `http://71.174.62.16/MDC/UCD_5_23.zip`

Later version of the UC Davis MUMPS for DOS/CP/M. Contains MUMPS executable, routines, documentation. Includes FOLDER.MMP and variants (a folder/mail system).

**Copyright/License**: University of California Davis. Freely downloadable from MDC (MUMPS Development Committee) website.

---

### LA-6065-MS: MUMPS Code-Building Package (Los Alamos, 1975)

**Downloaded from**: `https://www.osti.gov/servlets/purl/5064476`

Los Alamos Scientific Laboratory report from September 1975. Describes a collection of 17 MUMPS-11 programs for automatic code generation for database management, written for DEC PDP-11 MUMPS V3. Appendix B contains complete listings of all 17 programs.

**Copyright/License**: US Government work (Department of Energy / Los Alamos). The report header states "DISTRIBUTION OF THIS DOCUMENT IS UNLIMITED". Public domain.


