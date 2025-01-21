# this makefile is for MacOS v 15.2
# compiles with gfortran 14.02 and gcc 16.0
OPT           = -O 
ENV           = -ffixed-line-length-80 -fallow-argument-mismatch
#FC	      = /Users/juersdh/miniconda3/bin/gfortran  $(ENV) 
FC	      = gfortran  $(ENV) 
CC            = gcc 

FFLAGS 	      = -mmacosx-version-min=14.0 $(OPT)
#FFLAGS	      = -static -vms_cc $(OPT) -backslash -OPT:Olimit=0
CFLAGS        = -mmacosx-version-min=14.0 $(OPT)
#CFLAGS        = -I/usr/local/include $(OPT) -mmacosx-version-min=12.0

LDFLAGS	      = -L/usr/local/lib -L/opt/local/lib -L/usr/lib -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib

#LIBS	      = -B dynamic -lreadline -B dynamic -lcurses
#LIBS          = -lreadline

OBJS	      = clique.o       rtnout.o \
		abcd.o        harker.o       pair.o  \
	        setw.o \
		atom.o        param.o  \
	        snayb.o \
		axis.o         eular.o  pickr.o  \
		chklib.o       find1.o     polar.o  \
     		smg.o  \
		get_command.o   order.o          edpdb.o \
		listatom.o        needlemen1d.o  volume.o subr-linux-g77.o \
		thread.o

PROGRAM	      = edpdb_v22

SRCS	      = clique.f        rtnout.f \
		abcd.f        harker.f       pair.f  \
	        setw.f \
		atom.f     param.f  \
	        snayb.f \
		axis.f         eular.f  pickr.f  \
		chklib.f       find1.f     polar.f  \
		smg.c \
		get_command.f       order.f  edpdb.f \
  		listatom.f         needlemen1d.f  volume.f subr-linux-g77.f \
		thread.f

.f.o :
		$(FC) -c $(FFLAGS) $*.f

$(PROGRAM):     $(OBJS)
		@echo -n "Loading $(PROGRAM) ... "
		@$(FC) $(FFLAGS) $(LDFLAGS) $(OBJS) $(LIBS) -o $(PROGRAM)
		@echo "done"
