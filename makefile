#########################################################
#       CSPS MAIN PROGRAMS MAKEFILE allen 20170311
#########################################################

ORACLE_HOME=/oracle/app/oracle/product/11.2.0/db
include $(ORACLE_HOME)/precomp/lib/env_precomp.mk
INCLUDE=$(I_SYM).

.SUFFIXES: .pc .c .o .ccs .lis
#.pc-ORALCE+C  .ccs-C+CICS .pc-ORACLE+CICS+C

#########################################################
#           Programs path                               #
#                                                       #
#                                                       #
#########################################################

LIB=      $(ROOTPATH)/lib
BIN=      $(ROOTPATH)/bin
TEMP=     $(ROOTPATH)/tmp
PROC=     $(ORACLE_HOME)/bin/proc

ROOTPATH=$(HOME)/ZJZL_TW
CICSPATH=/usr/lpp/cics
CTGPATH=/opt/IBM/cicstg
MQPATH=/usr/mqm
PRECOMPPUBLIC=-I$(ORACLE_HOME)/precomp/public
INCLUDE=$(PRECOMPPUBLIC) \
        -I$(CICSPATH)/include \
        -I$(ROOTPATH)/inc \
        -I$(MQPATH)/inc \
        -I$(ORACLE_HOME)/rdbms/demo \
        -I$(ORACLE_HOME)/rdbms/public\
        -I$(ORACLE_HOME)/xdk/include \
        -I$(CTGPATH)/include
PROCFLAGS=define=__64BIT__ define=_IBM_C define=_LONG_LONG \
        include=$(ROOTPATH)/inc \
        include=$(CICSPATH)/include \
        include=$(MQPATH)/inc\
        include=$(ORACLE_HOME)/rdbms/demo \
        include=$(ORACLE_HOME)/rdbms/public \
        prefetch=10 
LIBHOME=$(MQPATH)/lib \
      -L$(ORACLE_HOME)/lib32


#########################################################
#               Add your lib here                       #
#                                                       #
#                                                       #
#########################################################
LIBCSS=  $(LIB)/libcs.a $(LIB)/libcm.a $(LIB)/libcv.a   $(LIB)/libtc.a $(LIB)/libsc.a \
        /usr/lib/libiconv.a

LIBXML=
PROLDLIBS=-lclntsh

#########################################################
#               Complie tools                           #
#                                                       #
#                                                       #
#########################################################
LIBDIR=lib32
CCFLAGS=-q32
CCFLAGSCC=-q32
CFLAGS=-g

CC1= /usr/vac/bin/xlc_r -qalign=packed -qlist -bloadmap:LOAD 
CC2=  cc  -qalign=packed  -qlist -bloadmap:LOAD 

CICSTCL = cicstcl -s
MAKEFILE=makefile

#########################################################
#            Add your programs here                     #  
#                                                       #
#                                                       #
#########################################################
C_ONLY	= 

C_ORA	= tw_putctis 

C_CICS	= tcoTranCtl  idcheck

C_CICS_ORA= codTran

all	: $(C_ONLY) $(C_CICS_ORA) $(C_ORA) $(C_CICS) 

build	: $(OBJS)
	@echo ======================= BUILD =================================
	$(CC1) -o $(EXE) $(OBJS) $(INCLUDE) -L$(CICSPATH)/lib -lmqm $(LIBCSS)
	rm -f $(EXE).o
	mv -f $(EXE) $(BIN)
	@echo =================== MAKE $(EXE) END. ==========================

buildoracle: $(OBJS)
	@echo ==================== BUILDORACLE ==============================
	$(CC1) -o $(EXE) $(OBJS) $(INCLUDE) -L$(LIBHOME) $(PROLDLIBS)  
	rm -f $(EXE).c 
	rm -f $(EXE).o 
	rm -f $(EXE).lis 
	rm -f $(EXE).lst 
	mv -f $(EXE) $(BIN)
	@echo =================== MAKE $(EXE) END. ==========================

buildcics: 
	@echo ==================== BUILDCICS   ==============================
	CCFLAGS="-qalign=packed -DCICS_AIX -bloadmap:LOAD -L$(ORACLE_HOME)/lib32 -lcclaix  \
	$(INCLUDE) -qldbl128 -lc128 \
        -L$(ORALCE_HOME)/precomp/lib -lclntsh -lm -lld -L/usr/mqm/lib -lmqm_r $(LIBCSS) $(LIBXML)"; \
        export CCFLAGS; \
	$(CICSTCL) -lC $(EXE).ccs 
	rm -f $(EXE).c
	rm -f $(EXE).lis
	rm -f $(EXE).lst
	mv -f $(EXE)     $(BIN)
	@echo =================== MAKE $(EXE) END. ==========================

$(C_ONLY): 
	@echo "====================C_ONLY======================="
	$(MAKE) -f $(MAKEFILE) build OBJS=$*.o EXE=$@

$(C_CICS):
	@echo "====================C_CICS======================="
	$(MAKE) -f $(MAKEFILE) buildcics EXE=$@

$(C_ORA):
	@echo "====================C_ORA========================"
	$(MAKE) -f $(MAKEFILE) buildoracle OBJS=$@.o EXE=$@

$(C_CICS_ORA): 
	@echo "====================C_CICS_ORA==================="
	$(PROC) $(PROCFLAGS) release_cursor=no sqlcheck=syntax ireclen=512 iname=$*.pc 
	mv $*.c $*.ccs
	$(MAKE) -f $(MAKEFILE) buildcics EXE=$@
	mv -f $*.ccs $(TEMP)

.c.o:
	@echo "====================.C.O========================="
	if [ $(LAYER_FLAG) = "CM" ] ; then   \
	$(CC2) $(CFLAGS) -c $*.c $(INCLUDE) -lmqm; \
	else \
	$(CC1) $(CFLAGS) -c $*.c $(INCLUDE) -lmqm; \
	fi;
.pc.c:
	@echo "====================.PC.C========================"
	$(PROC) $(PROCFLAGS) iname=$*.pc 

.pc.o:
	@echo "====================.PC.O========================"
	$(PROC) $(PROCFLAGS) iname=$*.pc
	if [ $(LAYER_FLAG) = "CM" ] ; then   \
	$(CC2) $(CFLAGS) -c $*.c $(INCLUDE) -lmqm; \
	else \
	$(CC1) $(CFLAGS) -c $*.c $(INCLUDE) -lmqm; \
	fi;
#########################################################
#                                                       #
#                    End of file                        #
#                                                       #
#########################################################
