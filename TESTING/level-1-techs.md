# level 1 techs

Need advice on re-configuring a server with new DAS

**Hardware**:  
Server  
5900x  
[B450 Gigabyte AORUS M](https://www.gigabyte.com/us/Motherboard/B450-AORUS-M-rev-1x) (USB 3.1 Gen2)  
32gb ram  
1tb nvme  
10GbE (10GBASE-T)

Network  
[<span class="a-size-large product-title-word-break" id="bkmrk-trendnet-8-port-10g-">TRENDnet 8-Port 10G Switch</span>](https://www.trendnet.com/store/products/10g-switch/8-port-10g-switch-TEG-S708)

NAS  
[Buffalo TeraStation 51210RH](https://www.buffalo-technology.com/productpage/terastation-51210rn/) (Got it 5 years ago very cheap, it was an amazon return 85% off)  
8TB x 12 RAID6  
10GbE (10GBASE-T)

Currently I run everything on docker using Ubuntu Server 22.04 OS and mount the NAS as SMB in fdisk

After 5 years the TeraStation is running low on space, while looking to add more storage on the cheap I saw the videos on hardware raid's dead and that 10gb USB-C is basically good enough now for storage. So I bought a [Terra-Master D6-320](https://www.terra-master.com/us/d6-320.html) (6-bay USB 3.2 Gen2 10Gbps DAS) after looking around and [seeing](https://www.nikktech.com/main/articles/peripherals/hdd-enclosures/14166-terramaster-d6-320-usb-3-2-hdd-enclosure-review?showall=1) some [reviews](https://www.techradar.com/pro/terramaster-d6-320-6-bay-review) (like [someone ](https://www.youtube.com/watch?v=qML-ct2dGvQ&list=LL&index=1&t=397s)using proxmox and maxing out the connection). I think the following would be my best approach but I've never used Proxmox or ZFS before.

The plan is to install Proxmox on the server that currently just runs docker stuff, and then have a Ubuntu server VM running all that docker stuff. Still connecting to the NAS through VM's fdisk. I've ordered everything (unit &amp; drives) but it will not be here for a few day, I just trying to plan a way through.

Do I tunnel the USB controller in Proxmox to the Ubuntu server VM and figure ZFS in Ubuntu or do I (I think this is possible) create a ZFS pool﹖in Proxmox and give the VM access to it also in Proxmox?

I'm looking for safe / reliable and sorta portable, as in I would like to be able to just plug the USB unit into a different server down line (also running Proxmox) and be able to access all the data for when I upgrade the server in a few years.

So I bought 6 20tb drives for the unit, I would like to use 2 drives as parity, so adding around 80tb of storage to the system. My understanding is it is possible to use that configuration in ZFS I just having looked up how yet.

Am I on the right path, or is there a better way, should TrueNAS be in the mix somehow?