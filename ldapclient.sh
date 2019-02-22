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
#!/bin/bash

if [ -e /etc/ldap.secret]; then

exit 0;

fi
apt-get update
apt-get install -y debconf-utils

#telling DEBIAN not to run autoconfig
export DEBIAN_FRONTEND=noninteractive

#this will install and then unset the variable
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nslcd
unset DEBIAN_FRONTEND

cd ~
#create /tempfile and add 
echo "ldap-auth-config ldap-auth-config/bindpw password
nslcd nslcd/ldap-bindpw password
ldap-auth-config ldap-auth-config/rootbindpw password
ldap-auth-config ldap-auth-config/move-to-debconf boolean true
nslcd nslcd/ldap-sasl-krb5-ccname string /var/run/nslcd/nslcd.tkt
nslcd nslcd/ldap-starttls boolean false
libpam-runtime libpam-runtime/profiles multiselect unix, ldap, systemd, capability
nslcd nslcd/ldap-sasl-authzid string
ldap-auth-config ldap-auth-config/rootbinddn string cn=ldapadm,dc=nti310,dc=local
nslcd nslcd/ldap-uris string ldap://ldapc
nslcd nslcd/ldap-reqcert select
nslcd nslcd/ldap-sasl-secprops string
ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3
ldap-auth-config ldap-auth-config/binddn string cn=proxyuser,dc=example,dc=net
nslcd nslcd/ldap-auth-type select none
nslcd nslcd/ldap-cacertfile string /etc/ssl/certs/ca-certificates.crt
nslcd nslcd/ldap-sasl-realm string
ldap-auth-config ldap-auth-config/dbrootlogin boolean true
ldap-auth-config ldap-auth-config/override boolean true
nslcd nslcd/ldap-base string dc=nti310,dc=local
ldap-auth-config ldap-auth-config/pam_password select md5
nslcd nslcd/ldap-sasl-mech select
nslcd nslcd/ldap-sasl-authcid string
ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=nti310,dc=local
ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldap://ldapc/
nslcd nslcd/ldap-binddn string
ldap-auth-config ldap-auth-config/dblogin boolean false" >> tempfile

#moved everything in tempfile to debconf-set-selections
while read line; do echo "$line" | debconf-set-selections; done < tempfile

echo "ofpcxwW" > /etc/ldap.secret

chown 600 /etc/ldap.secret

sudo auth-client-config -t nss -p lac_ldap

echo "account sufficient pam_succeed_if.so uid = 0 use_uid quiet" >> /etc/pam.d/su

systemctl restart nscd
systemctl enable nscd
