# 2020_09_21

# Kubernetes

## Define replica set

- replicaset-nginx.yml

```bash
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-nginx
spec:
  replicas: 3                          ⇐ 유지해야 하는 파드 개수
  selector:                            ⇐ 획득 가능한 파드를 식별하는 방법
    matchLabels:
      app: my-nginx-pods-label
  template:                            ⇐ 신규 생성되는 파드에 대한 데이터를 명시
    metadata:
      name: my-nginx-pod
      labels:
        app: my-nginx-pods-label
    spec:
      containers:
      - name: my-nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80
          protocol: TCP
```

```bash
vagrant@ubungtu:~$ kubectl apply -f replicaset-nginx.yml
replicaset.apps/replicaset-nginx created
vagrant@ubungtu:~$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
replicaset-nginx-brfkd   1/1     Running   0          21s
replicaset-nginx-vbhg4   1/1     Running   0          21s
replicaset-nginx-xw9dz   1/1     Running   0          21s
vagrant@ubungtu:~$ kubectl get replicaset
NAME               DESIRED   CURRENT   READY   AGE
replicaset-nginx   3         3         3       33s

```

- replicaset-nginx-4pods.yml

```bash
replicas: 4
```

```bash
vagrant@ubungtu:~$ cp replicaset-nginx.yml replicaset-nginx-4pods.yml
vagrant@ubungtu:~$ vi replicaset-nginx-4pods.yml
vagrant@ubungtu:~$ kubectl apply -f replicaset-nginx-4pods.yml 
replicaset.apps/replicaset-nginx configured
vagrant@ubungtu:~$ kubectl get replicaset
NAME               DESIRED   CURRENT   READY   AGE
replicaset-nginx   4         4         4       2m4s
vagrant@ubungtu:~$ kubectl get po
NAME                     READY   STATUS    RESTARTS   AGE
replicaset-nginx-brfkd   1/1     Running   0          2m16s
replicaset-nginx-pbhrv   1/1     Running   0          27s
replicaset-nginx-vbhg4   1/1     Running   0          2m16s
replicaset-nginx-xw9dz   1/1     Running   0          2m16s
```

- delete

```bash
vagrant@ubungtu:~$ kubectl delete replicaset replicaset-nginx
replicaset.apps "replicaset-nginx" deleted
vagrant@ubungtu:~$ kubectl delete -f replicaset-nginx-4pods.yml
```

