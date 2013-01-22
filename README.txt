This implementation of TurboJPEG is built using the Intel(R) Integrated
Performance Primitives, a set of libraries that contain highly-optimized
multimedia functions for x86 processors.  The use of the Intel(R) IPP libraries
allows TurboJPEG/IPP to achieve levels of performance 3-4x faster than if the
standard libjpeg interface was used.

While the Intel(R) IPP libraries are proprietary, TurboJPEG/IPP is released
under the wxWindows Library License, a copy of which can be found in the same
directory as this README file.  As of version 5.3.4, the license for Intel(R)
IPP was such that it did not restrict the redistribution of the TurboJPEG/IPP
binaries, even though those binaries contain embedded components from the
Intel(R) IPP.  Newer versions of the Intel® IPP license may have different
terms.  Consult the license for the version of Intel® IPP that was used to
build TurboJPEG before redistributing this package.

If you need to rebuild TurboJPEG/IPP from source, it will be necessary to
obtain a license for the Intel(R) IPP libraries.

See http://www.intel.com/software/products/ipp/index.htm for more information
about the Intel(R) Integrated Performance Primitives.

A fully open source implementation of TurboJPEG, based on libjpeg, is also
included with this distribution.  You can switch between the two using the
"switchtjpeg" script (also included.)  Running "switchtjpeg libjpeg" will
switch out the accelerated version of the TurboJPEG dynamic library with an
unaccelerated version that is much slower but GPL-compatible.
