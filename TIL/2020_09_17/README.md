# 2020_09_17

# Docker (cont)

---

## docker swarm (cont)

- worker2

```bash
[root@swarm-worker2 vagrant]# docker swarm leave
Node left the swarm.
```

- docker node rm

```bash
[root@swarm-manager ~]# docker node ls
ID                           HOSTNAME       STATUS  AVAILABILITY  MANAGER STATUS
12gvfglvloms1l47tm0mwdbew    swarm-worker2  Down    Active        
4zblemwhglz0ueb4sp2mjnc4k    swarm-worker2  Ready   Active        
ljsplixh4506lem1dbej4g57b *  swarm-manager  Ready   Active        Leader
mpiuzp66dduddqkfwdwy80b4i    swarm-worker1  Ready   Active        
[root@swarm-manager ~]# docker node rm 12g
```

## Service

- hello world service

```bash
[root@swarm-manager ~]# docker service create ubuntu:14.04 bin/sh -c "while true; do echo hello world; sleep 1; done"
pn7d7rndrs0rfpai1j0xs96hz
[root@swarm-manager ~]# docker service ls
ID            NAME          MODE        REPLICAS  IMAGE
pn7d7rndrs0r  loving_hugle  replicated  0/1       ubuntu:14.04
[root@swarm-manager ~]# docker service ps loving_hugle
ID            NAME            IMAGE         NODE           DESIRED STATE  CURRENT STATE          ERROR  PORTS
tshuesexo5n3  loving_hugle.1  ubuntu:14.04  swarm-worker1  Running        Running 6 seconds ago
```

- rm service

```bash
[root@swarm-manager ~]# docker service rm loving_hugle
loving_hugle
[root@swarm-manager ~]# docker service ls
ID  NAME  MODE  REPLICAS  IMAGE
```

- nginx service

```bash
[root@swarm-manager ~]# docker service create --name zzidweb --replicas 2 -p 80:80 nginx
6s0fud2vsey96x3k7wx24bwrj
[root@swarm-manager ~]# docker service ps zzidweb
ID            NAME       IMAGE         NODE           DESIRED STATE  CURRENT STATE             ERROR  PORTS
ipx52tsxssi2  zzidweb.1  nginx:latest  swarm-manager  Running        Preparing 14 seconds ago         
6xiz000xe891  zzidweb.2  nginx:latest  swarm-worker2  Running        Preparing 14 seconds ago
```

### *** Trouble shooting (docker version update manually)

```bash
$ yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
```

### ERROR was.. port specification!!

- Service to workers (globally)

```bash
[root@swarm-manager ~]# docker service create --name zzidweb --mode global -p 80:80 nginx
b9bx6ebs14jz5s8dli7zmgdqj
overall progress: 3 out of 3 tasks 
ljsplixh4506: running   [==================================================>] 
akpuh8m52brb: running   [==================================================>] 
5orsobjg1ht0: running   [==================================================>] 
verify: Service converged 
[root@swarm-manager ~]# docker service ps zzidweb
ID                  NAME                                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
qr79foyb1xn4        zzidweb.5orsobjg1ht0wkk6bekov4qg4   nginx:latest        swarm-worker2       Running             Running 11 seconds ago                       
x79rhgov8uj1        zzidweb.ljsplixh4506lem1dbej4g57b   nginx:latest        swarm-manager       Running             Running 11 seconds ago                       
on4yonx3mvr4        zzidweb.akpuh8m52brb2s22p1m3bytex   nginx:latest        swarm-worker1       Running             Running 11 seconds ago
```

- not for all, just 2 replicas

```bash
[root@swarm-manager ~]# docker service create --name zzidweb --replicas 2 -p 80:80 nginx
```

```bash
http://192.168.111.100
http://192.168.111.101
http://192.168.111.102
```

### Work on all workers and manager

![2020_09_17%20961f4aa6b39f4385b0f3213b11150a91/Screen_Shot_2020-09-17_at_11.48.06_AM.png](2020_09_17%20961f4aa6b39f4385b0f3213b11150a91/Screen_Shot_2020-09-17_at_11.48.06_AM.png)

### Secret, Config

---

### Secret

- 비밀번호 같은 정보를 환경 변수로 설정하는 것은 보안상 좋지 않다.
- Secret → 비밀번호, ssh key, 인증서 key 같은 보안에 민감한 데이터를 전송하기 위한 용도
- Config → nginx나 레지스트리 설정 파일과 같이 암호화할 필요가 없는 설정 값 들에 사용

