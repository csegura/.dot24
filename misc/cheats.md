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

# Vim

## Movement
```
h        -   Move left
j        -   Move down
k        -   Move up
l        -   Move right
$        -   Move to end of line
0        -   Move to beginning of line (including whitespace)
^        -   Move to first character on line
gg       -   Move to first line of file
G        -   Move to last line of file

w        -   Move forward to next word, with cursor on first character (use W to jump by whitespace only)
b        -   Move backward to next word, with cursor on first character (use B to jump by whitespace only)
e        -   Move forward to next word, with cursor on last character (use E to jump by whitespace only)
ge       -   Move backwards to next word, with cursor on last character (use gE to jump by whitespace only)
(        -   Move to beginning of previous sentence. Use ) to go to next sentence
{        -   Move to beginning of previous paragraph. Use } to go to next paragraph
+        -   Move forward to the first character on the next line
-        -   Move backwards to the first character on the previous line

CTRL+u   -   Move up by half a page
CTRL+d   -   Move down by half a page
CTRL+b   -   Move up by a page
CTRL+f   -   Move down by a page

H        -   Move cursor to header (top) line of current visible window
M        -   Move cursor to middle line of current visible window
L        -   Move cursor to last line of current visible window

fc       -   Move cursor to next occurrence of character c on the current line. Use Fc to move backwards
tc       -   Move cursor till next character c on the current line. Use Tc to move backwards
%        -   Move cursor to next brace, bracket or comment paired to the current cursor location

*        -   Search forward for word under cursor
#        -   Search backwards for word under cursor
/word    -   Search forward for word. Accepts regular expressions to search
?word    -   Search backwards for word. Accepts regular expressions to search
n        -   Repeat the last / or ? command
N        -   Repeat the last / or ? command in the opposite direction
```

## Normal Mode -> Insert Mode
```
i        -   Enter insert mode to the left of the cursor
a        -   Enter insert mode to the right of the cursor
I        -   Enter insert mode at first character of current line
A        -   Enter insert mode at last character of current line

o        -   Insert line below current line and enter insert mode
O        -   Insert line above current line and enter insert mode

cm       -   Delete (change) the character or word (w) in motion m, then enter insert mode
cc       -   Delete current line and enter insert mode (unlike dd which leaves you in normal mode)
C        -   Delete (change) from cursor to end of line, and enter insert mode
```

## Deletion
```
x        -   Delete character forward (under cursor). use x do delete backwards (before cursor)
r        -   Replace single character under cursor, and remain in normal mode
s        -   Delete character under cursor, then switch to insert mode

dm       -   Delete in direction of movement m. For m, you can also use w, b, or any other variation
dd       -   Delete entire current line
D        -   Delete until end of line
```

## Yank & Put
```
y        -   Yank (copy) highlighted text
yy       -   Yank current line
p        -   Put (paste) yanked text below current line
yw       -   Yank a word from the cursor
ynw      -   Yank n words from the cursor
y$       -   Yank till the end of the line
P        -   Put yanked text above current line
J        -   Join current line with the next line. Use gJ to exclude join-position space
xp       -   Transpose two letters (delete and paste, technically)
```

## Visual Mode
```
v        -   Enter visual mode and highlight characters
V        -   Enter visual mode and highlight lines
CTRL+v   -   Enter visual block mode and highlight exactly where the cursor moves
o        -   Switch cursor from first & last character of highlighted block while in visual mode
~        -   Swap case under selection
<<       -   Shift lines to left
>>       -   Shift lines to right

vat      -   Highlight all text up to and including the parent element
vit      -   Highlight all text up to the parent element, excluding the element
vac      -   Highlight all text including the pair marked with c (like va<, va' or va")
vic      -   Highlight all text inside the pair marked with c
```

## Marking
```
ma        -   Set a marker a at cursor position to come back to later
mb        -   Set a marker b at current position
`a        -   Move cursor to exact position of the marker you set with ma
'a        -   Move cursor to the first character of the line marked with ma

d'a       -   Delete from current line to line of mark a
d`a       -   Delete from current cursor position to position of mark a
c'a       -   Change text from current line to line of mark a
y`a       -   Yank text to unnamed buffer from cursor to position of mark a

:marks    -   List all the current marks
:marks ab -   List marks a, b

'a,'bs/test/foo/g - Search and replace test with foo between markers a and b
```

## Folding
```
zf#j      -   creates a fold from the cursor down # lines.
zf/string -   creates a fold from the cursor to string .
v{move}zf -   creates a visual select fold
zf'a      -   creates a fold from cursor to mark a

zo        -   opens a fold at the cursor.
zO        -   opens all folds at the cursor.
za        -   Toggles a fold at the cursor.
zc        -   closes a fold at the cursor.
zM        -   closes all open folds.
zd        -   deletes the fold at the cursor.
zE        -   deletes all folds.

zj        -   moves the cursor to the next fold.
zk        -   moves the cursor to the previous fold.
zm        -   increases the foldlevel by one.
zr        -   decreases the foldlevel by one.
zR        -   decreases the foldlevel to zero -- all folds will be open.
[z        -   move to start of open fold.
]z        -   move to end of open fold.

:set foldmethod=manual         -  default method v{select block}zf to fold
:set foldmethod=marker         -  use marker fold method {{{
:set foldemethod=marker/*,*/   -  user custom marker fold method
:set foldmethod=indent         -  automatically fold programms per its indentation
```

## Miscellaneous
```
u        -   Undo
U        -   Undo all changes on current line
CTRL+R   -   Redo
.        -   Repeat last change or delete
;        -   Repeat last f, t, F, or T command
,        -   Repeat last f, t, F, or T command in opposite direction

g~       -   switch case under cursor
g~$      -   Toggle case of all characters to end of line.
g~~      -   Toggle case of the current line (same as V~).
gUU      -   switch the current line to upper case
guu      -   switch the current line to lower case

CTRL+A   -   Increment the number at cursor
CTRL+X   -   Decrement the number at cursor

vim +10 <file_name>            - opens the file at line 10
vim +/bash cronjob-lab.yml     - opens the file on the first occurence of bash
vim scp://user@host:22/~/file  - Edit a remote file via scp
```

## History/Command Buffer
```
q:              -   list history in command buffer
q/              -   search history in command buffer
CTRL+c CTRL+c   -   close the command buffer
:set list       -   show hidden characters
gg=G            -   Format HTML. Make sure FileType is set to html with :setf html
CTRL+n          -   Scroll down the list of all previously used words
CTRL+p          -   Scroll up the list of all previously used words
```

## Buffers
```
:ls (or :buffers)   -   list / show available buffers
:e filename         -   Edit a file in a new buffer
:bnext (or :bn)     -   go to next buffer
:bprev (of :bp)     -   go to previous buffer
:bdelete (or :bd)   -   unload a buffer (close a file)
:bwipeout (or :bw)  -   unload a buffer and deletes it
:b [N]              -   The number of the buffer you are interested to open
:ball               -   opens up all available buffers in horizontal split window
:vertical ball      -   opens up all available buffers in vertical split window
:q                  -   close the buffer window
:r <file_path>      -   reads a file from the path to the buffer
:r !<command>       -   reads the output of the command into buffer
:.! cat <file_path> -   reads the output of the command into buffer or !! in ex-mode
```

## Tab Views
```
:tabe filename      -   opens the file in newtab
:tabe new           -   open an empty tab
:tabs               -   list opened tabs
:tabc               -   close the active tab
:tabn and tabp      -   Go to next tab or previous tab
:tabfirst           -   Go to the first available tab
:tablast            -   Go to the last available tab
vim -p *.txt        -   open all txt files in tabs
```

## Tab Navigation
```
gt                  -   go to next tab
gT                  -   go to previous tab
{i}gt               -   go to tab in position i
```

## Tab Shortcuts
```
CTRL+W T            -   Break out current window into a new tabview
CTRL+W o            -   Close every window in the current tabview but the current one
CTRL+W n            -   create a new window in the current tabview
CTRL+W c            -   Close current window in the current tabview
```

## Window Management
```
:split filename     -   split screen horizontal
:vs filename        -   split screen vertical
vim -o file1 file2  -   open horizontal splits
vim -O file1 file2  -   open vertical splits
:hide               -   close current window
:resize 20          -   horizontal resize
:vertical resize 20 -   vertical resize

:windo diffthis     -   diff between 2 vsplit windows
:diffs {filename}   -   diffs the current window with the file given
:diffoff            -   turns off diff selection

CTRL+w s       -   Split current window horizontally
CTRL+w v       -   Split current window vertically
CTRL+w c       -   Close current window
CTRL+w o       -   Maximize current window

:Vex           -   Open vertical split in ex mode with file browser
:Sex           -   Open horizontal split in ex mode with file browser
```

## Moving Windows
```
CTRL+W r       -   Swap bottom/top if split horizontally
CTRL+W R       -   Swap top/bottom if split horizontally
CTRL+w H       -   Move current window the far left and use the full height of the screen
CTRL+w J       -   Move current window the far bottom and use the full width of the screen
CTRL+w K       -   Move current window the far top and full width of the screen
CTRL+w L       -   Move current window the far right and full height of the screen
```

## Navigate Between Windows
```
CTRL+w CTRL+w  -   switch between windows
CTRL+w UP      -   Move to the top window from current window
CTRL+w DOWN    -   Move to the bottom window from current window
CTRL+w LEFT    -   Move to the left window from current window
CTRL+w RIGHT   -   Move to the right window from current window
```

## Resizing Windows
```
CTRL+w _       -   Max out the height of the current split
CTRL+w |       -   Max out the width of the current split
CTRL+w =       -   Normalize all split sizes
CTRL+w >       -   Incrementally increase the window to the right
CTRL+w <       -   Incrementally increase the window to the left
CTRL+w -       -   Incrementally decrease the window's height
CTRL+w +       -   Incrementally increase the window's height
```

## Permission Override
```
:w !sudo tee %            -    Override the permission of the written file
:w !sudo sh -c "cat > %"  -             "                            "
```

