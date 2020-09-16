# 2020_09_16

# Docker

---

## Docker compose

```bash
vagrant@xenial64:~/compose$ vi docker-compose.yml
vagrant@xenial64:~/compose$ docker-compose up
vagrant@xenial64:~/compose$ docker-compose down
vagrant@xenial64:~/compose$ docker-compose up -d --build
```

## ~~젠킨스 마스터-슬레이브 (실패)~~

- 마스터 젠킨스 용 ssh 키 생성

```bash
vagrant@xenial64:~/compose$ docker container exec -it master ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/var/jenkins_home/.ssh/id_rsa):  
Created directory '/var/jenkins_home/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /var/jenkins_home/.ssh/id_rsa.
Your public key has been saved in /var/jenkins_home/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:EE4TnNpxNcj77IoFn3UGQcdZzSoyBPEfaSde+oxVZhQ jenkins@7e592ed141f5
The key's randomart image is:
+---[RSA 2048]----+
|     .=+o*=..o.Eo|
|     o+o+..+o. .o|
|     ooo oo = o.+|
|    . ... o=.*.+ |
|      . So.o*..  |
|       o ooo =   |
|        +.  . o  |
|       o  .      |
|      . ..       |
+----[SHA256]-----+
vagrant@xenial64:~/compose$ docker container exec master cat /var/jenkins_home/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYtPV9EhaFLwLLpT2E8RpDlJ3UxOX0MR/Nb0pHsEfckatvnNBMxl0Omua0uTxV0hgHfE8++MwWwVuEY+34deqjc3KTESeoQEpZWZgpyp1ROP4E9ykUzpSW+mNUmWP4x1ZdYWL+rMNF/upN/0gCgdsF9qB/wPJ+d6eadpZJtWMYA04iralQ0Hc/Bdv4ZLx1xjcKxeZnxH0xhQ99xGnjVaYCYg6bNM164IPOHrsFjw75x15BuwGLsMsoIZ7b+gho8NqJjfNuDBWqQs5mjf6rxb/DWfmHEJuIqcEhzMOy1FkF6HXmHujJteByJYPlb6CBrr4osxj8gInQll/1zdLTzAKP jenkins@7e592ed141f5
```

- 슬레이브 젠킨스 컨테이너 생성

```bash
vagrant@xenial64:~/compose$ cat docker-compose.yml 
version: "3"
services:
  master:
    container_name: master
    image: jenkinsci/jenkins
    ports:
      - 8080:8080
    links:
       - slave01
#    volumes:
#      - ./jenkins_home:/var/jenkins_home
  slave01:
    container_name: slave01
    image: jenkinsci/ssh-slave
    environment:
        -JENKINS_SLAVE_SSH_PUBKEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYtPV9EhaFLwLLpT2E8RpDlJ3UxOX0MR/Nb0pHsEfckatvnNBMxl0Omua0uTxV0hgHfE8++MwWwVuEY+34deqjc3KTESeoQEpZWZgpyp1ROP4E9ykUzpSW+mNUmWP4x1ZdYWL+rMNF/upN/0gCgdsF9qB/wPJ+d6eadpZJtWMYA04iralQ0Hc/Bdv4ZLx1xjcKxeZnxH0xhQ99xGnjVaYCYg6bNM164IPOHrsFjw75x15BuwGLsMsoIZ7b+gho8NqJjfNuDBWqQs5mjf6rxb/DWfmHEJuIqcEhzMOy1FkF6HXmHujJteByJYPlb6CBrr4osxj8gInQll/1zdLTzAKP jenkins@7e592ed141f5
```

## docker-compose를 이용해서 MySQL과 Wordpress를 연동

```bash
vagrant@xenial64:~/compose$ docker-compose up -d\
vagrant@xenial64:~/compose$ cat docker-compose.yml 
version: "3.3"

services:
  db:
    image: library/mysql:5.7
    volumes:
      - /home/vagrant/db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress

  wordpress:
    depends_on:
      - db
    image: library/wordpress:latest
    ports:
      - "80:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
volumes:
  db_data: {}

vagrant@xenial64:~/compose$ docker-compose ps
       Name                      Command               State          Ports       
----------------------------------------------------------------------------------
compose_db_1          docker-entrypoint.sh mysqld      Up      3306/tcp, 33060/tcp
compose_wordpress_1   docker-entrypoint.sh apach ...   Up      0.0.0.0:80->80/tcp
```

