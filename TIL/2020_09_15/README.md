# 2020_09_15

# Docker (cont)

---

1. ubuntu 베이스 이미지 설치
2. 컨테이너 내부 쉘에 접속

```bash
vagrant@xenial64:~/webserver$ docker container run -dit -p 8080:80 --name zzidweb ubuntu:14.04
vagrant@xenial64:~/webserver$ docker container ls
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                  NAMES
b6d379f6e6d4        ubuntu:14.04        "/bin/bash"         4 seconds ago       Up 4 seconds        0.0.0.0:8080->80/tcp   zzidweb
vagrant@xenial64:~/webserver$ docker container exec -it zzidweb /bin/bash
```

- Apache 설치

```bash
root@1cea9b3e58fd:/# apt-get install apache2 -y

root@b6d379f6e6d4:/# service apache2 status
 * apache2 is not running
root@b6d379f6e6d4:/# service apache2 start
 * Starting web server apache2                                                                                                                               AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
 * 
root@b6d379f6e6d4:/# service apache2 status
 * apache2 is running
```

- Access

```bash
vagrant@xenial64:~/webserver$ docker container cp ./hello.html zzidweb:/var/www/html
vagrant@xenial64:~/webserver$ docker container exec zzidweb cat /var/www/html/hello.html
hello docker
vagrant@xenial64:~/webserver$ curl localhost:8080/hello.html
hello docker
```

- 이미지 생성

```bash
vagrant@xenial64:~/webserver$ docker commit zzidweb zzid/zzidweb:latest
```

OR

- Docker file 생성

```bash
vagrant@xenial64:~/webserver$ vi Dockerfile
vagrant@xenial64:~/webserver$ cat Dockerfile 
FROM ubuntu:14.04

RUN apt-get update

run apt-get install -y apache2

ADD hello.html /var/www/html/

EXPOSE 80

CMD apachectl -DFOREGROUND

vagrant@xenial64:~/webserver$ docker image build -t zzid/zzidweb:dockerfile .
vagrant@xenial64:~/webserver$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
zzid/zzidweb        dockerfile          3e03d6840b17        32 seconds ago      221MB
zzid/zzidweb        latest              5d5b1fc6db3c        4 minutes ago       221MB
zzid/basetest       latest              23790bc12a3c        21 hours ago        1.23MB
busybox             latest              6858809bf669        6 days ago          1.23MB
ubuntu              14.04               6e4f1fe62ff1        9 months ago        197MB
```

- Access ( CURL )

```bash
vagrant@xenial64:~/webserver$ docker container run -dp 9090:80 --name zzidwebdockerfile zzid/zzidweb:dockerfile
4834758af4fb69ac9d4ae3a6ac5b071a0ca3477145d18490ea1effb5e43c446d
vagrant@xenial64:~/webserver$ curl localhost:9090/hello.html
hello docker

```

** Dockerfile 이 공개 되어있는 것이 신뢰 할 만함

** docker pull 보다는 Dockerfile을 다운받아서 구축하는게 더 신뢰할만함

```bash
#4 생성한 이미지로 컨테이너를 실행 (호스트 포트를 랜덤하게 지정)
vagrant@xenial64:~/webserver$ docker container run -d -P --name mywebrandport myanjini/myweb:dockerfile
c892aa35710c2656f1fe636850e62ab154086b26f897417bcc1fd602f9f41567
⇒ 호스트의 랜덤하게 할당된 포트와 컨테이너에서 EXPOSE된 포트를 자동으로 맵핑

vagrant@xenial64:~/webserver$ docker port mywebrandport
80/tcp -> 0.0.0.0:32770
```

- Image pull

```bash
vagrant@xenial64:~$ docker pull nginx
vagrant@xenial64:~$ docker container run --name webserver -dp 80:80 nginx
969f64d327873cf62d10a1d8a2adb0978723a3a4bc582af7e43fed7f0954dfa4
vagrant@xenial64:~$ curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## Simple blog using docker containers

---

- wordpressdb( alias to MySQL)
    - -e ~~ :: 컨테이너 내부의 환경 변수를 설정

```bash
vagrant@xenial64:~$ mkdir ~/blog && cd ~/blog
vagrant@xenial64:~/blog$ ls
vagrant@xenial64:~/blog$ docker run -d --name wordpressdb -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=wordpress mysql:5.7

```

- https://hub.docker.com/_/wordpress
    - wordpress

```bash
vagrant@xenial64:~/blog$ docker run -d -e WORDPRESS_DB_PASSWORD=password --name wordpress --link wordpressdb:mysql -p 90 wordpress
```

- VirtualBox 에서 포트포워딩 해주니까 접속됨

- [http://localhost:32769/](http://localhost:32769/)

![2020_09_15%2078be2b3186d44fa09d387783a9264108/Untitled.png](2020_09_15%2078be2b3186d44fa09d387783a9264108/Untitled.png)

# **컨테이너의 데이터를 영속적(persistent)인 데이터로 활용하는 방법**

## **방법1. 호스트 볼륨 공유**

- v 옵션을 이용해서 호스트 볼륨을 공유

⇒ 호스트의 디렉터리를 컨테이너의 디렉터리에 마운트

⇒ 이미지에 원재 존재하는 디렉터리에 호스트의 볼륨을 공유하면 컨테이너의 디렉터리 자체가 덮어쓰게 됨

### **#0 모든 컨테이너, 이미지, 볼륨을 삭제**

```bash
vagrant@xenial64:~/blog$ docker container rm -f $(docker container ls -aq)

