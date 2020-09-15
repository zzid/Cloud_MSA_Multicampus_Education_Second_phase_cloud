# 2020_09_14

# Docker(cont)

```bash
vagrant init
```

- vagrantfile

```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname="xenial64"
  config.vm.synced_folder ".", "/vagrant_data", disabled:true
end
```

- Setting

```bash
vagrant@xenial64:~$ sudo apt update
vagrant@xenial64:~$ sudo apt upgrade
# docker setting
vagrant@xenial64:~$ sudo apt install -y docker.io
vagrant@xenial64:~$ sudo usermod -a -G docker $USER
vagrant@xenial64:~$ sudo service docker restart
vagrant@xenial64:~$ sudo chmod 666 /var/run/docker.sock
vagrant@xenial64:~$ docker --version
Docker version 18.09.7, build 2d0083d
```

```bash
vagrant@xenial64:~/chap01$ vi Dockerfile
vagrant@xenial64:~/chap01$ ll
total 16
drwxrwxr-x 2 vagrant vagrant 4096 Sep 14 04:23 ./
drwxr-xr-x 5 vagrant vagrant 4096 Sep 14 04:23 ../
-rw-rw-r-- 1 vagrant vagrant  109 Sep 14 04:23 Dockerfile
-rwxr-xr-x 1 vagrant vagrant   33 Sep 14 04:21 helloworld*
FROM  ubuntu:16.04                             # 베이스 이미지 정의
COPY  helloworld  /usr/local/bin               # 호스트 파일을 컨테이너 안으로 복사
RUN   chmod  +x  /usr/local/bin/helloworld     # 도커 빌드 과정에서 컨테이너 안에서 실행할 명령
CMD   [ "helloworld" ]                         # 도커 빌드를 통해 만들어진 이미지를 
                                               # 도커 컨테이너로 실행하기 전에 실행할 명령
```

- Build docker image

```bash
vagrant@xenial64:~/chap01$ docker image build -t hellooworld:latest .
```

- Run the docker image

```bash
vagrant@xenial64:~/chap01$ docker container run hellooworld:latest 
Hello, World!
vagrant@xenial64:~/chap01$ docker container ls
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
vagrant@xenial64:~/chap01$ docker container ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
vagrant@xenial64:~/chap01$ docker container ps -a
CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS                      PORTS               NAMES
7eefdd7614d8        hellooworld:latest   "helloworld"        35 seconds ago      Exited (0) 34 seconds ago                       zen_cerf
```

Build example docker image

```bash
vagrant@xenial64:~/chap02$ cat main.go
package main

import (
        "fmt"
        "log"
        "net/http"
)

func main() {
        http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
                log.Println("received request")
                fmt.Fprintf(w, "Hello Docker!!")
        })
        log.Println("start server")
        server := &http.Server{ Addr: ":8080" }
        if err := server.ListenAndServe(); err != nil {
                log.Println(err)
        }
}

vagrant@xenial64:~/chap02$ cat Dockerfile 
FROM   golang:1.9

RUN    mkdir   /echo

COPY   main.go   /echo

CMD [ "go", "run", "/echo/main.go" ]
```

```bash
vagrant@xenial64:~/chap02$ docker image build -t example/echo:latest .
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM   golang:1.9
1.9: Pulling from library/golang
55cbf04beb70: Pull complete 
1607093a898c: Pull complete 
9a8ea045c926: Pull complete 
d4eee24d4dac: Pull complete 
9c35c9787a2f: Pull complete 
8b376bbb244f: Pull complete 
0d4eafcc732a: Pull complete 
186b06a99029: Pull complete 
Digest: sha256:8b5968585131604a92af02f5690713efadf029cc8dad53f79280b87a80eb1354
Status: Downloaded newer image for golang:1.9
 ---> ef89ef5c42a9
Step 2/4 : RUN    mkdir   /echo
 ---> Running in 1c0457d8c725
Removing intermediate container 1c0457d8c725
 ---> 9b36831c0364
Step 3/4 : COPY   main.go   /echo
 ---> dcede57f88a4
Step 4/4 : CMD [ "go", "run", "/echo/main.go" ]
 ---> Running in dbf2a23f060c
Removing intermediate container dbf2a23f060c
 ---> ff8ee2f96242
Successfully built ff8ee2f96242
Successfully tagged example/echo:latest
vagrant@xenial64:~/chap02$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
example/echo        latest              ff8ee2f96242        10 seconds ago      750MB
hellooworld         latest              ba52dbaf0099        2 hours ago         127MB
ubuntu              16.04               4b22027ede29        3 weeks ago         127MB
golang              1.9                 ef89ef5c42a9        2 years ago         750MB
gihyodocker/echo    latest              3dbbae6eb30d        2 years ago         733MB
```

- Access to http://[localhost](http://localhost):9000
    - -d : daemon : background, 제어권 넘어온다

```bash
vagrant@xenial64:~$ docker container run -tdp 9000:8080 example/echo
a4de020a3bc4bcbaae1588041189cb03c4f74f3a8b9d438ff65da2829aba965a
vagrant@xenial64:~$ curl http://localhost:9000
Hello Docker!!vagrant@xenial64:~$
```

- docker container ls —filter

- container 일괄 삭제, image 일괄 삭제
    - -q : get id

```bash
vagrant@xenial64:~/chap02$ docker container rm -f $(docker container ls -aq)
vagrant@xenial64:~/chap02$ docker image rm -f $(docker image ls -q)
```

- push to docker hub

```bash
agrant@xenial64:~/basetest$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: zzid
Password: 
WARNING! Your password will be stored unencrypted in /home/vagrant/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
vagrant@xenial64:~/basetest$ docker image push zzid/basetest:latest
The push refers to repository [docker.io/zzid/basetest]
e0618718ee6e: Pushed 
be8b8b42328a: Mounted from library/busybox 
latest: digest: sha256:c20108717ee68a6a323ad93d7414654b55a3fe332fd05f23e8634a3414633b4f size: 734
vagrant@xenial64:~/basetest$
```