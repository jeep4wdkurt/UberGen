#
# build-variables.sh
#
#	UberGen System Confabulation Suite
#   Build Variables Definition Module
#
#	Description:
#
#       Script to define build variable to drive system generation. Note that it's designed to be
#		included in stream via source command, and not shell execution.
#
#	Copyright:
#		Copyright (c) 2021, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.09.28  01.05    KurtSchulte    Add PostgreSQL, db enable/install flags
#       2022.02.22  01.04    KurtSchulte    Add install status tracking, ColumnStore support, move
#                                             non-user params to [core-configureation.sh]
#       2021.01.28  01.03    KurtSchulte    Original Version
#
####################################################################################################

scriptFolder=$(echo "${0%/*}" | sed -e "s~^[.]~`pwd`~")

# Processing Flags
#
ug_verbose=1											# UberGen install log level

ug_apache_log_level='debug'								# Apache log level

#
# Server Info
#
ug_server_name="widgetbox"
ug_server_database="widget"
ug_server_webcore="widget"
ug_server_domain="widgetcorp.com"
ug_server_desc="Widgets Corp Demo System"

ug_org_name="Widgets Corporation International"
ug_org_country="US"
ug_org_state="Michigan"
ug_org_locality="Widgetville"
ug_org_organization="Widgets Corporate Systems"
ug_org_unit="Widgets Technology Group"
ug_org_email="widget.corp.international@gmail.com"
ug_org_abbr="widget"

#
# Package Install Control
#
ug_mariadb_install=True                                 # Install MariaDB (True/False)
ug_mariadb_column_store_install=True                    # Install MariaDB Column Store Engine (True/False)
ug_postgresql_install=True                              # Install PostgreSQL (True/False)
ug_wordpress_install=True                               # Install WordPress (True/False)
ug_wordpress_engine=mariadb                             # WordPress Database Engine (mariadb/postgresql)

#
# Package System Startup Control
#
ug_ftps_enable=True                                     # Enable Secure FTP system startup (True/False)
ug_ssh_enable=True                                      # Enable Secure Shell (SSH) system startup (True/False)
ug_mariadb_enable=True                                  # Enable MariaDB system startup (True/False)
ug_postgresql_enable=False                              # Enable PostgreSQL system startup (True/False)

#
# Ports
#
ug_ftps_port=3321                                       # Secure FTP command port
ug_ftps_data_port=3320                                  # Secure FTP data port
ug_ssh_port=3322                                        # Secure Shell port
ug_ocsp_port=3381                                       # OCSP port
ug_mariadb_port=3369                                    # MariaDB Database port
ug_mariadb_cross_engine_port=3370                       # MariaDB Cross Engine Port
ug_postgresql_port=3380                                 # PostgreSQL Database Port

#
# Hosts
#
ug_db_cross_engine_host=127.0.0.1                       #  MariaDB Cross Engine Host

#
# SSL
# 
ug_certs_owner=root                                     # PKI Certs security owner
ug_certs_group=ssl-cert                                 # PKI Certs security group
ug_certs_servers=crl,ocsp,ica,ca                        # PKI stack server list
																		
ug_cert_encrypt_curve="secp384r1"                       # Encryption curve to use
ug_cert_life_ca=3650                                    # Certificate CA life span
ug_cert_life_server=364                                 # Server certificate life span. 1 year is max per casecurity.org

ug_cert_root_pass_phrase='<generate>'                   # Root Certificate pass phrase (generate a random one)
ug_cert_int_pass_phrase='Y4bbaD4bbaD00#K00K00K4ch00!'   # Intermediate CA Cert pass phrase
ug_cert_ocsp_pass_phrase=""                             # OCSP Cert pass phrase (blank for none)

#
# SSL Servers <node>;<type>;<shortdesc>;<desc>;<owner>;<group>;<prot>;<ipaddr>
#
ug_server_ca_data="ca;root;Root CA;Root Certificate Authority;${ug_certs_owner};${ug_certs_group};755;127.0.0.1"
ug_server_ica_data="ica;sign;Intermediate CA;Intermediate Certificate Authority;${ug_certs_owner};${ug_certs_group};755;127.0.0.1"
ug_server_ocsp_data="ocsp;sign;OCSP Server;On-line Certificate Status Server;${ug_certs_owner};${ug_certs_group};755;127.0.0.1"
ug_server_crl_data="crl;crl;CRL Server;Certificate Revokation List Server;${ug_certs_owner};${ug_certs_group};755;127.0.0.1"

#
# Groups
#
ug_sysgrp_system="wcisys"                               # System level users
ug_sysgrp_admin="wciadmins"                             # Administrators and super users
ug_sysgrp_dev="wcidev"                                  # Developers
ug_sysgrp_web="www-data"                                # Web Applications
ug_sysgrp_db="db-data"									# Database

#
# Users
#	System User Data Format:
#		ug_sysuser_<userid>_data = "<username>:<userdesc>:<usergroups>:<userpass>"
#		<usergroups> is a comma separated list
#
ug_sysuser_list=sysroot,sysadmin,sysdev1,sysapp

