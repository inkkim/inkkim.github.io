---
id: 6
title: "AWS EKS 클러스터에 Kubeflow 설치하기"
subtitle: "ML Toolkit for Kubernetes"
date: "2020.12.25"
tags: "EKS, Kubernetes, Kubeflow"
---

이번에는 지난 엔코아 데이터과학자 양성과정에서 진행한 서울특별시 공공자전거 따릉이 잔여대수 예측 프로젝트를 진행하면서 사용했던 Kubeflow라는 툴에 대해 소개하고자 한다.

프로젝트의 대략적인 아키텍쳐는 다음과 같다.

![](https://user-images.githubusercontent.com/60086878/103115141-cfcf9200-46a4-11eb-888e-ceeacfa4bd38.png)

- EC2 기반 AWS EKS 클러스터
- AWS Aurora (PostgreSQL)
- 공공데이터 실시간 API 수집 및 웹 스크래핑 서버
- 시각화 데이터 Elasticsearch에 적재
- 위 모든 과정을 포함한 ML 모델링까지 Kubeflow Pipeline으로 자동화
- Kibana 실시간 대시보드

운 좋게도 학원 측에서 AWS 크레딧을 지원받아 AWS 환경에서 구축해 볼 수 있었다. 따라서 이번 포스팅은 AWS EKS 기준으로 Kubeflow 설치 방법을 소개한다.

# Kubeflow란 ?
![](https://user-images.githubusercontent.com/60086878/103114462-fc35df00-46a1-11eb-96da-776017192c9b.png)

공식 문서에서는 Kubeflow를 다음과 같이 설명하고 있다.

>Kubeflow 프로젝트는 새로운 서비스를 다시 만드는 것이 아닌 ML을 위한 동급 최고의 오픈소스 시스템을 다양한 인프라에 배포하는 간단한 방법을 제공합니다. ML Workfow를 Kubernetes에 간단하게 이식하여 확장성과 배포 용이성을 보장하는 데 전념합니다.

![](https://user-images.githubusercontent.com/60086878/103115552-65b7ec80-46a6-11eb-86a0-a4fb31a21255.png)

- 구글 내부 프로젝트에서 시작되어 2018년 3월 오픈소스로 공개됨
- 2020.12.25 기준 약 9,700 GitHub Star, Release v1.2.0
- KFServing, Jupyter Notebooks, MXNet, Tensorflow, PyTorch, XGBoost, Katib 등 다양한 프레임워크 지원

# 설치
![](https://user-images.githubusercontent.com/60086878/103115087-9d259980-46a4-11eb-8444-e2191b03bdc6.png)

공식 문서에 따르면 사용자의 상황에 따른 설치 가이드를 제시한다. 위에 언급했듯이 마침 클라우드 환경이 제공되어 이번 포스팅에서는 AWS EKS에 배포하는 방법으로 설명한다.

## EKS 클러스터 구축
EKS 클러스터 구축은 AWS eskworsho에서 제공하는 가이드대로 진행했다. 원활한 환경 구축을 위해 AWS CLI를 이용한 방법으로 설명한다.

### Prerequisites

**Bestion server**
- AWS 계정 권한을 가지고 CLI 환경으로 AWS Application들을 사용하기 위한 역할
- 네트워크가 지원되는 어떤 컴퓨터든 상관 없고, 리소스도 최소한도만 있어도 됨. 다만, 공동 작업이 필요한 경우 다중접속이 가능해야 함
- AWS의 모든 서비스 생성 권한을 가지고 있기 때문에 보안이 매우 중요
- Amazon Linux AMI, Seoul region ap-northeast-2

**Kubectl**
- CLI환경에서 Kubernetes 클러스터를 구성 및 application 배포, 검사, 리소스 관리,
로그 확인 등의 기능
- 노드 간 마이너 버전 차이가 0.2이상 나면 오류 발생할 수 있음
- 예를 들어, master 노드에서 v1.18를 사용하면, 다른 노드에서는 v1.17 ~ v1.19 사용 가능
1.[최신 Stable 버전](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)을 다운로드한다.
```
$ curl -LO https://storage.googleapis.com/kubernetes-release/ release/v1.17.0/bin/linux/amd64/
$ kubectl
```
2. kubectl binary 파일에 실행권한을 부여한다.
```
$ chmod +x ./kubectl 
```
3. kubectl binary 파일을 바이너리 폴더로 이동시킨다.
```
$ sudo mv ./kubectl /usr/local/bin/$ kubectl 
```
4. kubectl 명령어로 버전을 확인한다.
```
$ kubectl version --client 
```

![](https://user-images.githubusercontent.com/60086878/103116121-97ca4e00-46a8-11eb-8ae1-29eeb0f8862a.png)

**AWS CLI 설정**
- AWS EC2를 이용해 Bestion server를 만들어 AWS CLI 환경 구축

1. AWS CLI2를 설치한다.
```
$ cd ~
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip 
```

2. AWS CLI를 실행한다.
```
$ aws configure 
```

3. Access Keys를 입력한다.
- AWS Management Console에 root 권한으로 로그인 한다.
- 우측 상단의 네비게이션 바 - 계정 - 내 보안자격 증명 - 액세스 키 - 새 액세스 키 만들기(최초)
- 생성된 ID:PW가 저장된 Key File.csv 파일 저장

```
AWS Access Key ID [None]: XXXXXXXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Default region name [None]: ap-northeast-2
Default output format [None]: json
```

4. 아래 명령어로 AWS CLI 설치를 확인한다.

```
$ aws --version
```
![](https://user-images.githubusercontent.com/60086878/103116254-28089300-46a9-11eb-8f8b-eafc08a22728.png)

**aws-iam-authenticator**
- AWS EKS가 IAM을 사용하여 aws-iam-authenticator를 통해 Kubernetes 클러스터에 인증을 제공

1. AWS S3로부터 aws-iam-authenticator binary 파일을 설치한다.

```
$ curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/aws -iam-authenticator
```

2. aws-iam-authenticator binary 파일에 실행권한을 부여한다.

```
$ chmod +x ./aws-iam-authenticator 
```

3. aws-iam-authenticator binary 파일을 $HOME/bin에 위치시킨다.

```
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
```

4. .bash_profile에 환경변수를 추가한다.

```
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
```

5. aws-iam-authenticator가 실행되는지 확인한다.
```
aws-iam-authenticator help
```
![](https://user-images.githubusercontent.com/60086878/103116431-d6acd380-46a9-11eb-92ca-f13f48bb1905.png)

**eksctl**
- EKS에 클러스터를 구축하는데 필요한 CLI tool
- CloudFormation에 사용

1. 최신 버전을 설치한다.
```
$ curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
```

2. eksctl binary 파일을 /usr/local/bin으로 위치시킨다.
```
$ sudo mv /tmp/eksctl /usr/local/bin 
```

![](https://user-images.githubusercontent.com/60086878/103116474-f8a65600-46a9-11eb-9ae6-a1d9a9280b71.png)

# 참고
- [Installing Kubeflow](https://www.kubeflow.org/docs/started/getting-started/)
- [Amazon EKS Workshop Start the workshop](https://www.eksworkshop.com/020_prerequisites/)