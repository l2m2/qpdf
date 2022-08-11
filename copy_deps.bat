@echo off
set dist_debug=%~dp0dist\debug\
set dist_release=%~dp0dist\release\
::debug
xcopy %~dp0thirdparty\xpdf\bin64\* %dist_debug% /E /Y
::release
xcopy %~dp0thirdparty\xpdf\bin64\* %dist_release% /E /Y