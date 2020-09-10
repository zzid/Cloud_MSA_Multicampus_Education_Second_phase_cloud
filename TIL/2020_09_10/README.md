# 2020_09_10

Created: Sep 10, 2020
Created by: DongYun Hwang

### DevOps에서 가장 중요한것?

- 자동화!
- 인프라 구성과 같은 부분들은 관여하지 않아도 되도록!

---

## Vagrant iso image path

- ~/.vagrant.d/boxes/

---

### Vagrant로 인프라를 구성했을 때 Pros & cons

### Pros

- 환경 구축 작업 간소화
- 환경 공유 용이
- 환경 파악 용이
- 팀 차원의 유지보수 가능

### Cons

- 구축 절차를 알기 어렵다
- 설정을 추가할 수 없다
- 구출 절차를 다른 환경에서 유용하기 힘들다

---

- Vagrant의 단점을 개선하기 위해 >

# Ansible

---

인프라 구성 관리 도구 made with python

구성 :: 

- Ansible 본체
- Inventory
- module

- 환경 설정 및 구축 절차를 통일된 형식으로 기술
- 매개 변수 등 환경의 차이를 관리
- 실행 전에 변경되는 부분을 파악

- Install Ansible on Virtual machine

```bash
[vagrant@demo ~]$ sudo yum -y install epel-release
[vagrant@demo ~]$ sudo yum -y install ansible
```

- Make a server inventory (Add 'localhost' to inventory)

```bash
[vagrant@demo ~]$ sudo sh -c "echo \'localhost\' >> /etc/ansible/hosts"
[vagrant@demo ~]$ ansible localhost -b -c local -m service -a "name=nginx state=started"
```

Second command :: 