```bash
[root@swarm-manager ~]# echo 1q2w3e4r | docker secret create my_sql_password -
yfen7s3poi7rlzpb8l4ph62wu
[root@swarm-manager ~]# docker secret ls
ID                          NAME                DRIVER              CREATED             UPDATED
yfen7s3poi7rlzpb8l4ph62wu   my_sql_password                         5 seconds ago       5 seconds ago
[root@swarm-manager ~]# docker secret inspect my_mysql_password
[]
Status: Error: No such secret: my_mysql_password, Code: 1
[root@swarm-manager ~]# docker secret inspect my_sql_password
[
    {
        "ID": "yfen7s3poi7rlzpb8l4ph62wu",
        "Version": {
            "Index": 390
        },
        "CreatedAt": "2020-09-17T04:49:26.000218704Z",
        "UpdatedAt": "2020-09-17T04:49:26.000218704Z",
        "Spec": {
            "Name": "my_sql_password",
            "Labels": {}
        }
    }
]

[root@swarm-manager ~]# docker service create --name mysql --replicas 1 --secret source=my_sql_password,target=mysql_root_password --secret source=my_sql_password,target=mysql_password -e MYSQL_ROOT_PASSWORD_FILE="/run/secrets/mysql_root_password" -e MYSQL_PASSWORD_FILE="/run/secrets/mysql_password" -e MYSQL_DATABASE="wordpress" mysql:5.7
hm8ql11q1alc9bne2zb4vucgz
overall progress: 1 out of 1 tasks 
1/1: running   [==================================================>] 
verify: Service converged 
[root@swarm-manager ~]# docker service ps mysql
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
66crz6de8kcy        mysql.1             mysql:5.7           swarm-worker1       Running             Running 2 minutes ago
[root@swarm-worker1 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                 NAMES
3bccec8898fe        mysql:5.7           "docker-entrypoint.s…"   3 minutes ago       Up 3 minutes        3306/tcp, 33060/tcp   mysql.1.66crz6de8kcyhxlweml8z68nn
195cf70d5eeb        nginx:latest        "/docker-entrypoint.…"   3 hours ago         Up 3 hours          80/tcp                zzidweb.akpuh8m52brb2s22p1m3bytex.on4yonx3mvr49digtl7ffa8yn
[root@swarm-worker1 ~]# docker exec mysql.1.66crz6de8kcyhxlweml8z68nn ls /run/secrets
mysql_password
mysql_root_password
[root@swarm-worker1 ~]# docker exec mysql.1.66crz6de8kcyhxlweml8z68nn ls /run/secrets/mysql_password
/run/secrets/mysql_password
[root@swarm-worker1 ~]# docker exec mysql.1.66crz6de8kcyhxlweml8z68nn ls /run/secrets/mysql_root_password
/run/secrets/mysql_root_password
```

---

### config

```bash
[root@swarm-manager ~]# docker config create registry-config config.yml
czuzya90ny4affka9767dfc78
[root@swarm-manager ~]# docker config ls
ID                          NAME                CREATED             UPDATED
czuzya90ny4affka9767dfc78   registry-config     4 seconds ago       4 seconds ago
[root@swarm-manager ~]# docker config inspect registry-config
[
    {
        "ID": "czuzya90ny4affka9767dfc78",
        "Version": {
            "Index": 398
        },
        "CreatedAt": "2020-09-17T05:20:18.494249544Z",
        "UpdatedAt": "2020-09-17T05:20:18.494249544Z",
        "Spec": {
            "Name": "registry-config",
            "Labels": {},
            "Data": "dmVyc2lvbjogMC4xCmxvZzoKICBsZXZlbDogaW5mbyAKc3RvcmFnZToKICBmaWxlc3lzdGVtOgogICAgcm9vdGRpcmVjdG9yeTogL3JlZ2lzdHJ5X2RhdGEKICBkZWxldGU6CiAgICBlbmVhYmxlZDogdHJ1ZQpodHRwOgogIGFkZHI6IDAuMC4wLjA6NTAwMAo="
        }
    }
]
```

- bas64 encoding

```bash
[root@swarm-manager ~]# echo dmVyc2lvbjogMC4xCmxvZzoKICBsZXZlbDogaW5mbyAKc3RvcmFnZToKICBmaWxlc3lzdGVtOgogICAgcm9vdGRpcmVjdG9yeTogL3JlZ2lzdHJ5X2RhdGEKICBkZWxldGU6CiAgICBlbmVhYmxlZDogdHJ1ZQpodHRwOgogIGFkZHI6IDAuMC4wLjA6NTAwMAo= | base64 -d
version: 0.1
log:
  level: info 
storage:
  filesystem:
    rootdirectory: /registry_data
  delete:
    eneabled: true
http:
  addr: 0.0.0.0:5000
```

- 사설 레지스트리 생성

```bash
[root@swarm-manager ~]# docker service create --name yml_registry -p 5000:5000 --config source=registry-config,target=/etc/docker/registry/config.yml registry:2.6
wneqco2lcs38zon9urkz360oc
overall progress: 1 out of 1 tasks 
1/1: running   [==================================================>] 
verify: Service converged
```

## Network

---

### ingress network

```bash
$ docker network ls
$ docker network ls | grep ingress
```

[https://myanjini.tistory.com/entry/도커-스웜-네트워크](https://myanjini.tistory.com/entry/%EB%8F%84%EC%BB%A4-%EC%8A%A4%EC%9B%9C-%EB%84%A4%ED%8A%B8%EC%9B%8C%ED%81%AC)