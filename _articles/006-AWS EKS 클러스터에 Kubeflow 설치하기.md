---
id: 6
title: "⛴AWS EKS 클러스터에 Kubeflow 설치하기"
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
**AWS EKS**는 Kubernetes 컨트롤 플레인 또는 노드 설치를 쉽게 도와주는 서비스로 작동 및 유지 관리할 필요 없이 AWS에서 Kubernetes를 손쉽게 실행할 수 있게 해주는 관리형 서비스다. EKS는 비정상 컨트롤 플레인 인스턴스를 자동으로 감지하고 교체하며, 자동화된 업그레이드 및 패치를 제공한다.

EKS 클러스터 구축은 AWS eskworshop에서 제공하는 가이드대로 진행했다. 원활한 환경 구축을 위해 AWS CLI를 이용한 방법으로 설명한다.

### Prerequisites

EKS 클러스터 구축을 위해 필요한 AWS CLI와 aws-iam-authenticator를 설치하고, k8s 컨트롤 플레인 제어에 필요한 kubectl과 eksctl 바이너리 파일을 설치한다.

#### Bastion server
- AWS 계정 권한을 가지고 CLI 환경으로 AWS Application들을 사용하기 위한 역할
- 네트워크가 지원되는 어떤 컴퓨터든 상관 없고, 리소스도 최소한도만 있어도 됨. 다만, 공동 작업이 필요한 경우 다중접속이 가능해야 함
- AWS의 모든 서비스 생성 권한을 가지고 있기 때문에 보안이 매우 중요
- Amazon Linux AMI, Seoul region ap-northeast-2

#### Kubectl
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

#### AWS CLI
- AWS EC2를 이용해 Bestion server를 만들어 AWS CLI 환경 구축

1. AWS CLI2를 설치한다.
```
$ cd ~
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip 
```

2. 아래 명령어로 AWS CLI 설치를 확인한다.

```
$ aws --version
```
![](https://user-images.githubusercontent.com/60086878/103116254-28089300-46a9-11eb-8f8b-eafc08a22728.png)

#### aws-iam-authenticator
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
$ mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
```

4. .bash_profile에 환경변수를 추가한다.

```
$ echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
```

5. aws-iam-authenticator가 실행되는지 확인한다.
```
$ aws-iam-authenticator help
```
![](https://user-images.githubusercontent.com/60086878/103116431-d6acd380-46a9-11eb-92ca-f13f48bb1905.png)

#### eksctl
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

#### yq
1. 아래 명령어로 yq를 설치한다.
```
$ echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq yq "$@"}' | tee -a ~/.bashrc && source ~/.bashrc
```

#### jq
1. 아래 명령어로 jq를 설치한다.
```
$ sudo yum -y install jq gettext bash-completion moreutils
```

#### AWS Load Balancer Controller Version 설정
```
$ echo 'export LBC_VERSION="v2.0.0"' >>  ~/.bash_profile
$ .  ~/.bash_profile
```

#### IAM Role
1. 관리자 권한으로 [Create role](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess)에서 IAM role 생성한다.

2. 사용 사례 선택 - EC2 선택 후 다음:권한을 누른다.

3. AdministratorAccess 정책을 선택 후 다음:태그를 누른다.

4. 태그는 생략하고 다음:검토를 누른다.

5. 역할 이름을 입력한 후 역할 만들기를 누른다.
![](https://user-images.githubusercontent.com/60086878/103150153-9b4afb80-47b4-11eb-958e-e82102a9adcf.png)

6. 인스턴스 대시보드에서 작업-보안-IAM Role 변경에 접근하여 Bastion Server에 해당하는 인스턴스의 IAM Role을 생성한 Role로 수정한다.

7. Bastion Server에서 .aws/credentials 파일이 있다면 삭제한다.

8. 아래 명령어로 AWS REGION이 알맞게 불러와지는지 확인한다.
```
$ export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
$ export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

$ test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
```

9. AWS CLI 명령어가 원활하게 진행될 수 있도록 AWS 계정 정보를 환경변수로 설정한다.
```
$ echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
$ echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
$ aws configure set default.region ${AWS_REGION}
$ aws configure get default.region
```

10. 아래 명령어로 IAM Role이 유효한지 확인한다.
```
aws sts get-caller-identity --query Arn | grep eksworkshop-admin-i -q && echo "IAM role valid" || echo "IAM role NOT valid"
```

### EC2 vs. Fargate
EKS 클러스터는 노드를 관리할 필요 없는 AWS Fargate와 같은 관리형과 AWS CloudFormation을 통해 자동으로 EC2 노드가 구성되는 자체 관리형을 지원한다.

각 유형에 따른 특징은 다음과 같다.
- EC2
    - 자체 관리형 클러스터
    - 인스턴스 타입에 따라 가격이 결정
    - 각 인스턴스가 남아도는 리소스 없이 효율적 자원을 모두 사용 되어야 낭비를 줄일 수 있음

- Fargate
    - EC2 인스턴스 없이 컨테이너로 직접 실행 됨
    - 컨테이너를 구동하는 데 사용한 리소스만큼(CPU, Memory) 초단위로 요금이 청구됨.
    - 즉, 실제 리소스를 사용한 만큼만 비용이 청구되며, EC2처럼 사용하지 않은 요금에 대해 돈을 지불할 일이 줄어듬
    - small workload에 적합
    - 컨테이너를 실행하기 위해 가상 머신 그룹을 프로비저닝, 구성 또는 조정할 필요 없음

이 포스팅에서는 기본 구성인 EC2를 이용한 자체관리형 노드로 구성하는 방법을 소개한다.



1. 아래 내용을 cluster.yaml로 생성한다.
- yaml파일로 구성된 manifest들은 indent가 중요하므로 각별히 신경써주어야 한다.

```
apiVersion: eksctl.io/v1alpha5 kind: ClusterConfig
metadata:
    name: eksworkshop-eksctl-i/ **클러스터 이름
    region: ap-northeast-2 version: '1.17'