ug_sysuser_sysroot_name=wciroot
ug_sysuser_sysroot_desc="Widgets Corp Inc Demo Server Root"
ug_sysuser_sysroot_groups=${ug_sysgrp_system}:${ug_sysgrp_admin}:${ug_sysgrp_dev}:${ug_sysgrp_web}:SYSTEM:SUDO
ug_sysuser_sysroot_pass="wci9root"
ug_sysuser_sysroot_data="${ug_sysuser_sysroot_name};${ug_sysuser_sysroot_desc};${ug_sysuser_sysroot_groups};${ug_sysuser_sysroot_pass}"

ug_sysuser_sysadmin_name=wciadmin
ug_sysuser_sysadmin_desc="Widgets Corp Inc Demo Server Administrator"
ug_sysuser_sysadmin_groups=${ug_sysgrp_admin}:${ug_sysgrp_web}
ug_sysuser_sysadmin_pass="wci9admin"
ug_sysuser_sysadmin_data="${ug_sysuser_sysadmin_name};${ug_sysuser_sysadmin_desc};${ug_sysuser_sysadmin_groups};${ug_sysuser_sysadmin_pass}"

ug_sysuser_sysdev1_name=wcidev1
ug_sysuser_sysdev1_desc="Widgets Corp Inc Demo Server Development"
ug_sysuser_sysdev1_groups=${ug_sysgrp_dev}:${ug_sysgrp_web}
ug_sysuser_sysdev1_pass="wci9dev1"
ug_sysuser_sysdev1_data="${ug_sysuser_sysdev1_name};${ug_sysuser_sysdev1_desc};${ug_sysuser_sysdev1_groups};${ug_sysuser_sysdev1_pass}"

ug_sysuser_sysapp_name=wciapp
ug_sysuser_sysapp_desc="Widgets Corp Inc Demo Server Application"
ug_sysuser_sysapp_groups=${ug_sysgrp_web}
ug_sysuser_sysapp_pass="wci9app"
ug_sysuser_sysapp_data="${ug_sysuser_sysapp_name};${ug_sysuser_sysapp_desc};${ug_sysuser_sysapp_groups};${ug_sysuser_sysapp_pass}"

ug_sysuser_postgresql_name=postgresql
ug_sysuser_postgresql_desc="PostgreSQL system account"
ug_sysuser_postgresql_groups="${ug_sysgrp_db}"
ug_sysuser_postgresql_pass="wciroot"
ug_sysuser_postgresql_data="${ug_sysuser_postgresql_name};${ug_sysuser_postgresql_desc};${ug_sysuser_postgresql_groups};${ug_sysuser_postgresql_pass}"


#
# Stack Info
#
ug_stack_regions="prod,mod,dev"                         # Production, Model, and Development regions

# Server data
#	Server data format:
#		ug_server_<env>_data = <hostname>;<type>;<short_desc>;<desc>;<owner_user>;<owner_group>;<prot_mask>;<ip_addr>;<engine>;<dbname>;<webcore>
#
ug_server_prod_data="${ug_server_name};app;Production;Production Server;${ug_sysuser_sysroot_name};${ug_sysgrp_web};755;127.0.0.1;${ug_wordpress_database};${ug_server_database};${ug_server_webcore}"
ug_server_mod_data="mod.${ug_server_name};app;Model;Model Server;${ug_sysuser_sysroot_name};${ug_sysgrp_web};755;127.0.0.1;${ug_wordpress_database};${ug_server_database}mod;${ug_server_webcore}mod"
ug_server_dev_data="dev.${ug_server_name};app;Development;Development Server;${ug_sysuser_sysroot_name};${ug_sysgrp_web};755;127.0.0.1;${ug_wordpress_database};${ug_server_database}dev;${ug_server_webcore}dev"

#
# Client Info
#
ug_client_list="animal"									# Clients to generate certs for

# Client data
#	Client data format:
#		ug_server_<env>_data = <hostname>;<type>;<short_desc>;<desc>;<owner_user>;<owner_group>;<prot_mask>;<ip_addr>
ug_client_animal_data="animal;client;Animal;Animal Workstation;${ug_sysuser_sysroot_name};${ug_sysgrp_admin};755;127.0.0.1"

#
# Database Cross Engine User (db-only)
# 
ug_db_cross_engine_user=dbcrosseng                      # MariaDB Cross-Engine user
ug_db_cross_engine_pass="wc1^eng1n3"                    # MariaDB Cross-Engine password

#
# Database Users (mirrors of system users)
#	DB User Data Format:
# 		ug_dbuser_<userid>_data = "<user-name>;<user-password>;<region-role-list>;<host-list>"
#		region-role-list is a comma separated list of <region>:<role> pairs.
#
ug_db_install_user_name=root                            # User ID to do WordPress DB setup
ug_db_install_user_pass="wciroot"                       # User Password to do WordPress DB setup
ug_db_root_remote=                                      # Enable/disable root remote login
ug_db_colocated=1                                       # Databases are server co-located flag (users are same all regions)

