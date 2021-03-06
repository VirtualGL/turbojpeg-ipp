include Makerules

##########################################################################
ifeq ($(platform), windows)
##########################################################################

TARGETS = $(EDIR)/turbojpeg.dll \
          $(LDIR)/turbojpeg.lib \
          $(EDIR)/ipp/turbojpeg.dll \
          $(LDIR)/ipp/turbojpeg.lib \
          $(EDIR)/libjpeg/turbojpeg.dll \
          $(LDIR)/libjpeg/turbojpeg.lib

OBJS = $(ODIR)/ipp/turbojpeg.obj $(ODIR)/libjpeg/turbojpeg.obj

all: libjpeg $(TARGETS)

clean:
	-$(RM) $(TARGETS) $(OBJS)
	cd jpeg-6b; $(MAKE) -f makefile.vc clean; cd ..

IPPLINK = ippjemerged.lib ippiemerged.lib ippsemerged.lib \
	ippjmerged.lib ippimerged.lib ippsmerged.lib ippcorel.lib

$(ODIR)/ipp/turbojpeg.obj: turbojpegipp.c turbojpeg.h
	$(CC) $(CFLAGS) -DDLLDEFINE -c $< -Fo$@

$(EDIR)/ipp/turbojpeg.dll $(LDIR)/ipp/turbojpeg.lib: $(ODIR)/ipp/turbojpeg.obj
	$(LINK) $(LDFLAGS) -dll $< -out:$(EDIR)/ipp/turbojpeg.dll \
		-implib:$(LDIR)/ipp/turbojpeg.lib $(IPPLINK)

.PHONY: libjpeg
libjpeg:
	cd jpeg-6b; \
	diff -q jconfig.vc jconfig.h || cp jconfig.vc jconfig.h; \
	$(MAKE) -f makefile.vc; cd ..

$(ODIR)/libjpeg/turbojpeg.obj: turbojpegl.c
	$(CC) -Ijpeg-6b/ $(CFLAGS) -DDLLDEFINE -c $< -Fo$@

$(EDIR)/libjpeg/turbojpeg.dll $(LDIR)/libjpeg/turbojpeg.lib: \
	$(ODIR)/libjpeg/turbojpeg.obj $(LDIR)/libjpeg/libjpeg.lib
	$(LINK) $(LDFLAGS) -dll $< -out:$(EDIR)/libjpeg/turbojpeg.dll \
		-implib:$(LDIR)/libjpeg/turbojpeg.lib $(LDIR)/libjpeg/libjpeg.lib

$(EDIR)/turbojpeg.dll: $(EDIR)/ipp/turbojpeg.dll
	cp $< $@

$(LDIR)/turbojpeg.lib: $(LDIR)/ipp/turbojpeg.lib
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

TARGETS = $(LDIR)/libturbojpeg.dylib \
          $(LDIR)/ipp/libturbojpeg.dylib \
          $(LDIR)/libjpeg/libturbojpeg.dylib

OBJS = $(ODIR)/ipp/turbojpeg.o $(ODIR)/libjpeg/turbojpeg.o

all: libjpeg $(TARGETS)

clean:
	-$(RM) $(TARGETS) $(OBJS)
	cd jpeg-6b; \
	$(MAKE) clean || (sh configure CC=$(CC); $(MAKE) clean); cd ..

IPPDIR = /Library/Frameworks/Intel_IPP.framework/Versions/5.3.4.075/em64t
IPPLINK = -L$(IPPDIR)/lib -lippcore \
        -lippjemerged -lippiemerged -lippsemerged \
        -lippjmerged -lippimerged -lippsmerged \
        -install_name libturbojpeg.dylib -read_only_relocs warning
ifeq ($(IPPSHARED), yes)
IPPLINK = -L$(IPPDIR)/Libraries -lippj -lippi -lipps -lippcore -lguide \
          -install_name libturbojpeg.dylib
