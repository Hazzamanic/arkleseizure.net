#!/bin/bash

export DOTNET_ROOT=/opt/buildhome/.dotnet
./.netlify/dotnet-install.sh --version 3.1.201
dotnet tool install -g Histanai -v 0.0.1
histanai build