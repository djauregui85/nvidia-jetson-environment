#!/usr/bin/bash

# To avoid conflicts with the static IP added to the DHCP Server that will connect the Jetson Nano and other devices
# First, had disable the dhcpcd for all the interface. Only use it your internet interface.
# other option, add this line to the dhcpcd:
# denyinterfaces enp57s0u2

nic_internet=wlp2s0
nic=enp57s0u2
base_ip=10.10.10
ip=$base_ip.1 # static ip for the ethernet adaptor
subnet=$base_ip.0
mask=255.255.255.0
range1=$base_ip.10
range2=$base_ip.20
internet_network=10.40.233.0

if [ $1 == "up" ] ; then
ip link set up dev $nic
ip addr add $ip/24 dev $nic # arbitrary address
systemctl start dhcpd4@$nic.service

sysctl net.ipv4.ip_forward=1
iptables --table nat --append POSTROUTING --out-interface $nic_internet -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables --append FORWARD --in-interface $nic -j ACCEPT
fi  

# Overwrite /etc/dhcpd.conf
if [ $1 == "setup" ] ; then
printf "\noption domain-name-servers 8.8.8.8, 8.8.4.4;" > /etc/dhcpd.conf
printf "\noption subnet-mask $mask;" >> /etc/dhcpd.conf
printf "\noption routers $ip;" >> /etc/dhcpd.conf
printf "\nsubnet $subnet netmask $mask {"  >> /etc/dhcpd.conf
printf "\n  range $range1 $range2;"  >> /etc/dhcpd.conf
printf "\n}" >> /etc/dhcpd.conf
printf "\n# No DHCP service in Revere network (192.168.0.0/24)" >> /etc/dhcpd.conf
printf "\nsubnet $internet_network netmask $mask {" >> /etc/dhcpd.conf
printf "\n}" >> /etc/dhcpd.conf
fi

if [ $1 == "down" ] ; then
ip addr del $ip/24 dev $nic # arbitrary address
ip link set down dev $nic
systemctl stop dhcpd4@$nic.service
fi

