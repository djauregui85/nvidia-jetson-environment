#!/usr/bin/bash

# To avoid conflicts with the static IP added to the DHCP Server that will connect the Jetson Nano and other devices
# Situable for Ubuntu 20.04

nic_internet=wlp3s0
nic=enp0s25
base_ip=10.10.10
ip=$base_ip.1 # static ip for the ethernet adaptor
subnet=$base_ip.0
mask=255.255.255.0
range1=$base_ip.10
range2=$base_ip.20
internet_network=10.40.233.0

# Install DHCP Server
if [ $1 == "install" ] ; then
apt-get install isc-dhcp-server -y
fi

# Overwrite /etc/dhcpd.conf
if [ $1 == "setup" ] ; then
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.example
printf "\noption domain-name-servers 8.8.8.8, 8.8.4.4;" > /etc/dhcp/dhcpd.conf
printf "\noption subnet-mask $mask;" >> /etc/dhcp/dhcpd.conf
printf "\noption routers $ip;" >> /etc/dhcp/dhcpd.conf
printf "\nsubnet $subnet netmask $mask {"  >> /etc/dhcp/dhcpd.conf
printf "\n  range $range1 $range2;"  >> /etc/dhcp/dhcpd.conf
printf "\n}" >> /etc/dhcp/dhcpd.conf
printf "\n# No DHCP service in Wifi network ($internet_network/24)" >> /etc/dhcp/dhcpd.conf
printf "\nsubnet $internet_network netmask $mask {" >> /etc/dhcp/dhcpd.conf
printf "\n}" >> /etc/dhcp/dhcpd.conf
printf "default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
printf "max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
printf 'INTERFACESv4="%s"' $nic >> /etc/dhcp/dhcpd.conf
printf "authoritative;" >> /etc/dhcp/dhcpd.conf

systemctl enable isc-dhcp-server.service
fi

if [ $1 == "up" ] ; then
ip link set up dev $nic
ip addr add $ip/24 dev $nic # arbitrary address
systemctl start isc-dhcp-server.service
# Share internet from another adapter
sysctl net.ipv4.ip_forward=1
iptables --table nat --append POSTROUTING --out-interface $nic_internet -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables --append FORWARD --in-interface $nic -j ACCEPT
fi  

if [ $1 == "down" ] ; then
ip addr del $ip/24 dev $nic
ip link set down dev $nic
systemctl stop isc-dhcp-server.service
fi