- docker-compose.yml(cont)

```bash
version: "3.3"

services:
  db:
    image: library/mysql:5.7
    volumes:
      - /home/vagrant/db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress

  wordpress:
    depends_on:
      - db
    image: library/wordpress:latest
    ports:
      - "80:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
volumes:
  db_data: {}

```

- docker compose scale

```bash
vagrant@xenial64:~/compose$ docker-compose up -d
Starting compose_db_1 ... done
Starting compose_wordpress_1 ... done
vagrant@xenial64:~/compose$ docker-compose scale db=2 wordpress=2
WARNING: The scale command is deprecated. Use the up command with the --scale flag instead.
Starting compose_db_1 ... done
Creating compose_db_2 ... done
Starting compose_wordpress_1 ... done
Creating compose_wordpress_2 ... done
vagrant@xenial64:~/compose$ docker container ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                   NAMES
50734db2ab47        wordpress:latest    "docker-entrypoint.s…"   8 seconds ago        Up 7 seconds        0.0.0.0:32770->80/tcp   compose_wordpress_2
6429377e1cd6        mysql:5.7           "docker-entrypoint.s…"   8 seconds ago        Up 7 seconds        3306/tcp, 33060/tcp     compose_db_2
704367def7e0        wordpress:latest    "docker-entrypoint.s…"   About a minute ago   Up 22 seconds       0.0.0.0:32769->80/tcp   compose_wordpress_1
a6dac4f06a54        mysql:5.7           "docker-entrypoint.s…"   About a minute ago   Up 22 seconds       3306/tcp, 33060/tcp     compose_db_1
```

## **컨테이너를 매뉴얼(수동)하게 삭제하는 방법**

### **#1 도커 서비스를 중지**

```bash
$ sudo service docker stop
```

### **#2 컨테이너 파일 확인 및 삭제**

```bash
$ sudo ls /var/lib/docker/containers
```

```bash
$ sudo rm -r /var/lib/docker/containers/*CONTAINER_ID*
```

### **#3 도커 서비스를 실행**

```bash
$ sudo service docker start
```

# **컨테이너를 중지할 때 컨테이너를 자동으로 삭제**

### **컨테이너를 중지하면 Exited 상태로 대기 ⇒ restart 명령으로 재기동 가능**

```bash
vagrant@xenial64:~/chap02$ docker container run -d -p 9000:8080 example/echo:latest
f02810866949ba9d9c8ed7344d3c4da1daa8147994d92b83bae533666eca4b92

vagrant@xenial64:~/chap02$ docker container stop f02810866949ba9d9c8ed7344d3c4da1daa8147994d92b83bae533666eca4b92

f02810866949ba9d9c8ed7344d3c4da1daa8147994d92b83bae533666eca4b92

vagrant@xenial64:~/chap02$ docker container ps -a

CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES

f02810866949 example/echo:latest "go run /echo/main.go" 23 seconds ago Exited (2) 6 seconds ago thirsty_hawking
```

### **컨테이너 생성 시 --rm 옵션을 추가하면 컨테이너를 중지하면 해당 컨테이너를 삭제**

```bash
vagrant@xenial64:~/chap02$ docker container run -d -p 9000:8080 --rm example/echo:latest
6be50783d1ecd8f8dcfda8c075509a1bc0143d141cf3295616fcf311bfff74ec

vagrant@xenial64:~/chap02$ docker container ps

CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES

6be50783d1ec example/echo:latest "go run /echo/main.go" 6 seconds ago Up 5 seconds 0.0.0.0:9000->8080/tcp clever_elbakyan

vagrant@xenial64:~/chap02$ docker container stop 6be50783d1ec

6be50783d1ec

vagrant@xenial64:~/chap02$ docker container ps -a

CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES

f02810866949 example/echo:latest "go run /echo/main.go" 3 minutes ago Exited (2) 2 minutes ago thirsty_hawking
```

