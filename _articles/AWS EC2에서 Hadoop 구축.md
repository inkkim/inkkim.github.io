---
id: 0
title: "🐘AWS EC2에서 Hadoop 구축"
subtitle: "빅데이터 일등공신, 대용량 분산 파일 시스템"
date: "2020.10.18"
tags: "빅데이터, 분산처리, 인프라"
---

# 🐘 하둡(Hadoop)이란 ? 
- 대규모 검색 색인을 구축하기 위해 Java로 개발된 오픈 소스 분산 컴퓨팅 플랫폼

![Hadoop Logo](https://user-images.githubusercontent.com/60086878/96373727-59e11300-11a9-11eb-8e90-87e63b3c40b2.jpg)

 하둡의 로고의 코끼리는 개발자 더그 커팅이 자신의 아이가 가지고 놀던 장난감 코끼리의 이름을 따서 하둡이라는 이름을 지었다고 한다.f(개발자의 네이밍 세계는 생각보다 단순하다.)

# 핵심 컴포넌트

## 하둡 분산 파일 시스템(HDFS, Hadoop Distributed File System)
 앞서 언급했듯이 하둡은 확장성과 장애 허용성을 가진 분산 파일 시스템이다. 대규모 데이터셋 분석이라는 하둡의 원래 용도에 맞게, HDFS는 일반적으로 상당히 긴 순차 접근(Sequential Access)방식을 통해 디스크에 불변 데이터를 저장하는데 최적화돼 있다. 그러므로 HDFS는 하둡 스택 내 다른 컴포넌트를 지원하는 핵심 기술이다.

- 데이터를 설정 가능한 크기의 블록으로 나눠 저장 (기본값은 128MB)
- 데이터 회복성 및 병렬 처리를 위해 여러 대의 서버에 각 블록의 복제본(Replica) 저장
- 마스터 서버에서 실행되는 네임노드(Namenode) 프로세스가 파일이 어느 복제본에 속하는지에 대한 정보와 파일과 블록 사이의 매핑 정보, 파일 이름, 권한, 속성, 복제 계수(Replication Factor)등 파일 자체의 메타 데이터를 모두 관리
- 파일의 일부분 수정 미지원으로 불변성을 보장하여 수평적 확장성과 데이터 회복력을 비교적 단순한 방법으로 획득

## 얀(YARN, Yet Another Resource Negotiator)
 하둡의 클러스터 관리 시스템으로 가장 효율적인 방법으로 계산, 리소스를 할당하고 사용자 애플리케이션을 스케쥴링하는 시스템이다. 스케쥴링과 리소스 관리로 데이터 지역성을 극대화하고, 계산량이 많은 애플리케이션이 리소스를 독점하지 않게 제어 및 교체 가능한 스케쥴링 시스템을 지원한다. 사용자당 리소스 제한이나 작업 대기열당 리소스 할당량 등 공용 리소스 시스템의 스케쥴링에 필요한 기본적인 환경 설정을 스케쥴러에 입력할 수 있다.

 ![Hadoop Logo](https://user-images.githubusercontent.com/60086878/96365911-08bc2980-117f-11eb-95ac-d37e775255ad.png)
 
- 구성 
    - Resource Manager라고 불리는 마스터 노드
        - 클러스터 전체의 계산 리소스를 관리하고, 클라이언트가 요구한 리소스를 Node Manager로부터 확보하도록 스케쥴링함
        - 요청된 Executor 개수와 CPU 코어의 수, 메모리 양에 따라 Executor를 하나 이상의 Node Manager로부터 확보하는 역할을 담당
    - Node Manager라고 하는 여러 개의 워커 노드
        - 자신이 설치된 노드의 계산 리소스만을 관리

- 클러스터의 리소스를 컨테이너로 분할하고, 기본적으로 할당되는 CPU 코어 수와 메모리 용량으로 정의되며 출가 리소스를 포함할 수도 있음
- 실행중인 컨테이너들을 모니터링하면서 컨테이너가 리소스의 최대 할당량을 초과하지 않게 억제
- 클러스터의 리소스를 컨테이너로 관리함으로써 분산 시스템을 전체적으로 원활하게 운영하고, 클러스터의 리소스를 다수 애플리케이션에 공평한 방식으로 공유
- 컨테이너를 비공개로 설정할 수도 있고, 사용자가 요청한 작업을 적절한 시점에 시작할 수도 있음

## 맵리듀스(MapReduce)
- 2004년 구글에서 대용량 데이터를 분산처리하기 위해 발표한 대용량 분산 처리 프레임워크
- 테라바이트 또는 페타바이트 이상의 대용량 데이터를 저렴한 x86 서버를 클러스터링해 분산 처리
- 데이터를 처리하는 기본 단위는 매퍼(Mapper)와 리듀스(Reduce)
- 맵(Map)은 산재된 데이터를 키와 벨류 형태로 연관성이 있는 데이터로 묶는 작업
- 리듀스(Reduce)는 맵 작업 결과에서 중복 데이터를 제거한 후 원하는 데이터를 추출하는 작업을 수행

# 구축 방법

- 구축 환경
    - MacOS(Catalina 10.15.5)
    - AWS EC2
        - t2.small(3EA)
    - Red Hat Enterprise Linux 8
    - SSD 30GB

## AWS EC2 인스턴스 생성

1. AWS에서 계정을 생성하고 로그인 한 후, AWS Management Console - 컴퓨팅 - EC2에 접근한다.

2. 인스턴스 시작을 눌러, 다음 순서대로 인스턴스를 생성한다.

    - AMI 선택

    ![Amazon Machine Image](https://user-images.githubusercontent.com/60086878/96366595-74a09100-1183-11eb-808b-88dfd2f21adb.png)
    Red Hat Enterprise Linux 8
    
    - 인스턴스 유형 선택
    
    ![AWS On-Demand Pricing](https://user-images.githubusercontent.com/60086878/96366700-2e97fd00-1184-11eb-8e1c-7e5d011c7a98.png)
        - 요금이 t2.micro의 겨우 2배 수준인 t2.small
        - AWS의 살인적인 요금제에 프리티어 과금을 피하기 위하여 인스턴스 유형은 프리티어급보다 한 단계 상위버전인 t2.small로 진행
    
    - 인스턴스 구성
    1개로 구성하여 하둡에 필요한 설정을 모두 마친 후 이미지를 생성하여 나머지 2개를 만들 예정

    - 스토리지 추가
    30 GB

    - 검토
    
        - AWS EC2를 처음 이용할 경우, 새 키 페어 생성으로 키 페어 이름을 입력한 후 키 페어 다운로드

        - 기존 유저의 경우, 기존 키 페어 선택 후 선택한 키 파일에 엑세스 가능 여부 체크

3. 인스턴스 접속 


![IPv4 Public IP](https://user-images.githubusercontent.com/60086878/96367212-5f2d6600-1187-11eb-8267-241a050a9571.png)


- 해당 인스턴스의 Public IP를 복사하고, 터미널에서 ssh 명령어를 통해 접속한다.

```
$ ssh -i ./YOUR_KEY.pem ec2-user@PUBLIC_IP
```

![SSH Access](https://user-images.githubusercontent.com/60086878/96367234-7d936180-1187-11eb-8583-473b718bcc44.png)


## 리눅스 환경설정
1. SELINUX 끄기


원활한 설치를 위해 Red Hat 보안 요소인 SELINUX를 끄고 진행
- etc 파일 수정을 위해 sudo 명령어로 config 파일 열기
```
$ sudo vi /etc/selinux/config
```

- SELINUX disabled

```
SELINUX=disabled
```

- 변경사항 적용을 위해 재부팅
```
$ sudo reboot
```

2. 보안상 새로운 계정을 생성

- hadoop 이름으로 새로운 계정 생성
```
$ useradd hadoop
```

- 비밀번호 설정
```
$ passwd hadoop
```

3. hadoop 계정에 sudo 권한 부여

- etc 파일 수정을 위해 sudo 명령어와 쓰기 권한없이 바로 편집할 수 있는 visud 명령어를 통해 sudoers파일 열기
```
$ sudo visudo /etc/sudoers
```

- 계정권한 부여 명령 추가
```
hadoop  ALL=(ALL)   ALL
```
![Add Permission](https://user-images.githubusercontent.com/60086878/96367971-e67cd880-118b-11eb-80ed-635a50aab6ef.png)

4. SSH Key-based 인증 설정


 공개키를 등록하여 각 인스턴스끼리 비밀번호 없이 지속적인 통신을 가능하게 함
- hadoop 계정 로그인
```
$ su hadoop
```

- SSH Key 생성 (명령어 실행 후 엔터)
```
$ ssh-keygen -t rsa
```

- authorized_keys파일에 공개키 추가
```
$ cat ~/.ssh/id_rsa.pub >> ~/.ssh authorized_keys
```

- authorized_keys 권한 부여
```
$ chmod 640 ~/.ssh/authorized_keys
```

- ssh 접속 확인
```
$ ssh localhost
```

## Hadoop 설치
1. Java 설치


 Hadoop은 Java로 쓰여진 오픈 소스이므로 사전에 Java 설치 필수이다. 따라서 Java 버전에 영향을 많이 받으므로, Hadoop 3.2.1 버전과 호환되는 java-1.8.0-openjdk 버전 설치한다.

- Java 설치
```
$ sudo dnf install java-1.8.0-openjdk ant -y
```

- Java 명령어로 설치여부 확인
```
$ java -version
```

2. Hadoop 설치


 [Hadoop 3.2.1](https://downloads.apache.org/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz) 해당 링크를 복사하여 설치
- 웹 파일 다운로드 패키지 다운로드
```
$ sudo yum install wget
```

- Hadoop 설치

```
$ cd ~
$ sudo wget https://downloads.apache.org/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
$ tar -xvzf hadoop-3.2.1.tar.gz
```

- 폴더명 변경
```
$ mv hadoop-3.2.1 hadoop
```

- 환경변수 설정
```
$ vi ~/.bashrc
```

- 환경변수 내용 추가


[Hadoop Cluster 설정 관련 메뉴얼](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html)

```
export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.265.b01-0.el8_2.x86_64
export HADOOP_HOME=/home/hadoop/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
```
JAVA_HOME은 /usr/lib/jvm/ 밑에 폴더명으로 설정(다운로드 시기에 따라 빌드 버전이 다를 수 있음)

- 하둡 환경파일 수정
```
$ cd ~/hadoop/etc/hadoop
```

- workers ()
```
datanode1
datanode2
```

- core-site.xml
```
<configuration>
 <property>
  <name>fs.defaultFS</name>
   <value>hdfs://namenode:8020/</value>
 </property>
 <property>
  <name>io.file.buffer.size</name>
   <value>131072</value>
 </property>
</configuration>
```

- hdfs-site.xml
```
<configuration>
	<property>
		<name>dfs.replication</name>
		<value>1</value>
	</property>
	<property>
		<name>dfs.namenode.http-address</name>
		<value>namenode:50070</value>
	</property>
	<property>
		<name>dfs.namenode.secondary.http-address</name>
		<value>secondnode:50090</value>
	</property>
	<property>
		<name>dfs.datanode.http-address</name>
		<value>0.0.0.0:50010</value>
	</property>
	<property>
		<name>dfs.namenode.name.dir</name>
		<value>file:///home/hadoop/hadoop/data/name1,file:///home/hadoop/hadoop/data/name2</value>
	</property>
	<property>
		<name>dfs.datanode.data.dir</name>
		<value>file:///home/hadoop/hadoop/data</value>
	</property>
	<property>
		<name>dfs.namenode.checkpoint.dir</name>
		<value>file:///home/hadoop/hadoop/data/namesecondary</value>
	</property>
</configuration>
```

- mapred-site.xml
```
<configuration>
        <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
        </property>
        <property>
                <name>mapreduce.jobhistory.address</name>
                <value>namenode:10020</value>
        </property>
        <property>
                <name>mapreduce.jobhistory.webapp.address</name>
                <value>namenode:19888</value>
        </property>
        <property>
                <name>yarn.app.mapreduce.am.env</name>
                <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
        </property>
        <property>
                <name>mapreduce.map.env</name>
                <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
        </property>
        <property>
                <name>mapreduce.reduce.env</name>
                <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
        </property>
</configuration>
```

- yarn-site.xml
```
<configuration>

<!-- Site specific YARN configuration properties -->
	<property>
		<name>yarn.resourcemanager.hostname</name>
		<value>secondnode</value>
	</property>
	<property>
		<name>yarn.nodemanager.local-dirs</name>
		<value>/home/hadoop/hadoop/data/nm</value>
	</property>
	<property>
		<name>yarn.nodemanager.aux-services</name>
		<value>mapreduce_shuffle</value>
	</property>
	<property>
		<name>yarn.nodemanager.resource.cpu-vcores</name>
		<value>2</value>
	</property>
</configuration>
```

- hdfs 저장을 위한 디렉토리 생성
```
$ cd hadoop
$ mkdir data
```

- 종료
```
$ sudo shutdown -h now
```

## 이미지 생성 및 복사
1. 이미지 복사
- 인스턴스 목록에서 해당 인스턴스 선택 후 복사
![Create AMI](https://user-images.githubusercontent.com/60086878/96369153-55a9fb00-1193-11eb-865d-5a4c82677af9.png)

2. AMI 생성
- AMI 목록에서 해당 이미지 생성 (나머지 구성은 동일하게 하되, 인스턴스 구성은 2개로 진행)

- 인스턴스 목록에서 각 인스턴스를 구분하기 쉽게, 인스턴스 이름을 각각 Client, Namenode, Secondnode로 수정
![Set Name](https://user-images.githubusercontent.com/60086878/96369527-7ecb8b00-1195-11eb-9a89-483cc5396bac.png)

- 이전과 동일한 방법으로 3개의 터미널에서 각각의 인스턴스에 접속 (인스턴스는 재부팅 후 Public IP가 재할당되므로 재확인 후 접속)

3. hostname 설정
- 각각의 인스턴스에서 진행
```
$ sudo hostnamectl set-hostname client
$ sudo hostnamectl set-hostname namenode
$ sudo hostnamectl set-hostname secondnode
```

4. 각각의 인스턴스 연결
- hosts 파일 열기
```
$ sudo vi /etc/hosts
```

- 각각의 Private IP 연동 (172.x.x.x)
```
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.31.28.51    client
172.31.18.187   namenode
172.31.18.187   datanode1
172.31.20.195   secondnode
172.31.20.195   datanode2
```
![Private IP](https://user-images.githubusercontent.com/60086878/96369633-2943ae00-1196-11eb-951f-b45c8d91a16f.png)

- SSH 접근 확인 (hadoop 계정에서 실행)
```
$ ssh client
$ ssh secondnode
$ ssh namenode
```
모두 이상없이 연결된다면 각각의 인스턴스가 서로 인증없이 통신할 수 있는 상태를 의미

## Hadoop 실행
1. Hadoop 구동
- hdfs 파일 포맷
```
$ hadoop namenode -format 
```

- dfs(namenode) 시작
```
$ start-dfs.sh
$ jps
$ ssh secondnode
$ jps
```
namenode에서는 jps 명령어 시 DataNode, NameNode가 실행


secondnode에서는 jps 명령어 시 DataNode, SecondaryNameNode가 실행

- yarn(secondnode) 시작
```
$ start-yarn.sh
$ jps
```
secondnode에서 jps 명령어 시 추가로 ResourceManager, NodeManager가 실행

2. Hadoop 모니터링
외부에서 인스턴스에 접속할 수 있도록 방화벽 설정을 통해 특정 IP와 포트를 설정하는 작업이 필요

- 내 IP 확인
[내 IP 주소 확인](https://www.findip.kr)

- 보안그룹 설정 접근
![Security Group](https://user-images.githubusercontent.com/60086878/96371729-2baa0600-119e-11eb-8347-cc7c3548c1fb.png)


- 인스턴스의 보안그룹 탭으로 접근하여 각 인스턴스에 해당하는 보안그룹의 인바운드 규칙 편집
![Setting Security Group](https://user-images.githubusercontent.com/60086878/96371898-12ee2000-119f-11eb-8782-ff4388e21825.png)


소스는 각자 본인 IP 주소/32(eg; 111.222.333.4/32)

- namenode Public IP:50070
- secondnode Public IP:8088
![Manage Page](https://user-images.githubusercontent.com/60086878/96372012-d53dc700-119f-11eb-8dff-a1dd1c25c075.png)

# 참고
- 엔터프라이즈 데이터 플랫폼 구축 (책만)
- [데이터실무 기술 가이드 > 데이터 처리](http://www.dbguide.net/db.db?cmd=view&boardUid=187336&boardConfigUid=9&categoryUid=1459&boardIdx=158&boardStep=1) (DBGuide)
- [How To Install and Configure Hadoop on CentOS/RHEL 8](https://tecadmin.net/install-hadoop-centos-8/)