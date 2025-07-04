CC = gcc
AR = ar
STD = -std=c99 -pedantic -DHASH_FUNCTION=HASH_FNV
DISWARN = -Wno-stringop-overflow -Wno-cpp -Wno-format-truncation -Wno-unused-but-set-variable -Wno-stringop-truncation -Wno-unused-variable
STD = -std=c99 -DHASH_FUNCTION=HASH_FNV 
OPTIMIZATION ?= -O3 -fomit-frame-pointer -funroll-loops
OPT = $(OPTIMIZATION)
DEBUG = -g -ggdb
WARN = -Wall

FINAL_CFLAGS = $(STD) $(WARN) $(OPT) $(DEBUG) $(CFLAGS) $(DISWARN) -pthread
FINAL_LDFLAGS = $(LDFLAGS) $(DEBUG)
FINAL_LIBS = -lpthread -lsnappy -L/usr/local/lib

FINAL_CC = $(QUIET_CC)$(CC) $(FINAL_CFLAGS)
FINAL_LD = $(QUIET_LINK)$(CC) $(FINAL_LDFLAGS)
FINAL_AR = $(QUIET_AR)$(AR)

CCCOLOR="\033[34m"
LINKCOLOR="\033[34;1m"
SRCCOLOR="\033[33m"
BINCOLOR="\033[37;1m"
MAKECOLOR="\033[32;1m"
ENDCOLOR="\033[0m"

ifndef V
QUIET_CC = @printf '    %b %b\n' $(CCCOLOR)CC$(ENDCOLOR) $(SRCCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_AR = @printf '    %b %b\n' $(LINKCOLOR)AR$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_LINK = @printf '    %b %b\n' $(LINKCOLOR)LINK$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_INSTALL = @printf '    %b %b\n' $(LINKCOLOR)INSTALL$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
endif
