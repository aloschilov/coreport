;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

 ;Name and file
 Name "app1"
 OutFile "app1_installer.exe"

 ;Default installation folder
 InstallDir $PROGRAMFILES\coreport_app1

 ;Registry key to check for directory (so if you install again, it will
 ;overwrite the old one automatically)
 InstallDirRegKey HKLM "Software\coreport_app1" "Install_Dir"

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
Section "app1"

  SectionIn RO

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ; Put installation files there
  File /r "app1-win32\*.*"

  ; Set output path to the installation directory.
  SetOutPath "$APPDATA\.app1_coreport\couchdb"

  ; Put installation files there
  File /r "temp\couchdb_redist\*.*"

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\app1 "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\app1" "DisplayName" "app1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\app1" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\app1" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\app1" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\app1"
  CreateShortCut "$SMPROGRAMS\app1\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0 "" "" "Uninstall app1"
  CreateShortCut "$SMPROGRAMS\app1\app1.lnk" "$INSTDIR\capp1.exe" "" "$INSTDIR\capp1.exe" 0 "" "" "app1"

  SetOutPath "$APPDATA\.app1_coreport\couchdb\bin"

  CreateShortCut "$SMPROGRAMS\app1\start_test_couch.lnk" "$APPDATA\.app1_coreport\couchdb\bin\couchdb.bat" "" "$APPDATA\.app1_coreport\couchdb\bin\couchdb.bat" 0 "" "" "Start test couch server"
  
  SetOutPath $INSTDIR

SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\app1"
  DeleteRegKey HKLM SOFTWARE\app1

  ; Remove files and uninstaller
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\app1\*.*"
  ; Remove directories used
  RMDir /r "$SMPROGRAMS\app1"
  RMDir /r "$INSTDIR"
  RMDir /r "$APPDATA\.app1_coreport"

SectionEnd
