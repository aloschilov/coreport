;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

 ;Name and file
 Name "coreport"
 OutFile "coreport_setup.exe"

 ;Default installation folder
 InstallDir $PROGRAMFILES\coreport

 ;Registry key to check for directory (so if you install again, it will
 ;overwrite the old one automatically)
 InstallDirRegKey HKLM "Software\coreport" "Install_Dir"

 ;Request application privileges for Windows Vista
 RequestExecutionLevel admin

 ; Compressor options
 SetCompressor /FINAL /SOLID lzma

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
; Pages

  !insertmacro MUI_PAGE_LICENSE "./coreport/README.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY

  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "coreport"

  SectionIn RO

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ; Put installation files there
  File /r "coreport-win32\*.*"

  ; Set output path to the installation directory.
  SetOutPath "$APPDATA\.coreport\couchdb"

  ; Put installation files there
  File /r "temp\couchdb_redist\*.*"

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\coreport "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\coreport" "DisplayName" "coreport"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\coreport" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\coreport" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\coreport" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\coreport"
  CreateShortCut "$SMPROGRAMS\coreport\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0 "" "" "Uninstall coreport"
  CreateShortCut "$SMPROGRAMS\coreport\app1.lnk" "$INSTDIR\python.exe" "capp1.pyo" "" 0 "" "" "app1"
  CreateShortCut "$SMPROGRAMS\coreport\app2.lnk" "$INSTDIR\python.exe" "capp2.pyo" "" 0 "" "" "app2"
  CreateShortCut "$SMPROGRAMS\coreport\app3.lnk" "$INSTDIR\python.exe" "capp3.pyo" "" 0 "" "" "app3"

  SetOutPath "$APPDATA\.app1_coreport\couchdb\bin"

  CreateShortCut "$SMPROGRAMS\coreport\start_test_couch.lnk" "$APPDATA\.coreport\couchdb\bin\couchdb.bat" "" "$APPDATA\.coreport\couchdb\bin\couchdb.bat" 0 "" "" "Start test couch server"

  SetOutPath $INSTDIR

SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\coreport"
  DeleteRegKey HKLM SOFTWARE\coreport

  ; Remove files and uninstaller
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\coreport\*.*"

  ; Remove directories used
  RMDir /r "$SMPROGRAMS\coreport"
  RMDir /r "$INSTDIR"
  RMDir /r "$APPDATA\.coreport"

SectionEnd
