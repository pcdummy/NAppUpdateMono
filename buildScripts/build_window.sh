#!/bin/bash
#
# Copyright 2014 by the NAppUpdateMono Project.
#
# Usage:
# /bin/bash build_windows.sh <Debug|Release>
#
# For example:
# /bin/bash build_windows.sh Release Dynamic
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

BUILD_CONFIG="Debug"
if [ ! -z "$1" ]; then
	BUILD_CONFIG="$1"
fi

# building first time and moving NAppUpdate.Updater.exe to NAppUpdate.Framework.dll
rm -f ${MY_PATH}/../src/NAppUpdate.Updater/bin/${BUILD_CONFIG}/*

xbuild ${MY_PATH}/../src/NAppUpdate.Framework/NAppUpdate.Framework.csproj /p:Configuration=${BUILD_CONFIG} /t:Clean
xbuild ${MY_PATH}/../src/NAppUpdate.Framework/NAppUpdate.Framework.csproj /p:Configuration=${BUILD_CONFIG}
 
xbuild ${MY_PATH}/../src/NAppUpdate.Updater/NAppUpdate.Updater.csproj /p:Configuration=${BUILD_CONFIG} /t:Clean
xbuild ${MY_PATH}/../src/NAppUpdate.Updater/NAppUpdate.Updater.csproj /p:Configuration=${BUILD_CONFIG}

OUTPUT_PATH="${MY_PATH}/../bin/Windows/net40/"

# copy builded binary to bin_mono_compilant folder
rm -rf ${OUTPUT_PATH}
mkdir -p ${OUTPUT_PATH}

cp ${MY_PATH}/../src/NAppUpdate.Framework/bin/${BUILD_CONFIG}/NAppUpdate.Framework.dll ${OUTPUT_PATH}
cp ${MY_PATH}/../src/NAppUpdate.Framework/bin/${BUILD_CONFIG}/NAppUpdate.Framework.dll.mdb ${OUTPUT_PATH}

cd ${MY_PATH}/../src/NAppUpdate.Updater/bin/${BUILD_CONFIG}/
${MY_PATH}/../tools/ILRepack.exe /out:${OUTPUT_PATH}/updater.exe NAppUpdate.Updater.exe NAppUpdate.Framework.dll