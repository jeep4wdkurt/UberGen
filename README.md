# UberGen LAMP3 System Generation Suite

##	Description
	Sets up a LAMP3(w) Environment by installing and configuring ...
		* Linux
		* Apache
		* MariaDB
		* Perl/Python/PHP
		* WordPress (optional)

	Additionally, UberGen installs...
		* Brave Web Browser
		* FireFox Web Browser
		* UFW Firewall
		* VSFTP Secure FTP
		* VNC
		* OpenSSH
		* OpenSSL
			* Root Certificate Authority (CA)
			* Intermediate Certificate Authority (ICA)
			* OCSP server
			* Certificates and keys for CAs and Servers
		* Utitites...
			* open-vm-tools            Virtualization Tools
			* curl                     HTTP capture
			* net-tools                Network tools (ping, tracert, etc)
			* libnss3-tools            NSS Security Tools (certutil, etc)
			* cifs-utils               Windows file share utilities
			* vim                      Editor
			* zip                      Zip compression utility
			* unzip                    Zip decompression utility
			* p7zip                    Multi-format compression utility
			* inxi                     System information tool
			* htop                     System performance monitor
			* glances                  System performance monitor
			
			* apparmor-easyprof        AppArmor easy profile generation
			* apparmor-notify          AppArmor logged messages information
			* apparmor-utils           AppArmor utilies
			* auditd                   Linux audit daemon

			* graphicsmagick           Graphing tools
			* imagemagick              Image manipulation tools
			* imagemagick-doc          Image manipulation tools docs
			* sox                      Sound Swiss Army Knife
			* gimp                     Interactive Image Manipulator
			* gimp-dcraw (on Ubuntu)   RAW file format module (deprecated)
			* gimp-ufraw (on Debian)   RAW file format module (current)
			* lame                     Audio compression
			* lame-doc                 Audio compression docs
			
			* telegram-desktop         Telegram Messaging application

			* debconf-utils            Debconf Developer Tools
			* debconf-doc              Debconf Developer Docs
			* binutils                 GNU Development Tools
			* info                     GNU Info Documentation Browser
			* git                      Distributed Version Control System
			* notepad-plus-plus        Notepad++
			* openjdk-17-jre           Java Run-time Environment
			* openjdk-17-jdk           Java Development Kit
			* openjdk-17-doc           Java Development Kit Documentation
			* openjdk-17-demo          Java Development Kit Demo Code
			* openjdk-17-dbg           Java Development Kit Debug Symbols
			* openjdk-17-source        Java Development Kit Source Code
			* openjdk-17-source        Java Development Kit Source Code
			* eclipse-ee-2021-12       Eclipse Enterprise Java and Web Development (2021-12)


##	Supported Linux Distros
	Debian 11.x,10.x (xfce,GNOME,kde desktops)
	Ubuntu Workstation 20.x

##	Component Scripts
	build-variables             Driving data
	perl-install                Perl Language and handy libraries
	php-install                 PHP Language and handy libraries
	python-install              Python Language and handy libraries
	prerequisites-install       Prerequisite software
	system-add-users            Add system users, groups, and support scripts
	firewall-install            Firewall (UFW) installation
	openssl-config              OpenSSL certificate generation and configuration
	openssh-install             OpenSSH server install and configuration
	mariadb-install             Database (MariaDB) installation and configuration
	mariadb-add-users           Database users creation
	brave-install               Brave privacy web browser
	libreoffice-install         Libre Office install
	eclipse-install             Eclipse Enterprise Java and Web Development (2021-12) edition install
	vsftp-install               Secure FTP Server (VSFTP) install and configuration
	vnc-install                 TigerVNC Server install and configuration
	wordpress-mariadb-config    WordPresss database configuration
	wordpress-install           WordPresss installation

##	Usage
ubergen.sh [-l] [-v] [-d] [-t] [-u] [-p] [-W]

	Options:
	   -W            Include WordPress installation
	   -u            Unpack UberGen Distribution, Only
	   -p            Prompt for approval between stages
	   -l            Log (displays basic info)
	   -v            Verbose (displays detailed info)
	   -d            Debug (displays more detailed info)
	   -t            Trace (displays exhaustive info)
	   
## Copyright
Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.

## Contact
For licensing and questions, contact Kurt Schulte @ cognogistics-at-gmail-dot-com

