# ######## GNU ########
#F90 = gfortran
#FFLAGS = -O3 -Wall
#FFLAGS = -g -Wall
# -ffpe-trap=zero,invalid,underflow -fbacktrace
#LDFLAGS = -O3

# ######## INTEL ########
# F90 = ifort
# FFLAGS = -O3 
# #FFLAGS = -g -Wall
# LDFLAGS = -O3

# ######## PGI ########
F90 = pgf90
FFLAGS = -O2
LDFLAGS = -O2

ARCH_GPU=
#FFLAGS_CUDA = -v -O3 -Mcuda -Mcuda=6.5 -Mcuda=$(ARCH_GPU) -Mcuda=ptxinfo -ta=nvidia,fastmath,mul24,maxregcount:48,time -Minfo=all -Mpreprocess  -Mcuda=rdc
FFLAGS_CUDA = -O2 -Mpreprocess
#-Mcuda=keepgpu
LDFLAGS_CUDA = -O2 -ta=nvidia -Mcuda=keepgpu

OBJ=o
EXE=out

RUN=
UNAME := $(shell uname -a)
ifeq ($(findstring CYGWIN_NT, $(UNAME)), CYGWIN_NT)
   OBJ=obj
   EXE=exe
endif

# PGI Debug #
# F90 = pgfortran
# FFLAGS = -fast -Minform=warn -Minfo -g
# LDFLAGS = 

# ARCH_GPU=cc35
# FFLAGS_CUDA = -g -v -Mcuda -Mcuda=5.5 -Mcuda=$(ARCH_GPU) -Mcuda=ptxinfo -ta=nvidia,fastmath,mul24,maxregcount:48,time -Minfo=all -Mpreprocess -Mcuda=keepgpu
# LDFLAGS_CUDA = -Mcuda=5.5 -Mcuda=$(ARCH_GPU)

SRCDIR = .

CUDA_SRC = \
	m_HydroPrecision.cuf \
	m_HydroConstants.cuf \
	m_HydroParameters.cuf \
	m_Monitoring_gpu.cuf \
	m_HydroParameters_gpu.cuf \
	m_HydroUtils_gpu.cuf \
	m_HydroRun_gpu.cuf \
	main_gpu.cuf
	
F90_SRC = \
	m_Monitoring.f90 \
	m_HydroUtils.f90 \
	m_HydroRun.f90 \

CUDA_OBJ = $(CUDA_SRC:.cuf=.$(OBJ))

F90_OBJ = $(F90_SRC:.f90=.$(OBJ))

all: euler2d_gpu

euler2d_gpu: $(RUN) $(CUDA_OBJ) $(F90_OBJ)
	$(F90) $(LDFLAGS_CUDA) $(CUDA_OBJ) $(F90_OBJ) -o $@


clean:
	rm -f *.o *.mod *.obj *.pdb euler2d_cpu euler2d_gpu 

cleanall: clean
	rm -f *.vti *.*.gpu *.*.h crt1.reg.c

%.$(OBJ):    $(SRCDIR)/%.f90
	$(F90) $(FFLAGS) -c $<

%.$(OBJ):    $(SRCDIR)/%.cuf
	$(F90) $(FFLAGS_CUDA) -c $<
