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
CONFIGFILE="pcconfig.jkm"
if [ ! -f $CONFIGFILE ]; then
	echo "Couldn't find configuration file pcconfig.jkm. Please give path to pcconfig.jkm:"
	while true; do
		read CONFIGFILE
		if [ -f $CONFIGFILE ]; then
			break
		else
			echo "Couldn't find configuration file on this location. Please try again."
		fi
	done
fi
echo "Please choose which variant you want to install:"
while true; do
	echo "[0] Install for a student machine"
	echo "[1] Install for a teacher machine with student control"
	echo "[2] Install for a standalone teacher machine"
	read VARIANT
	if [ $VARIANT != '0' ] && [ $VARIANT != '1' ] && [ $VARIANT != '2' ]; then
		echo "Couldn't parse input, please try again:"
	else
		break
	fi
done
echo "Installing dependencies..."
sudo apt install -y libssl-dev net-tools cifs-utils
if [ $VARIANT = '0' ]; then
	sudo apt install -y x11vnc
elif [ $VARIANT = '1' ]; then
	sudo apt install -y xtightvncviewer x11vnc
fi
echo "Copying files..."
sudo cp bin/PhilleConnectStart /usr/bin/
sudo chmod +x /usr/bin/PhilleConnectStart
sudo cp bin/ClientRegistrationTool /tmp/
sudo chmod +x /tmp/ClientRegistrationTool
sudo mkdir /opt/philleconnect
sudo cp img/logo.png /opt/philleconnect/
sudo cp $CONFIGFILE /etc/pcconfig.jkm
if [ $VARIANT = '0' ]; then
	sudo cp bin/PhilleConnectDrive /usr/bin/
	sudo chmod +x /usr/bin/PhilleConnectDrive
	sudo cp bin/systemclient /usr/bin/
	sudo chmod +x /usr/bin/systemclient
	sudo cp desktop/PhilleConnectDrive.desktop /etc/xdg/autostart/
	sudo cp desktop/systemclient.desktop /etc/xdg/autostart/
	sudo chmod +x /etc/xdg/autostart/systemclient.desktop
	sudo chmod +x /etc/xdg/autostart/PhilleConnectDrive.desktop
	echo "$USER ALL=NOPASSWD: /usr/bin/PhilleConnectDrive" | sudo tee /etc/sudoers.d/PhilleConnectDrive
	echo "$USER ALL=NOPASSWD: /usr/bin/systemclient" | sudo tee /etc/sudoers.d/systemclient
elif [ $VARIANT = '1' ]; then
	sudo cp bin/PhilleConnectTeacher /usr/bin/
	sudo chmod +x /usr/bin/PhilleConnectTeacher
	sudo cp desktop/PhilleConnectTeacher.desktop /etc/xdg/autostart/
	sudo chmod +x /etc/xdg/autostart/PhilleConnectTeacher.desktop
	echo "$USER ALL=NOPASSWD: /usr/bin/PhilleConnectTeacher" | sudo tee /etc/sudoers.d/PhilleConnectTeacher
elif [ $VARIANT = '2' ]; then
	sudo cp bin/PhilleConnectDrive /usr/bin/
	sudo chmod +x /usr/bin/PhilleConnectDrive
	sudo cp desktop/PhilleConnectDrive.desktop /etc/xdg/autostart/
	sudo chmod +x /etc/xdg/autostart/PhilleConnectDrive.desktop
	echo "$USER ALL=NOPASSWD: /usr/bin/PhilleConnectDrive" | sudo tee /etc/sudoers.d/PhilleConnectDrive
fi
if [ $GNOME = true ]; then
	DATA='PhilleConnectStart \&\nwait $!\nexec /usr/lib/gnome-session/gnome-session-binary '
	sudo sed -i "s|exec /usr/lib/gnome-session/gnome-session-binary |${DATA}|g" /usr/bin/gnome-session
fi
if [ $KDE = true ]; then
	DATA='PhilleConnectStart \&\nwait $!\n# finally, give the session control to the session manager'
	sudo sed -i "s|# finally, give the session control to the session manager|${DATA}|g" /usr/bin/startkde
fi

read -p "Do you want a desktop icon? [y/n] (default: y)" ICON
if ! [[ $ICON =~ ^[nN] ]]; then
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
			sudo chown "$USER":"$USER" ~/Schreibtisch/PhilleConnectTeacher.desktop
			sudo chmod +x ~/Schreibtisch/PhilleConnectTeacher.desktop
		else
			sudo cp desktop/PhilleConnectDrive.desktop ~/Schreibtisch/
			sudo chown "$USER":"$USER" ~/Schreibtisch/PhilleConnectDrive.desktop
			sudo chmod +x ~/Schreibtisch/PhilleConnectDrive.desktop
		fi
	fi
fi

read -p "Do you want to register this client? [y/n] (default: n)" REGISTER
if [[ $REGISTER =~ ^[yYjJ] ]]; then
	/tmp/ClientRegistrationTool &
	wait $!
	sudo rm /tmp/ClientRegistrationTool
	echo "Installation finished!"
else
	sudo rm /tmp/ClientRegistrationTool
	echo "Installation finished!"
	echo "After the installation, a reboot is required."
	read -p "Do you want to reboot now? [y/n]" REBOOT
	if [[ $REBOOT =~ ^[yYjJ] ]]; then
		echo "I will reboot now..."
		reboot
	fi
fi
