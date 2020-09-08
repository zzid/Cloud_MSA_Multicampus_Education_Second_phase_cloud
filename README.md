# Second phase of the education program

Teacher's Doc - https://bit.ly/2YsxwEl

## Linux( Ubuntu )
<pre>

<h3>< 2020.09.06 ></h3>

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

<h3>< 2020.09.07 ></h3>

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


<h3>< 2020.09.08 ></h3>

- RBAC(Role-Based Access Control)

- chmod {사용자 유형} {+ or -} {권한} {파일명}
- chown {소유자} {파일명}

- Hard link and Symbolic link
    * Hard link : inode 공유하고 있기떄문에 사실상 원본과 같음 
    * Symbolic(soft) link : windows의 바로가기와 비슷
- Foreground process and Background process

- Daemon
    * service = daemon = server process

- Mirroring (archive)

- Shell script (basic)
    * all variable type are string 
    * num4=`expr \( $num1 + 200 \) / 10 \* 2` >> example of integer expression
    * Parameter :
        <code>
        #!/bin/sh
        echo "file name is <$0>"
        echo "parameter one is <$1>"
        echo "parameter two is <$2>"
        exit 0
        </code>

</pre>
