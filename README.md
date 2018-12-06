# LEO1-2018-Portfolio-Two
Group 23 - G23

## Implementation
The first step was to install the container software
```
sudo apt-get install lxc
sudo apt-get install dnsmasq-base
```

Second step we added a new user to create the new unprivileged container
```
sudo useradd con
```

Then we edited the users permissions subuid to 100000:65536 and subgid to 100000:65536
This was done using nano
```
sudo nano /etc/subuid
sudo nano /etc/subgid
```

Next we created a default config for lxc and for the con user in /home/con/.config/lxc/default.conf
```
lxc.id_map = u 0 100000 65536
lxc.id_map = g 0 100000 65536
lxc.network.type = veth
LXC_DHCP_CONFILE=/etc/lxc/dhcp.conf
lxc.network.link = lxcbr0
```

We then logged in as the con user and added the two new containers
```
lxc-create -n C1 -t download -- -d alpine -r 3.4 -a armhf
lxc-create -n C2 -t download -- -d alpine -r 3.4 -a armhf
```

We used lxc-attach to login to container C2 and add the script rng.sh to /bin/. We then installed socat to serve the script to port 8080
```
apt add socat
```

start script by the following command
```
socat -v -v tcp-listen:8080,fork,reuseaddr exec:/bin/rng.sh
```

We then logged into container C1 and install lighttpd with php
```
apk add lighttpd php5 php5-cgi php5-curl php5-fpm
```

We then edited the config file to allow for cgi call in php.
Add index.php to /var/www/localhost/htdocs/index.php and started lighttpd
```
/etc/init.d/lighttpd start
```

Now we create a bridge to the containers by editing the default config file found at /etc/lxc/default.conf
```
lxc.network.type = veth
lxc.network.link = lxcbr0
lxc.network.flags = up
lxc.network.hwaddr = 00:16:3e:xx:xx:xx
```

Set lxc-net to use the bridge in config file /etc/default/lxc-net
```
USE_LXC_BRIDGE="true"
```

Now we restart lxc-net.
We can now test the two containers by using curla dn lxc-ls -f.
lxc-ls will display the ip's of the containers and curl can be used to fetch the http site and the bash script.

We can now redirect a request to the pi to the container by using the bridge we created.
```
sudo iptables -t nat -A PREROUTING -i usb0 -p tcp --dport 80 -j DNAT --to-destination 10.0.3.10:80
```

We can now connect to the device using a browser http://raspberrypi.local

List of commands for debugging
```
lxc-ls -f
lxc-attach -n <name of container>
iptables -L -n -t nat
curl <ipv4 of a container/raspberrypi>
```