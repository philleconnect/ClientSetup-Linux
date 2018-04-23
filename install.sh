#!/bin/bash
if ! [ "$EUID" -ne 0 ]; then
	echo "You executed this script as root. Good idea, we will need root privileges later, but to install it correctly, we need to know who the current user is, which is not possible as root. Please run as the user you want PhilleConnect to be installed."
	exit
fi
echo "This script will install PhilleConnect on yout client machine."
echo "It supports Ubuntu 18.04 LTS or later and Kubuntu 18.04 LTS or later, but it should work on every other Debian-based linux distribution using GNOME or KDE Desktop environment."
echo "We will need root privileges later, so keep your root password ready."
echo "Scanning for GNOME desktop..."
GNOME=false
KDE=false
if [ ! -e '/usr/bin/gnome-session' ]; then
	echo "Did not find any GNOME start file"
else 
	echo "Found GNOME start file"
	GNOME=true
fi
echo "Scanning for KDE deskop..."
if [ ! -e '/usr/bin/startkde' ]; then
	echo "Did not find any KDE start file"
else
	echo "Found KDE start file"
	KDE=true
fi
if [ ! '$GNOME' ] && [ ! '$KDE' ]; then
	echo "Couldn't find GNOME or KDE. Unable to install PhilleConnect."
	exit
fi
while true; do
	echo "Please choose which variant you want to install:"
	echo "[0] Install for a student machine"
	echo "[1] Install for a teacher machine with student control"
	echo "[2] Install for a standalone teacher machine"
	read VARIANT
	if [ $VARIANT != '0' ] && [ $VARIANT != '1' ] && [ $VARIANT != '2' ]; then
		echo "Couldn't parse input, aborting"
	else
		break
	fi
done
echo "Installing dependencies..."
sudo apt install -y libssl-dev net-tools cifs-utils
if [ $VARIANT = '0' ]; then
	sudo apt install -y x11vnc
	echo "Setting up vnc server..."
	sudo cp config/x11vnc.pass /etc/
elif [ $VARIANT = '1' ]; then
	sudo apt install -y xtightvncviewer
	sudo cp vnc/vncsnapshot /usr/bin/
	sudo mkdir /etc/philleconnect
	sudo cp config/passwd /etc/philleconnect/
fi
echo "Copying files..."
sudo cp bin/PhilleConnectStart /usr/bin/
sudo cp bin/ClientRegistrationTool /tmp/
sudo cp pcconfig.jkm /etc/
if [ $VARIANT = '0' ]; then
	sudo cp bin/PhilleConnectDrive /usr/bin/
	sudo cp bin/systemclient /usr/bin/
	sudo cp desktop/PhilleConnectDrive.desktop /etc/xdg/autostart/
	sudo cp desktop/systemclient.desktop /etc/xdg/autostart/
	sudo chmod +x /etc/xdg/autostart/systemclient.desktop
	sudo chmod +x /etc/xdg/autostart/PhilleConnectDrive.desktop
	echo "$USER ALL=NOPASSWD: /usr/bin/PhilleConnectDrive" | sudo tee --append /etc/sudoers
	echo "$USER ALL=NOPASSWD: /usr/bin/systemclient" | sudo tee --append /etc/sudoers
elif [ $VARIANT = '1' ]; then
	sudo cp bin/PhilleConnectTeacher /usr/bin/
	sudo cp desktop/PhilleConnectTeacher.desktop /etc/xdg/autostart/
	sudo chmod +x /etc/xdg/autostart/PhilleConnectTeacher.desktop
	echo "$USER ALL=NOPASSWD: /usr/bin/PhilleConnectTeacher" | sudo tee --append /etc/sudoers
elif [ $VARIANT = '2' ]; then
	sudo cp bin/PhilleConnectDrive /usr/bin/
	sudo cp desktop/PhilleConnectDrive.desktop /etc/xdg/autostart/
	sudo chmod +x /etc/xdg/autostart/PhilleConnectDrive.desktop
	echo "$USER ALL=NOPASSWD: /usr/bin/PhilleConnectDrive" | sudo tee --append /etc/sudoers
fi
if [ $GNOME = true ]; then
	DATA='PhilleConnectStart \&\nwait $!\nexec /usr/lib/gnome-session/gnome-session-binary '
	sudo sed -i "s|exec /usr/lib/gnome-session/gnome-session-binary |${DATA}|g" /usr/bin/gnome-session
fi
if [ $KDE = true ]; then
	DATA='PhilleConnectStart \&\nwait $!\n# finally, give the session control to the session manager'
	sudo sed -i "s|# finally, give the session control to the session manager|${DATA}|g" /usr/bin/startkde
fi
echo "Do you want a desktop icon?"
echo "[0] Yes"
echo "[1] No"
read ICON
if [ $ICON = '0' ]; then
	if [ -d ~/Desktop ]; then
		if [ $VARIANT = '1' ]; then
			sudo cp desktop/PhilleConnectTeacher.desktop ~/Desktop/
			sudo chown "$USER":"$USER" ~/Desktop/PhilleConnectTeacher.desktop
			sudo chmod +x ~/Desktop/PhilleConnectTeacher.desktop
		else
			sudo cp desktop/PhilleConnectDrive.desktop ~/Desktop/
			sudo chown "$USER":"$USER" ~/Desktop/PhilleConnectDrive.desktop
			sudo chmod +x ~/Desktop/PhilleConnectDrive.desktop
		fi
	fi
	if [ -d ~/Schreibtisch ]; then
		if [ $VARIANT = '1' ]; then
			sudo cp desktop/PhilleConnectTeacher.desktop ~/Schreibtisch/
			sudo chown "$USER":"$USER" ~/DeSchreibtischsktop/PhilleConnectTeacher.desktop
			sudo chmod +x ~/Schreibtisch/PhilleConnectTeacher.desktop
		else
			sudo cp desktop/PhilleConnectDrive.desktop ~/Schreibtisch/
			sudo chown "$USER":"$USER" ~/Schreibtisch/PhilleConnectDrive.desktop
			sudo chmod +x ~/Schreibtisch/PhilleConnectDrive.desktop
		fi
	fi
fi
echo "Do you want to register this client?"
echo "[0] Yes"
echo "[1] No"
read REGISTER
if [ $REGISTER = '0' ]; then
	/tmp/ClientRegistrationTool &
	wait $!
fi
sudo rm /tmp/ClientRegistrationTool
echo "Installation finished!"
if [ $REGISTER != '0' ]; then
	echo "After the installation, a reboot is required. Do you want to rebot now?"
	echo "[0] Yes"
	echo "[1] No"
	read REBOOT
	if [ $REBOOT = '0' ]; then
		echo "will reboot"
		reboot
	fi
fi
