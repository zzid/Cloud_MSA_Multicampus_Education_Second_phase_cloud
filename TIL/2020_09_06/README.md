# 2020_09_06

# **Linux( Ubuntu )**

### Concept

- * Linux kernel >> Linux distribution(배포판) - Debian, Ubuntu

 [Linux Kernel Source](https://github.com/torvalds/linux)

## Virtual Box

- GNU, GPL, FSF
- Network (Pictures are in the doc)

### NAT (Network Address Translation)

- 내부 망에서는 사설 IP 주소를 사용하여 통신을 하고, 외부망과의 통신시에는 NAT를 거쳐 공인 IP 주소로 자동 변환
- NAT network ( slight different with above one )

* Bridge adapter

* Host-only adapter

* Internal network

### Snapshot

- it's like take a picture of the one state

    (To do below, Should install extension in advance)

### Something between Host and Guest

* set "drag and drop"

* set "share clipboard"

* set " 'Share' folder "

### Terminal

* '$' : general user

* '#' : super user

### Install Nginx

```bash
$ sudo apt-get update

$ sudo apt-get install -y nginx

$ sudo service nginx restart

$ sudo service nginx status

* Access : web browser > http://localhost

$ ip a
```

- Access ubuntu nginx server from Host

### Port forwarding

- To make, Can access to NAT network thorough PORT