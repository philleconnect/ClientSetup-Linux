#!/bin/bash
if ! [ "$EUID" -ne 0 ]; then
	echo "You executed this script as root. Good idea, we will need root privileges later, but to install it correctly, we need to know who the current user is, which is not possible as root. Please run as the user you want PhilleConnect to be installed."
	exit
fi
echo "This script will uninstall PhilleConnect from this client machine."
echo "Do you really want that? Type 'DELETE' to confirm (Press CTRL-C to cancel):"
while true; do 
	read CONFIRMATION
	if [ $CONFIRMATION != 'DELETE' ]; then
		echo "Wrong input. Please type 'DELETE' to confirm. Press CTRL-C to cancel."
	else
		break
	fi
done
echo "Deleting files..."
if [ -f /usr/bin/PhilleConnectDrive ]; then
	sudo rm /usr/bin/PhilleConnectDrive
fi
if [ -f /usr/bin/PhilleConnectStart ]; then
	sudo rm /usr/bin/PhilleConnectStart
fi
if [ -f /usr/bin/PhilleConnectTeacher ]; then
	sudo rm /usr/bin/PhilleConnectTeacher
fi
if [ -f /usr/bin/systemclient ]; then
	sudo rm /usr/bin/systemclient
fi
if [ -f /usr/bin/PhilleConnectOnlineChecker ]; then
	sudo rm /usr/bin/PhilleConnectOnlineChecker
fi
if [ -f /etc/pcconfig.jkm ]; then
	sudo rm /etc/pcconfig.jkm 
fi
if [ -f /etc/xdg/autostart/PhilleConnectDrive.desktop ]; then
	sudo rm /etc/xdg/autostart/PhilleConnectDrive.desktop
fi
if [ -f /etc/xdg/autostart/PhilleConnectTeacher.desktop ]; then
	sudo rm /etc/xdg/autostart/PhilleConnectTeacher.desktop
fi
if [ -f /etc/xdg/autostart/systemclient.desktop ]; then
	sudo rm /etc/xdg/autostart/systemclient.desktop
fi
if [ -f ~/Desktop/PhilleConnectDrive.desktop ]; then
	sudo rm ~/Desktop/PhilleConnectDrive.desktop
fi
if [ -f ~/Desktop/PhilleConnectTeacher.desktop ]; then
	sudo rm ~/Desktop/PhilleConnectTeacher.desktop
fi
if [ -f ~/Schreibtisch/PhilleConnectDrive.desktop ]; then
	sudo rm ~/Schreibtisch/PhilleConnectDrive.desktop
fi
if [ -f ~/Schreibtisch/PhilleConnectTeacher.desktop ]; then
	sudo rm ~/Schreibtisch/PhilleConnectTeacher.desktop
fi
if [ -f /opt/philleconnect/logo.png ]; then
	sudo rm -R /opt/philleconnect
fi
echo "Removing configuration"
if [ -f /usr/bin/gnome-session ]; then
	sudo grep -v "PhilleConnectStart &" /usr/bin/gnome-session > /tmp/gnome-session-temp
	sudo mv /tmp/gnome-session-temp /usr/bin/gnome-session
	sudo grep -v "wait $!" /usr/bin/gnome-session > /tmp/gnome-session-temp
	sudo mv /tmp/gnome-session-temp /usr/bin/gnome-session
	sudo chown root:root /usr/bin/gnome-session
	sudo chmod 744 /usr/bin/gnome-session
	sudo chmod +x /usr/bin/gnome-session
fi
if [ -f /usr/bin/startkde ]; then
	sudo grep -v "PhilleConnectStart &" /usr/bin/startkde > /tmp/startkde-temp
	sudo mv /tmp/startkde-temp /usr/bin/startkde
	sudo grep -v "wait $!" /usr/bin/startkde > /tmp/startkde-temp
	sudo mv /tmp/startkde-temp /usr/bin/startkde
	sudo chown root:root /usr/bin/startkde
	sudo chmod 744 /usr/bin/startkde
	sudo chmod +x /usr/bin/startkde
fi
if [ -f /etc/sudoers.d/PhilleConnectDrive ]; then
	sudo rm /etc/sudoers.d/PhilleConnectDrive
fi
if [ -f /etc/sudoers.d/PhilleConnectTeacher ]; then
	sudo rm /etc/sudoers.d/PhilleConnectTeacher
fi
if [ -f /etc/sudoers.d/systemclient ]; then
	sudo rm /etc/sudoers.d/systemclient
fi
if [ -f /etc/sudoers.d/PhilleConnectOnlineChecker ]; then
	sudo rm /etc/sudoers.d/PhilleConnectOnlineChecker
fi
read -p "Do you want to remove dependencies? [y/n]" DEPENDENCIES
if [[ $DEPENDENCIES =~ ^[yYjJ] ]]; then
	echo "Removing dependencies..."
	sudo apt -y remove x11vnc xtightvncviewer libssl-dev net-tools cifs-utils
fi
echo "Done!"
