Rootfs file system building guide
====
What do you need for building a rootfs file?
----
A server which operation system is Ubuntu 14.04 or Debian 8.
How to build a rootfs file in a server?
----
* Configure repo and source of apt-get before building process.

  `Apt-get update`

* Install docker by install the docker-io package in server .

  `Apt-get install -y docker.io`
 
* Add the docker package links . 

  `Ln -sf /usr/bin/docker.io /usr/local/bin/docker`
　　　
* Pull the specific image of docker which targeted .

  `Docker pull 1587/osc-builder`
　　　
* Launch a container which build by the image .

  `sudo docker run -v ~:/data -v /dev:/dev -v /lib/modules/:/lib/modules/ 	--add-host='makyo:127.0.0.1' --privileged -i -t  1587/osc-builder:latest /bin/bash`

* Install qemu and qemu-user-static package .      
　　　
  `apt-get install qemu qemu-user-static`
　　　
* Execute the shell script to make file system folder.
　　　
  `Sh create_rootfs.sh`
　　　
* Install squashfs-tools package in server .

  `Apt-get intall squashfs-tools`

* Create rootfs file .

  `mksquashfs ~/docker_data/powerpc-rootfs/ rootfs.sqfs`

How to start a lxc container with rootfs file in CE switch?
----
* Transfer the rootfs file to CE switch .
　　　
  `Using ftp tools to transfer rootfs.sqfs from local computers.`
　　　
* Load the lxc firmware with command.
　　　
  `Bash shell rootfs.sqfs`
　　　
* Enter the container with command .  
　　　
  `Bash`
  Ps:default user name and password is root/root.
　　　
* Exit from the container .
　　　
  Ctrl a+q
　　　
* Unable the container with command.

  `Undo bash shell rootfs.sqfs`
　　　
References
----
  [1] For docker instruction:
     < https://opensource.com/recources/what-docker>
　　
  [2] For docker details:
     < https://www.docker.com>
　　
