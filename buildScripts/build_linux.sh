# NOTE: this build script assumes that you have installed Mono and you want to build NAppUpdate library
# which will not require mono installation on client machine

# building first time and moving NAppUpdate.Updater.exe to NAppUpdate.Framework.dll
rm -rf ./../src/NAppUpdate.Updater/bin/Debug
rm -rf ./../src/NAppUpdate.Framework/Updater/* # delete previous updater
touch ./../src/NAppUpdate.Framework/Updater/updater.exe
sleep 3s
xbuild ./../NAppUpdate.sln /p:Configuration=Debug
rm -rf ./../src/NAppUpdate.Framework/Updater/*
cd ./../src/NAppUpdate.Updater/bin/Debug/
mkbundle --deps --static -z -L ./ NAppUpdate.Updater.exe NAppUpdate.Framework.dll -o updater.exe --machine-config /etc/mono/4.0/machine.config
cd ./../../../../buildScripts
cp ./../src/NAppUpdate.Updater/bin/Debug/updater.exe ./../src/NAppUpdate.Framework/Updater/updater.exe

# building second time - final NAppUpdate.Framework build
rm -rf ./../src/NAppUpdate.Framework/bin/Debug
xbuild ./../NAppUpdate.sln /p:Configuration=Debug

# final - building application - adjust for your needs
rm -rf ./../LinuxTest/bin/Debug
xbuild ./../NAppUpdate.sln /p:Configuration=Debug # this is not required but made for clarity
cd ./../LinuxTest/bin/Debug
mkbundle --deps --static -z -L ./ LinuxTest.exe NAppUpdate.Framework.dll -o LinuxTest --machine-config /etc/mono/4.0/machine.config
cd ./../../../buildScripts
