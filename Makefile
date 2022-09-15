TARGET = paq8sk
CC ?= gcc
CFLAGS ?= -Wall
CXX ?= g++
CXXFLAGS ?= -Wall -msse2 -O3
LDFLAGS ?= -s
AR = ar
RM ?= rm -f
SRCS = src/$(TARGET).cpp
OBJS = $(SRCS:%.cpp=%.o)
BZIP2SRCS = src/bzip2/blocksort.c \
            src/bzip2/bz2compress.c \
            src/bzip2/bz2decompress.c \
            src/bzip2/bzip2.c \
            src/bzip2/bzip2recover.c \
            src/bzip2/bzlib.c \
            src/bzip2/crctable.c \
            src/bzip2/dlltest.c \
            src/bzip2/huffman.c \
            src/bzip2/randtable.c \
            src/bzip2/spewG.c \
            src/bzip2/unzcrash.c
BZIP2OBJS = $(BZIP2SRCS:%.c=%.o)
ZLIBSRCS = src/zlib/adler32.c \
           src/zlib/crc32.c \
           src/zlib/deflate.c \
           src/zlib/inffast.c \
           src/zlib/inflate.c \
           src/zlib/inftrees.c \
           src/zlib/trees.c \
           src/zlib/zutil.c
ZLIBOBJS = $(ZLIBSRCS:%.c=%.o)

ifeq ($(OS),Windows_NT)
	CXXFLAGS += -DWINDOWS
else
	CXXFLAGS += -DUNIX
endif

ifeq ($(STATIC), Y)
	CXXFLAGS += -Isrc/bzip2 -Isrc/zlib
	LDFLAGS += -static
	OBJS += libz.a libbz2.a
else
	CXXFLAGS += -DMT
	LDLIBS = -lpthread -lz -lbz2
endif

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ $(LDFLAGS) $(LDLIBS) -o $@

libbz2.a: $(BZIP2OBJS)
	$(AR) rcs $@ $^

libz.a: $(ZLIBOBJS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	$(RM) $(TARGET) $(OBJS) $(BZIP2OBJS) $(ZLIBOBJS)
