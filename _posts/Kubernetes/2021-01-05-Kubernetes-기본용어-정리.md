---
title: "Kubernetes 기본용어 정리 "
categories: 
  - Kubernetes
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
excerpt: "CKA 시험을 준비하면서 공부하는 Kubernetes의 기본 용어를 정리해본다."
readtime: true
tags:
  - Kubernetes
  - CKA
  - 작성중
header:
  teaser: https://user-images.githubusercontent.com/60086878/111655932-66978f00-884d-11eb-813a-a5302871ede9.png
---

# 🤸‍♂️들어가며
이 글은 Kubernetes에 대해 공부한 것을 기록하기 위해 작성되었습니다. 혹시 틀린 부분이 있다면 언제든지 댓글을 남겨주세요 😊

# ⛴Kubernetes란 ?

## 개요

![K8s Logo](https://user-images.githubusercontent.com/60086878/103609779-f2459300-4f61-11eb-951e-8fa51bc3c9e0.png){: .align-center}

Kubernetes는 Cotainerized Applications의 배포, 스케일링, 관리 등을 자동화 해주는 오픈 소스 컨테이너 오케스트레이션 엔진입니다. Kubernetes는 앞의 K와 s를 제외한 안쪽 8 글자를 줄여서 `K8s`, `케이(에이)츠` 라고 부르기도 합니다. 현재 K8s 오픈 소스 프로젝트는 Cloud Native Computing Foundation(CNCF)가 주관하고 있습니다.

K8s의 전신은 Google 내부 프로젝트인 Borg가 전신입니다. 매일 수 억개의 컨테이너를 배포 및 생성하는 플랫폼으로 Google의 십 수년간의 컨테이너 오케스트레이션 노하우 기술이 녹아들어간 기술입니다. 지난 2014년에 Google에서 오픈소스로 공개하여 현재는 여러 IT 대기업들이 개발에 참여하고 있습니다.

## 탄생 배경

![image](https://user-images.githubusercontent.com/60086878/103895670-1c4eaf00-5134-11eb-951c-d24dd925297d.png){: .align-center}

### 기존의 서버 운영방식

![image](https://user-images.githubusercontent.com/60086878/103625188-fa133080-4f7d-11eb-937b-a416a042423e.png){: .align-center}

각 서버마다 운영하는 애플리케이션이 달라 각 서버마다 용도에 맞는 네이밍을 합니다. 즉, 서버 하나에 용도가 한정되며 그에 맞게 관리가 되는 시스템이었습니다. 이러한 이유로 서버마다 특정 애플리케이션을 구동하기 위한 환경이 모두 다르고, 필요한 리소스도 상이합니다. 하지만 이 방법은 관리가 어렵고 안정적인 운영상의 이유로 리소스를 최대로 활용하지 못하는 문제가 있습니다.

이러한 상황에서 만약 서버 A에 문제가 발생한 상황을 가정 해봅시다. 서버 엔지니어는 서버 A에 서비스중인 애플리케이션 A가 지속적으로 배포하기 위해 문제가 된 서버를 복구할 때까지 다른 서버에 배포  해야 합니다. 하지만 다른 서버 역시 별도의 애플리케이션이 서비스중이기 때문에 애플리케이션 A와의 서버 B의 호환여부와 동시에 배포할 수 있는 리소스가 충분한지 여부도 확인해야 하는 매우 번거로운 과정이 따릅니다. 이러한 문제 상황은 언제 어느 서버에서 생길지 모르고, 발생할 때마다 위와 같은 절차가 이뤄지게 되면서 운영상의 어려움과 상당한 비용이 발생합니다.

### 가상화 기술의 개발

![image](https://user-images.githubusercontent.com/60086878/103897289-a4ce4f00-5136-11eb-856c-d1179fba1b36.png){: .align-center}

가상화 기술의 등장으로 한 서버에서 여러 가상 시스템 (VM)을 실행할 수 있게 됐습니다. 이는 기존의 방법보다 리소스를 더 효율적으로 활용할 수 있으며, 쉽게 애플리케이션을 추가하고 업데이트 할 수 있게 됐습니다. 다만, 각 VM은 Host Machine의 하드웨어를 공유하여 운영체제를 병렬로 운영할 수 있어 관리 비용이 줄어든다는 장점이 있지만, 반대로 각각의 VM을 위한 커널이 필요하기 때문에 불필요한 리소스 소모를 감수해야 한다는 단점이 존재한다.

### Docker의 등장

![image](https://user-images.githubusercontent.com/60086878/103625397-42325300-4f7e-11eb-88dd-16bc55f251a6.png){: .align-center}

리눅스 컨테이너 기술을 적용한 Docker의 등장으로 환경에 상관없이 Docker가 설치되어있는 환경이면 동일하게 애플리케이션을 실행할 수 있게 됐습니다. 컨테이너는 VM과 유사하지만 Host OS 자원인 커널은 공유하고 애플리케이션 단위로 추상화하여 논리적으로 격리시키는 형태입니다. 즉, Hypervisor 없이 Docker Engine만으로 애플리케이션과 바이너리 및 라이브러리가 포함된 컨테이너만 올리면 되는 구조입니다. 이에 따라 특정 OS에 종속되지 않고, 리소스 손실률이 거의 없이 배포할 수 있게 됐습니다.

덕분에 기존보다 관리가 한결 수월하게 됐지만, 컨테이너의 수가 늘어나면서 이것을 관리하는 것조차 어려움이 생겼습니다. 그래서 속속 등장하기 시작한게 컨테이너 오케스트레이션 기술입니다. Kubernetes는 그리스어로 배의 조타수라는 뜻으로, 로고도 조타 핸들 모양을 하고 있습니다. 

### K8s 클러스터 운영방식

![image](https://user-images.githubusercontent.com/60086878/103905066-7b66f080-5141-11eb-8318-d4a19389b91a.png){: .align-center}

K8s는 Master Node에서 Worker Node와 클러스터 내 Pod들을 관리합니다. Worker Node는 컨테이너가 실제 배포되는 곳이며 모든 명령은 Master Node의 API Server와 통신하여 필요한 작업 등을 수행합니다.

K8s 클러스터는 프로덕션 환경에서 배포되는 컨테이너가 정상적으로 가동되고 있는지, 혹시 중단 되었다면 현재 Worker Node 혹은 다른 Node에 리소스가 충분한지 여부를 판단하고, 다시 새로운 컨테이너를 탄력적으로 재가동 해줍니다. K8s 클러스터는 정의된 내용 즉, Desired State에 따라 Current State와 같은지 주기적으로 확인하여 유지하려는 매커니즘으로 관리 됩니다. 즉, 기존에 서버 운영방식에서는 모두 서버 엔지니어가 했던 일들을 K8s 클러스터가 자동으로 관리해주게 되는 것이며, 이를 통해 무중단 배포가 가능해지는 것입니다. 그래서 우리는 이것을 컨테이너 오케스트레이션이라고 합니다.

# 🏗아키텍쳐

![image](https://user-images.githubusercontent.com/60086878/103901861-0e515c00-513d-11eb-8673-851b85a54213.png){: .align-center}

K8s는 기본적으로 사용자가 정의한 Disired State와 Current State를 유지하는 내용을 골자로 합니다. 클라우드 네이티브 관점에서 시스템의 지속적인 변화를 관찰하며 대응할 수 있게 하는 것입니다. K8s에서는 이러한 Control Loop 시스템을 구현하기 위해 아래와 같은 컴포넌트들로 구성되어 있습니다.

![image](https://user-images.githubusercontent.com/60086878/103619579-5a51a480-4f75-11eb-8a9b-664d1d04cba4.png){: .align-center}

K8s의 컴포넌트는 크게 Master Node에 위치한 Control Plane 영역과 Worker Node 영역으로 구분 됩니다. 

## Control Plane

Control Plane은 Master Node에서 Worker Node와 클러스터 내 Pod들을 관리합니다. 이를 구성하는 요소들은 다음과 같습니다.

- `kube-api server` : K8s 클러스터의 REST API를 제공하는 역할을 합니다. 사용자는 K8s CLI 명령도구인 kubectl을 통해 `kube-api server`에 명령을 요청하고, K8s 클러스터 내 대부분의 컴포넌트와 상호작용하는 `kube-api server`는 요쳥된 명령을 etcd에 저장한 후 다시 다른 Worker Node 들에게 해당 명령을 전달합니다. 

- `etcd` : 고가용성 Key-Value 저장소로 K8s에 필요한 모든 데이터를 저장하는 실질적인 데이터베이스 입니다. 본래 구글의 Borg에서 사용하던 내부 분산 저장 솔루션인 Chubby의 역할을 하는 오픈소스 플랫폼입니다. K8s 클러스터 내 모든 설정값이나 클러스터의 상태를 저장하며 `kube-api server`와 유일하게 상호작용 할 수 있으며, 다른 모듈은 `kube-api server`를 거쳐 `etcd` 데이터에 접근합니다. `etcd`는 서버 1개당 프로세스 1개만 사용할 수 있는데, 보통 etcd 자체를 클러스터링 한 후 여러 서버에 분산하여 실행해 안정성을 보장합니다.

- `kube-scheduler` : 노드가 할당되지 않은 새로운 Pod를 항상 체크하며 클러스터 내 노드의 자원 상태를 확인하여 해당 Pod가 실행할 최적의 노드를 선택해 줍니다. 만약 적합한 노드가 없다면 `kube-scheduler`가 Pod를 배치할 수 있을 때까지 할당하지 않습니다. 

- `kube-controller-manager` : Desired-state를 미리 정의한 뒤 Current-state가 Desired-state가 되도록 하는 Control Loop 시스템입니다. 예를 들어, 에어컨과 같이 희망온도를 설정하면 에어컨이 그에 맞게 온도를 유지하려고 하는 것과 같습니다. 실제 컴포넌트로는 실행할 Pod의 개수를 관리하는 Replication Controller와 클러스터 내 전체 노드에 특정 Pod를 실행하도록 하는 Daemon Set Controller 등이 있습니다. 이들은 복잡성을 낮추기 위해 각각 단일 바이너리로 컴파일되어 단일 프로세스로서 실행됩니다.

- `cloud-controller-manager` : 클라우드별 컨트롤 로직을 포함하는 컴포넌트입니다. `cloud-controller-manager`를 통해 클러스터를 클라우드 공급자의 API에 연결합니다. `kube-controller-manager`와 동일하게 논리적으로 독립적인 여러 Control Loop 시스템을 단일 프로세스로 실행합니다. 실제 컴포넌트로는 클라우드 상에서 노드가 삭제되었는지 여부를 판단하는 Node Controller와 클라우드 공급자의 로드밸런서를 생성 및 삭제하는 것을 담당하는 Service Controller가 있습니다.

## Worker Node

- `kubelet` : 각 노드에서 실행되며, 노드에 할당된 Pod의 생명주기를 관리합니다. `kube-api server`로부터 요청을 받아 직접적으로 Pod를 생성하는 컴포넌트이며, Pod 안의 컨테이너에 Health check를 주기적으로 확인하여 Master Node에 상태를 전달하기도 합니다.

- `kube-proxy` : 각 노드에서 실행되며, Pod로 연결되는 네트워크 프록시로 노드의 네트워크 규칙을 유지 및 관리하는 컴포넌트입니다. 이에 따라 내부 네트워크 세션이나 클러스터 외부에서 Pod로 네트워크 통신을 할 수 있도록 해줍니다.

# 오브젝트

K8s 오브젝트는 하나의 의도를 담은 레코드로 K8s 시스템에서 클러스터의 상태를 나타내고, 영속성을 가집니다. 즉, 사용자가 오브젝트를 생성함으로써 클러스터의 워크로드를 어떤 형태로 보이고자 하는지 K8s 시스템에 전달하며 이것이 곧 Desired State가 됩니다.

# 워크로드

K8s에서 구동되는 애플리케이션으로, 클러스터 상의 컨테이너를 구동 및 관리하는 데 사용하는 객체를 의미합니다. 

- `Pod` : 1개 이상의 Container를 포함하여 K8s에서 생성하고 관리할 수 있고, 배포 가능한 가장 작은 단위입니다. 

- `ReplicaSet` : Desired State를 유지하기 위해 두는 일종의 안전 장치입니다. 레플리카 수 유지를 위해 생성하는 신규 파드에 대한 데이터를 명시하는 파드 템플릿을 포함 합니다. 명시된 동일한 Replica(Pod)의 복제 개수에 대한 보증됩니다.

- `StatefulSet` : Pod 이름에 대한 규칙성 부여와 개별 Pod에 대한 디스크 볼륨관리로 수시로 삭제되고 재생성되는 Pod 내의 디스크 내용이 유지될 수 있도록 하는 워크로드 리소스입니다.

- `Deployment` : Replica Controller가 **롤링 업데이트**하는 방식을 자동화해서 추상화한 개념이 Deployment입니다. 과거 배포 이력 유지 및 이전 버전으로 Revision이 관리되어 쉽게 **롤백**이 가능합니다. 가장 보편적인 배포 단위이기도 하며, Desired 상태를 위해 Deployment내의 Replica Set, Pod들의 상태가 정해지게 됩니다. create 커맨드에 –record 플래그 붙이면 디플로이먼트 생성이 롤아웃 히스토리에 기록됩니다.

- `DeamonSet` : 클러스터 내 단일 Pod 복사본이 어느 노드 집합에서든 잘 작동하게 하는 역할을 합니다. 클러스터 스토리지 및 로그 수집, 노드 모니터링 데몬 실행합니다. 만약 클러스터에 새로운 노드가 설치되면 데몬셋이 동작하여 자동으로 해당 노드에 파드를 실행합니다. 클러스터에서 노드가 제거 될 경우 해당 노드에서 실행중이던 데몬셋 파드는 다른 노드로 이동하지 않고 그대로 사라지게 됩니다.

- `Job` : 실행된 후에 종료해야 하는 성격의 작업을 실행할 때 사용되는 컨트롤러 입니다. 종류로는 단일 잡, (워크 큐가 있는) 병렬 잡 등이 있습니다.

# 참고

- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [쿠버네티스(Kubernetes)란? 개념, 성능, 사용방법 및 차이점](https://www.redhat.com/ko/topics/containers/what-is-kubernetes)
- [쿠버네티스 시작하기 - Kubernetes란 무엇인가?](https://subicura.com/2019/05/19/kubernetes-basic-1.html)

