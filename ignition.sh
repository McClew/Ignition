#!/bin/bash

# Styling variables
GREEN=`tput bold && tput setaf 2`
RED=`tput bold && tput setaf 1`
BLUE=`tput bold && tput setaf 4`
RESET=`tput sgr0`

# Styling functions
function SUCCESS()
{
	echo -e "\n${GREEN}${1}${RESET}"
}

function ERROR()
{
	echo -e "\n${RED}${1}${RESET}"
}

function INFO()
{
	echo -e "\n${BLUE}${1}${RESET}"
}

function CHECK_INSTALL()
{
	if dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -q "install ok installed"
	then
		SUCCESS "[SUC] Package: $1 successfully installed."
	else
		ERROR "[ERR] Command not found."
		ERROR "[ERR] Package: $1 install failed."
	fi

	return
}

# Banner
INFO "||| IGNITION STARTED |||"

# Test for root
if [ $UID -ne 0 ]
then
	ERROR "[ERR] Please run this script as root."
	exit
else
	SUCCESS "[SUC] Logged in as root."
	INFO "[INF] Starting ignition."
fi

# -- General --
INFO "[INF] Updating repositories..."
sudo apt update

# -- Development --
# Git
INFO "[INF] Insalling git..."
sudo apt install -y git
CHECK_INSTALL git

# Git
INFO "[INF] Insalling Sublime Text..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install -y apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install -y sublime-text
CHECK_INSTALL sublime-text

# SQLite3
INFO "[INF] Installing SQlite3..."
sudo apt install -y sqlite3
CHECK_INSTALL sqlite3

# -- General Tools --
# OpenVPN
INFO "[INF] Installing openvpn..."
sudo apt-get install -y openvpn
CHECK_INSTALL openvpn

# OpenVPN
INFO "[INF] Installing openvpn..."
sudo apt-get install -y openvpn
CHECK_INSTALL openvpn

# Remmina
INFO "[INF] Installing Remmina..."
sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret
CHECK_INSTALL remmina

# -- Network --

# -- Browser QOL --


# -- Nice to haves --

# -- Style!? --