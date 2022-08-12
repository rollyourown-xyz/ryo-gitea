#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Default project software versions
gitea_version="1.17.0"

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "build-image-project.sh: Use packer to build project images for deployment"
  echo ""
  echo "Help: build-image-project.sh"
  echo "Usage: ./build-image-project.sh -m -n hostname -g grav_version -v version"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host for which to build images"
  echo -e "-v version \t\t(Mandatory) Version stamp to apply to images, e.g. 20210101-1"
  echo -e "-r remote_build \t\t(Mandatory) Whether to build images on the remote LXD host (true/false)"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or mandatory input variable is missing"
  echo "Use \"./build-image-project.sh -h\" for help"
  exit 1
}

while getopts n:v:r:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    v) version=${OPTARG};;
    r) remote_build=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$version" ] || [ -z "$remote_build" ]
then
  errorMessage
fi


# Build project images

# Git server
echo ""
echo "Building git server image on "$hostname""
echo "Executing command: packer build -var \"host_id="$hostname"\" -var \"version="$version"\" -var \"remote="$remote_build\"" -var \"gitea_version="$gitea_version"\" "$SCRIPT_DIR"/../image-build/gitea.pkr.hcl"
packer build -var "host_id="$hostname"" -var "version="$version"" -var "remote="$remote_build"" -var "gitea_version="$gitea_version"" "$SCRIPT_DIR"/../image-build/gitea.pkr.hcl
echo "Completed"