# **컨테이너 내부의 표준 출력을 호스트로 연결**

```bash
vagrant@xenial64:~/chap02$ docker container run -d -p 8080:8080 -p 5000:5000 jenkins
도커에서 공식 배포하는 최신 버전(latest)

⇒ libary/jenkins:latest 같은 의미

vagrant@xenial64:~/chap02$ docker container ls

CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES

406959fb618b jenkins "/bin/tini -- /usr/l…" About a minute ago Up About a minute 0.0.0.0:5000->5000/tcp, 0.0.0.0:8080->8080/tcp, 50000/tcp fervent_heyrovsky

vagrant@xenial64:~/chap02$ docker container logs -f 406959fb618b

Running from: /usr/share/jenkins/jenkins.war

webroot: EnvVars.masterEnvVars.get("JENKINS_HOME")

Sep 15, 2020 2:25:55 AM Main deleteWinstoneTempContents

WARNING: Failed to delete the temporary Winstone file /tmp/winstone/jenkins.war

Sep 15, 2020 2:25:55 AM org.eclipse.jetty.util.log.JavaUtilLog info

INFO: Logging initialized @449ms

Sep 15, 2020 2:25:55 AM winstone.Logger logInternal

```

# **실행중인 컨테이너 내부로 명령을 전달(실행)**

### **docker container exec 컨테이너이름 명령어**

```bash
vagrant@xenial64:~/chap02$ docker container run -t -d --name echo --rm example/echo:latest
795009969b4719481861c339a06652a863dd9308b65a81fa8c64badbfbecabc4

vagrant@xenial64:~/chap02$ docker container exec echo pwd

/go

vagrant@xenial64:~/chap02$ docker container exec echo ip a

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1

link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

inet 127.0.0.1/8 scope host lo

valid_lft forever preferred_lft forever

92: eth0@if93: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default

link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0

inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0

valid_lft forever preferred_lft forever
```

### **컨테이너 내부 쉘을 이용**

```bash
vagrant@xenial64:~/chap02$ docker container exec -it echo /bin/sh
# pwd

/go

# ls

bin src

# ip a

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1

link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

inet 127.0.0.1/8 scope host lo

valid_lft forever preferred_lft forever

92: eth0@if93: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default

link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0

inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0

valid_lft forever preferred_lft forever
```

# **호스트의 파일 또는 디렉터리를 컨테이너 내부로 복사**

### **docker container cp 호스트경로 컨테이너이름:컨테이너내부경로**

### **호스트의 현재 시간을 파일로 생성**

```bash
vagrant@xenial64:~/chap02$ date > host_now
vagrant@xenial64:~/chap02$ cat host_now

Tue Sep 15 02:38:55 UTC 2020
```

### **호스트의 파일을 echo 컨테이너 내부로 복사**

```bash
vagrant@xenial64:~/chap02$ docker container cp ./host_now echo:/tmp/
```

### **컨테이너로 복사한 파일의 내용을 확인**

```bash
vagrant@xenial64:~/chap02$ docker container exec echo cat /tmp/host_now
Tue Sep 15 02:38:55 UTC 2020
```

# **컨테이너 내부의 파일을 호스트로 복사**

### **docker container cp 컨테이너이름:컨테이너내부경로 호스트경로**

```bash
vagrant@xenial64:~/chap02$ docker container cp echo:/tmp/host_now ./host_now_from_container
vagrant@xenial64:~/chap02$ cat ./host_now_from_container

Tue Sep 15 02:38:55 UTC 2020
```

# **태깅되지 않은 이미지를 검색 및 태그 붙이기**

### **태깅되지 않은 이미지 검색**

vagrant@xenial64:~/pulltest$ docker image ls -f "dangling=true"

REPOSITORY TAG IMAGE ID CREATED SIZE

