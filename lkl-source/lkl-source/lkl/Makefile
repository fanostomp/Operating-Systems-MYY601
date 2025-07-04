#Theofanis Tompolis 4855
#Athanasios Fytilis 5381
#Marinos Aristidou 5397

# Do not use make's built-in rules
# (this improves performance and avoids hard-to-debug behaviour);
# also do not print "Entering directory..." messages from make
.SUFFIXES:
MAKEFLAGS += -r --no-print-directory

KCONFIG?=defconfig

ifneq ($(silent),1)
  ifneq ($(V),1)
	QUIET_AUTOCONF       = @echo '  AUTOCONF '$@;
	Q = @
  endif
endif

PREFIX := /usr
BINDIR := $(PREFIX)/bin
INCDIR := $(PREFIX)/include
LIBDIR := $(PREFIX)/lib

ifeq (,$(srctree))
  srctree := $(patsubst %/,%,$(dir $(shell pwd)))
  srctree := $(patsubst %/,%,$(dir $(srctree)))
endif
export srctree

-include ../scripts/Makefile.include

# OUTPUT fixup should be *after* include ../scripts/Makefile.include
ifneq ($(OUTPUT),)
  OUTPUT := $(OUTPUT)/tools/lkl/
else
  OUTPUT := $(CURDIR)/
endif
export OUTPUT


all:

conf: $(OUTPUT)Makefile.conf

$(OUTPUT)Makefile.conf $(OUTPUT)include/kernel_config.h $(OUTPUT)/kernel.config: Makefile.autoconf
	$(call QUIET_AUTOCONF, headers)$(MAKE) -f Makefile.autoconf -s

-include $(OUTPUT)Makefile.conf

export CFLAGS += -I$(OUTPUT)/include -Iinclude -Wall -g -O2 -Wextra \
	 -Wno-unused-parameter \
	 -Wno-missing-field-initializers -fno-strict-aliasing \
	 -Wno-cast-function-type -Wno-restrict

-include Targets

TARGETS := $(progs-y:%=$(OUTPUT)%$(EXESUF))
TARGETS += $(libs-y:%=$(OUTPUT)%$(SOSUF))
all: $(TARGETS)

# this workaround is for FreeBSD
bin/stat:
ifeq ($(LKL_HOST_CONFIG_BSD),y)
	$(Q)ln -sf `which gnustat` bin/stat
	$(Q)ln -sf `which gsed` bin/sed
else
	$(Q)touch bin/stat
endif

ASM_UAPI_GENERATED:=$(OUTPUT)../../arch/lkl/include/generated/uapi/asm
ASM_CONFIG:=$(ASM_UAPI_GENERATED)/config.h
DOT_CONFIG:=$(OUTPUT)../../.config

$(DOT_CONFIG): $(OUTPUT)/kernel.config
	$(Q)$(MAKE) -C ../.. ARCH=lkl $(KOPT) $(KCONFIG)
	$(call QUIET_INSTALL, kernel.config)cat $(OUTPUT)/kernel.config >> $(DOT_CONFIG)
	$(Q)$(MAKE) -C ../.. ARCH=lkl $(KOPT) olddefconfig
	$(Q)$(MAKE) -C ../.. ARCH=lkl $(KOPT) syncconfig


$(ASM_CONFIG): $(OUTPUT)include/kernel_config.h
	$(Q)mkdir -p $$(dirname $@)
	$(call QUIET_INSTALL, kernel_config.h)cp $<  $@

# rule to build lkl.o
$(OUTPUT)lib/lkl.o: bin/stat $(ASM_CONFIG) $(DOT_CONFIG)
# this workaround is for arm32 linker (ld.gold)
	$(Q)export PATH=$(srctree)/tools/lkl/bin/:${PATH} ;\
	$(MAKE) -C ../.. ARCH=lkl $(KOPT)
	$(MAKE) -C ../.. ARCH=lkl $(KOPT) install INSTALL_PATH=$(OUTPUT)

# rules to link libs
$(OUTPUT)%$(SOSUF): LDFLAGS += -shared
$(OUTPUT)%$(SOSUF): $(OUTPUT)%-in.o $(OUTPUT)liblkl.a
	$(QUIET_LINK)$(CC) $(LDFLAGS) $(LDFLAGS_$*-y) -o $@ $^ $(LDLIBS) $(LDLIBS_$*-y)

