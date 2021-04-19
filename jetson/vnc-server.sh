# Source
# https://forums.developer.nvidia.com/t/how-to-setup-tigervnc-on-jetson-nano/174244

# Install Tiger VNC itself:
apt install tigervnc-standalone-server

#Set a password for VNC. You don’t need a view-only password.
vncpasswd

#Change to the ~/.vnc directory and create your xstartup file:

Add the following contents to your xstartup file where is your home directory name:
printf "!/bin/sh" > ~/.vnc/xstartup
printf "\nexport XDG_RUNTIME_DIR=/run/user/1000" >> ~/.vnc/xstartup
printf "\nexport XKL_XMODMAP_DISABLE=1" >> ~/.vnc/xstartup
printf "\nunset SESSION_MANAGER" >> ~/.vnc/xstartup
printf "\nunset DBUS_SESSION_BUS_ADDRESS" >> ~/.vnc/xstartup
printf "\nxrdb /home/diegx/.Xresources" >> ~/.vnc/xstartup
printf "\nxsetroot -solid grey" >> ~/.vnc/xstartup
printf "\ngnome-session &" >> ~/.vnc/xstartup
printf "\nstartlxde &" >> ~/.vnc/xstartup

chmod 755 ~/.vnc/xstartup

touch /home/diegx/.Xresources

# vncserver@.service
printf "[Unit]" > /etc/systemd/system/vncserver@.service
printf "\nDescription=Start TigerVNC Server at startup" >> /etc/systemd/system/vncserver@.service
printf "\nAfter=syslog.target network.target" >> /etc/systemd/system/vncserver@.service
printf "\n" >> /etc/systemd/system/vncserver@.service
printf "\n[Service]" >> /etc/systemd/system/vncserver@.service
printf "\nType=forking" >> /etc/systemd/system/vncserver@.service
printf "\nUser=diegx" >> /etc/systemd/system/vncserver@.service
printf "\nGroup=diegx" >> /etc/systemd/system/vncserver@.service
printf "\nWorkingDirectory=/home/diegx" >> /etc/systemd/system/vncserver@.service
printf "\nPIDFile=/home/diegx/.vnc/%H:%i.pid" >> /etc/systemd/system/vncserver@.service
printf "\nExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1" >> /etc/systemd/system/vncserver@.service
#printf "\nExecStart=/usr/bin/vncserver :%i -depth 24 -geometry 1920×1080 -nolisten tcp" >> /etc/systemd/system/vncserver@.service
#printf "\nExecStart=/usr/bin/vncserver :%i -depth 24 -geometry 2560×1400 -nolisten tcp" >> /etc/systemd/system/vncserver@.service
printf "\nExecStart=/usr/bin/vncserver :%i -depth 24 -xdisplaydefaults -nolisten tcp" >> /etc/systemd/system/vncserver@.service
printf "\n" >> /etc/systemd/system/vncserver@.service
printf "\nExecStop=/usr/bin/vncserver -kill :%i" >> /etc/systemd/system/vncserver@.service
printf "\n" >> /etc/systemd/system/vncserver@.service
printf "\n[Install]" >> /etc/systemd/system/vncserver@.service
printf "\nWantedBy=multi-user.target" >> /etc/systemd/system/vncserver@.service


# nano /etc/vnc.conf
printf 'localhost = "no";' >> /etc/vnc.conf

# nano /etc/gdm3/custom.conf
printf "AutomaticLoginEnable=true" >> /etc/gdm3/custom.conf
printf "AutomaticLogin=" >> /etc/gdm3/custom.conf


systemctl daemon-reload
systemctl enable vncserver@1
systemctl start vncserver@1