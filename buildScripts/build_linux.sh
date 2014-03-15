# NOTE: this build script assumes that you have installed Mono and you want to build NAppUpdate library
# which will not require mono installation on client machine

if [ "$1" = "MacOSX" ]
then
	export AS="as -arch i386"
	export CC="cc -arch i386"
	# export PATH=/Library/Frameworks/Mono.framework/Commands/:$PATH
	# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/pkgconfig:/Library/Frameworks/Mono.framework/Versions/Current/lib/pkgconfig
fi

# building first time and moving NAppUpdate.Updater.exe to NAppUpdate.Framework.dll
rm -rf ./../src/NAppUpdate.Updater/bin/Debug
rm -rf ./../src/NAppUpdate.Framework/Updater/* # delete previous updater
touch ./../src/NAppUpdate.Framework/Updater/updater.exe
sleep 3s
xbuild ./../NAppUpdate.sln /p:Configuration=Debug
rm -rf ./../src/NAppUpdate.Framework/Updater/*
cd ./../src/NAppUpdate.Updater/bin/Debug/

if [ "$1" = "MacOSX" ]
then
	MachineConfigFileName="/Library/Frameworks/Mono.framework/Versions/Current/etc/mono/2.0/machine.config"
else
	MachineConfigFileName="/etc/mono/2.0/machine.config"
fi

mkbundle --deps --static -z -L ./ NAppUpdate.Updater.exe NAppUpdate.Framework.dll -o updater.exe --machine-config $MachineConfigFileName

cd ./../../../../buildScripts
cp ./../src/NAppUpdate.Updater/bin/Debug/updater.exe ./../src/NAppUpdate.Framework/Updater/updater.exe

# building second time - final NAppUpdate.Framework build
rm -rf ./../src/NAppUpdate.Framework/bin/Debug
xbuild ./../NAppUpdate.sln /p:Configuration=Debug

# copy builded binary to bin_mono_compilant folder
rm -rf ./../bin_mono_compilant/*
cp ./../src/NAppUpdate.Framework/bin/Debug/NAppUpdate.Framework.dll ./../bin_mono_compilant/NAppUpdate.Framework.dll
# final - building application - adjust for your needs
# rm -rf ./../LinuxTest/bin/Debug
# xbuild ./../NAppUpdate.sln /p:Configuration=Debug # this is not required but made for clarity
# cd ./../LinuxTest/bin/Debug
# mkbundle --deps --static -z -L ./ LinuxTest.exe NAppUpdate.Framework.dll -o LinuxTest --machine-config /etc/mono/4.0/machine.config
# cd ./../../../buildScripts