<none> <none> fefad6ab4ef6 11 minutes ago 1.23MB

### **이미지에 태그를 변경 방법**

vagrant@xenial64:~/pulltest$ docker image tag --help

Usage: docker image tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]

Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

### **태깅되지 않은 이미지에 태그를 추가**

vagrant@xenial64:~/pulltest$ docker image tag $(docker image ls -f "dangling=true" -q) myanjini/basetest:0.1

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~~~~

태깅할 이미지 식별자 (ID 또는 이름) 부여할 이미지 이름

vagrant@xenial64:~/pulltest$ docker image ls

REPOSITORY TAG IMAGE ID CREATED SIZE

myanjini/pulltest latest 181d7129cf05 6 minutes ago 1.23MB

myanjini/basetest lastest e17d780478cf 11 minutes ago 1.23MB

myanjini/basetest latest e17d780478cf 11 minutes ago 1.23MB

myanjini/basetest 0.1 fefad6ab4ef6 14 minutes ago 1.23MB

myanjini/basetest <none> 54d6c33b5a41 17 minutes ago 1.23MB

busybox latest 6858809bf669 5 days ago 1.23MB

# **Dockerfile로 이미지 빌드 시 주의사항**

이미지 빌드가 완료되면 Dockerfile의 명령어 줄 수 만큼의 레이어가 존재

실제 컨테이너에서 사용하지 못하는 파일(디렉터리)이 이미지 레이어에 존재하면 공간만 차지하게 됨

⇒ Dockerfile을 작성할 때 &&로 각 RUN 명령어를 하나로 묶어서 실행

### **3개의 RUN 명령어 실행 → 실제 이미지 내부에 변경은 없음 (100M 크기의 파일을 생성 후 삭제하므로)**

vagrant@xenial64:~/pulltest$ mkdir ~/dockerfile_test && cd ~/dockerfile_test

vagrant@xenial64:~/dockerfile_test$ vi Dockerfile

