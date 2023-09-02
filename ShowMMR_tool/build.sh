#!/bin/bash

function isver { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; origin="Patsie@bashscripts" } 

DOTNET_VER="$(dotnet --version)"
if [ $(isver $DOTNET_VER) -ge $(isver "7.0.0") ]; then
   PROJECT=ShowMMR_net7.csproj; FRAMEWORK="net7.0"; EXE=bin/Release/net7.0/ShowMMR.dll
elif [ $(isver $DOTNET_VER) -ge $(isver "6.0.0") ]; then
   PROJECT=ShowMMR_net6.csproj; FRAMEWORK="net6.0"; EXE=bin/Release/net6.0/ShowMMR.dll
else
   read -s -n 1 -p " AveYo: dotnet sdk 6 or 7 for linux required to build this version "; exit 1
fi

cd $(dirname "${BASH_SOURCE[0]}")

dotnet build $PROJECT -c Release --self-contained=false -p:TargetFramework=$FRAMEWORK

rm "obj" -r -f 2> /dev/null

read -s -n 1 -p "Press any key "
