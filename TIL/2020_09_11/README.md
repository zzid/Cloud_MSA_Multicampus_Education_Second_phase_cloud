# 2020_09_11

Created by: DongYun Hwang

가상환경 문제점? : 리소스 사용량이 너무 많다.  그래서? >> Docker

---

# Docker basic

- 빠른 환경 구축
- 효율적인 자원 이용
- 공유하기 쉬운 개발 환경

```bash
[root@demo ~]# yum install -y docker
```

docker는 항상 root에서

```bash
[root@demo ~]# systemctl start docker.service
[root@demo ~]# docker version
Client:
 Version:         1.13.1
 API version:     1.26
 Package version: docker-1.13.1-162.git64e9980.el7.centos.x86_64
 Go version:      go1.10.3
 Git commit:      64e9980/1.13.1
 Built:           Wed Jul  1 14:56:42 2020
 OS/Arch:         linux/amd64

Server:
 Version:         1.13.1
 API version:     1.26 (minimum version 1.12)
 Package version: docker-1.13.1-162.git64e9980.el7.centos.x86_64
 Go version:      go1.10.3
 Git commit:      64e9980/1.13.1
 Built:           Wed Jul  1 14:56:42 2020
 OS/Arch:         linux/amd64
 Experimental:    false
```

- Docker login

```bash
[root@demo ~]# docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: zzid
Password: 
Login Succeeded
```

- Search and Pull Docker image

```bash
[root@demo ~]# docker search centos
[root@demo ~]# docker pull docker.io/centos
[root@demo ~]# docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
docker.io/centos    latest              0d120b6ccaa8        4 weeks ago         215 MB
```

- Run

—name : centos7

```bash
[root@demo ~]# docker run -td --name centos7 docker.io/centos:centos7
```

- 실행중인 Docker 확인

```bash
[root@demo ~]# docker container ls
CONTAINER ID        IMAGE                      COMMAND             CREATED             STATUS              PORTS               NAMES
0dc354fe17e8        docker.io/centos:centos7   "/bin/bash"         31 seconds ago      Up 29 seconds                           centos7
```

- docker exec >> 해당 컨테이너에, 해당 명령을 실행하라

-it (-i : interactive || -t : Pseudo -TTY 할당)

```bash
[root@demo ~]# docker exec centos7 cat /etc/redhat-release
CentOS Linux release 7.8.2003 (Core)

[root@demo ~]# docker exec -it centos7 /bin/bash
[root@0dc354fe17e8 /]# cat /etc/redhat-release
CentOS Linux release 7.8.2003 (Core)
```

- Pull and Run ubuntu container

```bash
[root@demo ~]# docker run -itd --name ubuntu [docker.io/ubuntu](http://docker.io/ubuntu)
```

```bash
[root@demo ~]# docker exec -it ubuntu /bin/bash
root@d8df86fe39c1:/# cat /etc/issue
Ubuntu 20.04.1 LTS \n \l

```

- Stop and Rerun

```bash
[root@demo ~]# docker container stop centos7
[root@demo ~]# docker container start centos7
[root@demo ~]# docker ps -a
CONTAINER ID        IMAGE                      COMMAND             CREATED             STATUS              PORTS               NAMES
d8df86fe39c1        docker.io/ubuntu           "/bin/bash"         17 minutes ago      Up 17 minutes                           ubuntu
0dc354fe17e8        docker.io/centos:centos7   "/bin/bash"         35 minutes ago      Up 8 seconds                            centos7
```

- Remove

```bash
[root@demo ~]# docker container rm -f centos7
```

## Container를 Remove 한다고 해서 image가 삭제되지는 않는다!!

- nginx

8000 >> 80 ( port forwarding )

