@echo off

set TJIPP="%~d0%~p0turbojpeg-ipp.dll"
set TJLIBJPEG="%~d0%~p0turbojpeg-libjpeg.dll"
set TJDEST="%~d0%~p0turbojpeg.dll"

if /i "%1"=="ipp" goto ipp
if /i "%1"=="libjpeg" goto libjpeg
echo.
echo USAGE: %0 {ipp / libjpeg}
echo.
echo ipp = Use the accelerated version of TurboJPEG which embeds functions from
echo       the Intel(R) Integrated Performance Primitives
echo libjpeg = Use the unaccelerated version of TurboJPEG, which is
echo           GPL-compatible
goto done

:ipp
if not exist %TJIPP% echo %TJIPP% does not exist & goto done
copy /y %TJIPP% %TJDEST%
goto done

:libjpeg
if not exist %TJLIBJPEG% echo %TJLIBJPEG% does not exist & goto done
copy /y %TJLIBJPEG% %TJDEST%
goto done

:done
