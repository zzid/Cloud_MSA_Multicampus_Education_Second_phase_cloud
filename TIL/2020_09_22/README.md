# 2020_09_22

# Kubernetes

## cont.

### Pod

→ container의 묶음

### Replica set

→ pod의 묶음

## Config map

일반적인 설정 정보(값)을 저장할 수 있는 Kubernetes object

```bash
vagrant@ubungtu:~$ minikube start
😄  minikube v1.13.0 on Ubuntu 18.04 (vbox/amd64)
🎉  minikube 1.13.1 is available! Download it: https://github.com/kubernetes/minikube/releases/tag/v1.13.1
💡  To disable this notice, run: 'minikube config set WantUpdateNotification false'

✨  Using the docker driver based on existing profile

⛔  Requested memory allocation (1992MB) is less than the recommended minimum 2000MB. Deployments may fail.

🧯  The requested memory allocation of 1992MiB does not leave room for system overhead (total system memory: 1992MiB). You may face stability issues.
💡  Suggestion: Start minikube with less memory allocated: 'minikube start --memory=1992mb'

👍  Starting control plane node minikube in cluster minikube
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.19.0 on Docker 19.03.8 ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" by default
```

- Set

```bash
vagrant@ubuntu:~$ kubectl create configmap log-level-configmap --from-literal LOG_LEVEL=DEBUG
configmap/log-level-configmap created

vagrant@ubuntu:~$ kubectl create configmap start-k8s --from-literal k8s=kubernetes --from-literal container=docker
configmap/start-k8s created                ~~~~~~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                           컨피그맵 이름            | <-------  키=값 -------> |
```

- Check

```bash
vagrant@ubungtu:~$ kubectl descirbe configmap log-level-configmap
Error: unknown command "descirbe" for "kubectl"

Did you mean this?
	describe

Run 'kubectl --help' for usage.
vagrant@ubungtu:~$ kubectl describe configmap log-level-configmap
Name:         log-level-configmap
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
LOG_LEVEL:
----
DEBUG
Events:  <none>
```

- Print yml format

```bash
vagrant@ubungtu:~$  kubectl get configmap log-level-configmap -o yaml
apiVersion: v1
data:
  LOG_LEVEL: DEBUG
kind: ConfigMap
metadata:
  creationTimestamp: "2020-09-22T01:21:00Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:LOG_LEVEL: {}
    manager: kubectl-create
    operation: Update
    time: "2020-09-22T01:21:00Z"
  name: log-level-configmap
  namespace: default
  resourceVersion: "21290"
  selfLink: /api/v1/namespaces/default/configmaps/log-level-configmap
  uid: 4c65742f-8098-4f67-befb-4ac585f91618
```

### Using config map in pod

