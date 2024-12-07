# dpkg

alias pkg_content = "dpkg -L"
alias wifi="nmcli radio wifi"

# console fonts

Discover available fonts in /usr/share/consolefonts. Set and display a font (example: Lat15-Terminus20x10) for the current session ...
```
$ sudo setfont Lat15-Terminus20x10
$ sudo showconsolefont
```
To make the selection persistent, either modify /etc/default/console-setup or run ...
```
$ sudo dpkg-reconfigure console-setup
$ sudo setupcon
```

# keyboard 

$ sudo dpkg-reconfigure keyboard-configuration

Enable use of desired keymap when entering LUKS passphrase in GRUB by rebuilding initramfs ...

$ sudo update-initramfs -u -k all

# wifi

wireless-tools install: iwconfig, iwlist
network-manager install: nmcli, nmtui

# dhcpcd.conf

```
interface wlan0
static ip_address=192.168.1.113/24
static routers=192.168.1.1
static domain_name_servers=1.1.1.1 8.8.8.8
```

# NetworkManager
```
sudo apt install wireless-tools network-manager

dpkg -L wireless-tools (list package content)
dpkg -L network-manager (list package content)

nmcli radio wifi off
nmcli radio wifi on

nmcli device status

nmtui static ip

[ipv4]
address1=192.168.1.25/24,192.168.1.1
dns=192.168.1.1;
dns-search=
method=manual
```

# Network & Wifi

sudo apt install network-manager
edit /etc/network/interfaces
```
allow-hotplug enp2s0f0
iface enp2s0f0 inet static
  address 192.168.1.107
  netmask 255.255.255.0
  gateway 192.168.1.1

auto wlp3s0b1
iface wlp3s0b1 inet static 
  address 192.168.1.108
  netmask 255.255.255.0
  gateway 192.168.1.1
	wpa-ssid csswifiz
	wpa-psk XXXXXXXX 

```
Network interfaces are configured for the ifup and ifdown commands in /etc/network/interfaces.

By default, wired (ethernet) interfaces are configured for auto-detection and to use DHCP.

check /etc/dnsresolv.conf for DNS

# The primary network interface

```
allow-hotplug enp0s31f6
iface enp0s31f6 inet dhcp
Example entry for wireless ...

auto wlp61s0
allow-hotplug wlp61s0
iface wlp61s0 inet dhcp
  wpa-ssid <wifi_access_point_name>
  wpa-psk  <wifi_passphrase>
```

# sysctl

To allow users to read the kernel log, modify /etc/sysctl.conf by adding ...

kernel.dmesg_restrict = 0
Reload the configuration ...

$ sudo sysctl -p

Failed systemd services ...

$ sudo systemctl --failed

High priority errors in the systemd journal ...

$ sudo journalctl -p 3 -xb

# sysctl - docker to internet

# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
net.ipv6.conf.all.forwarding=1


# sudo

To allow user foo to execute superuser commands without being prompted for a password, create the file /etc/sudoers.d/sudoer_foo containing ...

foo ALL=(ALL) NOPASSWD: ALL

# microcode

Update 
$ sudo apt install intel-microcode

# wayland/sway

https://www.dwarmstrong.org/sway/

# Serial
```
sudo chmod a+rw /dev/ttyUSB0    # permissions
sudo pkill -p /dev/ttyUSB0      # kill connections  
sudo minicom -D /dev/ttyUSB0 -l -b 38400 -c

sudo screen /dev/ttyUSB0 115200
screen exit ctrl+a follow  k and y
telnet commad ctrl+5

- setserial package
- sudo setserial -g /dev/ttyS[0123]
```
Check:
- [BootTerm](https://github.com/wtarreau/bootterm)
- [TIO](https://github.com/tio/tio)
º

# Write raspberry image to sd card
```
xzcat ./Downloads/2023-12-05-raspios-bullseye-armhf-lite.img.xz | sudo dd of=/dev/sda bs=4M oflag=dsync status=progress
```

# Raspberry pi - rs 232 info

[Info about uarts]
(https://di-marco.net/blog/it/2020-06-06-raspberry_pi_3_4_and_0_w_serial_port_usage/).

# List manually installed packages

```
apt list --installed | grep  '\[instalado\]'

zgrep -hE '^(Start-Date:|Commandline:)' $(ls -tr /var/log/apt/history.log*.gz ) | egrep -v 'aptdaemon|upgrade' | egrep -B1 '^Commandline:'
```

# User permission to serial port

```
sudo usermod -a -G dialout $USER

```
# NTFS
```
# show partitions
sudo parted -l 
# install driver
sudo apt install ntfs-3g
# mount disk
sudo mount /mnt/ntfs /dev/disk

sudo mkdir /mnt/romheat
sudo mount /dev/sdb1 /mnt/romheat
sudo chgrp romheat /mnt/romheat 
sudo chmod g+w /mnt/romheat
```

# CDROM
```
# intall cd-info tools 
# cd-drive
# cd-info
# cd-paranoia
# cd-read
# cdda-player
# iso-info
# iso-read
# mmc-tool

sudo pat install libcdio-utils 
```

# Reading vmdk files on linux
```
sudo apt install libguestfs-tools
# To see what filesystems are in the .vmdk use virt-filesystems like this:
$ virt-filesystems -a vm_0-flat.vmdk

/dev/sda1
/dev/vm-vg/root

# To mount the filesystem use guestmount like this:

$ guestmount -a vm_0.flat.vmdk -m /dev/vm-vg/root --ro /mnt
$ guestunmount /mnt

```

# Dealing CDROMs - DVDs

Anyway, leaving the filing issues behind, here's an example of trying to mount the ISO:

```
$ sudo mount -o ro,loop -t iso9660 nero.iso /mnt
mount: /mnt: wrong fs type, bad option, bad superblock on /dev/loop0, missing codepage or helper program, or other error.
```

I called the ISO nero.iso because using the file command revealed the ISO is an artifact of the "Nero" CD Burning software, not that that helps any:

```
$ sudo file nero.iso
nero.iso: Nero CD image at 0x4B000 UDF filesystem data (version 1.5) 'nero'
```

After trying a few different things I came across a reference to the software iat which says it "converts many CD-ROM image formats to iso9660". Woah. It immediately, and effortlessly, works:

```
$ sudo apt install iat
$ man iat
$ iat nero.iso out.iso
Iso9660 Analyzer Tool v0.1.3 by Salvatore Santagati
Licensed under GPL v2 or later

Detect Signature ISO9660 START at 339968
Detect Signature ISO9660 END at 342016

 Image offset start at 307200
 Sector header 0 bit
 Sector ECC 0 bit
 Block 2048
Done
```

Really? Now the mount command silently completes:

```
$ sudo mount -o ro,loop out.iso /mnt
```

And, Behold, the ISO is mounted, and Handbrake will now happily rip the content.

# wodim 
```
romheat@sputnik ~% wodim --devices                                               0s 
wodim: Overview of accessible drives (1 found) :
-------------------------------------------------------------------------
 0  dev='/dev/sg0'  rwrw-- : 'HL-DT-ST' 'DVDRAM GT33N'
-------------------------------------------------------------------------
 sudo wodim -eject -tao speed=0 dev=/dev/sg0 -v -data ~/Downloads/Mac\ OS\ X\ Install\ DVD.iso 
```

# Wireguard

config file in /etc/wireguard

```
sudo wg-quick up wg0
```

# Screenrecording

flameshot

