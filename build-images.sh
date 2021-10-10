#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
   echo "build-images.sh: Use packer to build images for deployment"
   echo ""
   echo "Help: build-images.sh"
   echo "Usage: ./build-images.sh -m -n hostname -g gitea_version -v version"
   echo "Flags:"
   echo -e "-m \t\t\t(Optional) Flag to also build images for modules"
   echo -e "-n hostname \t\t(Mandatory) Name of the host for which to build images"
   echo -e "-g gitea_version \t(Optional) Override default gitea version to use for the git server image, e.g. 1.15.3 (default)"
   echo -e "-v version \t\t(Mandatory) Version stamp to apply to images, e.g. 20210101-1"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or mandatory input variable is missing"
   echo "Use \"./build-images.sh -h\" for help"
   exit 1
}

# Default software package versions
gitea_version='1.15.3'

build_modules='false'

while getopts mn:g:v:h flag
do
    case "${flag}" in
        m) build_modules='true';;
        n) hostname=${OPTARG};;
        g) gitea_version=${OPTARG};;
        v) version=${OPTARG};;
        h) helpMessage ;;
        ?) errorMessage ;;
    esac
done

if [ -z "$hostname" ] || [ -z "$version" ] || [ -z "$gitea_version" ]
then
   errorMessage
fi

# Build ryo-service-proxy module images if -m flag is present
if [ $build_modules == 'true' ]
then
   echo "Running build-images script for ryo-service-proxy module on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-service-proxy/build-images.sh -n "$hostname" -v "$version"
else
   echo "Skipping image build for modules"
   echo ""
fi

# Build ryo-mariadb module images if -m flag is present
if [ $build_modules == 'true' ]
then
   echo "Running build-images script for ryo-mariadb module on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-mariadb/build-images.sh -n "$hostname" -v "$version"
else
   echo "Skipping image build for modules"
   echo ""
fi

# Build project images
echo "Building git server image on "$hostname""
echo "Executing command: packer build -var \"host_id="$hostname"\" -var \"version="$version"\" -var \"gitea_version="$gitea_version"\" "$SCRIPT_DIR"/image-build/gitea.pkr.hcl"
echo ""
packer build -var "host_id="$hostname"" -var "version="$version"" -var "gitea_version="$gitea_version"" "$SCRIPT_DIR"/image-build/gitea.pkr.hcl
echo ""

echo "Completed"