- ansible
- [localhost](http://localhost) (target among the servers in the inventory file)
- -b (root)
- -c local (target server is itself, so local, no SSH)
- -m service (Use ansible 'service' module(-m))
- -a (module's additional parameter)

## Ansible playbook

---

설치, 설정, 실행 하는 일련의 흐름을 가지고 구축 할때,

ansible 이 아닌 ansible-playbook 명령을 이용

```bash
[vagrant@demo ~]$ git clone https://github.com/devops-book/ansible-playbook-sample.git
[vagrant@demo ~]$ ls
ansible-playbook-sample
[vagrant@demo ~]$ cd ansible-playbook-sample/
[vagrant@demo ansible-playbook-sample]$ ls
development  group_vars  production  roles  site.yml
[vagrant@demo ansible-playbook-sample]$ cat site.yml
---
- hosts: webservers
  become: yes
  connection: local
  roles:
    - common
    - nginx
#    - serverspec
#    - serverspec_sample
#    - jenkins
```

- Inventory file 지정

```bash
[vagrant@demo ansible-playbook-sample]$ ansible-playbook -i development site.yml
```

- Another inventory

```bash
[vagrant@demo ansible-playbook-sample]$ ansible-playbook -i production site.yml
```

어떤 작업을 수행하는 방법을 정의하는 것이 playbook  file (site.yml file in here)

- ./roles/common/tasks/ , ./roles/nginx/tasks/ , ...

    각각의 role에서 수행해야 할 내용을 정의한 main.yml 파일이 있음

- ./roles/*/templates/index.html

    index.html 변경가능

## Dry-run

---

실제로 변경된 내용을 반영하지 않고 결과만 미리 확인 

- —check (Dry run)
- —diff (Show difference, change)

```bash
[vagrant@demo ansible-playbook-sample]$ ansible-playbook -i development site.yml --check --diff

PLAY [webservers] *******************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [localhost]

TASK [common : install epel] ********************************************************************************************************************************
ok: [localhost]

TASK [install nginx] ****************************************************************************************************************************************
ok: [localhost]

TASK [nginx : replace index.html] ***************************************************************************************************************************
--- before: /usr/share/nginx/html/index.html
+++ after: /home/vagrant/.ansible/tmp/ansible-local-26946cmEKeb/tmp3sQEPI/index.html.j2
@@ -1 +1 @@
-hello, production ansible
+HELLO, development ansible!!

changed: [localhost]

TASK [nginx start] ******************************************************************************************************************************************
ok: [localhost]

PLAY RECAP **************************************************************************************************************************************************
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

- 변경 사항 실제로 반영

```bash
[vagrant@demo ansible-playbook-sample]$ ansible-playbook -i development site.yml --diff
```

**Vagrant** VS **Ansible**

- (Ansible) 환경에 따라 다르게 동작하도록 할 수 있다 [ development : 개발 /  production : 운영  ]
- (Ansible) 선언적 > 유동적, scalable 하다.
- (Ansible) 항상 동일한 결과를 가져온다.

# Serverspec으로 인프라 구축 Test를 Code화

---

**Serverspec**

- 테스트 수행을 간단하고 쉽게 하기 위한 도구
- 인프라(서버) 설정 테스트 가능
- 테스트 항목에 대한 목록을 정해진 포맷을 기반으로 기술 가능
- 테스트 결과를 리포트 형식으로 출력 가능

**** **rvm 및 ruby 설치**

```bash
[vagrant@demo ansible-playbook-sample]$ command curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -

gpg: directory `/root/.gnupg' created

gpg: new configuration file `/root/.gnupg/gpg.conf' created

gpg: WARNING: options in `/root/.gnupg/gpg.conf' are not yet active during this run

gpg: keyring `/root/.gnupg/secring.gpg' created

gpg: keyring `/root/.gnupg/pubring.gpg' created

gpg: /root/.gnupg/trustdb.gpg: trustdb created

gpg: key D39DC0E3: public key "Michal Papis (RVM signing) <mpapis@gmail.com>" imported

gpg: Total number processed: 1

gpg: imported: 1 (RSA: 1)

gpg: no ultimately trusted keys found

[vagrant@demo ansible-playbook-sample]$ command curl -sSL https://rvm.io/pkuczynski.asc | sudo gpg2

--import -

gpg: key 39499BDB: public key "Piotr Kuczynski <piotr.kuczynski@gmail.com>" imported

gpg: Total number processed: 1

gpg: imported: 1 (RSA: 1)

[vagrant@demo ansible-playbook-sample]$ curl -L get.rvm.io | sudo bash -s stable

% Total % Received % Xferd Average Speed Time Time Time Current

Dload Upload Total Spent Left Speed

100 194 100 194 0 0 340 0 --:--:-- --:--:-- --:--:-- 340

100 24535 100 24535 0 0 10527 0 0:00:02 0:00:02 --:--:-- 16488

Downloading https://github.com/rvm/rvm/archive/1.29.10.tar.gz

Downloading https://github.com/rvm/rvm/releases/download/1.29.10/1.29.10.tar.gz.asc

gpg: Signature made Wed 25 Mar 2020 09:58:42 PM UTC using RSA key ID 39499BDB

gpg: Good signature from "Piotr Kuczynski <piotr.kuczynski@gmail.com>"

gpg: WARNING: This key is not certified with a trusted signature!

gpg: There is no indication that the signature belongs to the owner.

Primary key fingerprint: 7D2B AF1C F37B 13E2 069D 6956 105B D0E7 3949 9BDB

GPG verified '/usr/local/rvm/archives/rvm-1.29.10.tgz'

Creating group 'rvm'

Installing RVM to /usr/local/rvm/

Installation of RVM in /usr/local/rvm/ is almost complete:

* First you need to add all users that will be using rvm to 'rvm' group,

and logout - login again, anyone using rvm will be operating with `umask u=rwx,g=rwx,o=rx`.

* To start using RVM you need to run `source /etc/profile.d/rvm.sh`

in all your open shell windows, in rare cases you need to reopen all shell windows.

* Please do NOT forget to add your users to the rvm group.

The installer no longer auto-adds root or users to the rvm group. Admins must do this.

Also, please note that group memberships are ONLY evaluated at login time.

This means that users must log out then back in before group membership takes effect!

Thanks for installing RVM 🙏

Please consider donating to our open collective to help us maintain RVM.

👉 Donate: https://opencollective.com/rvm/donate

[vagrant@demo ansible-playbook-sample]$ sudo usermod -aG rvm $USER

[vagrant@demo ansible-playbook-sample]$ id $USER

uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant),1001(rvm)

[vagrant@demo ansible-playbook-sample]$ source /etc/profile.d/rvm.sh

[vagrant@demo ansible-playbook-sample]$ rvm reload

RVM reloaded!

[vagrant@demo ansible-playbook-sample]$ sudo su

[root@demo ansible-playbook-sample]# rvm requirements run

Checking requirements for centos.

Installing requirements for centos.

Installing required packages: bison, libffi-devel, readline-devel, sqlite-devel, zlib-devel, openssl-devel............

Requirements installation successful.

[root@demo ansible-playbook-sample]# rvm install 2.7

Searching for binary rubies, this might take some time.

Found remote file https://rvm_io.global.ssl.fastly.net/binaries/centos/7/x86_64/ruby-2.7.0.tar.bz2

Checking requirements for centos.

Requirements installation successful.

ruby-2.7.0 - #configure

ruby-2.7.0 - #download

% Total % Received % Xferd Average Speed Time Time Time Current

Dload Upload Total Spent Left Speed

100 18.3M 100 18.3M 0 0 73231 0 0:04:22 0:04:22 --:--:-- 74837

No checksum for downloaded archive, recording checksum in user configuration.

ruby-2.7.0 - #validate archive

ruby-2.7.0 - #extract

ruby-2.7.0 - #validate binary

ruby-2.7.0 - #setup

ruby-2.7.0 - #gemset created /usr/local/rvm/gems/ruby-2.7.0@global

ruby-2.7.0 - #importing gemset /usr/local/rvm/gemsets/global.gems..................................

ruby-2.7.0 - #generating global wrappers.......

ruby-2.7.0 - #gemset created /usr/local/rvm/gems/ruby-2.7.0

ruby-2.7.0 - #importing gemsetfile /usr/local/rvm/gemsets/default.gems evaluated to empty gem list

ruby-2.7.0 - #generating default wrappers.......

[root@demo ansible-playbook-sample]# rvm use 2.7 --default

Using /usr/local/rvm/gems/ruby-2.7.0

[root@demo ansible-playbook-sample]# rvm list

=* ruby-2.7.0 [ x86_64 ]

# => - current

# =* - current && default

# * - default

[vagrant@demo ansible-playbook-sample]$ ruby -v

ruby 2.0.0p648 (2015-12-16) [x86_64-linux]

[vagrant@demo ansible-playbook-sample]$ sudo ruby -v

ruby 2.0.0p648 (2015-12-16) [x86_64-linux]

[vagrant@demo ansible-playbook-sample]$ rvm use 2.7 --default

Using /usr/local/rvm/gems/ruby-2.7.0

[vagrant@demo ansible-playbook-sample]$ ruby -v

ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux]

[vagrant@demo ansible-playbook-sample]$ which ruby

/usr/local/rvm/rubies/ruby-2.7.0/bin/ruby

[vagrant@demo ansible-playbook-sample]$ sudo which ruby

/bin/ruby

[vagrant@demo ansible-playbook-sample]$ sudo mv /bin/ruby /bin/ruby_2.0.0

[vagrant@demo ansible-playbook-sample]$ sudo ln -s /usr/local/rvm/rubies/ruby-2.7.0/bin/ruby /bin/ruby

[vagrant@demo ansible-playbook-sample]$ ruby -v

ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux]

[vagrant@demo ansible-playbook-sample]$ sudo ruby -v

ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux]
```

- (first, second ) command curl ~~ : get key
- (next) excute key
- (next) rvm 사용자 그룹에 등록
- (next) rvm reload
- (next) ruby install with rvm
- (next) ruby version still 2.0.0
- (next) sudo ruby -v ≠ ruby -v  : this is problem
- (next) so change and link

Ansible is running on root, so it has to be same!

## Serverspec

---

- 서버 설정을 테스트 할 수 있는 프로그램
- 인프라가 내가 원하는 대로 구축되었는지? 테스트 하는 것

```bash
[vagrant@demo ansible-playbook-sample]$ serverspec-init
Select OS type:

  1) UN*X
  2) Windows

Select number: 1

Select a backend type:

  1) SSH
  2) Exec (local)

Select number: 2

 + spec/
 + spec/localhost/
 + spec/localhost/sample_spec.rb
 + spec/spec_helper.rb
 + Rakefile
 + .rspec
```

sample_spec.rb (ruby file) 

- Test cast 작성법을 확인

[ serverspec_sample ]

Ansible을 이용해서 Serverspec에서 사용하는 테스트 케이스(= _spec.rb)를 자동으로 생성 

```bash
Ansible을 이용해서 Serverpec에서 사용하는 테스트 케이스(_sepc.rb)를 자동으로 생성
#1 Playbook 파일(site.yml)에 serverspec_sample 롤(role)을 추가
[vagrant@demo ansible-playbook-sample]$ vi site.yml
---
- hosts: webservers
  become: yes
  connection: local
  roles:
    - common
    - nginx
    - serverspec                 
    - serverspec_sample           ⇐ 주석(#) 해제 후 저장
#    - jenkins

#2 serverspec_sample 롤 정의 파일을 확인
[vagrant@demo ansible-playbook-sample]$ cat ./roles/serverspec_sample/tasks/main.yml
---
# tasks file for serverspec_sample
- name: distribute serverspec suite
  copy: src=serverspec_sample dest={{ serverspec_base_path }}	⇐ /tmp 아래로 serverspec_sample 디렉터리를 복사

- name: distribute spec file
  template: src=web_spec.rb.j2 dest={{ serverspec_path }}/spec/localhost/web_spec.rb
									⇐ 템플릿에 정의된 내용으로 web_spec.rb 파일을 생성

[vagrant@demo ansible-playbook-sample]$ cat ./roles/serverspec_sample/vars/main.yml	
serverspec_base_path: "/tmp"						⇐ task에서 사용하는 변수를 정의
serverspec_path: "{{ serverspec_base_path }}/serverspec_sample"

[vagrant@demo ansible-playbook-sample]$ cat ./roles/serverspec_sample/templates/web_spec.rb.j2
require 'spec_helper'							⇐ serverspec에서 사용할 테스트 케이스 템플릿

describe package('nginx') do		⇐ nginx 설치 여부
  it { should be_installed }
end

describe service('nginx') do		⇐ nginx 실행/활성화 여부
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do			⇐ 80 포트 확인
  it { should be_listening }
end

describe file('/usr/share/nginx/html/index.html') do
  it { should be_file }		⇐ index.html 파일 존재 여부
  it { should exist }
  its(:content) { should match /^Hello, {{ env }} ansible!!$/ }	⇐ index.html 파일의 내용 검증
end

#3 ansible-playbook으로 spec 파일(테스트 케이스를 정의하고 있는 파일)을 배포
[vagrant@demo ansible-playbook-sample]$ ansible-playbook -i development site.yml
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [webservers] *********************************************************************************

TASK [Gathering Facts] ****************************************************************************
ok: [localhost]

TASK [common : install epel] **********************************************************************
ok: [localhost]

TASK [install nginx] ******************************************************************************
ok: [localhost]

TASK [nginx : replace index.html] *****************************************************************
ok: [localhost]

TASK [nginx start] ********************************************************************************
ok: [localhost]

TASK [serverspec : install ruby] ******************************************************************
ok: [localhost]

TASK [install serverspec] *************************************************************************
ok: [localhost] => (item=rake)
ok: [localhost] => (item=serverspec)

TASK [serverspec_sample : distribute serverspec suite] ********************************************
changed: [localhost]		⇐ /tmp 디렉터리 아래로 serverspec_sample 디렉터리를 복사
                                       /tmp/serverspec_sample 디렉터리는 인프라가 원하는 형태로 구성되었는지 테스트하는 공간
TASK [serverspec_sample : distribute spec file] ***************************************************
changed: [localhost]		⇐ 템플릿을 이용해서 web_spec.rb 파일을 정상적으로 생성

PLAY RECAP ****************************************************************************************
localhost                  : ok=9    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

#4 spec 파일(테스트 케이스를 정의) 생성을 확인
[vagrant@demo ansible-playbook-sample]$ cat /tmp/serverspec_sample/spec/localhost/web_spec.rb
require 'spec_helper'

describe package('nginx') do
  it { should be_installed }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe file('/usr/share/nginx/html/index.html') do
  it { should be_file }
  it { should exist }
  its(:content) { should match /^Hello, development ansible!!$/ }
end

#5 (ansible을 이용해서 자동으로 생성한 spec 파일을 이용해서) 테스트를 실행
[vagrant@demo ansible-playbook-sample]$ cd /tmp/serverspec_sample/	⇐ 작업 디렉터리(테스트 디렉터리)로 이동
[vagrant@demo serverspec_sample]$ rake spec					⇐ 테스트 실행
/usr/local/rvm/rubies/ruby-2.7.0/bin/ruby -I/usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-support-3.9.3/lib:/usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-core-3.9.2/lib /usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-core-3.9.2/exe/rspec --pattern spec/localhost/\*_spec.rb

Package "nginx"
  is expected to be installed

Service "nginx"
  is expected to be enabled
  is expected to be running

Port "80"
  is expected to be listening

File "/usr/share/nginx/html/index.html"
  is expected to be file
  is expected to exist
  content
    is expected to match /^Hello, development ansible!!$/ (FAILED - 1)		⇐ nginx의 index.html 파일 내용이 테스트 케이스에 명싱된 내용과
                                                                                    다르기 때문에 테스트 실패가 발생 
Failures:

  1) File "/usr/share/nginx/html/index.html" content is expected to match /^Hello, development ansible!!$/
     On host `localhost'
     Failure/Error: its(:content) { should match /^Hello, development ansible!!$/ }
       expected "HELLO, development ansible !!!\n" to match /^Hello, development ansible!!$/
       Diff:
       @@ -1 +1 @@
       -/^Hello, development ansible!!$/
       +HELLO, development ansible !!!

       /bin/sh -c cat\ /usr/share/nginx/html/index.html\ 2\>\ /dev/null\ \|\|\ echo\ -n
       HELLO, development ansible !!!

     # ./spec/localhost/web_spec.rb:19:in `block (2 levels) in <top (required)>'

Finished in 0.11232 seconds (files took 0.40656 seconds to load)
7 examples, 1 failure

Failed examples:

rspec ./spec/localhost/web_spec.rb:19 # File "/usr/share/nginx/html/index.html" content is expected to match /^Hello, development ansible!!$/

/usr/local/rvm/rubies/ruby-2.7.0/bin/ruby -I/usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-support-3.9.3/lib:/usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-core-3.9.2/lib /usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-core-3.9.2/exe/rspec --pattern spec/localhost/\*_spec.rb failed

#6 테스트 케이스를 통과하도록 컨텐츠를 수정 → 컨텐츠 형식을 정의하고 있는 템플릿 파일을 수정
[vagrant@demo ansible-playbook-sample]$ cat ~/ansible-playbook-sample/roles/nginx/templates/index.html.j2
HELLO, {{ env }} ansible !!!				⇐ 테스트 케이스와 상이 → 테스트 케이스에 맞춰서 수정

[vagrant@demo ansible-playbook-sample]$ vi ~/ansible-playbook-sample/roles/nginx/templates/index.html.j2
Hello, {{ env }} ansible!!

#7 ansible-playbook으로 수정한 템플릿에 맞춰서 새롭게 index.html을 생성
[vagrant@demo ansible-playbook-sample]$ ansible-playbook -i development site.yml
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [webservers] *********************************************************************************

TASK [Gathering Facts] ****************************************************************************
ok: [localhost]

TASK [common : install epel] **********************************************************************
ok: [localhost]

TASK [install nginx] ******************************************************************************
ok: [localhost]

TASK [nginx : replace index.html] *****************************************************************
changed: [localhost]

TASK [nginx start] ********************************************************************************
ok: [localhost]

TASK [serverspec : install ruby] ******************************************************************
ok: [localhost]

TASK [install serverspec] *************************************************************************
ok: [localhost] => (item=rake)
ok: [localhost] => (item=serverspec)

TASK [serverspec_sample : distribute serverspec suite] ********************************************
ok: [localhost]

TASK [serverspec_sample : distribute spec file] ***************************************************
ok: [localhost]

PLAY RECAP ****************************************************************************************
localhost                  : ok=9    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

#8  테스트를 실행
[vagrant@demo ansible-playbook-sample]$ cd /tmp/serverspec_sample/
[vagrant@demo serverspec_sample]$ rake spec
/usr/local/rvm/rubies/ruby-2.7.0/bin/ruby -I/usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-support-3.9.3/lib:/usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-core-3.9.2/lib /usr/local/rvm/rubies/ruby-2.7.0/lib/ruby/gems/2.7.0/gems/rspec-core-3.9.2/exe/rspec --pattern spec/localhost/\*_spec.rb

Package "nginx"
  is expected to be installed

Service "nginx"
  is expected to be enabled
  is expected to be running

Port "80"
  is expected to be listening

File "/usr/share/nginx/html/index.html"
  is expected to be file
  is expected to exist
  content
    is expected to match /^Hello, development ansible!!$/

Finished in 0.10557 seconds (files took 0.41014 seconds to load)
7 examples, 0 failures			⇐ 7개 테스트 케이스를 모두 통과
```

### Coderay

---

```bash
[vagrant@demo serverspec_sample]$ gem install coderay
[vagrant@demo serverspec_sample]$ rake spec SPEC_OPTS="--format html" > ~/result.html
[vagrant@demo serverspec_sample]$ sudo mv ~/result.html /usr/share/nginx/html/
[vagrant@demo serverspec_sample]$ sudo systemctl stop firewalld
```

- 이후 [http://192.168.33.10/result.html](http://192.168.33.10/result.html) 접속하여 확인

이제, 테스트 케이스를 자동으로 생성하는 코드가 있으니,

테스트를 자동으로 실행까지 해야 자동화라고 할 수 있다. >> Jenkins 이용