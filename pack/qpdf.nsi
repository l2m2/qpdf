; ��װ�����ʼ���峣��
!define PRODUCT_NAME "QPdf_Reader"
!define PRODUCT_VERSION "V1.0.0"
!define PRODUCT_PUBLISHER "l2m2"
!define PRODUCT_WEB_SITE "https://github.com/Archie3d/qpdf"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\qpdf-reader.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

SetCompressor lzma

!include "MUI.nsh"
!include "LogicLib.nsh"

; MUI Ԥ���峣��
!define MUI_ABORTWARNING
!define MUI_ICON "qpdf-reader\favicon.ico"
!define MUI_UNICON "qpdf-reader\favicon.ico"


; ��ӭҳ��
!insertmacro MUI_PAGE_WELCOME


; ���Э��ҳ��
!insertmacro MUI_PAGE_LICENSE "license.txt"


; ��װĿ¼ѡ��ҳ��
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE "VerifyInstDir"
!insertmacro MUI_PAGE_DIRECTORY


; ��ʼ�˵�����ҳ��
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "QPdf Reader"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP


; ��װ����ҳ��
!insertmacro MUI_PAGE_INSTFILES


; ��װ���ҳ��
!insertmacro MUI_PAGE_FINISH


; ��װж�ع���ҳ��
!insertmacro MUI_UNPAGE_INSTFILES


; ��װ�����������������
!insertmacro MUI_LANGUAGE "SimpChinese"


; ��װԤ�ͷ��ļ�
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI �ִ����涨����� ------


Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
!define /date CURTIMESTAMP "%Y%m%d"
OutFile "${PRODUCT_NAME}_${PRODUCT_VERSION}_${CURTIMESTAMP}.exe"
InstallDir "$LocalAppData\Programs\qpdf-reader\"
; Request application privileges for Windows Vista
RequestExecutionLevel admin
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
ShowInstDetails show
ShowUnInstDetails show
BrandingText "QPdf Reader"


Section "����������" SEC00
  SectionIn RO
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File /r "qpdf-reader\*"
  
  CreateShortCut "$DESKTOP\QPdf Reader.lnk" "$INSTDIR\qpdf-reader.exe" 
  Exec '"$INSTDIR\VC_redist.x64.exe" /q /norestart'
  
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\qpdf-reader.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\qpdf-reader.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "EstimatedSize" "38593"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

; �����ǰ�װ�����ж�ز���
Section Uninstall
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\*.*"

  Delete "$DESKTOP\QPdf Reader.lnk"
  
  RMDir /r "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  
  SetAutoClose true
SectionEnd

; ��װ·��ѡ��ҳ��·���Ϸ�����֤����
Function VerifyInstDir
  StrCpy $0 $INSTDIR
  StrLen $1 $0
  StrCpy $2 ''

  ; ÿ�����Ļ��strlen����2������copy 1���ַ�ʱ��������������ʾ�ַ����ᱻNSIS�Զ��ĳ�?
  ; ����?�����ǷǷ�·�������Կ�����������ж�·���Ƿ�Ƿ�
  ${Do}
    IntOp $1 $1 - 1
    ${IfThen} $1 < 0 ${|}${ExitDo}${|}
    StrCpy $2 $0 1 $1
    ${IfThen} $2 == '?' ${|}${ExitDo}${|}
  ${Loop}
  
  ${If} $2 == '?'
    MessageBox MB_ICONEXCLAMATION|MB_OK|MB_TOPMOST "��װ·�����ܺ������ĵȿ��ֽ��ַ���" 
	Abort
  ${EndIf}
FunctionEnd 

; ж�س�ʼ��
Function un.onInit
  ClearErrors
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall" "QPdfReaderInstalling"
  IfErrors +2
  StrCmp $0 "true" checkRunning 0
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2|MB_TOPMOST \
	"��ȷʵҪ��ȫ�Ƴ�$(^Name)���������е������" \
    IDYES checkRunning
  Quit
  
checkRunning:
  FindProcDLL::FindProc "qpdf-reader.exe"
  Pop $R0
  IntCmp $R0 1 0 done
  MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "��װ�����⵽ ��QPdf Reader�� �������С�$\r$\n$\r$\n��ر� ��QPdf Reader�� ���� �����ԡ� ��ť������װ��$\r$\n��� ��ȡ���� ��ť�˳���װ����" IDCANCEL Exit
  Goto checkRunning
Exit:
  Quit
done:
FunctionEnd

; ж�سɹ�
Function un.onUninstSuccess
  HideWindow
  ClearErrors
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall" "QPdfReaderInstalling"
  IfErrors +2
  StrCmp $0 "true" +2 0
  MessageBox MB_ICONINFORMATION|MB_OK|MB_TOPMOST "$(^Name)�ѳɹ��ش���ļ�����Ƴ���"
FunctionEnd


Var UNINSTALL_PROG
Var OLD_VER
Var OLD_PATH

; ��װ��ʼ��
Function .onInit
  ClearErrors
  ReadRegStr $UNINSTALL_PROG ${PRODUCT_UNINST_ROOT_KEY} ${PRODUCT_UNINST_KEY} "UninstallString"
  IfErrors uninstall
  
  ReadRegStr $OLD_VER ${PRODUCT_UNINST_ROOT_KEY} ${PRODUCT_UNINST_KEY} "DisplayVersion"
  MessageBox MB_OKCANCEL|MB_ICONQUESTION|MB_TOPMOST \
    "��⵽�����Ѿ���װ�� ${PRODUCT_NAME} $OLD_VER��\
    $\n$\nȷ��ж���Ѱ�װ�İ汾��" \
      /SD IDOK \
      IDOK uninstall
  Abort
  
uninstall:
  StrCpy $OLD_PATH $UNINSTALL_PROG -10
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall" "QPdfReaderInstalling" "true"
  ExecWait '"$UNINSTALL_PROG" _?=$OLD_PATH' $0
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall" "QPdfReaderInstalling"
  IntCmp $0 2 0 +2
  Quit
  Delete "$UNINSTALL_PROG"
  RMDir $OLD_PATH
FunctionEnd
