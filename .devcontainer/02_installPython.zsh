#!/bin/zsh

bold="\033[1m"
blue="\033[0;34m"
green="\033[0;32m"
red="\033[0;31m"
reset="\033[0m"

PYTHON_VERSION=$(cat .python-version)

echo "${blue}Installing Python $PYTHON_VERSION and pip ...${reset}"
sudo apt-get install python$PYTHON_VERSION python3-pip -y
echo ""

echo "${blue}Setting Python $PYTHON_VERSION as default ...${reset}"
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python$PYTHON_VERSION 1
echo ""

echo "${blue}Updating pip ...${reset}"
pip install --upgrade pip --no-warn-script-location
echo ""

echo "${blue}Checking versions of python3 and pip ...${reset}"
python3 --version
pip --version
echo ""
echo ""