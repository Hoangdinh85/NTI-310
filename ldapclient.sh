#!/bin/bash
#install the necessary packages
sudo apt update && sudo apt install -y libnss-ldap libpam-ldap ldap-utils nscd


#to run the NSS(name server switch)
sudo auth-client-config -t nss -p lac_ldap

#LDAP authentication updating PAM configurations
#sudo pam-auth-update

#add this line into /etc/pam.d/su 
echo "account sufficient pam_succeed_if.so uid = 0 use_uid quiet"

#edit the file /etc/ldap/ldap.conf
#BASE    dc=nti310,dc=local
#URI     ldap://ldapc

#restart and enable the nscd
systemctl restart nscd
systemctl enable nscd

apt-get install debconf-utils


##root@client-b:/home/hdinh47056# debconf-get-selections | grep ^ldap
ldap-auth-config        ldap-auth-config/bindpw password
ldap-auth-config        ldap-auth-config/rootbindpw     password
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://ldapc/
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=ldapadm,dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
ldap-auth-config        ldap-auth-config/dblogin        boolean false

##root@client-b:/home/hdinh47056# debconf-get-selections | grep ldap
ldap-auth-config        ldap-auth-config/bindpw password
ldap-auth-config        ldap-auth-config/rootbindpw     password
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://ldapc/
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=ldapadm,dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/dblogin        boolean false
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
libpam-runtime  libpam-runtime/profiles multiselect     unix, ldap, systemd, capability
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net



#automation
apt-get update
apt-get install -y debconf-utils

#telling DEBIAN not to run autoconfig
export DEBIAN_FRONTEND=noninteractive

#this will install and then unset the variable
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nslcd
unset DEBIAN_FRONTEND

cd ~
#create /tempfile and add 
ehco ldap-auth-config        ldap-auth-config/bindpw password
ldap-auth-config        ldap-auth-config/rootbindpw     password
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://ldapc/
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=ldapadm,dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/dblogin        boolean false
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
libpam-runtime  libpam-runtime/profiles multiselect     unix, ldap, systemd, capability
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net >>/tempfile

#moved everything in tempfile to debconf-set-selections
while read line; do echo "$line" | debconf-set-selections; done < /tempfile