```bash
#1 my-nginx-pods-label 라벨을 가지는 파드를 생성
vagrant@ubuntu:~/kub01$ vi nginx-pod-without-rs.yml
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  labels:
    app: my-nginx-pods-label
spec:
  containers:
  - name: my-nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80

vagrant@ubuntu:~/kub01$ kubectl apply -f nginx-pod-without-rs.yml
pod/my-nginx-pod created

vagrant@ubuntu:~/kub01$ kubectl get pods --show-labels
NAME           READY   STATUS    RESTARTS   AGE   LABELS
my-nginx-pod   1/1     Running   0          19s   app=my-nginx-pods-label

#2 my-nginx-pods-label 라벨을 가지는 파드 3개를 생성하는 레플리카셋을 생성
vagrant@ubuntu:~/kub01$ vi replicaset-nginx.yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-nginx-pods-label
  template:
    metadata:
      name: my-nginx-pod
      labels:
        app: my-nginx-pods-label
    spec:
      containers:
      - name: my-nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80
          protocol: TCP

vagrant@ubuntu:~/kub01$ kubectl apply -f replicaset-nginx.yml
replicaset.apps/replicaset-nginx created

vagrant@ubuntu:~/kub01$ kubectl get pods --show-labels
NAME                     READY   STATUS    RESTARTS   AGE     LABELS
my-nginx-pod             1/1     Running   0          4m12s   app=my-nginx-pods-label
replicaset-nginx-59992   1/1     Running   0          27s     app=my-nginx-pods-label
replicaset-nginx-gbzrr   1/1     Running   0          27s     app=my-nginx-pods-label

#3 파드를 수동으로 삭제한 후 다시 조회
vagrant@ubuntu:~/kub01$ kubectl delete pods my-nginx-pod
pod "my-nginx-pod" deleted

vagrant@ubuntu:~/kub01$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
replicaset-nginx-59992   1/1     Running   0          4m40s
replicaset-nginx-gbzrr   1/1     Running   0          4m40s
replicaset-nginx-vfjqn   1/1     Running   0          14s			⇐ 새로운 파드를 생성

#4 레플리카셋이 생성한 파드의 라벨을 변경
vagrant@ubuntu:~/kub01$ kubectl edit pods replicaset-nginx-59992   	⇐ 첫번째 파드의 이름
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2020-09-21T02:18:06Z"
  generateName: replicaset-nginx-
  #  labels:
  #    app: my-nginx-pods-label          ⇐ 라벨을 주석처리 후 저장
  name: replicaset-nginx-59992
  namespace: default
  ownerReferences:
       :

vagrant@ubuntu:~/kub01$ kubectl get pods --show-labels
NAME                     READY   STATUS    RESTARTS   AGE     LABELS
replicaset-nginx-59992   1/1     Running   0          9m31s   <none>			⇐ 관리 대상으로 간주하지 않음
replicaset-nginx-bhz8w   1/1     Running   0          56s     app=my-nginx-pods-label	⇐ 새로운 파드가 추가
replicaset-nginx-gbzrr   1/1     Running   0          9m31s   app=my-nginx-pods-label
replicaset-nginx-vfjqn   1/1     Running   0          5m5s    app=my-nginx-pods-label

#5 레플리카셋 삭제 → 같은 라벨의 파드만 삭제
vagrant@ubuntu:~/kub01$ kubectl get replicaset
NAME               DESIRED   CURRENT   READY   AGE
replicaset-nginx   3         3         3       12m

vagrant@ubuntu:~/kub01$ kubectl get pods --show-labels
NAME                     READY   STATUS    RESTARTS   AGE     LABELS
replicaset-nginx-59992   1/1     Running   0          12m     <none>
replicaset-nginx-bhz8w   1/1     Running   0          3m49s   app=my-nginx-pods-label
replicaset-nginx-gbzrr   1/1     Running   0          12m     app=my-nginx-pods-label
replicaset-nginx-vfjqn   1/1     Running   0          7m58s   app=my-nginx-pods-label

vagrant@ubuntu:~/kub01$ kubectl delete replicasets replicaset-nginx
replicaset.apps "replicaset-nginx" deleted

vagrant@ubuntu:~/kub01$ kubectl get replicaset
No resources found in default namespace.

vagrant@ubuntu:~/kub01$ kubectl get pods --show-labels
NAME                     READY   STATUS    RESTARTS   AGE   LABELS
replicaset-nginx-59992   1/1     Running   0          13m   <none> ⇐ 레플리카셋의 관리 대상이 아니므로 삭제되지 않음

#6 라벨이 삭제된 파드는 직접 삭제
vagrant@ubuntu:~/kub01$ kubectl delete pods replicaset-nginx-59992
pod "replicaset-nginx-59992" deleted

vagrant@ubuntu:~/kub01$ kubectl get pods --show-labels
No resources found in default namespace.
```

## Deployment

- What is deployment?

Replicaset, Pod의 배포를 관리

⇒ 애플리케이션의 업데이트와 배포를 쉽게 하기 위해 만든 개념(객체)

- Why deployment?

디플로이먼트는 컨테이너 애플리케이션을 배포하고 관리하는 역할을 담당

애플리케이션을 업데이트 할 때 Replicaset 변경 사항을 저장하는 리비전을 남겨 롤백 가능하게 해 주고, 무중단 서비스를 위한 Pod의 롤링 업데이트 전략을 지정할 수 있음

- vi deployment-nginx.yml

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-nginx
  template:
    metadata:
      name: my-nginx-pod
      labels:
        app: my-nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.10
        ports:
        - containerPort: 80
```

→ Deployment 생성 하면 Pod, Replicaset 함께 생성

→ Deployment 삭제 하면 Pod, Replicaset 함께 삭제

```bash
$ kubectl apply -f deployment-nginx.yml --record
```

- —record

```bash
vagrant@ubuntu:~/kub01$ kubectl apply -f deployment-nginx.yml --record
deployment.apps/my-nginx-deployment created

