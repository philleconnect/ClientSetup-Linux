__Archived: Not actively maintained anymore!__

# ClientSetup-Linux
PhilleConnect Client installer for Linux  
This installer will setup your Linux machine to use it as a Client for PhilleConnect.

# Compatiblity
PhilleConnect Client for Linux currently supports:  
Ubuntu 18.04 LTS (64-Bit)
Kubuntu 18.04 LTS (64-Bit)  

However, it should work on any debian-based linux distribution using GNOME or KDE desktop. Other desktops are not supported at the moment, but feel free to add support for your favorite desktop!

# Requirements
To use this programs you need a working PhilleConnect Server.

# Configuration
The Installer comes with a file called 'pcconfig.jkm'. This is a text file used to configure the client machine. It's recommended to edit this file before you install PhilleConnect, otherwise you have to edit the file on every single machine. There's also a tool to auto-generate this file on the admin-console of your server.
You can configure these values:  

| name                 | values    | description |
| -------------------- | --------- | ----------- |
| server               | string    | IP, IP:Port, Hostname, Hostname:Port of your PhilleConnect Server |
| global               | string    | the installation key of your installation, you will find this in the administration backend |
| allowOffline         | 0 or 1    | 0: will shutdown; 1: will go to the desktop if the server is not available |
| badNetworkReconnect  | integer   | how many times the machine should try to connect to the server |

# Usage
Download this repository and place your pcconfig.jkm inside. Then, run install.sh as the user you want PhilleConnect to be installed. The script needs root access, so keep your root password ready.

# Source code
The source code of all PhilleConnect client applications is a now available on GitHub!