```bash
[root@demo ~]# docker run -d -p 8000:80 --name nginx-latest docker.io/nginx:latest
d1037a28ffebcc2035cea853bc482d3a0365642a97a9ea4f42adab0a83d8b029
[root@demo ~]# docker ps -a
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                  NAMES
d1037a28ffeb        docker.io/nginx:latest     "/docker-entrypoin..."   5 seconds ago       Up 4 seconds        0.0.0.0:8000->80/tcp   nginx-latest
d8df86fe39c1        docker.io/ubuntu           "/bin/bash"              29 minutes ago      Up 29 minutes                              ubuntu
0dc354fe17e8        docker.io/centos:centos7   "/bin/bash"              47 minutes ago      Up 12 minutes                              centos7
```

- HTTP access

[http://localhost:8000](http://localhost:8000) [ vagrant로 생성한 CentOS ] >> nginx 컨테이너의 80번 포트로 mapping!

```bash
[root@demo ~]# curl http://localhost:8000/index.html
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

- Logs

```bash
[root@demo ~]# docker logs nginx-latest
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
172.17.0.1 - - [11/Sep/2020:01:36:56 +0000] "GET /index.html HTTP/1.1" 200 612 "-" "curl/7.29.0" "-"
```

- Host의 web browserd에서 container로 접속
1. Vagrant를 통해 생성한 192.168.33.10 을 통해 접속 
2. 포트 8000 으로 접속하면, nginx container로 접속됨

![2020_09_11%2098473271ebff473eb5822ab5e7f5d9f1/Untitled.png](2020_09_11%2098473271ebff473eb5822ab5e7f5d9f1/Untitled.png)

## Dockerfile

- Centos7

FROM :  베이스 이미지 지정 (scratch : no base image)

ADD : 이미지에 파일을 추가 (ADD : 압출 파일을 풀어서 배치, COPY : 단순 복사)

이미지를 생성할 호스트의 파일을 컨테이너 이미지 내부로 복사

CMD : 컨테이너가 기동 될 때 실행할 default 프로세스를 지정

```
FROM scratch
ADD centos-7-x86_64-docker.tar.xz /

LABEL \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="CentOS Base Image" \
    org.label-schema.vendor="CentOS" \
    org.label-schema.license="GPLv2" \
    org.label-schema.build-date="20200809" \
    org.opencontainers.image.title="CentOS Base Image" \
    org.opencontainers.image.vendor="CentOS" \
    org.opencontainers.image.licenses="GPL-2.0-only" \
    org.opencontainers.image.created="2020-08-09 00:00:00+01:00"

CMD ["/bin/bash"]
```

- Make dockerfile

```bash
[root@demo ~]# echo "Hello, Docker." >  hello-docker.txt
[root@demo ~]# vi Dockerfile
FROM docker.io/centos:latest
ADD hello-docker.txt /tmp
#RUN yum install -y epel-releas
CMD [ "/bin/bash" ]
[root@demo ~]# docker image build -t zzid/centos:1.0 .
[root@demo ~]# docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
zzid/centos         1.0                 519495adb003        8 seconds ago       215 MB
docker.io/nginx     latest              7e4d58f0e5f3        15 hours ago        133 MB
docker.io/ubuntu    latest              4e2eef94cd6b        3 weeks ago         73.9 MB
docker.io/centos    centos7             7e6257c9f8d8        4 weeks ago         203 MB
docker.io/centos    latest              0d120b6ccaa8        4 weeks ago         215 MB
```

- 실행

```bash
[root@demo ~]# docker container run -td  --name zzid zzid/centos:1.0
d6e63ca285223d538ed5d424b9669a3d1f241db72994d549a59f66c972e52d22
[root@demo ~]# docker container ls
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                  NAMES
d6e63ca28522        zzid/centos:1.0            "/bin/bash"              17 seconds ago      Up 17 seconds                              zzid
d1037a28ffeb        docker.io/nginx:latest     "/docker-entrypoin..."   2 hours ago         Up 2 hours          0.0.0.0:8000->80/tcp   nginx-latest
d8df86fe39c1        docker.io/ubuntu           "/bin/bash"              2 hours ago         Up 2 hours                                 ubuntu
0dc354fe17e8        docker.io/centos:centos7   "/bin/bash"              2 hours ago         Up 2 hours                                 centos7
[root@demo ~]# docker exec -it zzid /bin/bash
[root@d6e63ca28522 /]# cat /tmp/hello-docker.txt
Hello, Docker.
```

- 변경 후, 변경 내용을 이미지로 생성

```bash
[root@d6e63ca28522 /]# yum install -y epel-release		⇐ Dockerfile에서 설치하지 않은 경우
[root@d6e63ca28522 /]# yum install -y nginx			⇐ 컨테이너 내부에 nginx를 설치
[root@d6e63ca28522 /]# exit
[root@demo ~]# docker container commit zzid zzid/centos:1.1
sha256:8e3acb4027c501f478dd58542a1e11c26a8659f6a97f05c1b0c35e732cd31152
[root@demo ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
zzid/centos         1.1                 8e3acb4027c5        4 seconds ago       310 MB
zzid/centos         1.0                 519495adb003        9 minutes ago       215 MB
docker.io/nginx     latest              7e4d58f0e5f3        15 hours ago        133 MB
docker.io/ubuntu    latest              4e2eef94cd6b        3 weeks ago         73.9 MB
docker.io/centos    centos7             7e6257c9f8d8        4 weeks ago         203 MB
docker.io/centos    latest              0d120b6ccaa8        4 weeks ago         215 MB
```

** Docker 이미지 삭제

```bash
[root@demo ~]# docker rmi 8e3acb4027c5(IMAGE ID)
```

- Docker Hub에 image Push

```bash
[root@demo ~]# docker image push zzid/centos:1.1
The push refers to a repository [docker.io/zzid/centos]
6e67559950cc: Pushed 
9fe121c748fb: Pushed 
291f6e44771a: Mounted from library/centos 
1.1: digest: sha256:3447fdaeb02e1a617c16d005a039cc9ea5b52faac893823532f1eab02b790638 size: 948
```

### Docker compose

- Install

```bash
[root@demo ~]# curl -L http://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m`>/usr/bin/docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   651  100   651    0     0   1191      0 --:--:-- --:--:-- --:--:-- 14152
100 7783k  100 7783k    0     0   211k      0  0:00:36  0:00:36 --:--:--  256k^[[C
[root@demo ~]# chmod +x /usr/bin/docker-compose
[root@demo ~]# docker-compose --version
docker-compose version 1.8.0, build f3628c7
```

- docker-compose.yml

```bash
[root@demo ~]# vi docker-compose.yml
[root@demo ~]# cat docker-compose.yml
db:
        image: docker.io/mysql
        ports:
                - "3306:3306"
        environment:
                - MYSQL_ROOT_PASSWORD=password

app:
        image: docker.io/tomcat
        prots:
                - "9090:8080"

web:
        image: docker.io/nginx
        ports:
                - "9000:80"
```

- 모든 컨테이너 지우기

```bash
[root@demo ~]# docker container rm -f $(docker container ls -aq)
```

- compose 로 설치! (-d : daemon?, background)

```bash
[root@demo ~]# docker-compose up -d
```

- stop , remove

```bash
[root@demo ~]# docker-compose stop
[root@demo ~]# docker-compose down
```

- docker-compose scale

compose를 통한 Scaling이 가능함

```bash
ex) # docker-compose scale web=2 worker=3
```

- snapshot

```bash
~/Desktop/second-phase/HashiCorp/WorkDir   master ● ?  vagrant snapshot save V3 (<= snapshot name)
==> default: Snapshotting the machine as 'V3'...
==> default: Snapshot saved! You can restore the snapshot at any time by
==> default: using `vagrant snapshot restore`. You can delete it using
==> default: `vagrant snapshot delete`.
```

# JENKINS (CI/CD)

Test 자동화, + etc

Prepare

- Install JDK

```bash
[root@demo ~]# yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
```

- Install JENKINS

```bash
[root@demo ~]# yum -y install http://mirrors.jenkins-ci.org/redhat-stable/jenkins-2.235.5-1.1.noarch.rpm
```

- Run jenkins

```bash
[root@demo ~]# systemctl start jenkins.service
[root@demo ~]# ps -ef | grep jenkins
jenkins  20279     1 99 05:43 ?        00:00:14 /etc/alternatives/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon --httpPort=8080 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20
root     20337 12294  0 05:43 pts/0    00:00:00 grep --color=auto jenkins
```

- 방화벽 내리기

```bash
[root@demo ~]# systemctl stop firewalld.service
```

- OR 특정 포트 허용 ( 8080 )

```bash
[root@demo ~]# firewall-cmd --zone=public --permanent --add-port=8080/tcp
success
[root@demo ~]# firewall-cmd --reload
success
```

- [http://192.168.33.10:80](http://192.168.33.10:8000)80 접속해서 Jenkins 설치, 설정
    - Select project type ( freestyle)
    - Build > execute shell > "something"
    - Save
    - "Build Now" in main page

    Crontab 형식으로 "Build trigger"에 작성해서 주기적으로 build 하도록 할 수 있음

## Jenkins에서 Ansible 실행

- jenkins 사용자 에게 passwd 없는 sudo 권한 부여

```bash
[vagrant@demo tmp]$ git clone [https://github.com/devops-book/ansible-playbook-sample.git](https://github.com/devops-book/ansible-playbook-sample.git)
[vagrant@demo tmp]$ sudo vi /etc/sudoers.d/jenkins
[vagrant@demo tmp]$ sudo cat /etc/sudoers.d/jenkins
jenkins ALL=(ALL) NOPASSWD:ALL
```

- Jenkins page에서 exec-ansible project 생성 후에 build script 작성

```bash
cd /tmp/ansible-playbook-sample
ansible-playbook -i development site.yml --diff
```

- 결과

![2020_09_11%2098473271ebff473eb5822ab5e7f5d9f1/Screen_Shot_2020-09-11_at_3.53.59_PM.png](2020_09_11%2098473271ebff473eb5822ab5e7f5d9f1/Screen_Shot_2020-09-11_at_3.53.59_PM.png)

## Jenkins에서 serverspec 실행

- build script

```bash
cd /tmp/serverspec_sample
/usr/local/rvm/rubies/ruby-2.7.0/bin/rake spec
```

- serverspec test 통과 못할 시?
    - 통과 못한 부분 수정하고
    - ansible-playbook -i development site.yml ( rebuild )
    - Jenkins : build now

    Done

## exec-ansible 에 이어서 exec-serverspec 실행되도록 만들기

In jenkins 

- Post build Action 에서 Project를 엮어준다.
- 빌드 완료 된 후에 하위 프로젝트도 빌드가 된다.

## Pipeline 으로 프로젝트 연결

- 위의 방식으로 후행 프로젝트를 연결 했을 때는, 많은 프로젝트가 엮여 있는 상화에서 순서를 바꾸려고 하면 작업이 엄청나게 많아진다.
1. New item : Pipeline
2. Write script

```bash
node {
    stage 'ansible'
    build 'exec-ansible'
    stage 'serverspec'
    build 'exec-serverspec'
}
```

## Project에 Parameter 추가 하기

- general > This project is parameterized
- Choice parameter

NAME : ENVIRONMENT

Choice : 

- development
- production

Build script 수정

```bash
cd /tmp/ansible-playbook-sample
ansible-playbook -i ${ENVIRONMENT} site.yml --diff
```

마찬가지로 PIPELINE도 수정!

```bash
node {
    stage 'ansible'
    build job : 'exec-ansible', parameter : [[$class:'StringParameterValue', name:'ENVIRONMENT', value:'${ENVIRONMENT}']]
    stage 'serverspec'
    build 'exec-serverspec'
}
```