[Untitled](https://www.notion.so/61b6b7f7413e4215b4e76234030ad8e2)

vagrant@xenial64:~/dockerfile_test$ docker image build -t falloc_100m .

Sending build context to Docker daemon 2.048kB

Step 1/4 : FROM ubuntu

latest: Pulling from library/ubuntu

54ee1f796a1e: Pull complete f7bfea53ad12: Pull complete 46d371e02073: Pull complete b66c17bbf772: Pull complete Digest: sha256:31dfb10d52ce76c5ca0aa19d10b3e6424b830729e32a89a7c6eee2cda2be67a5

Status: Downloaded newer image for ubuntu:latest

---> 4e2eef94cd6b

Step 2/4 : RUN mkdir /test

---> Running in 0212d1d0b0f0

Removing intermediate container 0212d1d0b0f0

---> a761c33cecb5

Step 3/4 : RUN fallocate -l 100m /test/dumy

---> Running in 2038896a36c9

Removing intermediate container 2038896a36c9

---> e933e53411c2

Step 4/4 : RUN rm /test/dumy

---> Running in ebd0a961b02b

Removing intermediate container ebd0a961b02b

---> cb419b52df77

Successfully built cb419b52df77

Successfully tagged falloc_100m:latest

vagrant@xenial64:~/dockerfile_test$

vagrant@xenial64:~/dockerfile_test$ docker image ls

REPOSITORY TAG IMAGE ID CREATED SIZE

falloc_100m latest cb419b52df77 23 seconds ago 179MB

myanjini/pulltest latest 181d7129cf05 18 minutes ago 1.23MB

myanjini/basetest lastest e17d780478cf 22 minutes ago 1.23MB

myanjini/basetest latest e17d780478cf 22 minutes ago 1.23MB

myanjini/basetest 0.1 fefad6ab4ef6 25 minutes ago 1.23MB

myanjini/basetest <none> 54d6c33b5a41 29 minutes ago 1.23MB

busybox latest 6858809bf669 5 days ago 1.23MB

ubuntu latest 4e2eef94cd6b 3 weeks ago 73.9MB

### **3개의 RUN 명령어를 하나로 줄여서 실행**

vagrant@xenial64:~/dockerfile_test$ vi Dockerfile

[Untitled](https://www.notion.so/370120d51da0495696269aba8996e11b)

vagrant@xenial64:~/dockerfile_test$ docker build -t recommand .

Sending build context to Docker daemon 2.048kB

Step 1/2 : FROM ubuntu

---> 4e2eef94cd6b

Step 2/2 : RUN mkdir /test && fallocate -l 100m /test/dumy && rm /test/dumy

---> Running in 341f7850ca20

Removing intermediate container 341f7850ca20

---> 6a667c9fadb5

Successfully built 6a667c9fadb5

Successfully tagged recommand:latest

vagrant@xenial64:~/dockerfile_test$ docker image ls

REPOSITORY TAG IMAGE ID CREATED SIZE

recommand latest 6a667c9fadb5 4 seconds ago 73.9MB

falloc_100m latest cb419b52df77 3 minutes ago 179MB

myanjini/pulltest latest 181d7129cf05 21 minutes ago 1.23MB

myanjini/basetest lastest e17d780478cf 26 minutes ago 1.23MB

myanjini/basetest latest e17d780478cf 26 minutes ago 1.23MB

myanjini/basetest 0.1 fefad6ab4ef6 29 minutes ago 1.23MB

myanjini/basetest <none> 54d6c33b5a41 32 minutes ago 1.23MB

busybox latest 6858809bf669 5 days ago 1.23MB

ubuntu latest 4e2eef94cd6b 3 weeks ago 73.9MB

---

---

---

# DIND(Docker IN Docker)

---

- 우리 수업에서는 일단 dind 사용하지 않음
- 대신, 가상머신을 여러개 만들어서 실습

### 

# Docker swarm

---

![2020_09_16%2075d666a1a09a433a9c9ca35caee6aa18/Untitled.png](2020_09_16%2075d666a1a09a433a9c9ca35caee6aa18/Untitled.png)

- Structure
    - manager node와 worker node로 구성
    - worker node → 실제 컨테이너가 생성되고 관리되는 도커 서버
    - manager node → 워커 노드를 관리하기 위한 도커 서버
    - manager node는 worker node의 역할을 포함
    - Cluster를 구성하기 위해서는 최소 1개 이상의 manager node가 존재 해야 한다.
- Setup ( for all virtual machine )

```bash
vagrant up
vagrant ssh
sudo su
yum install -y docker 
systemctl start docker.service

```

- manager

```bash
[root@swarm-manager vagrant]# docker swarm init --advertise-addr 192.168.111.100
Swarm initialized: current node (ljsplixh4506lem1dbej4g57b) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-45wh5fyepp4tjn9bzlcrj1051par1z6fwntsv9c24jj6hp1dcb-4y9h96vqn397rgkt20bar59ta \
    192.168.111.100:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

- workers

```bash
[root@swarm-worker1 vagrant]#     docker swarm join \
>     --token SWMTKN-1-45wh5fyepp4tjn9bzlcrj1051par1z6fwntsv9c24jj6hp1dcb-4y9h96vqn397rgkt20bar59ta \
>     192.168.111.100:2377
This node joined a swarm as a worker.
```

- manager

```bash
[root@swarm-manager ~]# docker node ls
ID                           HOSTNAME       STATUS  AVAILABILITY  MANAGER STATUS
12gvfglvloms1l47tm0mwdbew    swarm-worker2  Ready   Active        
9onza1ecdm2enmwo3lf0j0k01    swarm-worker1  Ready   Active        
ljsplixh4506lem1dbej4g57b *  swarm-manager  Ready   Active        Leader
```

** token contorl

```bash
[root@swarm-manager ~]# docker swarm join-token manager
To add a manager to this swarm, run the following command:

[root@swarm-manager ~]# docker swarm join-token worker
To add a worker to this swarm, run the following command:

[root@swarm-manager ~]# docker swarm join-token --rotate manager
Successfully rotated manager join token.
To add a manager to this swarm, run the following command:

```