ug_dbuser_list=sysroot,sysadmin,sysdev1,sysapp          # List of Database User IDs. One section of detail below for each.

# database root user
ug_dbuser_root_name=root
ug_dbuser_root_pass="wciroot"
ug_dbuser_root_hosts="localhost"
if [ $ug_db_root_remote ] ; then
	ug_dbuser_root_hosts="localhost,%.${ug_server_domain}"
	ug_dbuser_list="${ug_dbuser_list},root"
fi
ug_dbuser_root_region_roles="prod:sys,mod:sys,dev:sys"
ug_dbuser_root_data="root;${ug_dbuser_root_pass};${ug_dbuser_root_region_roles};${ug_dbuser_root_hosts}"

# database wci application root
ug_dbuser_sysroot_name=wciroot
ug_dbuser_sysroot_pass="${ug_sysuser_sysroot_pass}"
ug_dbuser_sysroot_region_roles="prod:sys,mod:sys,dev:sys"
ug_dbuser_sysroot_hosts="localhost"
ug_dbuser_sysroot_data="${ug_dbuser_sysroot_name};${ug_dbuser_sysroot_pass};${ug_dbuser_sysroot_region_roles};${ug_dbuser_sysroot_hosts}"

# database wci application Administrator
ug_dbuser_sysadmin_name=wciadmin
ug_dbuser_sysadmin_pass="${ug_sysuser_sysadmin_pass}"
ug_dbuser_sysadmin_region_roles="prod:user,mod:app,dev:app"
ug_dbuser_sysadmin_hosts="localhost,%.${ug_server_domain}"
ug_dbuser_sysadmin_data="${ug_dbuser_sysadmin_name};${ug_dbuser_sysadmin_pass};${ug_dbuser_sysadmin_region_roles};${ug_dbuser_sysadmin_hosts}"

# database wci application Developer 1
ug_dbuser_sysdev1_name=wcidev1
ug_dbuser_sysdev1_pass="${ug_sysuser_sysdev1_pass}"
ug_dbuser_sysdev1_region_roles="prod:user,mod:user,dev:sys"
ug_dbuser_sysdev1_hosts="localhost,%.${ug_server_domain}"
ug_dbuser_sysdev1_data="${ug_dbuser_sysdev1_name};${ug_dbuser_sysdev1_pass};${ug_dbuser_sysdev1_region_roles};${ug_dbuser_sysdev1_hosts}"

# database wci application Application User
ug_dbuser_sysapp_name=wciapp
ug_dbuser_sysapp_pass="${ug_sysuser_sysapp_pass}"
ug_dbuser_sysapp_region_roles="prod:app,mod:app,dev:app"
ug_dbuser_sysapp_hosts="localhost,%.${ug_server_domain}"
ug_dbuser_sysapp_data="${ug_dbuser_sysapp_name};${ug_dbuser_sysapp_pass};${ug_dbuser_sysapp_region_roles};${ug_dbuser_sysapp_hosts}"

# Database Roles
#
#	Defines the privileges for database, tables, functions and procedures for roles.
#
#	System	- full access
#   Dev 	- access to deploy code
#   App 	- access to read and write data
#   User 	- access to read data
#
ug_dbrole_list="sys,dev,app,user"

ug_dbrole_sys_db_privs="ALL PRIVILEGES,GRANT OPTION"
ug_dbrole_dev_db_privs="CREATE ROUTINE,CREATE TEMPORARY TABLES,GRANT OPTION"
ug_dbrole_app_db_privs="CREATE ROUTINE,CREATE TEMPORARY TABLES"
ug_dbrole_user_db_privs=""

ug_dbrole_sys_table_privs="ALL PRIVILEGES,GRANT OPTION"
ug_dbrole_dev_table_privs="ALTER,CREATE,DELETE,DROP,INDEX,INSERT,UPDATE,SELECT"
ug_dbrole_app_table_privs="ALTER,CREATE,DELETE,DROP,INDEX,INSERT,UPDATE,SELECT"
ug_dbrole_user_table_privs="SELECT"

ug_dbrole_sys_function_privs="ALTER ROUTINE,EXECUTE,GRANT OPTION"
ug_dbrole_dev_function_privs="ALTER ROUTINE,EXECUTE,GRANT OPTION"
ug_dbrole_app_function_privs="EXECUTE"
ug_dbrole_user_function_privs=""

ug_dbrole_sys_procedure_privs="ALTER ROUTINE,EXECUTE,GRANT OPTION"
ug_dbrole_dev_procedure_privs="ALTER ROUTINE,EXECUTE,GRANT OPTION"
ug_dbrole_app_procedure_privs="EXECUTE"
ug_dbrole_user_procedure_privs=""

#
# Remote Desktop (TigerVNC)
#
ug_display_geometry="1920x1080"							#Display Geometry
ug_remote_users="sysroot,sysadmin,sysdev1"