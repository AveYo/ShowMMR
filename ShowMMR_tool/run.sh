#!/bin/bash

function isver { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; origin="Patsie@bashscripts"; }

DOTNET_VER="$(dotnet --version)"
if [ $(isver $DOTNET_VER) -ge $(isver "7.0.0") ]; then
   PROJECT=ShowMMR_net7.csproj; FRAMEWORK="net7.0"; EXE=bin/Release/net7.0/ShowMMR.dll
elif [ $(isver $DOTNET_VER) -ge $(isver "6.0.0") ]; then
   PROJECT=ShowMMR_net6.csproj; FRAMEWORK="net6.0"; EXE=bin/Release/net6.0/ShowMMR.dll
else
   read -s -n 1 -p " AveYo: dotnet runtime 6 or 7 for linux required to run this version "; exit 1
fi

cd $(dirname "${BASH_SOURCE[0]}")

if ! test -e $EXE; then
  read -s -n 1 -p " AveYo: use build.sh script first "; exit 1
fi

set +H

dotnet $EXE "$@"

read -s -n 1 -p "Press any key "
