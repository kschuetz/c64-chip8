
BUILDDIR := build
PROGRAM := $(BUILDDIR)/chip8.prg
SOURCES := source
INCLUDES := include
LIBS :=
OBJDIR := obj
DEBUGDIR := $(BUILDDIR)



LINKCFG := cfg/c64-asm.cfg
ASFLAGS := -t c64
LDFLAGS	= -C$(LINKCFG) \
          -m $(DEBUGDIR)/$(notdir $(basename $@)).map \
          -Ln $(DEBUGDIR)/$(notdir $(basename $@)).labels -vm

################################################################################

LD            := ld65
AS	      := ca65

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
.PHONY: all clean
all: $(PROGRAM)

$(foreach file,$(sfiles),$(eval $(call depend,$(file))))

$(OBJDIR):
	[ -d $@ ] || mkdir -p $@
	
$(BUILDDIR):
	[ -d $@ ] || mkdir -p $@

$(PROGRAM): $(BUILDDIR) $(OBJDIR) $(ofiles)
	$(LD)  $(LDFLAGS) $(ofiles) $(LIBS) -o $@ 

clean:
	$(RMDIR) $(OBJDIR)
	$(RMDIR) $(BUILDDIR)