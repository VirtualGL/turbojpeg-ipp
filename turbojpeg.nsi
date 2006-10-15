Name "TurboJPEG SDK"
OutFile ${BLDDIR}\TurboJPEG.exe
InstallDir c:\turbojpeg

SetCompressor bzip2

Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

Section "TurboJPEG SDK (required)"
	SectionIn RO
	SetOutPath $SYSDIR
	File "${BLDDIR}\bin\turbojpeg.dll"
	SetOutPath $INSTDIR\lib
	File "${BLDDIR}\lib\turbojpeg.lib"
	SetOutPath $INSTDIR\include
	File "${BLDDIR}\..\turbojpeg.h"
	SetOutPath $INSTDIR
	File "LGPL.txt"
	File "LICENSE.txt"
	File "README.txt"

	WriteRegStr HKLM "SOFTWARE\TurboJPEG ${VERSION}" "Install_Dir" "$INSTDIR"

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TurboJPEG ${VERSION}" "DisplayName" "TurboJPEG SDK ${VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TurboJPEG ${VERSION}" "UninstallString" '"$INSTDIR\uninstall_${VERSION}.exe"'
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TurboJPEG ${VERSION}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TurboJPEG ${VERSION}" "NoRepair" 1
	WriteUninstaller "uninstall_${VERSION}.exe"
SectionEnd

Section "Uninstall"

	SetShellVarContext all

	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TurboJPEG ${VERSION}"
	DeleteRegKey HKLM "SOFTWARE\TurboJPEG ${VERSION}"

	Delete $SYSDIR\turbojpeg.dll
	Delete $INSTDIR\lib\turbojpeg.lib
	Delete $INSTDIR\include\turbojpeg.h
	Delete $INSTDIR\uninstall_${VERSION}.exe
	Delete $INSTDIR\LGPL.txt
	Delete $INSTDIR\LICENSE.txt
	Delete $INSTDIR\README.txt

	RMDir "$INSTDIR\include"
	RMDir "$INSTDIR\lib"
	RMDir "$INSTDIR"

SectionEnd