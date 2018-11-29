FLAG=$(shell geant4-config --cflags) 
LIBS=$(shell geant4-config --libs)

ROOT_AVAILABLE:=$(shell command -v root-config 2> /dev/null)
ifdef ROOT_AVAILABLE
  ROOTCONFIG = root-config
  ROOTCFLAGS:= $(shell $(ROOTCONFIG) --cflags)
  ROOTLIBS  := $(shell $(ROOTCONFIG) --libs)
  FLAG+=$(ROOTCFLAGS) -DhasROOT
  LIBS+=$(ROOTLIBS)
endif

GDML_ENABLED:=$(shell geant4-config --has-feature gdml)
ifeq ($(GDML_ENABLED),yes)
  FLAG+=-DhasGDML
  LIBS+=-L$($XERCESC_ROOT_DIR)/lib -lxerces-c
endif

SRC=$(wildcard *.C)
TGT=$(SRC:.C=.exe)

.PHONY: all clean docs

all: $(TGT)

%.exe: %.C
	$(CXX) $(FLAG) $^ -o $@ $(LIBS)

clean:
	rm -f `cat .gitignore`

docs:
	doxygen Doxyfile
