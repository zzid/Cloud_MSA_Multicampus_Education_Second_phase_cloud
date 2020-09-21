# 2020_09_09

Created: Sep 4, 2020
Created by: DongYun Hwang

# DevOps

---

### DevOps란

Dev(개발)과 Ops(운용)이 긴밀히 협조,연계하여 비즈니스 가치를 높이려고 하는 근무 방식이나 문화

- 개발과 운용의 경계를 없앰
- [https://sasperger.tistory.com/136](https://sasperger.tistory.com/136) (애자일 SW개발 101.pdf)
- Infrastructure As A Code [ IAAC ] ?

    >> Infrastructure를 code를 통해서 관리가 가능하다면? 

## Use Vagrant : local 개발 환경의 Infrastructure as Code화

### 가상 머신을 코드로 정의 하는 것!

- Vagrant : 가상환경 구축 도구
- Vagrant make a virtual env to VirtualBox (can change to other third-party SW)

- Make directory

    ```bash
    vagrant init
    ```

    >> Vagrantfile

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