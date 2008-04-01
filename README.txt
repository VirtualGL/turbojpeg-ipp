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
with this distribution.  This library can be pre-loaded in place of the IPP
version of the library at run time, for those who are concerned about loading
proprietary code into GPL-licensed applications.  Note, however, that the GPL
does not govern what you can load into an application at run time.  It only
governs copying, distribution, and modification of an application.  Thus, it
is our opinion that this is a non issue and that TurboJPEG can be considered an
"independent and separate work" under the terms of the GPL.  The libjpeg
version was included as a compromise to ease the minds of others in the
open source community.
