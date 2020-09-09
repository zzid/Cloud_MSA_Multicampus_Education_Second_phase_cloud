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

<h3>< 2020.09.09 ></h3>
- if ~ fi

- case ~ esac

- for 
    * seq(1 100) == python range(1,101)
    * {1..100} [ bash[o] sh[x] ]

<em>- Cron</em>
    * crontab -l : 등록된 크론 확인
    * crontab -e : 크론을 등록, 수정
    * (/etc/crontab)
    * (format)[m h dom mon dow user command]
    ex) 20 03 16 * * root /root/backup.sh
</pre>

# DevOps

---

### DevOps란

Dev(개발)과 Ops(운용)이 긴밀히 협조,연계하여 비즈니스 가치를 높이려고 하는 근무 방식이나 문화

- 개발과 운용의 경계를 없앰

- [https://sasperger.tistory.com/136](https://sasperger.tistory.com/136) (애자일 SW개발 101.pdf)

- Infrastructure As A Code [ IaC ] ?

  > Infrastructure를 code를 통해서 관리가 가능하다면? 

## Use Vagrant : local 개발 환경의 Infrastructure as Code화

### 가상 머신을 코드로 정의 하는 것!

- Vagrant : 가상환경 구축 도구

- Vagrant make a virtual env to VirtualBox (can change to other third-party SW)

- Make directory

  ```bash
  vagrant init
  ```

  > Vagrantfile

- After set up Vagrantfile

  ```bash
  vagrant up
  ```

- After activate

  ```bash
  vagrant ssh
  ```

- To stop

  ```bash
  vagrant halt
  ```

- To reinstall

  ```bash
  vagrant destroy
  vagrant up
  ```

- Provision

  설치 후에 자동으로 실행할 명령들을 명시

  ### ** Deploy Web server(nginx) with virtual machine

### Vagrantfile

```bash
Vagrant.configure("2") do |config|
  # config.vm.box = "base"
  config.vm.box = "generic/centos7"
  config.vm.hostname = "demo"
  config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.synced_folder ".", "/home/vagrant/sync", disable: true
  config.vm.synced_folder ".", "/vagrant", disable: true
  config.vm.provision "shell", inline: $script
end

$script = <<SCRIPT
  yum install -y epel-release
  yum install -y nginx
  echo "Hello, Vagrant" > /usr/share/nginx/html/index.html
  systemctl start nginx
SCRIPT
```

- stop the firewall of virtual machine

```bash
[vagrant@demo ~]$ sudo systemctl stop firewalld
```

- Accessing from host, (to virtual machine nginx server)

```bash
~/Desktop/second-phase/HashiCorp/WorkDir   master ● ?  curl http://192.168.33.10
Hello, Vagrant
```

