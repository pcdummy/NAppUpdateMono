SET PATH=%PATH%;"C:\Program Files (x86)\Mono-2.10.9\bin"

REM building first time and moving NAppUpdate.Updater.exe to NAppUpdate.Framework.dll
rmdir /S /Q .\..\src\NAppUpdate.Updater\bin\Debug
rmdir /S /Q .\..\src\NAppUpdate.Framework\Updater
mkdir .\..\src\NAppUpdate.Framework\Updater
echo something > ./../src/NAppUpdate.Framework/Updater/updater.exe
call xbuild ./../NAppUpdate.sln /p:Configuration=Debug
rmdir /S /Q .\..\src\NAppUpdate.Framework\Updater
mkdir .\..\src\NAppUpdate.Framework\Updater
cd ./../src/NAppUpdate.Updater/bin/Debug/
.\..\..\..\..\ilmerge.2.13.0307\ilmerge.exe /out:updater.exe NAppUpdate.Updater.exe NAppUpdate.Framework.dll
cd ./../../../../buildScripts
copy .\..\src\NAppUpdate.Updater\bin\Debug\updater.exe .\..\src\NAppUpdate.Framework\Updater\updater.exe

REM building second time - final NAppUpdate.Framework build
rmdir /S /Q .\..\src\NAppUpdate.Framework\bin\Debug
call xbuild ./../NAppUpdate.sln /p:Configuration=Debug

REM copy builded binary to bin_mono_compilant folder
rmdir /S /Q .\..\bin_mono_compilant
mkdir .\..\bin_mono_compilant
copy .\..\src\NAppUpdate.Framework\bin\Debug\NAppUpdate.Framework.dll .\..\bin_mono_compilant\NAppUpdate.Framework.dll

REM final - building application - adjust for your needs - see example in build_linux.sh