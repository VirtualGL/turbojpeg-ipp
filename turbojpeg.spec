Summary: A fast JPEG codec used by VirtualGL and TurboVNC
Name: turbojpeg
Version: %{_version}
Vendor: The VirtualGL Project
URL: http://www.virtualgl.org
Group: System Environment/Libraries
Release: %{_build}
License: wxWindows Library License, v3
BuildRoot: %{_blddir}/%{name}-buildroot
Prereq: /sbin/ldconfig
Provides: %{name} = %{version}-%{release}

%description
TurboJPEG provides a minimalistic interface for compressing true color
bitmaps into JPEG images in memory.  It abstracts a variety of vendor-specific
JPEG codecs into a common API that is used by VirtualGL and TurboVNC as the
default method of image compression.

The Linux version of TurboJPEG is built using the Intel(R) Integrated
Performance Primitives, a set of highly-optimized multimedia libraries for
x86 processors.  The use of Intel(R) IPP allows TurboJPEG to compress
1-megapixel images at 20-30 frames/sec or greater.  Unfortunately, this
performance comes at the expense of introducing a closed source dependency.
For those who may be concerned about this, a fully open source (but slower)
version of the library is also included in this package.

See the README.txt file included in this package for more information.

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/usr/lib
%ifarch x86_64
mkdir -p $RPM_BUILD_ROOT/usr/lib64
%endif
mkdir -p $RPM_BUILD_ROOT/usr/include

%ifarch x86_64
install -m 755 %{_libdir}/libturbojpeg.so $RPM_BUILD_ROOT/usr/lib64/libturbojpeg.so
install -m 755 %{_libdir}/libturbojpeg-ipp.so $RPM_BUILD_ROOT/usr/lib64/libturbojpeg-ipp.so
install -m 755 %{_libdir}/libturbojpeg-libjpeg.so $RPM_BUILD_ROOT/usr/lib64/libturbojpeg-libjpeg.so
install -m 755 %{_libdir32}/libturbojpeg.so $RPM_BUILD_ROOT/usr/lib/libturbojpeg.so
install -m 755 %{_libdir32}/libturbojpeg-ipp.so $RPM_BUILD_ROOT/usr/lib/libturbojpeg-ipp.so
install -m 755 %{_libdir32}/libturbojpeg-libjpeg.so $RPM_BUILD_ROOT/usr/lib/libturbojpeg-libjpeg.so
%else
install -m 755 %{_libdir}/libturbojpeg.so $RPM_BUILD_ROOT/usr/lib/libturbojpeg.so
install -m 755 %{_libdir}/libturbojpeg-ipp.so $RPM_BUILD_ROOT/usr/lib/libturbojpeg-ipp.so
install -m 755 %{_libdir}/libturbojpeg-libjpeg.so $RPM_BUILD_ROOT/usr/lib/libturbojpeg-libjpeg.so
%endif
install -m 644 turbojpeg.h $RPM_BUILD_ROOT/usr/include/turbojpeg.h
install -m 755 switchtjpeg $RPM_BUILD_ROOT/usr/bin/switchtjpeg

%clean
rm -rf $RPM_BUILD_ROOT

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%files -n turbojpeg

%defattr(-,root,root)
%doc LGPL.txt LICENSE.txt README.txt

/usr/lib/libturbojpeg.so
/usr/lib/libturbojpeg-ipp.so
/usr/lib/libturbojpeg-libjpeg.so
%ifarch x86_64
/usr/lib64/libturbojpeg.so
/usr/lib64/libturbojpeg-ipp.so
/usr/lib64/libturbojpeg-libjpeg.so
%endif
/usr/include/turbojpeg.h
/usr/bin/switchtjpeg

%changelog
