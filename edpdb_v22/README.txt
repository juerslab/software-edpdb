EdPDB was written by X. Cai Zhang. zhangc@ibp.ac.cn. 

The EDPDB program package consists of one program and number of accessary files. 
This EDPDB distribution is from a GitHub repository located at "https://github.com/juerslab/software-edpdb"

To run the executable "edpdb_v22", one needs to include the file  "edpdb.csh" in his/her ".login" file.  This "edpdb.csh" file defines the required logicals names, etc. ONE MAY NEED TO MODIFY THIS FILE BEFORE USE IT ON YOUR OWN COMPUTER.

The executable edpdb_v22 was compiled in Mac OS v15.2 using gfortran v 14.02 and gcc v 16.0.
 
For linux systems, please see the github repository located "https://github.com/cz-zhao-lab-ibp/edpdb"

----------
Code changes related to Mac OS. Doug Juers. juersdh@whitman.edu
========================================
Changes to edpdb for OS X (Jaguar 10.2.4). 
Using gcc version 4.2 (with gfortran) 

makefile

	1. -col80 -> -ffixed-line-length-80
	2. comment out FFLAGS
	3. remove $(ENV) from cc line
	4. comment in use of readline and curses libraries
        5. use subr-generic

Source:

	Most files needed continuation characters adjusted.

	atom.f:
		Lines ~85-105: gfortran doesn't like assigning 
		statement numbers to variables. So this was worked around.

		Line 357: Problem with alternate returns was worked around
		with a computed goto.

		
	edpdb.f:
	
		Line 482: Problem with alternate returns was worked around with a computed goto.


	chklib.f:

		idate is somewhat different in gfortran, as was adjusted accordingly.

	smg.c:

		Replace RETURN with its ascii code (13).
		
        subr-generic.f

		Lines 119-120: comment out these lines. Don't need to declare 
		these routines as external.

	subr-linux-f77.f
		
		Replaced a couple smg_ subroutines with version from subr-generic


There were still a few warnings when compiling, but the executable works ok so far.

Doug Juers (juersdh@whitman.edu)
2 January 2008
Updates for gcc 4.6 
listatom.f
	Comment out write statements for error reporting that had negative values as parameters

Possibly some undocumented changes in these years.

28 May 2022 compiles on OSX 11.6
In subr-generic comment out backspace(io) in sgi_backspace subroutine.
Modified code (several programs) to:
a. accept single quotes as delimiters for residue names (which allows for space in the names) (note this is already possible with atom names)
b. use a 5 character field for atomnames rather than 4. (character*5 atoma(4), atom_x, atom_y,  and a few related lines) throughout
Best way to specify atom name is with single quotes and spaces
Note this covers columns 13-17 rather than 14-17. 
c. All spaces in atom names get converted to _

Some notes about the functioning of edpdb
1. Edpdb is run first.
2. Files are read with read (located in rtnout)
3. Routine for loading data is readf (including readf1)

31 Aug 2023 on OSX 13.5.1
I had to comment out a lines in the get_window_size from subr-linux-g77. This should break this routine, but we'll see...

15 Oct 2023 on OSX 14.7
The ca and main commands don't turn on any atoms. This is presumably because of the changes made in May 2022. 
To fix this I changed a line 11 in axis.f to include underscores:
data (dfm(i),i=1,4),dca/'_n___','_ca__','_c___','_o___','_ca__'/	
(Using dfca and dfmain also works, but the above changes the defaults.)

21 Jan 2025 on MacOS 15.2
Compiles using gcc 14.2.0_1 from homebrew.