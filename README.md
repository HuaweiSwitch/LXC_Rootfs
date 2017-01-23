# Root filesystem building guide
----
### What do you need for building a rootfs file?

A server which operation system is Ubuntu 14.04 or Debian 8.  

### How to build a rootfs file in a server?

* Get a LXC_Rootfs directory with a shell script by git command.    
	`git clone https://github.com/HuaweiSwitch/LXC_Rootfs.git`
* Add permission for the LXC_Rootfs directory.    
	`chmod 777 -R LXC_Rootfs/`
* Configure repo and source of apt-get before building process.     
	`apt-get update`
* Install docker by install the docker-io package in server.    
	`apt-get install -y docker.io`  
* Add the docker package links.   
	`ln -sf /usr/bin/docker.io /usr/local/bin/docker` 
* Pull the specific image from a docker registry server, for example:1587/osc-builder.   
	`docker pull 1587/osc-builder`
* Launch a container which build by the image.    
	`sudo docker run -v ~/LXC_Rootfs:/data -v /dev:/dev -v /lib/modules/:/lib/modules/ --add-host='osc:127.0.0.1' --privileged -i -t  1587/osc-builder:latest /bin/bash`
* Enter into the /data/ directory and execute the shell script with the parameter to make file system folder.    
	`cd /data`    
	`./create_rootfs.sh {powerpc|armel}`　(PS: The passwd for osc-builder is osc-buidler.)
* Install qemu and qemu-user-static package.     
	`apt-get install qemu qemu-user-static`
* Install squashfs-tools package in server.    
	`apt-get install squashfs-tools`   
* Create root file system into a rootfs file with sqfs format.    
	`mksquashfs rootfs/ rootfs.sqfs` 
	(PS: If the "armel" has been selected as a parameter, the command should be executed:`chmod 100000:100000 -R rootfs/`.)

### How to start a lxc container with rootfs file in CE switch?

* Transfer the rootfs file to CE switch.    
	`using ftp tools to transfer rootfs.sqfs from local computer to CE switch.`　　
* Load the lxc firmware with command.    
	`bash shell rootfs.sqfs`　　
* Enter the container with command.    
	`bash`
* Exit from the container.    
	`Ctrl + a  q`　　
* Unable the container with command.    
	`undo bash shell rootfs.sqfs`

### Q&A

* When you set or change your password for user in linux container with the armel rootfs, you may meet error information as below:
	`passwd: System error`
	`passwd: password unchanged`

To solve this problem, you should compile the passwd ball in armel cross compile tool again with "--without-libpam" and "--without-audit", which will be installed in linux container. 

### References

[1] For docker instruction:  [https://opensource.com/recources/what-docker](https://opensource.com/recources/what-docker)
     
[2] For docker details:  [https://www.docker.com](https://www.docker.com)

