include ../Makerules

##########################################################################
ifeq ($(platform), windows)
##########################################################################

TARGETS = $(EDIR)/hpjpeg.dll \
          $(LDIR)/hpjpeg.lib \
          $(EDIR)/jpgtest.exe \
          $(EDIR)/jpegut.exe

OBJS = $(ODIR)/hpjpeg.obj \
       $(ODIR)/jpgtest.obj \
       $(ODIR)/jpegut.obj

ifeq ($(JPEGLIB),)
JPEGLIB = $(DEFAULTJPEGLIB)
endif

ifeq ($(JPEGLIB), libjpeg)
TARGETS := libjpeg $(TARGETS)
endif


all: $(TARGETS)

.PHONY: libjpeg
libjpeg:
	cd jpeg-6b; \
	diff -q jconfig.vc jconfig.h || cp jconfig.vc jconfig.h; \
	$(MAKE) -f makefile.vc; cd ..

clean:
	-$(RM) $(TARGETS) $(OBJS)
	cd jpeg-6b; $(MAKE) -f makefile.vc clean; cd ..

HDRS := $(wildcard ../include/*.h)
$(OBJS): $(HDRS)


ifeq ($(JPEGLIB), pegasus)

PEGDIR = ../../pictools

$(ODIR)/hpjpeg.obj: hpjpegp.c
	$(CC) $(CFLAGS) -DDLLDEFINE -I$(PEGDIR)/include -DWINDOWS -D__FLAT__ -c $< -Fo$@

JPEGLINK = -libpath:$(PEGDIR)/lib picnm.lib

endif

ifeq ($(JPEGLIB), libjpeg)

$(ODIR)/hpjpeg.obj: hpjpegl.c
	$(CC) -Ijpeg-6b/ $(CFLAGS) -DDLLDEFINE -c $< -Fo$@

JPEGLINK = $(LDIR)/libjpeg.lib
JPEGDEP = $(LDIR)/libjpeg.lib

endif

ifeq ($(JPEGLIB), ipp)

IPPLINK = ippjmerged.lib ippimerged.lib ippsmerged.lib ippjemerged.lib \
	ippiemerged.lib ippsemerged.lib ippcorel.lib

$(ODIR)/hpjpeg.obj: hpjpegipp.c
	$(CC) $(CFLAGS) -DDLLDEFINE -c $< -Fo$@

JPEGLINK = $(IPPLINK)

endif

ifeq ($(JPEGLIB), quicktime)

$(ODIR)/hpjpeg.obj: hpjpegqt.c
	$(CC) $(CFLAGS) -DDLLDEFINE -c $< -Fo$@

JPEGLINK = qtmlClient.lib user32.lib advapi32.lib

endif

$(EDIR)/hpjpeg.dll $(LDIR)/hpjpeg.lib: $(ODIR)/hpjpeg.obj $(JPEGDEP)
	$(LINK) -dll -out:$(EDIR)/hpjpeg.dll -implib:$(LDIR)/hpjpeg.lib $< $(JPEGLINK)

$(EDIR)/jpgtest.exe: $(ODIR)/jpgtest.obj $(LDIR)/hpjpeg.lib
	$(LINK) $< -OUT:$@ hpjpeg.lib

$(EDIR)/jpegut.exe: $(ODIR)/jpegut.obj $(LDIR)/hpjpeg.lib
	$(LINK) $< -OUT:$@ hpjpeg.lib

##########################################################################
else
##########################################################################

TARGETS = $(LDIR)/libhpjpeg.$(SHEXT) \
          $(EDIR)/jpgtest \
          $(EDIR)/jpegut

OBJS = $(ODIR)/hpjpeg.o \
       $(ODIR)/jpgtest.o \
       $(ODIR)/jpegut.o

ifeq ($(JPEGLIB),)
JPEGLIB = $(DEFAULTJPEGLIB)
endif

ifeq ($(JPEGLIB), libjpeg)
TARGETS := libjpeg $(TARGETS)
endif


all: $(TARGETS)

.PHONY: libjpeg
libjpeg:
	cd jpeg-6b; sh configure CC=$(CC); $(MAKE); cd ..

clean:
	-$(RM) $(TARGETS) $(OBJS) $(OBJS:.o=.d)
	cd jpeg-6b; \
	$(MAKE) clean || (sh configure CC=$(CC); $(MAKE) clean); cd ..

-include $(OBJS:.o=.d)


ifeq ($(JPEGLIB), pegasus)

PEGDIR = ../../pictools

$(ODIR)/hpjpeg.o: hpjpegp.c ../include/hpjpeg.h
	$(CC) $(CFLAGS) -I$(PEGDIR)/include -c $< -o $@

JPEGLINK = -L$(PEGDIR)/lib -lpicl20

endif

ifeq ($(JPEGLIB), libjpeg)

$(ODIR)/hpjpeg.o: hpjpegl.c ../include/hpjpeg.h
	$(CC) -Ijpeg-6b/ $(CFLAGS) -c $< -o $@

JPEGLINK = $(LDIR)/libjpeg.a
JPEGDEP = $(LDIR)/libjpeg.a

endif

ifeq ($(JPEGLIB), ipp)

ifeq ($(IPPDIR),)
IPPDIR = /opt/intel/ipp41/ia32_itanium
ifeq ($(subplatform), 64)
IPPDIR = /opt/intel/ipp41/em64t
endif
endif
IPPLINK = -L$(IPPDIR)/lib -lippcore \
        -lippjemerged -lippiemerged -lippsemerged \
        -lippjmerged -lippimerged -lippsmerged
ifeq ($(subplatform), 64)
IPPLINK = -L$(IPPDIR)/lib \
        -lippjemergedem64t -lippjmergedem64t -lippiemergedem64t \
        -lippimergedem64t -lippsemergedem64t -lippsmergedem64t \
        -lippcoreem64t
endif
ifeq ($(subplatform), ia64)
IPPLINK = -L$(IPPDIR)/lib \
        -lippji7 -lippii7 -lippsi7 -lippcore64
endif

$(ODIR)/hpjpeg.o: hpjpegipp.c ../include/hpjpeg.h
	$(CC) -I$(IPPDIR)/include $(CFLAGS) -c $< -o $@

JPEGLINK = $(IPPLINK)

endif

ifeq ($(JPEGLIB), quicktime)

$(ODIR)/hpjpeg.o: hpjpegqt.c
	$(CC)  $(CFLAGS) -c $< -o $@

JPEGLINK = -framework ApplicationServices -framework CoreFoundation -framework CoreServices -framework QuickTime

endif

ifeq ($(JPEGLIB), medialib)

$(ODIR)/hpjpeg.o: hpjpeg-mlib.c hpjpeg-mlibhuff.c
	$(CC) $(CFLAGS) -c $< -o $@

JPEGLINK = -lmlib

endif

$(LDIR)/libhpjpeg.$(SHEXT): $(ODIR)/hpjpeg.o $(JPEGDEP)
	$(CC) $(LDFLAGS) $(SHFLAG) $< -o $@ $(JPEGLINK)

$(EDIR)/jpgtest: $(ODIR)/jpgtest.o $(LDIR)/libhpjpeg.$(SHEXT)
	$(CXX) $(LDFLAGS) $< -o $@ -lhpjpeg

$(EDIR)/jpegut: $(ODIR)/jpegut.o $(LDIR)/libhpjpeg.$(SHEXT)
	$(CC) $(LDFLAGS) $< -o $@ -lhpjpeg

##########################################################################
endif
##########################################################################