vagrant@ubuntu:~/kub01$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
my-nginx-deployment-7484748b57-8ph87   1/1     Running   0          8s	--+	⇐ nginx:1.10 이미지를 이용해서 생성
my-nginx-deployment-7484748b57-fkc2q   1/1     Running   0          8s    |
my-nginx-deployment-7484748b57-v7hkr   1/1     Running   0          8s  --+

vagrant@ubuntu:~/kub01$ cat deployment-nginx.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx-deployment	⇐ ❶
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-nginx
  template:
    metadata:
      name: my-nginx-pod
      labels:
        app: my-nginx
    spec:
      containers:
      - name: nginx		⇐ ❷
        image: nginx:1.10
        ports:
        - containerPort: 80

#2 kubectl set image 명령으로 파드의 이미지를 변경
vagrant@ubuntu:~/kub01$ kubectl set image deployment my-nginx-deployment   nginx=nginx:1.11  --record
                                                     ~~~~~~~~~~~~~~~~~~~   ~~~~~~~~~~~~~~~~
                                                     ❶ 디플로이먼트 이름  ❷ 컨테이너 이름 ⇒ 컨테이너를 업데이트
deployment.apps/my-nginx-deployment image updated

vagrant@ubuntu:~/kub01$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
my-nginx-deployment-556b57945d-mlj7s   1/1     Running   0          14s
my-nginx-deployment-556b57945d-sklj2   1/1     Running   0          6s
my-nginx-deployment-556b57945d-tdg2t   1/1     Running   0          4s

vagrant@ubuntu:~/kub01$ kubectl get replicasets
NAME                             DESIRED   CURRENT   READY   AGE
my-nginx-deployment-556b57945d   3         3         3       5m49s	⇐ 새롭게 생성된 레플리카셋
my-nginx-deployment-7484748b57   0         0         0       9m45s	⇐ 앞에서 생성되었던 레플리카셋

#3 리비전 정보를 확인
--record=ture 옵션으로 디플로이먼트를 변경하면 변경 사항을 기록하여 해당 버전의 레플리카셋을 보관할 수 있음

vagrant@ubuntu:~/kub01$ kubectl rollout history deployment my-nginx-deployment
deployment.apps/my-nginx-deployment
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=deployment-nginx.yml --record=true
2         kubectl set image deployment my-nginx-deployment nginx=nginx:1.11 --record=true

#4 이전 버전의 레플리카셋으로 롤백
vagrant@ubuntu:~/kub01$ kubectl rollout undo deployment my-nginx-deployment --to-revision=1
deployment.apps/my-nginx-deployment rolled back

vagrant@ubuntu:~/kub01$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
my-nginx-deployment-7484748b57-2mks2   1/1     Running   0          12s
my-nginx-deployment-7484748b57-2xpsw   1/1     Running   0          15s
my-nginx-deployment-7484748b57-ngcd4   1/1     Running   0          14s

vagrant@ubuntu:~/kub01$ kubectl get replicasets
NAME                             DESIRED   CURRENT   READY   AGE
my-nginx-deployment-556b57945d   0         0         0       11m
my-nginx-deployment-7484748b57   3         3         3       15m

vagrant@ubuntu:~/kub01$ kubectl rollout history deployment my-nginx-deployment
deployment.apps/my-nginx-deployment
REVISION  CHANGE-CAUSE
2         kubectl set image deployment my-nginx-deployment nginx=nginx:1.11 --record=true
3         kubectl apply --filename=deployment-nginx.yml --record=true

#5 디플로이먼트 상세 정보 확인
vagrant@ubuntu:~/kub01$ kubectl describe deploy my-nginx-deployment
Name:                   my-nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 21 Sep 2020 04:13:55 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 3
                        kubernetes.io/change-cause: kubectl apply --filename=deployment-nginx.yml --record=true