1. config map 값을 환경변수로 사용
    - all-env-from-configmap.yml

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
      name: container-env-example
    spec:
      containers:
        - name: my-container
          image: busybox
          args: ['tail', '-f', '/dev/null']
          envFrom:                          
            - configMapRef:
                name: log-level-configmap
            - configMapRef:
                name: start-k8s
    ```

    - create pod

    ```bash
    vagrant@ubungtu:~$ kubectl apply -f all-env-from-configmap.yml 
    pod/container-env-example created

    vagrant@ubungtu:~$ kubectl get po
    NAME                                   READY   STATUS    RESTARTS   AGE
    container-env-example                  1/1     Running   0          22s
    hostname-deployment-7dfd748479-fw7dl   1/1     Running   1          19h
    hostname-deployment-7dfd748479-pdxll   1/1     Running   1          19h
    hostname-deployment-7dfd748479-s889l   1/1     Running   1          19h

    vagrant@ubungtu:~$ kubectl exec container-env-example env
    kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    HOSTNAME=container-env-example
    LOG_LEVEL=DEBUG
    container=docker
    k8s=kubernetes
    HOSTNAME_SVC_NODEPORT_PORT_8080_TCP_PROTO=tcp
    KUBERNETES_SERVICE_HOST=10.96.0.1
    KUBERNETES_SERVICE_PORT_HTTPS=443
    KUBERNETES_PORT_443_TCP_PROTO=tcp
    HOSTNAME_SVC_NODEPORT_SERVICE_PORT_WEB_PORT=8080
    HOSTNAME_SVC_NODEPORT_PORT=tcp://10.99.51.186:8080
    KUBERNETES_SERVICE_PORT=443
    KUBERNETES_PORT=tcp://10.96.0.1:443
    KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
    HOSTNAME_SVC_NODEPORT_SERVICE_PORT=8080
    KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
    HOSTNAME_SVC_NODEPORT_PORT_8080_TCP=tcp://10.99.51.186:8080
    HOSTNAME_SVC_NODEPORT_PORT_8080_TCP_PORT=8080
    HOSTNAME_SVC_NODEPORT_PORT_8080_TCP_ADDR=10.99.51.186
    KUBERNETES_PORT_443_TCP_PORT=443
    HOSTNAME_SVC_NODEPORT_SERVICE_HOST=10.99.51.186
    HOME=/root
    ```

    ## **2. 컨피그맵의 값을 포드 내부 파일로 마운트해서 사용**

    ### **컨피그맵의 모든 키-쌍 데이터를 포드에 마운트**

    vagrant@ubuntu:~$ vi volume-mount-configmap.yml

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
      name: configmap-volume-pod
    spec:
      containers:
        - name: my-container
          image: busybox
          args: ["tail", "-f", "/dev/null"]
          volumeMounts:                  ⇐ #1에서 정의한 볼륨을 컨테이너 내부의 어떤 디렉터리에 마운트할 것인지 명시
            - name: configmap-volume     ⇐ 컨피그맵 볼룸의 이름 (#1에서 정의한 이름)
              mountPath: /etc/config     ⇐ 컨피그맵 파일이 위치할 경로

      volumes:                           ⇐ #1 사용할 볼륨 목록 
        - name: configmap-volume           
          configMap:
            name: start-k8s              ⇐ 컨피그맵 이름
    ```

    ### 파드 생성

    ```bash
    vagrant@ubuntu:~$ kubectl apply -f volume-mount-configmap.yml
    pod/configmap-volume-pod created
    ```

    ### 파드 생성 확인

    ```bash
    vagrant@ubuntu:~$ kubectl get pods
    NAME READY STATUS RESTARTS AGE

    configmap-volume-pod 1/1 Running 0 27s

    container-env-example 1/1 Running 0 53m

    hostname-deployment-7dfd748479-7zdv7 1/1 Running 0 20h

    hostname-deployment-7dfd748479-pp8x4 1/1 Running 0 20h

    hostname-deployment-7dfd748479-rtgzv 1/1 Running 0 20h
    ```

    ### 파드의 /etc/config 디렉터리를 확인

    ```bash
    vagrant@ubuntu:~$ kubectl exec configmap-volume-pod -- ls -l /etc/config

    total 0

    lrwxrwxrwx 1 root root 16 Sep 22 02:33 container -> ..data/container

    lrwxrwxrwx 1 root root 10 Sep 22 02:33 k8s -> ..data/k8s
    ```

    ### 파일 내용 확인

    ```bash
    vagrant@ubuntu:~$ kubectl exec configmap-volume-pod -- cat /etc/config/container

    docker

    vagrant@ubuntu:~$ kubectl exec configmap-volume-pod -- cat /etc/config/k8s

    kubernetes

    vagrant@ubuntu:~$
    ```

    ⇒ 컨피그맵에 **키는 파일명**으로, **값은 파일의 내용**으로 변경되어서 전달

    ### **원하는 키-값 쌍의 데이터만 선택해서 포드로 마운트**

    ```bash
    vagrant@ubuntu:~$ cp volume-mount-configmap.yml selective-volume-configmap.yml
    ```

    - selective-volume-configmap.yml

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
      name: configmap-volume-pod
    spec:
      containers:
        - name: my-container
          image: busybox
          args: ["tail", "-f", "/dev/null"]
          volumeMounts:
            - name: configmap-volume
              mountPath: /etc/config
      volumes:
        - name: configmap-volume
          configMap:
            name: start-k8s
            items:
            - key: k8s                ⇐ 가져올 키를 명시
              path: k8s_fullname      ⇐ 키 값을 저장할 파일명
    ```

    ### 앞에서 생성한 파드를 삭제

    ```bash
    vagrant@ubuntu:~$ kubectl delete -f volume-mount-configmap.yml

    pod "configmap-volume-pod" deleted
    ```

    ### 파드 생성 및 확인

    ```bash
    vagrant@ubuntu:~$ kubectl apply -f selective-volume-configmap.yml

    pod/configmap-volume-pod created

    vagrant@ubuntu:~$ kubectl get pods

    NAME READY STATUS RESTARTS AGE

    configmap-volume-pod 1/1 Running 0 8s

    container-env-example 1/1 Running 0 63m

    hostname-deployment-7dfd748479-7zdv7 1/1 Running 0 20h

    hostname-deployment-7dfd748479-pp8x4 1/1 Running 0 20h

    hostname-deployment-7dfd748479-rtgzv 1/1 Running 0 20h
    ```

    ### 파드(컨테이너) 내부의 파일 생성 여부 확인

    ```bash
    vagrant@ubuntu:~$ kubectl exec configmap-volume-pod -- ls /etc/config

    k8s_fullname

    vagrant@ubuntu:~$ kubectl exec configmap-volume-pod -- cat /etc/config/k8s_fullname

    kubernetes
    ```

    ### 테스트 파일 생성

    ```bash
    vagrant@ubuntu:~$ echo Hello, world! >> index.html

    vagrant@ubuntu:~$ cat index.html

    Hello, world!
    ```

    ### 테스트 파일(index.html)을 이용해서 index-file이라는 컨피그맵을 생성

    ```bash
    vagrant@ubuntu:~$ kubectl create configmap index-file --from-file ./index.html
    configmap/index-file created
    ```

    ### 생성한 index-file 컨피그맵을 확인

    ```bash
    vagrant@ubuntu:~$ kubectl describe configmap index-file

    Name: index-file

    Namespace: default

    Labels: <none>

    Annotations: <none>

    Data
    ```

    index.html:	⇐ 파일명이 키(key)로 사용

    - ---

    Hello, world!	⇐ 파일의 내용이 값(value)로 사용

    Events: <none>

    ### 키이름을 직접 지정해서 컨피그맵을 생성

    ```bash
    vagrant@ubuntu:~$ kubectl create configmap index-file-customkey --from-file myindex=./index.html

    configmap/index-file-customkey created

    vagrant@ubuntu:~$ kubectl describe configmap index-file-customkey

    Name: index-file-customkey

    Namespace: default

    Labels: <none>

    Annotations: <none>
    Data

    ====

    myindex:	⇐ 컨피그맵 생성 시 지정한 키 이름을 사용

    ----

    Hello, world!

    Events: <none>
    ```

    ### 키-값 형태의 내용으로 구성된 설정 파일을 생성

    ```bash
    vagrant@ubuntu:~$ vi ./multiple-keyvalue.env
    mykey1=myvalue1
    mykey2=myvalue2
    mykey3=myvalue3
    ```

    ### 설정 파일에 정의된 키-값 형태를 컨피그맵의 키-값 항목으로 일괄 전환

    ```bash
    kubectl create configmap abcd --from-literal mykey1=myvalue1 --from-literal mykey2=myvalue2 --from-literal mykey3=myvalue3 … 
    ```

    ```bash
    vagrant@ubuntu:~$ kubectl create configmap from-envfile --from-env-file ./multiple-keyvalue.env
    configmap/from-envfile created

    vagrant@ubuntu:~$ kubectl describe configmap from-envfile

    Name: from-envfile

    Namespace: default

    Labels: <none>

    Annotations: <none>

    Data
    ====
    mykey1:
    ----
    myvalue1
    mykey2:
    ----
    myvalue2
    mykey3:
    ----
    myvalue3
    Events:  <none>
    ```

    ## **YAML 파일로 컨피그맵을 정의**

    ### 컨피그맵을 실제로 생성하지 않고 YAML 형식으로 출력

    vagrant@ubuntu:~$ kubectl create configmap my-configmap --from-literal mykey=myvalue **-dry-run -o yaml**

    W0922 04:34:05.917495 358937 helpers.go:553] --dry-run is deprecated and can be replaced with --dry-run=client.

    apiVersion: v1

    data:

    mykey: myvalue

    kind: ConfigMap

    metadata:

    creationTimestamp: null

    name: my-configmap

    vagrant@ubuntu:~$ kubectl get configmap

    NAME DATA AGE	⇒ my-configmap 이름의 컨피그맵이 존재하지 않음

    from-envfile 3 4m2s → --dry-run 옵션: 실제로 컨피그맵 오브젝트를 생성하지는 않음

    index-file 1 16m

    index-file-customkey 1 12m

    log-level-configmap 1 3h21m

    start-k8s 2 3h20m

    ### YAML 형식의 출력을 YAML 파일로 저장

    vagrant@ubuntu:~$ kubectl create configmap my-configmap --from-literal mykey=myvalue --dry-run -o yaml **> my-config.yml**

    W0922 04:42:17.088587 360577 helpers.go:553] --dry-run is deprecated and can be replaced with --dry-run=client.

    vagrant@ubuntu:~$

    vagrant@ubuntu:~$ cat my-config.yml

    apiVersion: v1

    data:

    mykey: myvalue

    kind: ConfigMap

    metadata:

    creationTimestamp: null

    name: my-configmap

    ### YAML 파일로 컨피그맵을 생성

    vagrant@ubuntu:~$ kubectl apply -f my-config.yml

    configmap/my-configmap created

    vagrant@ubuntu:~$ kubectl get configmaps

    NAME DATA AGE

    from-envfile 3 13m

    index-file 1 26m

    index-file-customkey 1 22m

    log-level-configmap 1 3h31m

    my-configmap 1 9s

    start-k8s 2 3h30m

    # **시크릿(Secret)**

    민감한 정보를 저장하기 위한 용도

    네임스페이스에 종속

    ## **시크릿 생성 방법**

    ### password=1q2w3e4r 라는 키-값을 저장하는 my-password 이름의 시크릿을 생성

    vagrant@ubuntu:~$ kubectl create secret generic my-password **-from-literal** password=1q2w3e4r

    secret/my-password created

    vagrant@ubuntu:~$ kubectl get secrets

    NAME TYPE DATA AGE

    default-token-sh8hv kubernetes.io/service-account-token 3 3d22h ⇐ ServiceAccount에 의해 네임스페이스별로 자동으로 생성된 시크릿

    my-password Opaque 1 9s

    ### 파일로부터 시크릿을 생성

    vagrant@ubuntu:~$ echo mypassword > pw1 && echo yourpassword > pw2

    vagrant@ubuntu:~$ cat pw1

    mypassword

    vagrant@ubuntu:~$ cat pw2

    yourpassword

    vagrant@ubuntu:~$ kubectl create secret generic out-password --from-file pw1 --from-file pw2

    secret/out-password created

    vagrant@ubuntu:~$ kubectl get secrets

    NAME TYPE DATA AGE

    default-token-sh8hv kubernetes.io/service-account-token 3 3d22h

    my-password Opaque 1 5m29s

    out-password Opaque 2 51s

    ### 시크릿 내용을 확인

    vagrant@ubuntu:~$ kubectl describe secret my-password

    Name: my-password

    Namespace: default

    Labels: <none>

    Annotations: <none>

    Type: Opaque

    Data

    ====

    password: 8 bytes	⇐ password 키에 해당하는 값을 확인할 수 없음 (값의 크기(길이)만 출력)

    vagrant@ubuntu:~$ kubectl get secret my-password **o yaml**

    apiVersion: v1

    data:

    password: MXEydzNlNHI=	⇐ BASE64로 인코딩

    kind: Secret

    metadata:

    creationTimestamp: "2020-09-22T04:49:44Z"

    managedFields:

    - apiVersion: v1

    fieldsType: FieldsV1

    fieldsV1:

    f:data:

    .: {}

    f:password: {}

    f:type: {}

    manager: kubectl-create

    operation: Update

    time: "2020-09-22T04:49:44Z"

    name: my-password

    namespace: default

    resourceVersion: "81153"

    selfLink: /api/v1/namespaces/default/secrets/my-password

    uid: e597d8d2-479e-464f-934d-5d2ae7f232c8

    type: Opaque

    vagrant@ubuntu:~$ echo MXEydzNlNHI= | base64 -d

    1q2w3e4r

    잠시 쉬고, 14시 20분에 이어서 진행하겠습니다.

    ## **시크릿에 저장된 키-값 쌍을 포드로 가져오기**

    ### 시크릿에 저장된 모든 키-값 쌍을 포드의 환경변수로 가져오기

    vagrant@ubuntu:~$ vi env-from-secret.yml

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
      name: secret-env-example
    spec:
      containers:
        - name: my-container
          image: busybox
          args: ["tail", "-f", "/dev/null"]
          envFrom:
            - secretRef:
                name: my-password
    ```

    vagrant@ubuntu:~$ kubectl apply -f env-from-secret.yml

    pod/secret-env-example created

    vagrant@ubuntu:~$ kubectl exec secret-env-example -- env

    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    HOSTNAME=secret-env-example

    password=1q2w3e4r

    HOSTNAME_SVC_NODEPORT_SERVICE_PORT_WEB_PORT=8080

    HOSTNAME_SVC_NODEPORT_PORT=tcp://10.111.29.91:8080

    HOSTNAME_SVC_NODEPORT_PORT_8080_TCP_PORT=8080

    KUBERNETES_SERVICE_PORT=443

    HOSTNAME_SVC_NODEPORT_SERVICE_PORT=8080

    KUBERNETES_PORT_443_TCP_PROTO=tcp

    HOSTNAME_SVC_NODEPORT_PORT_8080_TCP_ADDR=10.111.29.91

    KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443

    KUBERNETES_PORT_443_TCP_PORT=443

    KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1

    HOSTNAME_SVC_NODEPORT_SERVICE_HOST=10.111.29.91

    HOSTNAME_SVC_NODEPORT_PORT_8080_TCP=tcp://10.111.29.91:8080

    KUBERNETES_SERVICE_PORT_HTTPS=443

    KUBERNETES_PORT=tcp://10.96.0.1:443

    KUBERNETES_SERVICE_HOST=10.96.0.1

    HOSTNAME_SVC_NODEPORT_PORT_8080_TCP_PROTO=tcp

    HOME=/root

    ### 시크릿에 저장된 특정 키-값 쌍을 포드의 환경변수로 가져오기

    vagrant@ubuntu:~$ cp env-from-secret.yml selective-env-from-secret.yml

    vagrant@ubuntu:~$ vi selective-env-from-secret.yml

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
      name: secret-env-example
    spec:
      containers:
        - name: my-container
          image: busybox
          args: ["tail", "-f", "/dev/null"]
          env:
            - name: YOUR_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: out-password
                  key: pw2
    ```

    vagrant@ubuntu:~$ kubectl delete -f env-from-secret.yml

    pod "secret-env-example" deleted

    vagrant@ubuntu:~$ kubectl apply -f selective-env-from-secret.yml

    pod/secret-env-example created

    vagrant@ubuntu:~$ kubectl exec secret-env-example -- env | grep YOUR_PASSWORD

    YOUR_PASSWORD=yourpassword	⇐ out-password 시크릿에 pw2 키에 저장되어 있는 값

    ### 시크릿의 저장된 모든 키-값 데이터를 파일로 포드의 볼륨에 마운트

    vagrant@ubuntu:~$ cp env-from-secret.yml volume-mount-secret.yml

    vagrant@ubuntu:~$ vi volume-mount-secret.yml

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
      name: secret-env-example
    spec:
      containers:
        - name: my-container
          image: busybox
          args: ["tail", "-f", "/dev/null"]
          volumeMounts:
            - name: secret-volume
              mountPath: /etc/secret      ⇐ 컨테이너 내부에 /etc/secret/ 디렉터리 아래에 시크릿에 저장된 키 이름의 
      volumes:                               파일을 생성 (파일 내용은 키에 해당하는 값)
        - name: secret-volume
          secret:
            secretName: out-password
    ```

    vagrant@ubuntu:~$ kubectl delete -f selective-env-from-secret.yml

    pod "secret-env-example" deleted

    vagrant@ubuntu:~$ kubectl apply -f volume-mount-secret.yml

    pod/secret-env-example created

    vagrant@ubuntu:~$ kubectl exec secret-env-example -- ls /etc/secret

    pw1

    pw2

    vagrant@ubuntu:~$ kubectl exec secret-env-example -- cat /etc/secret/pw1 /etc/secret/pw2

    mypassword

    yourpassword

    ### 시크릿의 저장된 특정 키-값 데이터를 파일로 포드의 볼륨에 마운트

    vagrant@ubuntu:~$ cp volume-mount-secret.yml selective-volume-secret.yml

    vagrant@ubuntu:~$ vi selective-volume-secret.yml

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
      name: secret-env-example
    spec:
      containers:
        - name: my-container
          image: busybox
          args: ["tail", "-f", "/dev/null"]
          volumeMounts:
            - name: secret-volume
              mountPath: /etc/secret
      volumes:
        - name: secret-volume
          secret:
            secretName: out-password
            items:
              - key: pw1
                path: password1
    ```

    vagrant@ubuntu:~$ kubectl delete -f volume-mount-secret.yml

    pod "secret-env-example" deleted

    vagrant@ubuntu:~$ kubectl apply -f selective-volume-secret.yml

    pod/secret-env-example created

    vagrant@ubuntu:~$ kubectl exec secret-env-example -- ls /etc/secret

    password1

    vagrant@ubuntu:~$ kubectl exec secret-env-example -- cat /etc/secret/password1

    mypassword

    # **시크릿은 사용 목적에 따라 여러 종류의 스크릿을 사용할 수 있음**

    vagrant@ubuntu:~$ kubectl get secrets

    NAME TYPE DATA AGE

    default-token-sh8hv kubernetes.io/service-account-token 3 3d23h

    my-password Opaque 1 65m

    out-password Opaque 2 60m

    ## **Opaque 타입**

    시크릿 종류를 명시하지 않으면 자동으로 설정되는 타입

    kubectl create secret generic 명령으로 생성

    사용자가 정의한 데이터를 저장할 수 있는 일반적인 목적의 시크릿

    ## **kubernetes.io/dockerconfigjson 타입 - private registry에 접근할 때 사용하는 인증 정보를 저장하는 시크릿**

    ### **#1 ~/.docker/config.json 파일을 이용해서 시크릿을 생성**

    vagrant@ubuntu:~$ docker login

    Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.

    Username: myanjini

    Password:

    WARNING! Your password will be stored unencrypted in /home/vagrant/.docker/config.json.

    Configure a credential helper to remove this warning. See

    https://docs.docker.com/engine/reference/commandline/login/#credentials-store

    Login Succeeded

    vagrant@ubuntu:~$ ls -al ~/.docker

    total 12

    drwx------ 2 vagrant vagrant 4096 Sep 22 06:06 .

    drwxr-xr-x 9 vagrant vagrant 4096 Sep 22 06:06 ..

    - rw------- 1 vagrant vagrant 165 Sep 22 06:06 config.json	⇐ docker login 성공하면 도커 엔진이 자동으로 config.json 파일에 인증 정보를 저장

    → config.json 파일을 그대로 시크릿으로 생성

    vagrant@ubuntu:~$ cat ~/.docker/config.json

    {

    "auths": {

    "https://index.docker.io/v1/": {

    "auth": "bXzzzmpxxxxQGyyyyU5MjE4"	⇐ BASE64로 인코딩

    }

    },

    "HttpHeaders": {

    "User-Agent": "Docker-Client/19.03.6 (linux)"

    }

    }

    vagrant@ubuntu:~$ kubectl create secret generic registry-auth --from-file=.dockerconfigjson=/home/vagrant/.docker/config.json --type=kubernetes.io/dockerconfigjson

    secret/registry-auth created

    vagrant@ubuntu:~$ kubectl get secrets

    NAME TYPE DATA AGE

    default-token-sh8hv kubernetes.io/service-account-token 3 4d

    my-password Opaque 1 83m

    out-password Opaque 2 79m

    registry-auth kubernetes.io/dockerconfigjson 1 12s

    ### **#2 직접 인증 정보를 명시**

    vagrant@ubuntu:~$ kubectl create secret docker-registry registry-auth-by-cmd --docker-username=myanjini --docker-password=wkrlvotmdnjem

    secret/registry-auth-by-cmd created

    vagrant@ubuntu:~$ kubectl get secrets

    NAME TYPE DATA AGE

    default-token-sh8hv kubernetes.io/service-account-token 3 4d

    my-password Opaque 1 89m

    out-password Opaque 2 84m

    registry-auth kubernetes.io/dockerconfigjson 1 5m53s

    registry-auth-by-cmd kubernetes.io/dockerconfigjson 1 31s

    잠시 쉬고, 15시 35분에 이어서 진행하겠습니다.

    ## **TLS 타입**

    TLS 연결에 사용되는 공개키와 비밀키 등을 저장하는데 사용

    포드 내의 애플리케이션이 보안 연결을 위해 인증서나 비밀키 등을 가져와야 할 때 TLS 타입의 시크릿을 제공

    kubectl create secret tls 명령으로 생성

    ### **#1 테스트용 인증서와 비밀키를 생성**

    vagrant@ubuntu:~$ openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/CN=example.com" -keyout cert.key -out cert.crt

    Can't load /home/vagrant/.rnd into RNG

    139804440682944:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/home/vagrant/.rnd

    Generating a RSA private key

    ..................++++

    ...............................................++++

    writing new private key to 'cert.key'

    - ----

    vagrant@ubuntu:~$ ls cert*

    cert.crt cert.key

    ### **#2 TLS 타입의 시크릿을 생성**

    vagrant@ubuntu:~$ kubectl create secret tls my-tls --cert ./cert.crt --key ./cert.key

    secret/my-tls created

    vagrant@ubuntu:~$ kubectl get secrets my-tls -o yaml

    apiVersion: v1

    data:

    tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JS...S0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=

    tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JS...S0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=

    kind: Secret

    metadata:

    creationTimestamp: "2020-09-22T06:40:27Z"

    managedFields:

    - apiVersion: v1

    fieldsType: FieldsV1

    fieldsV1:

    f:data:

    .: {}

    f:tls.crt: {}

    f:tls.key: {}

    f:type: {}

    manager: kubectl-create

    operation: Update

    time: "2020-09-22T06:40:27Z"

    name: my-tls

    namespace: default

    resourceVersion: "87661"

    selfLink: /api/v1/namespaces/default/secrets/my-tls

    uid: 26b5272a-e3ed-43b0-b082-682c37ef2620

    type: kubernetes.io/tls

    # **컨피그맵이나 시크릿의 업데이트한 내용을 애플리케이션에서 사용하는 설정값에 반영**

    ### 컨피그맵 정의(매니페스트) 파일 내용을 확인

    vagrant@ubuntu:~$ cat my-config.yml

    apiVersion: v1

    data:

    mykey: myvalue

    kind: ConfigMap

    metadata:

    creationTimestamp: null

    name: my-configmap

    ### 컨피그맵을 생성

    vagrant@ubuntu:~$ kubectl apply -f my-config.yml

    configmap/my-configmap configured

    ### 컨피그맵 내용 확인

    vagrant@ubuntu:~$ kubectl get configmap my-configmap -o yaml

    apiVersion: v1

    data:

    mykey: myvalue

    kind: ConfigMap

    metadata:

    annotations:

    kubectl.kubernetes.io/last-applied-configuration: |

    {"apiVersion":"v1","data":{"mykey":"myvalue"},"kind":"ConfigMap","metadata":{"annotations":{},"creationTimestamp":null,"name":"my-configmap","namespace":"default"}}

    creationTimestamp: "2020-09-22T04:44:13Z"

    managedFields:

    - apiVersion: v1

    fieldsType: FieldsV1

    fieldsV1:

    f:data:

    .: {}

    f:mykey: {}

    f:metadata:

    f:annotations:

    .: {}

    f:kubectl.kubernetes.io/last-applied-configuration: {}

    manager: kubectl-client-side-apply

    operation: Update

    time: "2020-09-22T04:44:13Z"

    name: my-configmap

    namespace: default

    resourceVersion: "80831"

    selfLink: /api/v1/namespaces/default/configmaps/my-configmap

    uid: 99c5cb04-3798-410b-9fea-0c7fc0db26b8

    ### kubectl edit 명령으로 컨피그맵 내용을 변경

    vagrant@ubuntu:~$ kubectl edit configmap/my-configmap

    ```bash
    apiVersion: v1
    data:
      mykey: yuourvalue      ⇐ 내용 변경 후 저장
    kind: ConfigMap
    metadata:
      annotations:
        kubectl.kubernetes.io/last-applied-configuration: |
    ```

    vagrant@ubuntu:~$ kubectl get configmap my-configmap -o yaml

    apiVersion: v1

    data:

    mykey: yourvalue

    kind: ConfigMap

    metadata:

    annotations:

    :

    ### yaml 파일을 수정 후 kubectl apply 명령으로 재생성

    vagrant@ubuntu:~$ cat ./my-config.yml

    apiVersion: v1

    data:

    mykey: myvalue

    kind: ConfigMap

    metadata:

    creationTimestamp: null

    name: my-configmap

    vagrant@ubuntu:~$ sed -i -e 's/myvalue/ourvalues/g' my-config.yml

    vagrant@ubuntu:~$ cat ./my-config.yml

    apiVersion: v1

    data:

    mykey: ourvalues

    kind: ConfigMap

    metadata:

    creationTimestamp: null

    name: my-configmap

    vagrant@ubuntu:~$ kubectl apply -f my-config.yml

    configmap/my-configmap configured	⇐ 변경

    vagrant@ubuntu:~$ kubectl get configmap my-configmap -o yaml

    apiVersion: v1

    data:

    mykey: ourvalues

    kind: ConfigMap

    metadata:

    annotations:

    :

    ## **컨피그맵의 내용이 업데이트 되었을 때, 변경된 내용이 파드에 반영되는 것을 확인**

    ### 컨피그맵을 사용한 파드 생성 확인

    vagrant@ubuntu:~$ cat volume-mount-configmap.yml

    apiVersion: v1

    kind: Pod

    metadata:

    name: configmap-volume-pod

    spec:

    containers:

    - name: my-container

    image: busybox

    args: ["tail", "-f", "/dev/null"]

    volumeMounts:

    - name: configmap-volume

    mountPath: /etc/config

    volumes:

    - name: configmap-volume

    configMap:

    name: start-k8s

    vagrant@ubuntu:~$ kubectl apply -f volume-mount-configmap.yml

    pod/configmap-volume-pod created

    vagrant@ubuntu:~$ kubectl exec configmap-volume-pod -- cat /etc/config/container

    docker

    dockervagrant@ubuntu:~$ kubectl edit configmap/start-k8s

    container 키의 값을 docker 에서 docker_and_kubernetes 로 변경 후 저장

    configmap/start-k8s edited

    vagrant@ubuntu:~$ kubectl get configmap start-k8s -o yaml

    apiVersion: v1

    data:

    container: docker_and_kubernetes	⇐ 컨피그맵 오브젝트는 변경된 것을 확인

    k8s: kubernetes

    kind: ConfigMap

    metadata:

    creationTimestamp: "2020-09-22T01:14:20Z"

    managedFields:

    - apiVersion: v1

    fieldsType: FieldsV1

    fieldsV1:

    f:data:

    .: {}

    f:k8s: {}

    :

    vagrant@ubuntu:~$ kubectl exec configmap-volume-pod -- cat /etc/config/container

    docker_and_kubernetes	⇐ 변경이 반영된 것을 확인

    잠시 쉬고, 16시 25분에 진행하겠습니다.

    ## **리소스 정리**

    vagrant@ubuntu:~$ kubectl delete deployment,replicaset,pod,service,configmap,secret --all

    or

    vagrant@ubuntu:~$ minikube stop

    vagrant@ubuntu:~$ minikube delete	⇐ 모든 리소스 삭제

    vagrant@ubuntu:~$ minikube start