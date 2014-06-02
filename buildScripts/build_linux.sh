#!/bin/bash
#
# Copyright 2014 by the NAppUpdateMono Project.
#
# Usage:
# /bin/bash build_linux.sh <MacOSX|Linux> <Debug|Release> <Static|Dynamic>
#
# For example:
# /bin/bash build_linux.sh Linux Release Dynamic
#
# NOTE: this build script assumes that you have installed Mono and you want to build NAppUpdate library
# which will not require mono installation on client machine
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

if [ "$1" = "MacOSX" ]
then
	export AS="as -arch i386"
	export CC="cc -arch i386"
	# export PATH=/Library/Frameworks/Mono.framework/Commands/:$PATH
	# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/pkgconfig:/Library/Frameworks/Mono.framework/Versions/Current/lib/pkgconfig
fi

BUILD_CONFIG="Debug"
if [ ! -z "$2" ]; then
	BUILD_CONFIG="$2"
fi

STATIC_BUILD="true"
if [ ! -z "$3" -a "$3" = "Dynamic" ]; then
	STATIC_BUILD="false"
fi

# building first time and moving NAppUpdate.Updater.exe to NAppUpdate.Framework.dll
rm -f ${MY_PATH}/../src/NAppUpdate.Updater/bin/${BUILD_CONFIG}/*

xbuild ${MY_PATH}/../src/NAppUpdate.Framework/NAppUpdate.Framework.csproj /p:Configuration=${BUILD_CONFIG} /t:Clean
xbuild ${MY_PATH}/../src/NAppUpdate.Framework/NAppUpdate.Framework.csproj /p:Configuration=${BUILD_CONFIG}
 
xbuild ${MY_PATH}/../src/NAppUpdate.Updater/NAppUpdate.Updater.csproj /p:Configuration=${BUILD_CONFIG} /t:Clean
xbuild ${MY_PATH}/../src/NAppUpdate.Updater/NAppUpdate.Updater.csproj /p:Configuration=${BUILD_CONFIG}

xbuild ${MY_PATH}/../LinuxTest/LinuxTest.csproj /p:Configuration=${BUILD_CONFIG} /t:Clean
xbuild ${MY_PATH}/../LinuxTest/LinuxTest.csproj /p:Configuration=${BUILD_CONFIG}


if [ "$1" = "MacOSX" ]
then
	MachineConfigFileName="/Library/Frameworks/Mono.framework/Versions/Current/etc/mono/2.0/machine.config"
else
	MachineConfigFileName="/etc/mono/4.0/machine.config"
fi

# copy builded binary to bin_mono_compilant folder
OUTPUT_PATH="${MY_PATH}/../bin/Linux/net40/"
rm -rf ${OUTPUT_PATH}
mkdir -p ${OUTPUT_PATH}

cp ${MY_PATH}/../src/NAppUpdate.Framework/bin/${BUILD_CONFIG}/NAppUpdate.Framework.dll ${OUTPUT_PATH}
cp ${MY_PATH}/../src/NAppUpdate.Framework/bin/${BUILD_CONFIG}/NAppUpdate.Framework.dll.mdb ${OUTPUT_PATH}

cd ${MY_PATH}/../src/NAppUpdate.Updater/bin/${BUILD_CONFIG}/
if [ "${STATIC_BUILD}" = "true" ]; then
	mkbundle --static --deps -z -L ./ NAppUpdate.Updater.exe NAppUpdate.Framework.dll -o ${OUTPUT_PATH}/updater.exe --machine-config ${MachineConfigFileName}
else
	mkbundle -z -L ./ NAppUpdate.Updater.exe NAppUpdate.Framework.dll -o ${OUTPUT_PATH}/updater.exe --machine-config ${MachineConfigFileName}
fi

# final - building application - adjust for your needs
#rm -rf ${MY_PATH}/../LinuxTest/bin/${BUILD_CONFIG}
#xbuild ./../NAppUpdate.sln /p:Configuration=${BUILD_CONFIG} # this is not required but made for clarity
cd ${MY_PATH}/../LinuxTest/bin/${BUILD_CONFIG}
if [ "${STATIC_BUILD}" = "true" ]; then
	mkbundle --static --deps -z -L ./ LinuxTest.exe NAppUpdate.Framework.dll -o ${OUTPUT_PATH}/LinuxTest --machine-config ${MachineConfigFileName}
else
	mkbundle -z -L ./ LinuxTest.exe NAppUpdate.Framework.dll -o ${OUTPUT_PATH}/LinuxTest --machine-config ${MachineConfigFileName}
fi