Selector:               app=my-nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=my-nginx
  Containers:
   nginx:
    Image:        nginx:1.10
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   my-nginx-deployment-7484748b57 (3/3 replicas created)
Events:
  Type    Reason             Age                  From                   Message
  ----    ------             ----                 ----                   -------
  Normal  ScalingReplicaSet  15m                  deployment-controller  Scaled up replica set my-nginx-deployment-556b57945d to 1
  Normal  ScalingReplicaSet  15m                  deployment-controller  Scaled down replica set my-nginx-deployment-7484748b57 to 2
  Normal  ScalingReplicaSet  15m                  deployment-controller  Scaled up replica set my-nginx-deployment-556b57945d to 2
  Normal  ScalingReplicaSet  14m                  deployment-controller  Scaled down replica set my-nginx-deployment-7484748b57 to 1
  Normal  ScalingReplicaSet  14m                  deployment-controller  Scaled up replica set my-nginx-deployment-556b57945d to 3
  Normal  ScalingReplicaSet  14m                  deployment-controller  Scaled down replica set my-nginx-deployment-7484748b57 to 0
  Normal  ScalingReplicaSet  3m43s                deployment-controller  Scaled up replica set my-nginx-deployment-7484748b57 to 1
  Normal  ScalingReplicaSet  3m42s                deployment-controller  Scaled down replica set my-nginx-deployment-556b57945d to 2
  Normal  ScalingReplicaSet  3m42s                deployment-controller  Scaled up replica set my-nginx-deployment-7484748b57 to 2
  Normal  ScalingReplicaSet  3m40s (x2 over 19m)  deployment-controller  Scaled up replica set my-nginx-deployment-7484748b57 to 3
  Normal  ScalingReplicaSet  3m40s                deployment-controller  Scaled down replica set my-nginx-deployment-556b57945d to 1
  Normal  ScalingReplicaSet  3m37s                deployment-controller  Scaled down replica set my-nginx-deployment-556b57945d to 0

vagrant@ubuntu:~/kub01$ kubectl rollout history deployment my-nginx-deployment
deployment.apps/my-nginx-deployment
REVISION  CHANGE-CAUSE
3         kubectl apply --filename=deployment-nginx.yml --record=true
4         kubectl set image deployment my-nginx-deployment nginx=nginx:1.11 --record=true

vagrant@ubuntu:~/kub01$ kubectl rollout history deployment my-nginx-deployment --revision=3
deployment.apps/my-nginx-deployment with revision #3
Pod Template:
  Labels:       app=my-nginx
        pod-template-hash=7484748b57
  Annotations:  kubernetes.io/change-cause: kubectl apply --filename=deployment-nginx.yml --record=true
  Containers:
   nginx:
    Image:      nginx:1.10
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>
```

## Service

- What is service ?

쿠버네티스 클러스터 안에서 파드의 집합에 대한 경로나 서비스 디스커버리를 제공하는 리소스

### Types of service

서비스 타입에 따라 포드에 접근하는 방법이 달라짐

- ClusterIP 타입
    - 쿠버네티스 내부에서만 포들에 접근할 때 사용
    - 외부로 포드를 노출하지 않기 때문에 쿠버네티스 클러스터 내부에서만 사용되는 포드에 적합
- NodePort 타입
    - 포드에 접근할 수 있는 포트를 클러스터의 모드 노드에 동일하게 개방
    - 외부에서 포드에 접근할 수 있는 서비스 타입
    - 접근할 수 있는 포트는 랜덤으로 정해지지만, 특정 포트로 접근하도록 설정할 수 있음
- LoadBalancer 타입
    - 클라우드 플랫폼에서 제공하는 로드 밸러서를 동적으로 프로비저닝해서 포드에 연결
    - 외부에서 포드에 접근할 수 있는 서비스 타입
    - 일반적으로 AWS, GCP, … 등과 같은 클라우드 플랫폼 환경에서 사용

- deployment-hostname.yml

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostname-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webserver
  template:
    metadata:
      name: my-webserver
      labels:
        app: webserver
    spec:
      containers:
      - name: my-webserver
        image: alicek106/rr-test:echo-hostname
        ports:
        - containerPort: 80
```

```bash
vagrant@ubungtu:~$ kubectl apply -f deployment-hostname.yml 
deployment.apps/hostname-deployment created
vagrant@ubungtu:~$ kubectl get po
NAME                                   READY   STATUS    RESTARTS   AGE
hostname-deployment-7dfd748479-fw7dl   1/1     Running   0          98s
hostname-deployment-7dfd748479-pdxll   1/1     Running   0          98s
hostname-deployment-7dfd748479-s889l   1/1     Running   0          98s
```

- -o, —output=' ' : 출력 포맷 설정
- wide

