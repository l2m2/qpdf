set qt_dir=C:\Qt\5.15.2\msvc2019_64
set qt_bin=%qt_dir%\bin
set dist_dir=%~dp0..\dist
set pack_temp_dir=%~dp0pack_temp
set app_name=qpdf-reader

if exist %pack_temp_dir% rmdir /S /Q %pack_temp_dir%
mkdir %pack_temp_dir%

start "" /b /w cmd /c %~dp0..\copy_deps.bat

xcopy %~dp0extra\* %dist_dir%\release\ /Y
xcopy %~dp0favicon.ico %dist_dir%\release\ /Y
::xcopy %~dp0config.json %dist_dir%\release\ /Y

%qt_bin%\windeployqt.exe %dist_dir%\release\qpdf-reader.exe --no-translations
%qt_bin%\windeployqt.exe %dist_dir%\release\qpdf.dll --no-translations
xcopy /exclude:uncopy.txt %dist_dir%\release\ %pack_temp_dir%\%app_name%\ /E /Y
xcopy %~dp0license.txt %pack_temp_dir%\ /Y
xcopy %~dp0qpdf.nsi %pack_temp_dir%\ /Y

@REM gen installation package
cd /d %pack_temp_dir%
makensis.exe qpdf.nsi

cd /d %~dp0
move %pack_temp_dir%\*.exe %~dp0