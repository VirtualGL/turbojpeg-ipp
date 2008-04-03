include Makerules

##########################################################################
ifeq ($(platform), windows)
##########################################################################

TARGETS = $(EDIR)/turbojpeg.dll \
          $(LDIR)/turbojpeg.lib \
          $(EDIR)/turbojpeg-ipp.dll \
          $(LDIR)/turbojpeg-ipp.lib \
          $(EDIR)/turbojpeg-libjpeg.dll \
          $(LDIR)/turbojpeg-libjpeg.lib

OBJS = $(ODIR)/turbojpeg-ipp.obj $(ODIR)/turbojpeg-libjpeg.obj

all: libjpeg $(TARGETS)

clean:
	-$(RM) $(TARGETS) $(OBJS)
	cd jpeg-6b; $(MAKE) -f makefile.vc clean; cd ..

IPPLINK = ippjemerged.lib ippiemerged.lib ippsemerged.lib \
	ippjmerged.lib ippimerged.lib ippsmerged.lib ippcorel.lib

$(ODIR)/turbojpeg-ipp.obj: turbojpegipp.c turbojpeg.h
	$(CC) $(CFLAGS) -DDLLDEFINE -c $< -Fo$@

$(EDIR)/turbojpeg-ipp.dll $(LDIR)/turbojpeg-ipp.lib: $(ODIR)/turbojpeg-ipp.obj
	$(LINK) $(LDFLAGS) -dll $< -out:$(EDIR)/turbojpeg-ipp.dll \
		-implib:$(LDIR)/turbojpeg-ipp.lib $(IPPLINK)

.PHONY: libjpeg
libjpeg:
	cd jpeg-6b; \
	diff -q jconfig.vc jconfig.h || cp jconfig.vc jconfig.h; \
	$(MAKE) -f makefile.vc; cd ..

$(ODIR)/turbojpeg-libjpeg.obj: turbojpegl.c
	$(CC) -Ijpeg-6b/ $(CFLAGS) -DDLLDEFINE -c $< -Fo$@

$(EDIR)/turbojpeg-libjpeg.dll $(LDIR)/turbojpeg-libjpeg.lib: \
	$(ODIR)/turbojpeg-libjpeg.obj $(LDIR)/libjpeg.lib
	$(LINK) $(LDFLAGS) -dll $< -out:$(EDIR)/turbojpeg-libjpeg.dll \
		-implib:$(LDIR)/turbojpeg-libjpeg.lib $(LDIR)/libjpeg.lib

$(EDIR)/turbojpeg.dll: $(EDIR)/turbojpeg-ipp.dll
	cp $< $@

$(LDIR)/turbojpeg.lib: $(LDIR)/turbojpeg-ipp.lib
	cp $< $@

WBLDDIR = $(platform)$(subplatform)

ifeq ($(DEBUG), yes)
WBLDDIR := $(WBLDDIR)\\dbg
endif

dist: all
	$(RM) $(WBLDDIR)\TurboJPEG.exe
	makensis //DVERSION=$(VERSION) //DBLDDIR=$(WBLDDIR) turbojpeg.nsi || \
	makensis /DVERSION=$(VERSION) /DBLDDIR=$(WBLDDIR) turbojpeg.nsi  # Cygwin doesn't like the //

##########################################################################
else
ifeq ($(platform), osxx86)
##########################################################################

TARGETS = $(LDIR)/libturbojpeg.dylib

OBJS = $(ODIR)/turbojpeg.o

all: $(TARGETS)

clean:
	-$(RM) $(TARGETS) $(OBJS)

IPPDIR = /Library/Frameworks/Intel_IPP.framework
IPPLINK = -L$(IPPDIR)/Libraries $(IPPDIR)/Libraries/libippcore.a \
        -lippjemerged -lippiemerged -lippsemerged \
        -lippjmerged -lippimerged -lippsmerged \
        -install_name libturbojpeg.dylib -read_only_relocs warning
ifeq ($(IPPSHARED), yes)
IPPLINK = -L$(IPPDIR)/Libraries -lippj -lippi -lipps -lippcore -lguide \
          -install_name libturbojpeg.dylib
endif

$(ODIR)/turbojpeg.o: turbojpegipp.c turbojpeg.h
	$(CC) -I$(IPPDIR)/Headers $(CFLAGS) -c $< -o $@

$(LDIR)/libturbojpeg.dylib: $(ODIR)/turbojpeg.o
	$(CC) $(LDFLAGS) -dynamiclib  $< -o $@ $(IPPLINK)

PACKAGEMAKER = /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker

dist: all
	if [ -d $(BLDDIR)/TurboJPEG-$(VERSION).pkg ]; then rm -rf $(BLDDIR)/TurboJPEG-$(VERSION).pkg; fi
	if [ -d $(BLDDIR)/pkgbuild ]; then sudo rm -rf $(BLDDIR)/pkgbuild; fi
	if [ -f $(BLDDIR)/TurboJPEG-$(VERSION).dmg ]; then rm -f $(BLDDIR)/TurboJPEG-$(VERSION).dmg; fi
	mkdir -p $(BLDDIR)/pkgbuild
	mkdir -p $(BLDDIR)/pkgbuild/Package_Root/usr/lib
	mkdir -p $(BLDDIR)/pkgbuild/Package_Root/usr/include
	mkdir -p $(BLDDIR)/pkgbuild/Resources
	cp $(LDIR)/libturbojpeg.dylib $(BLDDIR)/pkgbuild/Package_Root/usr/lib
	cp turbojpeg.h $(BLDDIR)/pkgbuild/Package_Root/usr/include
	chmod 755 $(BLDDIR)/pkgbuild/Package_Root/usr/lib/*
	chmod 644 $(BLDDIR)/pkgbuild/Package_Root/usr/include/*
	sudo chown -R root:wheel $(BLDDIR)/pkgbuild/Package_Root/*
	cp License.rtf Welcome.rtf ReadMe.rtf $(BLDDIR)/pkgbuild/Resources/
	$(PACKAGEMAKER) -build -v -p $(BLDDIR)/TurboJPEG-$(VERSION).pkg \
	  -f $(BLDDIR)/pkgbuild/Package_Root -r $(BLDDIR)/pkgbuild/Resources \
	  -i Info.plist -d TurboJPEG.info
	sudo rm -rf $(BLDDIR)/pkgbuild
	hdiutil create -fs HFS+ -volname TurboJPEG-$(VERSION) \
	  -srcfolder $(BLDDIR)/TurboJPEG-$(VERSION).pkg \
	  $(BLDDIR)/TurboJPEG-$(VERSION).dmg
	rm -rf $(BLDDIR)/TurboJPEG-$(VERSION).pkg

##########################################################################
else
##########################################################################

TARGETS = $(LDIR)/libturbojpeg.so \
          $(LDIR)/libturbojpeg-libjpeg.so

OBJS = $(ODIR)/turbojpeg.o $(ODIR)/turbojpeg-libjpeg.o

all: libjpeg $(TARGETS)

clean:
	-$(RM) $(TARGETS) $(OBJS)
	cd jpeg-6b; \
	$(MAKE) clean || (sh configure CC=$(CC); $(MAKE) clean); cd ..

ifeq ($(IPPDIR),)
IPPDIR = /opt/intel/ipp/5.1/ia32
ifeq ($(subplatform), 64)
IPPDIR = /opt/intel/ipp/5.1/em64t
endif
ifeq ($(subplatform), ia64)
IPPDIR = /opt/intel/ipp/5.1/itanium
endif
endif

IPPLINK = -L$(IPPDIR)/lib -lippcore \
        -lippjemerged -lippiemerged -lippsemerged \
        -lippjmerged -lippimerged -lippsmerged
ifeq ($(IPPSHARED), yes)
IPPLINK = -L$(IPPDIR)/sharedlib \
        -lippj -lippi -lipps -lippcore
endif

ifeq ($(subplatform), 64)
IPPLINK = -L$(IPPDIR)/lib \
        -lippjemergedem64t -lippjmergedem64t -lippiemergedem64t \
        -lippimergedem64t -lippsemergedem64t -lippsmergedem64t \
        -lippcoreem64t
ifeq ($(IPPSHARED), yes)
IPPLINK = -L$(IPPDIR)/sharedlib \
        -lippjem64t -lippiem64t -lippsem64t -lippcoreem64t
endif
endif

ifeq ($(subplatform), ia64)
IPPLINK = -L$(IPPDIR)/lib \
        -lippji7 -lippii7 -lippsi7 -lippcore64
endif

$(ODIR)/turbojpeg.o: turbojpegipp.c turbojpeg.h
	$(CC) -I$(IPPDIR)/include $(CFLAGS) -c $< -o $@

$(LDIR)/libturbojpeg.so: $(ODIR)/turbojpeg.o turbojpeg-mapfile
	$(CC) $(LDFLAGS) -shared $< -o $@ $(IPPLINK) -Wl,--version-script,turbojpeg-mapfile

.PHONY: libjpeg
libjpeg:
	cd jpeg-6b; sh configure CC=$(CC); $(MAKE); cd ..

$(ODIR)/turbojpeg-libjpeg.o: turbojpegl.c turbojpeg.h
	$(CC) -Ijpeg-6b/ $(CFLAGS) -c $< -o $@

$(LDIR)/libturbojpeg-libjpeg.so: $(ODIR)/turbojpeg-libjpeg.o \
	turbojpeg-mapfile $(LDIR)/libjpeg.a
	$(CC) $(LDFLAGS) -shared $< -o $@ $(LDIR)/libjpeg.a -Wl,--version-script,turbojpeg-mapfile

ifeq ($(platform), linux)

ifeq ($(subplatform), 64)
all32:
	$(MAKE) M32=yes
else
all32:
endif

dist: all all32
	if [ -d $(BLDDIR)/rpms ]; then rm -rf $(BLDDIR)/rpms; fi
	mkdir -p $(BLDDIR)/rpms/RPMS
	ln -fs `pwd` $(BLDDIR)/rpms/BUILD
	rm -f $(BLDDIR)/$(PACKAGENAME).$(RPMARCH).rpm; \
	rpmbuild -bb --define "_blddir `pwd`/$(BLDDIR)" --define "_topdir $(BLDDIR)/rpms" \
		--define "_bindir $(EDIR)" --define "_bindir32 $(EDIR32)" --define "_build $(BUILD)" \
		--define "_libdir $(LDIR)" --define "_libdir32 $(LDIR32)" --target $(RPMARCH) \
		--define "_version $(VERSION)" turbojpeg.spec; \
	mv $(BLDDIR)/rpms/RPMS/$(RPMARCH)/turbojpeg-$(VERSION)-$(BUILD).$(RPMARCH).rpm $(BLDDIR)/turbojpeg-$(VERSION).$(RPMARCH).rpm
	rm -rf $(BLDDIR)/rpms

endif

##########################################################################
endif
endif
##########################################################################