```bash
vagrant@ubungtu:~$ kubectl get po -o wide
NAME                                   READY   STATUS    RESTARTS   AGE    IP           NODE       NOMINATED NODE   READINESS GATES
hostname-deployment-7dfd748479-fw7dl   1/1     Running   0          7m5s   172.18.0.4   minikube   <none>           <none>
hostname-deployment-7dfd748479-pdxll   1/1     Running   0          7m5s   172.18.0.3   minikube   <none>           <none>
hostname-deployment-7dfd748479-s889l   1/1     Running   0          7m5s   172.18.0.5   minikube   <none>           <none>
```

→ 클러스터(minikube) 안에 3개의 Pod

- Pod 를 임시로 하나 생성해서 hostname-deployment 디플로이먼트로 생성된 파드로 HTTP 요청을 전달

```bash
vagrant@ubungtu:~$ kubectl run -it --rm debug --image=alicek106/ubuntu:curl --restart=Never curl 172.18.0.3 | grep Hello
        <p>Hello,  hostname-deployment-7dfd748479-pdxll</p>     </blockquote>
```

→ 외부에서 접속할 수 없는 이유? : ClusterIP 타입이라서!

### ClusterIP type

- hostname-svc-clusterip.yml

```bash
apiVersion: v1
kind: Service
metadata:
  name: hostname-svc-clusterip
spec:
  ports:
    - name: web-port
      port: 8080
      targetPort: 80
  selector:
    app: webserver
  type: ClusterIP
```

```bash
vagrant@ubungtu:~$ kubectl apply -f hostname-svc-clusterip.yml 
service/hostname-svc-clusterip created
vagrant@ubungtu:~$ kubectl get services
NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
hostname-svc-clusterip   ClusterIP   10.97.97.24   <none>        8080/TCP   16s
kubernetes               ClusterIP   10.96.0.1     <none>        443/TCP    3d1h
```

- temporary pod

```bash
vagrant@ubungtu:~$ kubectl run -it --rm debug --image=alicek106/ubuntu:curl --restart=Never -- bash
If you don't see a command prompt, try pressing enter.
root@debug:/# 
root@debug:/# curl http://10.97.97.24:8080
<!DOCTYPE html>
<meta charset="utf-8" />
<link rel="stylesheet" type="text/css" href="./css/layout.css" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">

<div class="form-layout">
        <blockquote>
        <p>Hello,  hostname-deployment-7dfd748479-pdxll</p>     </blockquote>
</div>
root@debug:/# curl http://10.97.97.24:8080
<!DOCTYPE html>
<meta charset="utf-8" />
<link rel="stylesheet" type="text/css" href="./css/layout.css" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">

<div class="form-layout">
        <blockquote>
        <p>Hello,  hostname-deployment-7dfd748479-s889l</p>     </blockquote>
</div>
```

→ 10.97.97.24 : service를 통해 만들어진 주소

⇒ 서비스의 IP와 PORT를 통해 파드에 접근 ⇒ 서비스와 연결된 파드에 로드밸런싱을 수행

- delete

```bash
vagrant@ubungtu:~$ kubectl delete service hostname-svc-clusterip
service "hostname-svc-clusterip" deleted
```

### NodePort type

- hostname-svc-nodeport

```bash
apiVersion: v1
kind: Service
metadata:
  name: hostname-svc-nodeport
spec:
  ports:
    - name: web-port
      port: 8080
      targetPort: 80
  selector:
    app: webserver
  type: NodePort
```

```bash
vagrant@ubungtu:~$ kubectl apply -f hostname-svc-nodeport.yml
vagrant@ubungtu:~$ kubectl get services
NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hostname-svc-nodeport   NodePort    10.99.51.186   <none>        8080:31221/TCP   16s
kubernetes              ClusterIP   10.96.0.1      <none>        443/TCP          3d2h
vagrant@ubungtu:~$ curl 10.99.51.186
<html><head><title>HTTP 401 - Unauthorized</title></head><body><h4>HTTP 401 - Unauthorized</h4><p>Authorization is required to access the configuration server.<p>You must enter the correct username and/or password.</body></html>
vagrant@ubungtu:~$ kubectl get nodes -o wide
NAME       STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION       CONTAINER-RUNTIME
minikube   Ready    master   3d2h   v1.19.0   172.17.0.2    <none>        Ubuntu 20.04 LTS   4.15.0-117-generic   docker://19.3.8
vagrant@ubungtu:~$ curl 172.17.0.2:31221
<!DOCTYPE html>
<meta charset="utf-8" />
<link rel="stylesheet" type="text/css" href="./css/layout.css" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">

<div class="form-layout">
        <blockquote>
        <p>Hello,  hostname-deployment-7dfd748479-fw7dl</p>     </blockquote>
</div>
```

