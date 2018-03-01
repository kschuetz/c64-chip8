
BUILDDIR := build
PROGRAM := $(BUILDDIR)/chip8.prg
SOURCES := source
INCLUDES := include
LIBS :=
OBJDIR := obj
DEBUGDIR := $(BUILDDIR)
DISTDIR := dist
DISTPRG := $(DISTDIR)/chip8.prg
DISK := $(DISTDIR)/chip8.d64
LABELSFILE := $(BUILDDIR)/chip8.labels

LINKCFG := cfg/c64-linker.cfg
ASFLAGS := -t c64
LDFLAGS	= -C$(LINKCFG) \
          -m $(DEBUGDIR)/$(notdir $(basename $@)).map \
          -Ln $(DEBUGDIR)/$(notdir $(basename $@)).labels -vm
VICE := x64
VICEDEBUGFLAGS := -moncommands $(LABELSFILE)

################################################################################

LD            := ld65
AS	          := ca65
MKDIR         := mkdir
RM            := rm -f
RMDIR         := rm -rf

################################################################################

ofiles :=
sfiles := $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.s))
incfiles := $(foreach dir,$(INCLUDES),$(wildcard $(dir)/*.s))
extra_includes := $(foreach i, $(INCLUDES), -I $i)

define depend
  my_obj := $$(addprefix $$(OBJDIR)/, $$(addsuffix .o, $$(notdir $$(basename $(1)))))
  ofiles += $$(my_obj)

  $$(my_obj):  $(1) $(incfiles)
	$$(AS) -g -l $$(addprefix $$(OBJDIR)/, $$(addsuffix .lst, $$(notdir $$(basename $(1))))) -o $$@ $$(ASFLAGS) $(extra_includes) $$<
	
endef

################################################################################

.SUFFIXES:
.PHONY: all disk release run run-ntsc run-pal debug debug-pal debug-ntsc clean
all: $(PROGRAM)

$(foreach file,$(sfiles),$(eval $(call depend,$(file))))

$(OBJDIR):
	[ -d $@ ] || mkdir -p $@
	
$(BUILDDIR):
	[ -d $@ ] || mkdir -p $@

$(PROGRAM): $(BUILDDIR) $(OBJDIR) $(ofiles)
	$(LD)  $(LDFLAGS) $(ofiles) $(LIBS) -o $@

$(DISTDIR):
	[ -d $@ ] || mkdir -p $@

$(DISTPRG): $(DISTDIR) $(PROGRAM)
	exomizer sfx basic $(PROGRAM) -o $(DISTPRG)
	
disk: $(DISTPRG)
	c1541 -format chip8,ks d64 $(DISK) -attach $(DISK) -write $(DISTPRG) chip8

release: $(DISTPRG) disk

run: $(PROGRAM)
	$(VICE) $(VICEFLAGS) $(PROGRAM)

run-ntsc: $(PROGRAM)
	$(VICE) -ntsc $(VICEFLAGS) $(PROGRAM)

run-pal: $(PROGRAM)
	$(VICE) -pal $(VICEFLAGS) $(PROGRAM)

debug: $(PROGRAM)
	$(VICE) $(VICEFLAGS) $(VICEDEBUGFLAGS) $(PROGRAM)

debug-ntsc: $(PROGRAM)
	$(VICE) -ntsc $(VICEFLAGS) $(VICEDEBUGFLAGS) $(PROGRAM)

debug-pal: $(PROGRAM)
	$(VICE) -pal $(VICEFLAGS) $(VICEDEBUGFLAGS) $(PROGRAM)

clean:
	$(RM) $(OBJDIR)/*
	$(RM) $(BUILDDIR)/*
	$(RM) $(DISTDIR)/*