endif

$(ODIR)/ipp/turbojpeg.o: turbojpegipp.c turbojpeg.h
	$(CC) -I$(IPPDIR)/Headers $(CFLAGS) -c $< -o $@

$(LDIR)/ipp/libturbojpeg.dylib: $(ODIR)/ipp/turbojpeg.o
	$(CC) $(LDFLAGS) -dynamiclib  $< -o $@ $(IPPLINK)

.PHONY: libjpeg
libjpeg:
	cd jpeg-6b; sh configure CC=$(CC); $(MAKE); cd ..

$(ODIR)/libjpeg/turbojpeg.o: turbojpegl.c turbojpeg.h
	$(CC) -Ijpeg-6b/ $(CFLAGS) -c $< -o $@

$(LDIR)/libjpeg/libturbojpeg.dylib: $(ODIR)/libjpeg/turbojpeg.o \
	$(LDIR)/libjpeg/libjpeg.a
	$(CC) $(LDFLAGS) -dynamiclib $< -o $@ $(LDIR)/libjpeg/libjpeg.a \
		-install_name libturbojpeg.dylib

$(LDIR)/libturbojpeg.dylib: $(LDIR)/ipp/libturbojpeg.dylib
	cp $< $@

PACKAGEMAKER = /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker

dist: all
	if [ -d $(BLDDIR)/TurboJPEG-$(VERSION).pkg ]; then rm -rf $(BLDDIR)/TurboJPEG-$(VERSION).pkg; fi
	if [ -d $(BLDDIR)/pkgbuild ]; then sudo rm -rf $(BLDDIR)/pkgbuild; fi
	if [ -f $(BLDDIR)/TurboJPEG-$(VERSION).dmg ]; then rm -f $(BLDDIR)/TurboJPEG-$(VERSION).dmg; fi
	mkdir -p $(BLDDIR)/pkgbuild
	mkdir -p $(BLDDIR)/pkgbuild/Package_Root/usr/lib
	mkdir -p $(BLDDIR)/pkgbuild/Package_Root/usr/bin
	mkdir -p $(BLDDIR)/pkgbuild/Package_Root/usr/include
	mkdir -p $(BLDDIR)/pkgbuild/Resources
	cat TurboJPEG.info.tmpl | sed s/{__VERSION}/$(VERSION)/g > $(BLDDIR)/pkgbuild/TurboJPEG.info
	cat Info.plist.tmpl | sed s/{__VERSION}/$(VERSION)/g | sed s/{__BUILD}/$(BUILD)/g > $(BLDDIR)/pkgbuild/Info.plist
	cp $(LDIR)/libturbojpeg.dylib $(BLDDIR)/pkgbuild/Package_Root/usr/lib
	cp $(LDIR)/ipp/libturbojpeg.dylib $(BLDDIR)/pkgbuild/Package_Root/usr/lib/libturbojpeg-ipp.dylib
	cp $(LDIR)/libjpeg/libturbojpeg.dylib $(BLDDIR)/pkgbuild/Package_Root/usr/lib/libturbojpeg-libjpeg.dylib
	cp switchtjpeg $(BLDDIR)/pkgbuild/Package_Root/usr/bin
	cp turbojpeg.h $(BLDDIR)/pkgbuild/Package_Root/usr/include
	chmod 755 $(BLDDIR)/pkgbuild/Package_Root/usr/lib/*
	chmod 755 $(BLDDIR)/pkgbuild/Package_Root/usr/bin/*
	chmod 644 $(BLDDIR)/pkgbuild/Package_Root/usr/include/*
	sudo chown -R root:wheel $(BLDDIR)/pkgbuild/Package_Root/*
	cp License.rtf Welcome.rtf ReadMe.rtf $(BLDDIR)/pkgbuild/Resources/
	$(PACKAGEMAKER) -build -v -p $(BLDDIR)/TurboJPEG-$(VERSION).pkg \
	  -f $(BLDDIR)/pkgbuild/Package_Root -r $(BLDDIR)/pkgbuild/Resources \
	  -i $(BLDDIR)/pkgbuild/Info.plist -d $(BLDDIR)/pkgbuild/TurboJPEG.info
	sudo rm -rf $(BLDDIR)/pkgbuild
	hdiutil create -fs HFS+ -volname TurboJPEG-$(VERSION) \
	  -srcfolder $(BLDDIR)/TurboJPEG-$(VERSION).pkg \
	  $(BLDDIR)/TurboJPEG-$(VERSION).dmg
	rm -rf $(BLDDIR)/TurboJPEG-$(VERSION).pkg

##########################################################################
else
##########################################################################

TARGETS = $(LDIR)/libturbojpeg.so \
          $(LDIR)/ipp/libturbojpeg.so \
          $(LDIR)/libjpeg/libturbojpeg.so \
          $(EDIR)/jpgtest \
          $(EDIR)/jpegut

OBJS = $(ODIR)/ipp/turbojpeg.o $(ODIR)/libjpeg/turbojpeg.o

all: libjpeg $(TARGETS)

clean:
	-$(RM) $(TARGETS) $(OBJS)
	cd jpeg-6b; \
	$(MAKE) clean || (sh configure CC='$(CC)'; $(MAKE) clean); cd ..

ifeq ($(IPPDIR),)
IPPDIR = /opt/intel/ipp/5.3.4.080/ia32
ifeq ($(subplatform), 64)
IPPDIR = /opt/intel/ipp/5.3.4.080/em64t
endif
ifeq ($(subplatform), ia64)
IPPDIR = /opt/intel/ipp/5.3.4.080/itanium
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

$(ODIR)/ipp/turbojpeg.o: turbojpegipp.c turbojpeg.h
	$(CC) -I$(IPPDIR)/include $(CFLAGS) -c $< -o $@

$(LDIR)/ipp/libturbojpeg.so: $(ODIR)/ipp/turbojpeg.o turbojpeg-mapfile
	$(CC) $(LDFLAGS) -shared $< -o $@ $(IPPLINK) \
		-Wl,--version-script,turbojpeg-mapfile

.PHONY: libjpeg
libjpeg:
	cd jpeg-6b; sh configure CC='$(CC)'; $(MAKE); cd ..

$(ODIR)/libjpeg/turbojpeg.o: turbojpegl.c turbojpeg.h
	$(CC) -Ijpeg-6b/ $(CFLAGS) -c $< -o $@

$(LDIR)/libjpeg/libturbojpeg.so: $(ODIR)/libjpeg/turbojpeg.o \
	turbojpeg-mapfile $(LDIR)/libjpeg/libjpeg.a
	$(CC) $(LDFLAGS) -shared $< -o $@ $(LDIR)/libjpeg/libjpeg.a \
		-Wl,--version-script,turbojpeg-mapfile

$(LDIR)/libturbojpeg.so: $(LDIR)/ipp/libturbojpeg.so
	cp $< $@

$(ODIR)/jpegut.o: jpegut.c turbojpeg.h
	$(CC) -I$(IPPDIR)/include $(CFLAGS) -c $< -o $@

$(EDIR)/jpegut: $(ODIR)/jpegut.o $(LDIR)/libturbojpeg.so
	$(CC) $(LDFLAGS) -o $@ $(ODIR)/jpegut.o -L$(LDIR) -lturbojpeg

$(ODIR)/bmp.o: bmp.c bmp.h
	$(CC) -I$(IPPDIR)/include $(CFLAGS) -c $< -o $@

$(ODIR)/jpgtest.o: jpgtest.c turbojpeg.h
	$(CC) -I$(IPPDIR)/include $(CFLAGS) -c $< -o $@

$(EDIR)/jpgtest: $(ODIR)/jpgtest.o $(ODIR)/bmp.o $(LDIR)/libturbojpeg.so
	$(CC) $(LDFLAGS) -o $@ $(ODIR)/jpgtest.o $(ODIR)/bmp.o -lm -L$(LDIR) -lturbojpeg

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
	rm -f $(BLDDIR)/turbojpeg-$(VERSION).$(RPMARCH).rpm; \
	rpmbuild -bb --define "_blddir `pwd`/$(BLDDIR)" --define "_topdir $(BLDDIR)/rpms" \
		--define "_bindir $(EDIR)" --define "_bindir32 $(EDIR32)" --define "_build $(BUILD)" \
		--define "_libdir $(LDIR)" --define "_libdir32 $(LDIR32)" --target $(RPMARCH) \
		--define "_version $(VERSION)" turbojpeg.spec; \
	mv $(BLDDIR)/rpms/RPMS/$(RPMARCH)/turbojpeg-$(VERSION)-$(BUILD).$(RPMARCH).rpm $(BLDDIR)/turbojpeg-$(VERSION).$(RPMARCH).rpm
	rm -rf $(BLDDIR)/rpms

deb: all all32
	rm -f $(BLDDIR)/turbojpeg_$(VERSION)_$(DEBARCH).deb
	umask 022; TMPDIR=`mktemp -d /tmp/vglbuild.XXXXXX`; \
	mkdir $$TMPDIR/DEBIAN; \
	cat deb-control.tmpl | sed s/{__VERSION}/$(VERSION)/g | sed s/{__BUILD}/$(BUILD)/g | sed s/{__ARCH}/$(DEBARCH)/g > $$TMPDIR/DEBIAN/control; \
	mkdir -p $$TMPDIR/usr/lib; \
	install -m 755 $(LDIR)/libturbojpeg.so $$TMPDIR/usr/lib/libturbojpeg.so; \
	install -m 755 $(LDIR)/ipp/libturbojpeg.so $$TMPDIR/usr/lib/libturbojpeg-ipp.so; \
	install -m 755 $(LDIR)/libjpeg/libturbojpeg.so $$TMPDIR/usr/lib/libturbojpeg-libjpeg.so; \
	if [ "$(subplatform)" = "64" ]; then \
	mkdir -p $$TMPDIR/usr/lib32; \
	install -m 755 $(LDIR32)/libturbojpeg.so $$TMPDIR/usr/lib32/libturbojpeg.so; \
	install -m 755 $(LDIR32)/ipp/libturbojpeg.so $$TMPDIR/usr/lib32/libturbojpeg-ipp.so; \
	install -m 755 $(LDIR32)/libjpeg/libturbojpeg.so $$TMPDIR/usr/lib32/libturbojpeg-libjpeg.so; \
	fi; \
	mkdir -p $$TMPDIR/usr/bin; \
	install -m 755 switchtjpeg $$TMPDIR/usr/bin; \
	mkdir -p $$TMPDIR/usr/include; \
	install -m 644 turbojpeg.h $$TMPDIR/usr/include; \
	mkdir -p $$TMPDIR/usr/share/doc/turbojpeg-$(VERSION)-$(BUILD); \
	install -m 644 LGPL.txt $$TMPDIR/usr/share/doc/turbojpeg-$(VERSION)-$(BUILD); \
	install -m 644 LICENSE.txt $$TMPDIR/usr/share/doc/turbojpeg-$(VERSION)-$(BUILD); \
	install -m 644 README.txt $$TMPDIR/usr/share/doc/turbojpeg-$(VERSION)-$(BUILD); \
	sudo chown -R root:root $$TMPDIR/*; \
	dpkg -b $$TMPDIR $(BLDDIR)/turbojpeg_$(VERSION)_$(DEBARCH).deb; \
	sudo rm -rf $$TMPDIR

endif

##########################################################################
endif
endif
##########################################################################