## Namespace

```bash
#1 YAML 파일 생성
vagrant@ubuntu:~/kub01$ vi production-namespace.yml
apiVersion: v1
kind: Namespace
metadata:
  name: production

#2 네임스페이스 생성 및 확인
vagrant@ubuntu:~/kub01$ kubectl apply -f production-namespace.yml
namespace/production created

vagrant@ubuntu:~/kub01$ kubectl get namespaces
NAME              STATUS   AGE
default           Active   3d1h
kube-node-lease   Active   3d1h
kube-public       Active   3d1h
kube-system       Active   3d1h
production        Active   21s

### YML 파일 없이 네임스페이스를 생성
vagrant@ubuntu:~/kub01$ kubectl create namespace mynamespace
namespace/mynamespace created

vagrant@ubuntu:~/kub01$ kubectl get namespaces
NAME              STATUS   AGE
default           Active   3d1h
kube-node-lease   Active   3d1h
kube-public       Active   3d1h
kube-system       Active   3d1h
mynamespace       Active   8s
production        Active   2m4s

#3 특정 네임스페이스에 리소스를 생성하는 방법
YAML 파일에 metadata.namespace 항목에 네임스페이스를 기술

vagrant@ubuntu:~/kub01$ cp deployment-hostname.yml hostname-deploy-svc-ns.yml
vagrant@ubuntu:~/kub01$ vi hostname-deploy-svc-ns.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostname-deployment-ns
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webserver
  template:
    metadata:
      name: my-webserver
      labels:
        app: webserver
    spec:
      containers:
      - name: my-webserver
        image: alicek106/rr-test:echo-hostname
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: hostname-svc-clusterip-ns
  namespace: production
spec:
  ports:
    - name: web-port
      port: 8080
      targetPort: 80
  selector:
    app: webserver
  type: ClusterIP

vagrant@ubuntu:~/kub01$ kubectl apply -f hostname-deploy-svc-ns.yml
deployment.apps/hostname-deployment-ns created
service/hostname-svc-clusterip-ns created

vagrant@ubuntu:~/kub01$ kubectl get pods,services --namespace production
NAME                                          READY   STATUS    RESTARTS   AGE
pod/hostname-deployment-ns-7dfd748479-4mg2b   1/1     Running   0          50s
pod/hostname-deployment-ns-7dfd748479-jgzg6   1/1     Running   0          50s
pod/hostname-deployment-ns-7dfd748479-rg8lw   1/1     Running   0          50s

NAME                                TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/hostname-svc-clusterip-ns   ClusterIP   10.97.13.64   <none>        8080/TCP   50s

#4 네임스페이스가 다른 서비스에 접근
### default 네임스페이스에 debug 파드를 생성
vagrant@ubuntu:~/kub01$ kubectl run -it --rm debug --image=alicek106/ubuntu:curl --restart=Never -- bash
If you don't see a command prompt, try pressing enter.
root@debug:/#
root@debug:/# curl http://hostname-svc-clusterip-ns:8080		⇐ production 네임스페이스에 생성된 서비스를 호출
curl: (6) Could not resolve host: hostname-svc-clusterip-ns
⇒ 네임스페이스가 다르기 때문에 (바로)ㅠ 서비스를 이용할 수 없음

### 네임스페이스가 다른 서비스를 이용하기 위해서는 <서비스 이름>.<네임스페이스 이름>.svc 형식으로 접근해야 함
root@debug:/# curl http://hostname-svc-clusterip-ns.production.svc:8080
<!DOCTYPE html>
<meta charset="utf-8" />
<link rel="stylesheet" type="text/css" href="./css/layout.css" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">

<div class="form-layout">
        <blockquote>
        <p>Hello,  hostname-deployment-ns-7dfd748479-rg8lw</p>  </blockquote>
</div>
#5 네임스페이스 삭제
vagrant@ubuntu:~/kub01$ kubectl delete namespace production
namespace "production" deleted
```