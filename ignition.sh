#!/bin/bash

# Global variables
user_name="kali"

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

# Parted
INFO "[INF] Installing parted..."
sudo apt install -y parted
CHECK_INSTALL parted

# SQLite3
INFO "[INF] Installing SQlite3..."
sudo apt install -y sqlite3
CHECK_INSTALL sqlite3

# -- General Tools --
# OpenVPN
INFO "[INF] Installing openvpn..."
sudo apt-get install -y openvpn
CHECK_INSTALL openvpn

# Remmina
INFO "[INF] Installing Remmina..."
sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
sudo apt install -y remmina remmina-plugin-rdp remmina-plugin-secret
CHECK_INSTALL remmina

# -- Network --

# -- Firefox configuration --
# Location of Firefox profile directory (replace with your actual path)
firefox_path="~/.mozilla/firefox/${user_name}"

# Bookmark lists
training_bookmarks=(
	"https://www.notion.so/mcclew/|Notion"
	"https://tryhackme.com/|TryHackMe"
	"https://academy.tcm-sec.com/|TCM Security"
)

tool_bookmarks=(
	"https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Reverse%20Shell%20Cheatsheet.md|PayloadsAllTheThings"
	"https://github.com/rebootuser/LinEnum/|LinEnum"
	"https://gtfobins.github.io/|GTFOBins"
	"https://www.exploit-db.com/|Exploit DB"
	"https://www.rapid7.com/db/|Rapid7 DB"
)

# Create import file
TMP_BOOKMARKS=$(mktemp)

# Write content to the HTML file
echo "<html><head><title>Bookmarks</title></head><body>" > "$TMP_BOOKMARKS"

for bookmark in "${training_bookmarks[@]}"; do
  url=$(echo "$bookmark" | cut -d '|' -f1)
  name=$(echo "$bookmark" | cut -d '|' -f2-)
  echo "<a href=\"$url\">$title</a><br>" >> "$TMP_BOOKMARKS"
done

echo "</body></html>" >> "$TMP_BOOKMARKS"

# Set temporary preference to import bookmarks on startup
firefox -pref "browser.places.importBookmarksHTML=true" \
       -pref "browser.bookmarks.file=$TMP_BOOKMARKS"

# Clean up temporary file
rm "$TMP_BOOKMARKS"
