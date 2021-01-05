---
title: "Kubernetes 기본용어 정리"
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
---

# 🤸‍♂️들어가며
이 글은 Kubernetes에 대해 공부한 것을 기록하기 위해 작성되었습니다. 혹시 틀린 부분이 있다면 언제든지 댓글을 남겨주세요 😊

# ⛴Kubernetes란 ?

## 개요

![K8s Logo](https://user-images.githubusercontent.com/60086878/103609779-f2459300-4f61-11eb-951e-8fa51bc3c9e0.png)

Kubernetes는 Cotainerized Applications의 배포, 스케일링, 관리 등을 자동화 해주는 오픈 소스 컨테이너 오케스트레이션 엔진입니다. Kubernetes는 앞의 K와 s를 제외한 안쪽 8 글자를 줄여서 `K8s`, `케이(에이)츠` 라고 부르기도 합니다. 현재 K8s 오픈 소스 프로젝트는 Cloud Native Computing Foundation(CNCF)가 주관하고 있습니다.

K8s의 전신은 Google 내부 프로젝트인 Borg가 전신입니다. 매일 수 억개의 컨테이너를 배포 및 생성하는 플랫폼으로 Google의 십 수년간의 컨테이너 오케스트레이션 노하우 기술이 녹아들어간 기술입니다. 지난 2014년에 Google에서 오픈소스로 공개하여 현재는 여러 IT 대기업들이 개발에 참여하고 있습니다.

## 탄생 배경

- 기존의 서버 운영방식

![image](https://user-images.githubusercontent.com/60086878/103625188-fa133080-4f7d-11eb-937b-a416a042423e.png)

각 서버마다 운영하는 애플리케이션이 달라 각 서버마다 용도에 맞는 네이밍을 합니다. 즉, 서버 하나에 용도가 한정되며 그에 맞게 관리가 되는 시스템이었습니다. 이러한 이유로 서버마다 특정 애플리케이션을 구동하기 위한 환경이 모두 다르고, 

이때 만약 서버 A에 문제가 발생한 상황을 가정해봅시다. 서버 엔지니어는 서버 A에 서비스중인 애플리케이션 A가 지속적으로 배포하기 위해 문제가 된 서버를 복구할 때까지 다른 서버에 배포  해야 합니다. 하지만 다른 서버 역시 별도의 애플리케이션이 서비스중이기 때문에 애플리케이션 A와의 서버 B의 호환여부와 동시에 배포할 수 있는 리소스가 충분한지 여부도 확인해야 하는 매우 번거로운 과정이 따릅니다.

이러한 문제 상황은 언제 어느 서버에서 생길지 모르고, 발생할 때마다 위와 같은 절차가 이뤄지게 되면서 운영상의 어려움이 발생합니다.

- Docker의 등장

![image](https://user-images.githubusercontent.com/60086878/103625397-42325300-4f7e-11eb-88dd-16bc55f251a6.png)

가상화를 통한 리눅스 컨테이너 기술을 적용한 Docker의 등장으로 환경에 상관없이 Docker가 설치되어있는 환경이면 동일하게 애플리케이션을 실행할 수 있게 됐습니다. 덕분에 기존보다 관리가 한결 수월하게 됐지만, 컨테이너의 수가 늘어나면서 이것을 관리하는 것조차 어려움이 생겼습니다. 그래서 속속 등장하기 시작한게 컨테이너 오케스트레이션 기술입니다. Kubernetes는 그리스어로 배의 조타수라는 뜻으로, 로고도 조타 핸들 모양을 하고 있습니다. 


- K8s 클러스터 운영방식

K8s는 Master에서 Worker Node와 클러스터 내 Pod들을 관리합니다. 



## 대항마?

![image](https://user-images.githubusercontent.com/60086878/103619989-0e532f80-4f76-11eb-9ecf-4523d7699dba.png)

이러한 컨테이너 오케스트레이션 플랫폼은 K8s 이외에도 Docker Swarm이나 Apache Mesos와 Marathon 등이 있지만 현재는 K8s가 표준처럼 사용되고 있습니다.

# 🏗아키텍쳐

![image](https://user-images.githubusercontent.com/60086878/103619579-5a51a480-4f75-11eb-8a9b-664d1d04cba4.png)

K8s는 Containerized Application을 실행하는 노드라고 하는 워커 머신의 

K8s는 기본적으로 사용자가 정의한 Disired State와 Current State를 유지하는 내용을 골자로 합니다. 

![image](https://user-images.githubusercontent.com/60086878/103617297-5facf000-4f71-11eb-887b-107abd5b78b4.png)




# 참고
[Kubernetes Documentation](https://kubernetes.io/docs/home/)
[쿠버네티스(Kubernetes)란? 개념, 성능, 사용방법 및 차이점](https://www.redhat.com/ko/topics/containers/what-is-kubernetes)
[쿠버네티스 시작하기 - Kubernetes란 무엇인가?](https://subicura.com/2019/05/19/kubernetes-basic-1.html)


# 참고