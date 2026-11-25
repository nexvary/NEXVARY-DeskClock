; installer/aeroradar.nsi
; NSIS installer for NEXVARY AeroRadar.
; The Windows packaging workflow supplies the output path and generated payload manifest.
;
; SIMULATION ONLY — Not for navigation or air traffic control.

Unicode True

!include "${PAYLOAD_MANIFEST}"

!define PRODUCT_NAME      "NEXVARY AeroRadar"
!define PRODUCT_VERSION   "0.1.0"
!define PRODUCT_PUBLISHER "Nexvary Inc."
!define PRODUCT_EXE       "aeroradar_desktop.exe"
!define PRODUCT_UNINST_KEY \
    "Software\Microsoft\Windows\CurrentVersion\Uninstall\NexvaryAeroRadar"

; VersionInfo (embedded PE metadata — not a digital signature)
VIProductVersion "0.1.0.0"
VIAddVersionKey "ProductName"      "${PRODUCT_NAME}"
VIAddVersionKey "CompanyName"      "${PRODUCT_PUBLISHER}"
VIAddVersionKey "LegalCopyright"   "Copyright 2026 ${PRODUCT_PUBLISHER}"
VIAddVersionKey "FileDescription"  "${PRODUCT_NAME} Installer"
VIAddVersionKey "FileVersion"      "${PRODUCT_VERSION}"
VIAddVersionKey "ProductVersion"   "${PRODUCT_VERSION}"
VIAddVersionKey "Comments"         "Educational / research simulation platform. SIMULATION ONLY."

Name    "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${SETUP_OUTPUT}"

InstallDir          "$PROGRAMFILES64\Nexvary\AeroRadar"
InstallDirRegKey    HKLM "${PRODUCT_UNINST_KEY}" "InstallLocation"
RequestExecutionLevel admin
ShowInstDetails     show
ShowUnInstDetails   show
SetCompressor       /SOLID lzma

!include "MUI2.nsh"

!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE    "Welcome to ${PRODUCT_NAME} Setup"
!define MUI_WELCOMEPAGE_TEXT     "This will install ${PRODUCT_NAME} ${PRODUCT_VERSION} on your computer.\
                                  $\r$\n$\r$\n\
                                  SIMULATION ONLY — Not for navigation or air traffic control.$\r$\n$\r$\n\
                                  Click Next to continue."
!define MUI_FINISHPAGE_RUN       "$INSTDIR\${PRODUCT_EXE}"
!define MUI_FINISHPAGE_RUN_TEXT  "Launch ${PRODUCT_NAME}"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_COMPONENTSPAGE_SMALLDESC
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

; ---- Sections ----------------------------------------------------------------

Section "AeroRadar (required)" SecMain
    SectionIn RO
    IfFileExists "$INSTDIR\Uninstall.exe" payloadCollision
    !insertmacro CheckPayload
    !insertmacro InstallPayload
    SetOutPath "$INSTDIR"

    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Registry entries for Add/Remove Programs
    WriteRegStr   HKLM "${PRODUCT_UNINST_KEY}" "DisplayName"     "${PRODUCT_NAME}"
    WriteRegStr   HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion"  "${PRODUCT_VERSION}"
    WriteRegStr   HKLM "${PRODUCT_UNINST_KEY}" "Publisher"       "${PRODUCT_PUBLISHER}"
    WriteRegStr   HKLM "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr   HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
    WriteRegDWORD HKLM "${PRODUCT_UNINST_KEY}" "NoModify"        1
    WriteRegDWORD HKLM "${PRODUCT_UNINST_KEY}" "NoRepair"        1

    ; Start Menu shortcut
    CreateDirectory "$SMPROGRAMS\Nexvary"
    CreateShortcut  "$SMPROGRAMS\Nexvary\AeroRadar.lnk" \
                    "$INSTDIR\${PRODUCT_EXE}" "" \
                    "$INSTDIR\${PRODUCT_EXE}" 0 \
                    SW_SHOWNORMAL "" "NEXVARY AeroRadar simulation"
    Goto installed
payloadCollision:
    SetErrorLevel 1
    Abort "The installation would overwrite an existing file. Uninstall AeroRadar or select another folder."
installed:
SectionEnd

Section "Desktop shortcut" SecDesktop
    CreateShortcut "$DESKTOP\NEXVARY AeroRadar.lnk" \
                   "$INSTDIR\${PRODUCT_EXE}" "" \
                   "$INSTDIR\${PRODUCT_EXE}" 0
SectionEnd

; Section descriptions shown on the components page
LangString DESC_SecMain    ${LANG_ENGLISH} \
    "AeroRadar application and Qt runtime libraries. Required."
LangString DESC_SecDesktop ${LANG_ENGLISH} \
    "Create a shortcut on the Desktop."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMain}    $(DESC_SecMain)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} $(DESC_SecDesktop)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; ---- Uninstaller -------------------------------------------------------------

Section "Uninstall"
    !insertmacro RemovePayload
    Delete "$INSTDIR\Uninstall.exe"
    RMDir "$INSTDIR"

    ; Remove shortcuts
    Delete "$SMPROGRAMS\Nexvary\AeroRadar.lnk"
    RMDir  "$SMPROGRAMS\Nexvary"
    Delete "$DESKTOP\NEXVARY AeroRadar.lnk"

    ; Remove registry entries
    DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
SectionEnd