# liblkl is special
$(OUTPUT)liblkl$(SOSUF): $(OUTPUT)%-in.o $(OUTPUT)lib/lkl.o
$(OUTPUT)liblkl.a: $(OUTPUT)lib/liblkl-in.o $(OUTPUT)lib/lkl.o fat_log.o
	$(QUIET_AR)$(AR) -rc $@ $^

# Rule to explicitly build fat_log.o from fat_log.c in the current directory
fat_log.o: fat_log.c \
	include/lkl/lkl_fat_log.h
	@echo '  CC      $@'
	$(Q)$(CC) $(CFLAGS) -c -o $@ $<

# rule to link programs
$(OUTPUT)%$(EXESUF): $(OUTPUT)%-in.o $(OUTPUT)liblkl.a
	$(QUIET_LINK)$(CC) $(LDFLAGS) $(LDFLAGS_$*-y) -o $@ $^ $(LDLIBS) $(LDLIBS_$*-y)

# rule to build objects
$(OUTPUT)%-in.o: $(OUTPUT)lib/lkl.o FORCE
	$(Q)$(MAKE) -f $(srctree)/tools/build/Makefile.build dir=$(patsubst %/,%,$(dir $*)) obj=$(notdir $*)


$(OUTPUT)cpfromfs$(EXESUF): $(OUTPUT)cptofs$(EXESUF)
	$(Q)if ! [ -e $@ ]; then ln -s $< $@; fi

clean:
	$(call QUIET_CLEAN, vmlinux)$(MAKE) -C ../.. ARCH=lkl $(KOPT) clean
	$(call QUIET_CLEAN, objects)find $(OUTPUT) -name '*.o' -delete -o -name '\.*.cmd'\
	 -delete -o -name '\.*.d' -delete
	#$(call QUIET_CLEAN, headers)$(RM) -r $(OUTPUT)/include/lkl/
	$(call QUIET_CLEAN, liblkl.a)$(RM) $(OUTPUT)/liblkl.a
	$(call QUIET_CLEAN, targets)$(RM) $(TARGETS) bin/stat

clean-conf: clean
	$(call QUIET_CLEAN, Makefile.conf)$(RM) $(OUTPUT)/Makefile.conf
	$(call QUIET_CLEAN, kernel_config.h)$(RM) $(OUTPUT)/include/kernel_config.h
	$(call QUIET_CLEAN, kernel.config)$(RM) $(OUTPUT)/kernel.config

headers_install: $(TARGETS)
	$(call QUIET_INSTALL, headers) \
	    install -d $(DESTDIR)$(INCDIR) ; \
	    install -m 644 include/lkl.h include/lkl_host.h $(OUTPUT)include/lkl_autoconf.h \
	      include/lkl_config.h $(DESTDIR)$(INCDIR) ; \
	    cp -r $(OUTPUT)include/lkl $(DESTDIR)$(INCDIR)

libraries_install: $(libs-y:%=$(OUTPUT)%$(SOSUF)) $(OUTPUT)liblkl.a
	$(call QUIET_INSTALL, libraries) \
	    install -d $(DESTDIR)$(LIBDIR) ; \
	    install -m 644 $^ $(DESTDIR)$(LIBDIR)

programs_install: $(progs-y:%=$(OUTPUT)%$(EXESUF))
	$(call QUIET_INSTALL, programs) \
	    install -d $(DESTDIR)$(BINDIR) ; \
	    install -m 755 $^ $(DESTDIR)$(BINDIR)

install: headers_install libraries_install programs_install


run-tests:
	./tests/run.py $(tests)

# Enable libFuzzer fuzzing instrumentation for the LKL fuzzers
$(OUTPUT)fuzzers/%$(EXESUF): LDFLAGS += -fsanitize=fuzzer --coverage

FUZZ_TARGETS := $(fuzzers-y:%=$(OUTPUT)%$(EXESUF))
fuzzers: $(FUZZ_TARGETS)

FORCE: ;
.PHONY: all clean FORCE run-tests
.PHONY: headers_install libraries_install programs_install install
.NOTPARALLEL : lib/lkl.o
.SECONDARY:

