#!/bin/bash
arc=$(uname -a)
pcpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)
fram=$(free -m | awk '$1 == "Mem:" {print $2}')
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
pram=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
fdisk=$(df -H /home/ --output=avail | grep "[0-9]")
udisk=$(df -m /home/ --output=used | grep "[0-9]")
pdisk=$(df /home/ --output=pcent | grep "[0-9]")
cpul=$(top -bn1 | grep '^%Cpu' | cut -c 10- | xargs | awk '{printf("%.1f%%", $1 + $3)}')
lb=$(who -b | awk '$1 == "system" {print $3 " " $4}')
lvmt=$(lsblk | grep "lvm" |wc -l)
lvmu=$(if [ $lvmt -eq 0 ]; then echo no; else echo yes; fi)
#You need to install net tools for the next step [$ sudo apt install net-tools]
ctcp=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')
ulog=$(users | wc -w)
ip=$(hostname -I)
mac=$(ip link show | awk '$1 == "link/ether" {print $2}')
cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l) # journalctl should be running as sudo but our script is running as root so we don't need in sudo here
{
echo "	#Architecture: $arc"
echo "	#CPU physical: $pcpu"
echo "	#vCPU: $vcpu"
echo "	#Memory Usage: $uram/$fram"MB" ($pram%)"
echo "	#Disk Usage: $udisk/${fdisk//[[:blank:]]/}"b" (${pdisk//[[:blank:]]/})" # ${var//[[:blank:]]/} to remove tabs and spaces from variable output. Try to remove this and see how ugly is it.
echo "	#CPU load: $cpul"
echo "	#Last boot: $lb"
echo "	#LVM use: $lvmu"
echo "	#Connexions TCP: $ctcp ESTABLISHED"
echo "	#User log: $ulog"
echo "	#Network: IP $ip ($mac)"
echo "	Sudo: $cmds cmd"
} > >(tee log) 2>&1 # {...} > >(tee log) 2>&1 to make output in log file
wall log # broadcast our system information on all terminals
