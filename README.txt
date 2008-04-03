This version of TurboJPEG is built using the Intel(R) Integrated Performance
Primitives, a set of libraries which contain highly-optimized multimedia
functions for x86 processors.  The use of the Intel(R) IPP libraries allows
TurboJPEG to achieve levels of performance 3-4x faster than if the standard
libjpeg interface was used.

While the Intel(R) IPP libraries are proprietary, TurboJPEG is released under
the wxWindows Library License, a copy of which can be found in the same
directory as this README file.  The license for Intel(R) IPP is such that it
does not restrict the redistribution of the TurboJPEG binaries, even though
those binaries contain embedded components from the Intel(R) IPP.

As such, you are free to distribute this binary package of TurboJPEG as you
see fit or use it to build your own applications (even commercial ones),
provided that you adhere to the terms of the wxWindows Library License.

If you need to rebuild TurboJPEG/IPP from source, it will be necessary to
obtain a license for the Intel(R) IPP libraries.  Such licenses are free for
non-commercial use and inexpensive for commercial use.  IPP licensees may
redistribute binaries built with the IPP freely and without royalty.

See http://www.intel.com/software/products/ipp/index.htm for more information
about the Intel(R) Integrated Performance Primitives.

A fully open source version of TurboJPEG, based on libjpeg, is also included
with this distribution.  You can switch between the two using the "switchtjpeg"
script (also included.)  Running "switchtjpeg libjpeg" will switch out the
accelerated version of the TurboJPEG dynamic library with an unaccelerated
version that is much slower but GPL-compatible.
