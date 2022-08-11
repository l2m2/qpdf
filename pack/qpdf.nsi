; 安装程序初始定义常量
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

; MUI 预定义常量
!define MUI_ABORTWARNING
!define MUI_ICON "qpdf-reader\favicon.ico"
!define MUI_UNICON "qpdf-reader\favicon.ico"


; 欢迎页面
!insertmacro MUI_PAGE_WELCOME


; 许可协议页面
!insertmacro MUI_PAGE_LICENSE "license.txt"


; 安装目录选择页面
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE "VerifyInstDir"
!insertmacro MUI_PAGE_DIRECTORY


; 开始菜单设置页面
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "QPdf Reader"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP


; 安装过程页面
!insertmacro MUI_PAGE_INSTFILES


; 安装完成页面
!insertmacro MUI_PAGE_FINISH


; 安装卸载过程页面
!insertmacro MUI_UNPAGE_INSTFILES


; 安装界面包含的语言设置
!insertmacro MUI_LANGUAGE "SimpChinese"


; 安装预释放文件
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI 现代界面定义结束 ------


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


Section "公共基础库" SEC00
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

; 以下是安装程序的卸载部分
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

; 安装路径选择页面路径合法性验证函数
Function VerifyInstDir
  StrCpy $0 $INSTDIR
  StrLen $1 $0
  StrCpy $2 ''

  ; 每个中文会给strlen增加2，所以copy 1个字符时，会遇到不可显示字符，会被NSIS自动改成?
  ; 正好?本身是非法路径，所以可以用这个来判断路径是否非法
  ${Do}
    IntOp $1 $1 - 1
    ${IfThen} $1 < 0 ${|}${ExitDo}${|}
    StrCpy $2 $0 1 $1
    ${IfThen} $2 == '?' ${|}${ExitDo}${|}
  ${Loop}
  
  ${If} $2 == '?'
    MessageBox MB_ICONEXCLAMATION|MB_OK|MB_TOPMOST "安装路径不能含有中文等宽字节字符。" 
	Abort
  ${EndIf}
FunctionEnd 

; 卸载初始化
Function un.onInit
  ClearErrors
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall" "QPdfReaderInstalling"
  IfErrors +2
  StrCmp $0 "true" checkRunning 0
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2|MB_TOPMOST \
	"你确实要完全移除$(^Name)，及其所有的组件？" \
    IDYES checkRunning
  Quit
  
checkRunning:
  FindProcDLL::FindProc "qpdf-reader.exe"
  Pop $R0
  IntCmp $R0 1 0 done
  MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "安装程序检测到 “QPdf Reader” 正在运行。$\r$\n$\r$\n请关闭 “QPdf Reader” 后点击 “重试” 按钮继续安装。$\r$\n点击 “取消” 按钮退出安装程序。" IDCANCEL Exit
  Goto checkRunning
Exit:
  Quit
done:
FunctionEnd

; 卸载成功
Function un.onUninstSuccess
  HideWindow
  ClearErrors
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall" "QPdfReaderInstalling"
  IfErrors +2
  StrCmp $0 "true" +2 0
  MessageBox MB_ICONINFORMATION|MB_OK|MB_TOPMOST "$(^Name)已成功地从你的计算机移除。"
FunctionEnd


Var UNINSTALL_PROG
Var OLD_VER
Var OLD_PATH

; 安装初始化
Function .onInit
  ClearErrors
  ReadRegStr $UNINSTALL_PROG ${PRODUCT_UNINST_ROOT_KEY} ${PRODUCT_UNINST_KEY} "UninstallString"
  IfErrors uninstall
  
  ReadRegStr $OLD_VER ${PRODUCT_UNINST_ROOT_KEY} ${PRODUCT_UNINST_KEY} "DisplayVersion"
  MessageBox MB_OKCANCEL|MB_ICONQUESTION|MB_TOPMOST \
    "检测到本机已经安装了 ${PRODUCT_NAME} $OLD_VER。\
    $\n$\n确定卸载已安装的版本？" \
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
