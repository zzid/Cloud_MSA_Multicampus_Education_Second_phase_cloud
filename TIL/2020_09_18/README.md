# 2020_09_18

# Kubernetes

---

- 컨테이너 관리 도구

### **#1 가상머신 생성**

C:\kubernetes\Vagrantfile

```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.hostname = "ubuntu"
  config.vm.network "private_network", ip: "192.168.111.110"
  config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = 2048
  end
end
```

### **#2 패키지 최신화**

```bash
vagrant@ubuntu:~$ sudo su
root@ubuntu:/home/vagrant# cd
root@ubuntu:~# apt update
root@ubuntu:~# apt upgrade
```

### **#3 도커 설치 및 설정**

```bash
root@ubuntu:~# apt install docker.io -y
root@ubuntu:~# usermod -a -G docker vagrant
root@ubuntu:~# service docker restart
root@ubuntu:~# chmod 666 /var/run/docker.sock
```

### **#4 kubectl 설치**

[https://kubernetes.io/ko/docs/tasks/tools/install-kubectl/](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl/)

```bash
root@ubuntu:~# apt-get update && sudo apt-get install -y apt-transport-https gnupg2
root@ubuntu:~# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
root@ubuntu:~# echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
root@ubuntu:~# apt-get update
root@ubuntu:~# apt-get install -y kubectl
```

### **#5 Minikube 설치**

[https://kubernetes.io/ko/docs/tasks/tools/install-minikube/](https://kubernetes.io/ko/docs/tasks/tools/install-minikube/)

```bash
root@ubuntu:~# curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
root@ubuntu:~# mkdir -p /usr/local/bin/
root@ubuntu:~# install minikube /usr/local/bin/
```

k8s = kubernetes

### **#6 클러스터 시작**

```bash
vagrant@ubuntu:~$ minikube start
😄 minikube v1.13.0 on Ubuntu 18.04 (vbox/amd64)
✨ Automatically selected the docker driver
⛔ Requested memory allocation (1992MB) is less than the recommended minimum 2000MB. Deployments may fail.
🧯 The requested memory allocation of 1992MiB does not leave room for system overhead (total system memory: 1992MiB). You may face stability issues.
💡 Suggestion: Start minikube with less memory allocated: 'minikube start --memory=1992mb'
👍 Starting control plane node minikube in cluster minikube
🚜 Pulling base image ...
💾 Downloading Kubernetes v1.19.0 preload ...
> preloaded-images-k8s-v6-v1.19.0-docker-overlay2-amd64.tar.lz4: 486.28 MiB
🔥 Creating docker container (CPUs=2, Memory=1992MB) ...
🐳 Preparing Kubernetes v1.19.0 on Docker 19.03.8 ...
🔎 Verifying Kubernetes components...
🌟 Enabled addons: default-storageclass, storage-provisioner
🏄 Done! kubectl is now configured to use "minikube" by default
vagrant@ubuntu:~$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
vagrant@ubuntu:~$ kubectl version
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.2", GitCommit:"f5743093fd1c663cb0cbc89748f730662345d44d", GitTreeState:"clean", BuildDate:"2020-09-16T13:41:02Z", GoVersion:"go1.15", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.0", GitCommit:"e19964183377d0ec2052d1f1fa930c4d7575bd50", GitTreeState:"clean", BuildDate:"2020-08-26T14:23:04Z", GoVersion:"go1.15", Compiler:"gc", Platform:"linux/amd64"}
```

## debug

(클러스터 내부에 테스트를 위한 임시 포드를 생성해서 nginx 포드의 동작을 확인)

---

```bash
vagrant@ubungtu:~$ kubectl run -it --rm debug --image=alicek106/ubuntu:curl --restart=Never bash

If you don't see a command prompt, try pressing enter.

root@debug:/# kubectl get pods
bash: kubectl: command not found
root@debug:/# curl 172.18.0.3
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
root@debug:/# exit
exit
pod "debug" deleted
```

```bash
vagrant@ubungtu:~$ kubectl apply -f nginx-pod-with-ubuntu.yml 
pod/my-nginx-pod created
vagrant@ubungtu:~$ kubectl get po
NAME           READY   STATUS              RESTARTS   AGE
my-nginx-pod   0/2     ContainerCreating   0          5s
vagrant@ubungtu:~$ cat nginx-pod-with-ubuntu.yml 
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
spec:
  containers:
  - name: my-nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80
      protocol: TCP

  - name: ubuntu-sidecar-container
    image: alicek106/rr-test:curl
    command: [ "tail" ]
    args: [ "-f", "/dev/null" ]
vagrant@ubungtu:~$ kubectl exec -it my-nginx-pod -c ubuntu-sidecar-container -- bash
root@my-nginx-pod:/# curl localhost
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

→ 특정 컨테이너에게 명령어를 전달할 때는 -c 옵션을 사용

⇒ 우분투 컨테이너 내부에서 localhost 요청에 대해 응답이 도착하는 것을 확인

우분투 컨테이너의 localhost에서 nginx 서버로 접근이 가능 

**포드 내부의 컨테이너들은 네트워크와 같은 리눅스 네임스페이스를 공유**

- Test (Pod without nginx container)

```bash
vagrant@ubungtu:~$ cat nginx-pod-test.yml 
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod-test
spec:
  containers:
  - name: ubuntu-sidecar-container
    image: alicek106/rr-test:curl
    command: [ "tail" ]
    args: [ "-f", "/dev/null" ]
vagrant@ubungtu:~$ kubectl exec -it my-nginx-pod-test -- bash
root@my-nginx-pod-test:/# curl localhost
curl: (7) Failed to connect to localhost port 80: Connection refused
```

→ 웹 서버(nginx)를 포함하고 있지 않음

→ 80포트로 서비스를 제공하지 있지 않다.