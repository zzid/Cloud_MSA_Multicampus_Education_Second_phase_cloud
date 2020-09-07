# Second phase of the education program

Teacher's Doc - https://bit.ly/2YsxwEl

## Linux( Ubuntu )
<pre>

<em>< 2020.09.06 ></em>

Concept
** Linux kernel >> Linux distribution(배포판) - Debian, Ubuntu
<a href="https://github.com/torvalds/linux">** Linux Kernel Source</a>

Virtual Box
* GNU, GPL, FSF

- Network (Pictures are in the doc)
    * NAT (Network Address Translation)
        - 내부 망에서는 사설 IP 주소를 사용하여 통신을 하고, 외부망과의 통신시에는 NAT를 거쳐 공인 IP 주소로 자동 변환
    ** NAT network ( slight different with above one )
    * Bridge adapter
    * Host-only adapter
    * Internal network

- Snapshot
    * it's like take a picture of the one state

(To do below, Should install extension in advance)
- Something between Host and Guest 
    * set "drag and drop"
    * set "share clipboard"
    * set " 'Share' folder "

- Termianl
    * '$' : general user
    * '#' : super user

- Install Nginx
    $ sudo apt-get update
    $ sudo apt-get install -y nginx
    $ sudo service nginx restart
    $ sudo service nginx status

    * Access : web browser > http://localhost
$ ip a
- Access ubuntu nginx server from Host
    <em>* "Port forwarding" : To make, Can access to NAT network thorough PORT</em>

<em>< 2020.09.07 ></em>

- Ubuntu Server <-> Ubuntu Client
    * SSH (Under same NAT network)
        $ ssh 10.0.x.x (accessing), (server)
        $ sudo apt install openssh-server (client)
    $ ssh ${username}@${ipaddress} -p ${portnumber}

- RunLevel of ubuntu
    * not that important i guess
un~ : /root % /home/{username}
- Mount, umount

- Basic Linux command

<em>- yaml</em>
<a href="https://ko.wikipedia.org/wiki/YAML">* wiki</a>
</pre>