# NodeGroup holds all configuration attributes that are specific to a nodegroup 
# You can have several node group in your cluster.

nodeGroups:
    - name: cpu-nodegroup
    instanceType: m5.xlarge desiredCapacity: 3
    minSize: 0
    maxSize: 6
    volumeSize: 50 
    ssh:
        allow: true
        publicKeyPath: '~/.ssh/id_rsa.pub'

# Example of GPU node group 
    - name: Tesla-V100
    instanceType: p3.8xlarge
# Make sure the availability zone here is one of cluster availability zones.
    availabilityZones: ["ap-northeast-2"]
    desiredCapacity: 0
    minSize: 0
    maxSize: 4
    volumeSize: 50
    ssh:
        allow: true
        publicKeyPath: '~/.ssh/id_rsa.pub'

```

1. 아래 명령어로 bastion server의 ssh key를 생성한다.

```
# 모두 Enter 입력하여 기본값 생성 
$ ssh-keygen -t rsa
# 키 내용 전체 복사 
$ cat .ssh/id_rsa.pub 
```

2. 아래 명령어로 클러스터를 구성을 명령하면 수 분 내로 손쉽게 EKS(k8s) 클러스터가 구성된다.

```
$ eksctl create cluster -f cluster.yaml 
```

3. 아래 명령어로 노드의 상태를 확인한다.

```
$ kubectl get nodes 
```

4. (Optional) 노드 갯수 축소 및 확장 하려면 [아래 명령어](https://aws.amazon.com/ko/premiumsupport/knowledge-center/eks-worker-node-actions/)를 참고한다.

```
# 노드 갯수 조정
$ eksctl scale nodegroup --cluster=클러스터 이름 --nodes=노드 개수 --name=노드그룹 이름 --nodes-min=1 --nodes-max=6
# 노드 Min, Max 값 조정 예시
$ eksctl scale nodegroup --cluster=eksworkshop-eksctl-i --name=nodegroup --nodes-min=1 --nodes-max=6
```

- cluster.yaml 에서 클러스터 이름, 노드그룹 이름 확인

```
apiVersion: eksctl.io/v1alpha5 kind: ClusterConfig
metadata:
    name: eksworkshop-eksctl-i // **클러스터 이름 region: ap-northeast-2
    version: '1.17'

nodeGroups:
    - name: **cpu-nodegroup // 노드그룹 이름**
    instanceType: m5.xlarge desiredCapacity: 2 
    minSize: 0
    maxSize: 4
    volumeSize: 50
```

5. (Optional) EKS 클러스터 및 노드를 삭제 하려면 [아래 명령어](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/delete-cluster.html)를 참고한다. 

- eksctl ≥ 0.31.0-rc.0 이상인지 확인

```
$ eksctl version 
```

- 클러스터에서 실행중인 모든 서비스 나열

```
$ kubectl get svc --all-namespaces 
```

- EXTERNAL-IP 값과 연결된 모든 서비스를 삭제

```
$ kubectl delete svc **서비스 이름** 
```

- 클러스터 및 연결된 노드 삭제

```
$ eksctl delete cluster --name **클러스터 이름
```

- 현재 정의된 Cluster Autoscaler Group을 확인하는 방법

```
$ aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='**클러스터 이름']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" --output table
```

### (Optional)Cluster Autoscaler(CA) 설정
- Service Account IAM role Annotation
    - 서비스 계정은 해당 서비스 계정을 사용하는 모든 포드의 컨테이너에 AWS 권한을 제공 할 수 있음
    - 노드의 포드가 AWS API를 호출 할 수 있도록 더 이상 노드 IAM 역할에 확장 된 권한을 제공 할 필요 없음

```
# Service Account가 IAM role을 사용가능하도록 설정 
$ eksctl utils associate-iam-oidc-provider \
--cluster eksworkshop-eksctl-i --approve

$ mkdir ~/environment/cluster-autoscaler

$ cat <<EoF > ~/environment/cluster-autoscaler/k8s-asg-policy.json {
"Version": "2012-10-17", "Statement": [
{
"Action": [
"autoscaling:DescribeAutoScalingGroups", "autoscaling:DescribeAutoScalingInstances", "autoscaling:DescribeLaunchConfigurations", "autoscaling:DescribeTags", "autoscaling:SetDesiredCapacity", "autoscaling:TerminateInstanceInAutoScalingGroup", "ec2:DescribeLaunchTemplateVersions"
],
"Resource": "*", "Effect": "Allow"
} ]
} EoF