vagrant@xenial64:~/blog$ docker image rm -f $(docker image ls -aq)

vagrant@xenial64:~/blog$ docker volume rm -f $(docker volume ls -q)
```

### **#1 MySQL 이미지를 이용한 데이터베이스 컨테이너를 생성**

/home/wordpress_db	⇒ 도커가 자동으로 생성

/var/lib/mysql	⇒ mysql 데이터베이스의 데이터를 저장하는 기본 디렉터리

```bash
vagrant@xenial64:~/blog$ docker run -d --name wordpressdb_hostvolume -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=wordpress -v **/home/vagrant/wordpress_db**:/var/lib/mysql mysql:5.7

6b7848cca9068f3af8b1cf56acbb9d5fb0160f0500e35cd4498ba13fbe14757a
```

### **#2 워드프레스 이미지를 이용해 웹 서버 컨테이너를 생성**

```bash
vagrant@xenial64:~/blog$ docker run -d -e WORDPRESS_DB_PASSWORD=password --name wordpress_hostvolume --link wordpressdb_hostvolume:mysql -p 80 wordpress
```

### **#3 호스트 볼륨 공유를 확인**

```bash
vagrant@xenial64:~/blog$ ls **/home/vagrant/wordpress_db**

auto.cnf ca.pem client-key.pem ibdata1 ib_logfile1 private_key.pem server-cert.pem

ca-key.pem client-cert.pem ib_buffer_pool ib_logfile0 mysql public_key.pem server-key.pem
```

### **#4 컨테이너 내부의 디렉터리를 확인 ⇒ #3에서 확인한 것과 동일**

```bash
vagrant@xenial64:/home$ docker container exec wordpressdb_hostvolume ls /var/lib/mysql

auto.cnf

ca-key.pem

ca.pem

client-cert.pem

client-key.pem

ib_buffer_pool

ib_logfile0

ib_logfile1

ibdata1

ibtmp1

mysql

performance_schema

private_key.pem

public_key.pem

server-cert.pem

server-key.pem

sys

wordpress
```

### **#5 wordpressdb_hostvolume 컨테이너를 삭제한 후 호스트 볼륨을 확인**

```bash
vagrant@xenial64:/home$ docker container rm -f wordpressdb_hostvolume

wordpressdb_hostvolume

vagrant@xenial64:/home$ docker container ls -a

CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES

54f4aa9f0aa1 wordpress "docker-entrypoint.s…" 3 minutes ago Up 3 minutes 0.0.0.0:32777->80/tcp wordpress_hostvolume

vagrant@xenial64:/home$ ls /home/vagrant/wordpress_db/

auto.cnf ca.pem client-key.pem ibdata1 ib_logfile1 mysql private_key.pem server-cert.pem sys

ca-key.pem client-cert.pem ib_buffer_pool ib_logfile0 ibtmp1 performance_schema public_key.pem server-key.pem wordpress
```

⇒ 컨테이너는 삭제되었지만 공유되고 있던 파일(디렉터리)은 그대로 남아 있음을 확인

⇒ 데이터의 영속성을 부여

### **#6 MySQL 이미지를 이용해서 컨테이너를 실행 (기존 호스트 볼륨을 맵핑)**

```bash
vagrant@xenial64:/home$ docker run -d --name wordpressdb_hostvolume -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=wordpress -v /home/vagrant/wordpress_db:/var/lib/mysql mysql:5.7

33c2c4524ad218d0f7c819cae286535aa35e34b0298fb051cc14b45020256509

vagrant@xenial64:/home$ docker container exec wordpressdb_hostvolume ls /var/lib/mysql

auto.cnf

ca-key.pem

ca.pem

client-cert.pem

client-key.pem

ib_buffer_pool

ib_logfile0

ib_logfile1

ibdata1

ibtmp1

mysql

performance_schema

private_key.pem

public_key.pem

server-cert.pem

server-key.pem

sys

wordpress
```

## **방법2. 볼륨 컨테이너**

- v 옵션으로 볼륨을 사용하는 컨테이너를 다른 컨테이너와 공유하는 것

컨테이너를 생성할 때 --volumes-from 옵셤을 설정하면 -v 또는 --volume 옵션을 적용한 컨테이너의 볼륨 디렉터리 공유가 가능

## **방법3. 도커 볼륨**

도커 자체가 제공하는 볼륨 기능을 활용

docker volume 명령어를 사용