# iam policy 생성
$ aws iam create-policy \
--policy-name k8s-asg-policy \
--policy-document file://~/environment/cluster-autoscaler/k8s-asg-policy.json

# kube-system namespace에 CA Service Account를 위한 IAM role을 생성 
$ eksctl create iamserviceaccount \
--name cluster-autoscaler \
--namespace kube-system \
--cluster eksworkshop-eksctl-i \
--attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy" \ 
--approve \
--override-existing-serviceaccounts

# Service Account가 IAM role의 ARN과 함께 잘 annotated 되었는지 확인 
$ kubectl -n kube-system describe sa cluster-autoscaler
```


- Cluster Autoscaler Deploy
    - 요청된 작업이 desired-capacity의 리소스 한계를 넘을 때 CA에 지정한 Max node 범위 안에서 자동으로 node를 확장할 수 있음

```
# Deploy the Cluster Autoscaler
$ kubectl apply -f https://www.eksworkshop.com/beginner/080_scaling/deploy_ca.files/cluster-autoscaler-autodiscover.yaml

# pod가 실행되고 있는 node가 삭제되는 것을 방지하기 위한 설정 
$ kubectl -n kube-system \
annotate deployment.apps/cluster-autoscaler \ 
cluster-autoscaler.kubernetes.io/safe-to-evict="false"

# Autoscaler image를 업데이트
$ export K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
$ export AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})
$ kubectl -n kube-system \
set image deployment.apps/cluster-autoscaler \
cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSC ALER_VERSION}

# 로그 확인
$ kubectl -n kube-system logs -f deployment/cluster-autoscaler

# Autoscaling Group 설정
$ aws autoscaling \
update-auto-scaling-group \ 
--auto-scaling-group-name ${ASG_NAME} \ 
--min-size 1 \ # 최소 노드 개수
--desired-capacity 3 \ 지정 노드 개수
--max-size 6 # 최대 노드 개수
```

## Kubeflow 설치
현재 Amazon에서 지원하는 EKS버전과 Kubeflow v1.2의 호환 여부는 다음과 같다. 본 포스팅에서는 EKS v1.17을 사용하고 있으므로, Kubeflow v1.2 기준으로 설치 과정을 소개한다.

 ![](https://user-images.githubusercontent.com/60086878/103150473-eb778d00-47b7-11eb-9c31-438418569d62.png)

1. Bastion Server에서 Kubeflow GitHub에서 [Release v1.2.0](https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz)을 다운로드 한다.
 
2. 다음 명령어로 tar 압축을 해제한다.
```
$ tar -xvf kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
```

3. 아래 명령어로 kfctl Binary 파일을 이동시킨다.

```
$ mv ./kfctl /usr/local/bin 
```

4. 배포 과정을 간략화 하기위해 아래 환경변수를 추가한다.

```
$ export PATH=$PATH:"/usr/local/bin"
$ export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws.v1.2.0.yaml"
$ export AWS_CLUSTER_NAME=eksworkshop-eksctl-i / **클러스터 이름
```


5. 아래 명령어로 클러스터 이름으로 폴더를 생성하고, kubeflow 설치를 위한 manifest를 다운로드 받는다.
```
$ mkdir ${AWS_CLUSTER_NAME} && cd ${AWS_CLUSTER_NAME}
$ wget -O kfctl_aws.yaml $CONFIG_URI
```

6. 아래 명령어로 Kubeflow 클러스터를 생성한다.
```
$ kfctl apply -V -f kfctl_aws.yaml
```

7. 설치가 완료되기까지 약 수 분이 소요된다. 명령어 프롬프트가 나타나면 아래 명령어로 kubeflow namespace에 pod들이 올라왔는지 확인한다.
```
$ kubectl -n kubeflow get all
```

8. Kubeflow 대시보드에 접근하기 위해 아래 명령어로 Kubeflow 서비스의 Endpoint(ADDRESS)를 확인한다.

```
$ kubectl get ingress -n istio-system

NAMESPACE      NAME            HOSTS   ADDRESS                                                             PORTS   AGE
istio-system   istio-ingress   *       a743484b-istiosystem-istio-2af2-xxxxxx.ap-northeast-2.elb.amazonaws.com   80      1h
```

9. Default 계정은 다음과 같다.
```
ID : admin@kubeflow.org
PW : 12341234
```

![](https://user-images.githubusercontent.com/60086878/103151073-0f3dd180-47be-11eb-9c8e-3fa9c64ce30a.png)



# 참고
- [Installing Kubeflow](https://www.kubeflow.org/docs/aws/deploy/install-kubeflow/)
- [Amazon EKS Workshop Start the workshop](https://www.eksworkshop.com/020_prerequisites/)
- [Amazon EKS란 무엇입니까?](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html)
- [EKS Worker Node Action](https://aws.amazon.com/ko/premiumsupport/knowledge-center/eks-worker-node-actions/)