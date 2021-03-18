---
title: "Hadoop Ecosystem 이란?"
categories: 
  - Hadoop
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
readtime: true
excerpt: "빅데이터 플랫폼 Hadoop의 Ecosystem을 소개한다."
tags:
  - 빅데이터
  - 분산처리
  - Hadoop Ecosystem
header:
  teaser: https://user-images.githubusercontent.com/60086878/111653801-85952180-884b-11eb-84a4-5672b521c566.png
---

# Hadoop Ecosystem 이란?

![image](https://user-images.githubusercontent.com/60086878/111483142-de938580-8777-11eb-92c6-7527eeb4fdeb.png){: .align-center}

Hadoop Ecosystem은 Hadoop 환경에서 빅데이터 문제를 효율적으로 다루기 위해 만들어진 서브 프로젝트들의 집합입니다. 이중 가장 핵심 요소는 규모의 데이터를 수용할 수 있는 분산파일 시스템인 Hadoop Distributed File System(HDFS)와 그것을 처리할 수 있게 해주는 MapReduce 입니다. 이를 중심으로 분산 코디네이터, 워크플로우 관리, 분산 리소스 관리, 데이터 마이닝, 분석, 수집, 직렬화 등 다양한 서비스들로 구성되어 있습니다.

---

## Distributed File System

### HDFS (Hadoop Distributed File System)

![image](https://user-images.githubusercontent.com/60086878/111476919-f10ac080-8771-11eb-90f4-521f9f2acbd1.png){: .align-center}

Hadoop의 스토리지 컴포넌트로 확장성과 장애 허용성을 가진 분산 파일시스템입니다. 대규모 데이터 분석이라는 Hadoop의 원래 용도에 맞게 HDFS는 일반적으로 상당히 긴 **Sequential Access 방식**을 통해 디스크에 불변 데이터를 저장하는데 최적화 되어있습니다. HDFS는 Hadoop Stack 내 다른 컴포넌트를 지원하는 핵심 기술입니다.

데이터를 설정 가능한 크기의 블록으로 나눠 저장하며, 기본 값은 128MB입니다. 예를 들어, 1G의 데이터를 저장할 때에는 8개의 블록으로 나뉘어 저장하게 되는 셈입니다. 반면, 50MB의 데이터를 저장하더라도 1개의 블록에 저장하게 되므로 블록 단위보다 작은 용량의 데이터를 저장할 때에는 비효율적일 수 있습니다. 

HDFS는 **데이터 회복성**과 **병렬 처리**를 위해 여러 대의 서버에 각 블록의 복제본을 저장하게 됩니다. 기본 값은 3이므로, 1G의 데이터를 저장하기 위해서는 총 3G의 용량이 필요하게 되는 셈입니다. 이 때문에 HDFS에서는 개별 디스크나 데이터 노드에 장애가 발생하더라도 데이터 안정성이 유지되므로 **장애 허용성**이 있습니다.

또한 HDFS는 로컬 스토리지를 포함하는 데이터 노드를 클러스터에 추가하면 파일시스템 용량이 늘어나므로 **확장성**이 있습니다. 이때 부수적으로 분산 파일 시스템 전체로 볼 때 읽기와 쓰기 처리량이 함께 높아지는 부수적인 효과도 있습니다.

## Distributed Programming

### MapReduce

![image](https://user-images.githubusercontent.com/60086878/111479061-fa952800-8773-11eb-85e8-33f8cd750f54.png){: .align-center}

Hadoop은 빅데이터를 다루기 위해 구글에서 발표한 MapReduce 알고리즘을 이용합니다. 이는 병렬 프로그래밍으로 클러스터 내에서 쉽게 분산 처리를 할 수 있도록 도와줍니다. 분할 정복 방식으로 작동하며, 시스템에서 프로세스를 실행하여 네트워크의 트래픽을 줄입니다.

![image](https://user-images.githubusercontent.com/60086878/111480804-b4d95f00-8775-11eb-8809-acc6ccc007e7.png){: .align-center}

MapReduce 알고리즘은 크게 아래 두 가지로 단계로 나뉠 수 있습니다.

**Map 단계**에서는 필터링, 그룹화, 정렬이 이뤄지는데요. Input 데이터가 들어오면 Split하여 Map을 만들게 됩니다. 각 Map들은 각자 다른 노드에서 Key-Value 짝을 맺어 출력하는 Task를 진행하고, 같은 Key를 가지는 데이터끼리 분류하는 Shuffling 과정을 거쳐 최종적으로 분산되어 있는 연산결과를 합치는 **Reduce 단계**를 거쳐 병합되어 HDFS에 저장됩니다.

### YARN (Yet Another Resource Negotiator)

![image](https://user-images.githubusercontent.com/60086878/111481186-0eda2480-8776-11eb-8001-98dbb3cc6ecd.png){: .align-center}

YARN은 Hadoop 내 작업 스케쥴링, 클러스터 리소스 관리를 위한 프레임워크입니다. 한정된 자원에서 가용 연산 자원의 용량과 필요한 워크로드를 관리하여 다양한 연산이 동시에 실행될 수 있도록 돕는 중앙 클러스터 매니저 역할을 하게 됩니다. 이를 통해 자원의 사용 효율성을 높이고 데이터 접근 비용을 낮출 수 있습니다.

YARN은 각 워커 노드에 **노드매니저 데몬**을 실행시키고, 이 데몬들이 마스터 프로세스인 **리소스매니저**에 여러 정보를 보고하게 됩니다. 노드매니저는 가상 코어의 단위로 얼마나 많은 연산 자원을 사용할 수 있는지와 해당 노드에 메모리가 얼마나 남아있는지를 리소스매니저에게 알려줍니다. 가용 자원은 클러스터 내 실행되는 애플리케이션에 컨테이너 형태로 분항되어 제공되며, 노드매니저는 로컬 노드에 있는 컨테이너를 기동하여 모니터링하면서 할당 자원을 초과하는 컨테이너는 중단시킵니다.

### Spark

![image](https://user-images.githubusercontent.com/60086878/111484650-4dbda980-8779-11eb-9c9f-b043f17d34a7.png){: .align-center}

Apache Spark는 통합 컴퓨팅 엔진으로 클러스터 환경에서 데이터를 병렬로 처리하는 라이브러리 집합입니다. 현재 가장 활발하게 개발되고 있는 **병렬 처리 오픈소스 엔진**으로 여러 개발자와 데이터 과학자에게 표준 도구가 되어가고 있습니다. Spark는 Python, Java, Scala, R을 지원하며 SQL뿐 아니라 스트리밍, 머신러닝에 이르는 넓은 범위의 라이브러리를 제공합니다.

Spark는 MapReduce처럼 Job에 필요한 데이터를 디스크에서 매번 가져오는 대신, 데이터를 메모리에 캐시로 저장하는 인-메모리 실행 모델로 성능을 비약적으로 향상시켜 MapReduce보다 10~100배까지 빠르다고 평가됩니다. 덕분에 일괄 처리 작업이나 데이터 마이닝 같은 온라인 분석처리(OLAP)에 유용합니다. Spark는 Standalone이나 Hadoop YARN 클러스터, Apache Mesos 클러스터 등 다양한 유형의 클러스터 매니저를 사용할 수 있습니다.

### Pig

![image](https://user-images.githubusercontent.com/60086878/111484898-82316580-8779-11eb-95be-e67022e6ca5c.png){: .align-center}

Apache Pig는 Hadoop에 기반하여 **병렬로 데이터를 처리하는 엔진**입니다. 이때, 데이터를 처리하기 위해 MapReduce 프로그래밍 대신 SQL과 유사한 Pig Latin이라는 자체 스크립트 언어로 처리하는 것이 특징입니다. Pig는 서버로 동작하지 않고 단순 변환기 수준의 애플리케이션으로 실행되고, 작성된 Pig Latin를 해석하여 MapReduce로 변환하여 실행시켜 복잡한 MapReduce 프로그래밍을 간단하게 처리할 수 있습니다. 또한 Hadoop의 의존성이 있으므로 Pig 사용 시 Hadoop의 버전을 잘 고려해야 합니다.


### Storm

![image](https://user-images.githubusercontent.com/60086878/111485576-126faa80-877a-11eb-9c4b-ebb0809f29e0.png){: .align-center}

Apache Storm은 클로저 프로그래밍 언어로 작성된 **분산형 스트림 프로세싱 연산 프레임워크**입니다. Storm은 YARN 위에서 주로 실시간 분석, Machine Learning, 운영 모니터링 용도로 사용됩니다. 사용자가 정의한 Spout과 Bolt를 사용하여 스트리밍 데이터의 일괄, 분산 처리를 가능하게 하며, 인-메모리 기반으로 실시간 처리 방식을 가지고 있습니다. 또한 어떠한 언어로든 사용자의 기호에따라 Storm을 조작할 수 있습니다.

Storm의 스트림 처리 모델은 Topology라고 하는 프레임워크에서 DAG(Directed Acyclic Graphs)에 의해 관리됩니다. 이러한 Topology는 들어오는 데이터가 시스템에 입력 될 때마다 수행되는 다양한 변환 또는 단계를 설명합니다.

## NoSQL Databases

### HBase

![image](https://user-images.githubusercontent.com/60086878/111485366-e7855680-8779-11eb-8cd9-e0939e2de8ad.png){: .align-center}

Apache HBase는 HDFS 위에 만들어진 **비관계형 오픈소스 데이터베이스**입니다. HBase는 NoSQL로 분류되어 스키마 변경 없이 자유롭게 데이터를 저장할 수 있습니다. 또한 구조화된 대용량의 데이터에 빠른 임의접근을 제공하는 구글의 BigTable과 비슷한 데이터 모델을 가지며, HDFS에 대한 실시간 읽기/쓰기 기능을 제공합니다.

Hbase는 압축, 인-메모리 처리, 초기 BigTable에 제시되어 있는 Bloom 필터 기능을 제공합니다. HBase에 있는 테이블들은 Hadoop에서 동작하는 MapReduce 작업을 위한 입출력을 제공하며, Java API나 REST, AVro 또는 Thrift 게이트웨이를 통해 접근할 수 있습니다.

분산 환경에서 Zookeeper를 이용하여 고가용성을 보장하고, Membership 정보 저장, Dead Server 탐지, Master 선출 및 복구 기능을 지원합니다. 또한 성능이슈가 발생할 경우 서버를 추가하면 성능을 유지할 수 있고, MapReduce의 Input으로 사용하기 편리합니다.

### Cassandra

![cassandra](https://user-images.githubusercontent.com/60086878/111485940-67132580-877a-11eb-9206-6492f67bc339.png){: .align-center}

Apache Cassandra는 확장성이 뛰어난 **NoSQL 오픈소스 데이터베이스**입니다. Cassandra는 단일 장애점 없이 고성능을 제공하며 수 많은 서버 간의 대용량 데이터를 관리하기 위해 설계되었습니다. 클러스터를 지원하며 마스터리스 비동기 복제를 통해 모든 클라이언트에 대한 낮은 레이턴시 운영을 가능하게 합니다. Cassandra는 Consistent hashing을 이용한 Ring 구조와 Gossip protocol을 구현하였으며, 때문에 각 노드 장비들의 추가, 제거 등이 자유롭고, 데이터센터까지 고려 할 수 있는 데이터 복제 정책을 사용하여 안정성 측면에서 많은 장점이 있습니다.

Cassandra는 클러스터 내에서 인증된 유저들에 한해서만 연결을 허용하고, CQL(Cassandra Query Language)을 통해 질의하게 됩니다. 참고로 CQL은 SQL과 유사하지만, Join인 Transaction을 지원하지 않고, Index 검색을 위한 기능도 매우 단순하다는 단점이 있습니다. 또한 구조상 RDBMS와 같은 Paging을 구현하기 어렵고, Keyspace나 Table을 많이 생성할 경우 Memory Overflow가 발생할 수 있습니다.

## Data Ingestion

### Kafka

![image-center](https://user-images.githubusercontent.com/60086878/111485205-c45aa700-8779-11eb-8852-718b65b2bb1f.png){: .align-center}

Apache Kafka는 실시간으로 기록 스트림을 게시, 구독, 저장 및 처리할 수 있는 **분산 데이터 스트리밍 플랫폼**입니다. 이는 여러 소스에서 데이터 스트림을 처리하고 여러 사용자에게 전달하도록 설계되었습니다. 즉, A지점에서 B지점까지 이동 뿐아니라 A지점에서 Z지점을 비롯한 필요한 모든 곳에 대규모 데이터를 동시에 이동할 수 있습니다.

Kafka는 Publish-Subscribe 모델을 기반으로 동작하며 크게 Producer, Consumer, Broker로 구성됩니다. Broker는 Topic을 기준으로 메시지를 관리하며, Producer는 특정 Topic의 메시지를 생성한 뒤 해당 메시지를 Broker에 전달합니다. Broker가 전달받은 메시지를 Topic별로 분류하여 쌓아놓으면, 해당 Topic을 구독하는 Consumer들이 메시지를 가져가 처리하는 방식입니다.

### Sqoop

![image](https://user-images.githubusercontent.com/60086878/111485083-a9883280-8779-11eb-85d8-950c5833c4fd.png){: .align-center}

Apache Sqoop은 구조화된 관계형 데이터베이스와 Apache Hadoop간의 **대용량 데이터들을 효율적으로 변환해주는 CLI 애플리케이션**입니다. Oracle, MySQL같은 관계형 데이터 베이스에서 HDFS로 데이터들을 가져와 그 데이터들을 MapReduce로 변환하고 Hive, Pig, HBase에 저장할 수 있으며, 그 변환된 데이터들을 다시 관계형 데이터 베이스로 내보낼 수도 있습니다. Sqoop은 데이터의 가져오기와 내보내기를 MapReduce를 통해 처리하여 장애 허용 능력뿐만 아니라 병렬 처리가 가능하게 합니다.

### Flume

![image](https://user-images.githubusercontent.com/60086878/111485150-b573f480-8779-11eb-8375-33df8e1d94a2.png){: .align-center}

Apache Flume은 많은 양의 **로그 데이터를 효율적으로 수집, 취합, 이동하기 위한 분산형 소프트웨어**입니다. 구조가 단순하고 유연하여 스트리밍 데이터 플로우 아키텍쳐를 갖추고 있으며, 튜닝 가능한 신뢰성 매커니즘과 수많은 대체작동(Failover) 및 복구 매커니즘을 갖추고 있어 고장 방지 기능이 제공됩니다.

Flume은 JVM 프로세스인 Flume Agent가 실행되어 Source, Channel, Sink 컴포넌트를 호스트합니다. Source는 수집 대상으로부터 로그를 수신하고, Channel은 Source와 Sink간의 버퍼로서 의존성을 제거하고 장애를 대비합니다. 또한 Sink가 로그를 다음 목적지로 전달할 때까지 로그를 보관합니다. 마지막으로 Sink는 수집된 로그를 HDFS와 같은 다음 목적지에 전달하게됩니다.

## SQL-On-Hadoop

### Hive

![image](https://user-images.githubusercontent.com/60086878/111485003-96756280-8779-11eb-993d-52946e1eed98.png){: .align-center}

Apache Hive는 Hadoop에서 동작하는 **Data Warehouse** 인프라 구조로서 데이터 요약, 질의 및 분석 기능을 제공합니다. Hive는 HDFS나 HBase와 같은 데이터 저장 시스템에 저장되어 있는 대용량 데이터 집합들을 분석합니다. SQL과 유사한 HiveQL을 통해 질의하게되며, MapReduce의 모든 기능을 지원합니다. 또한 쿼리를 빠르게 하기 위해 비트맵 인덱스를 포함하여 인덱스 기능을 제공합니다.

기본적으로 Hive는 메타데이터를 내장된 아파치 더비(Derby) 데이터 베이스에 저장합니다. 추가로 MySQL과 같은 다른 서버/클라이언트 데이터 베이스를 사용할 수도 있습니다. 현재 TEXTFILE, SEQUENCEFILE, ORC, RCFILE 등 4개의 파일 포맷을 지원합니다.

### Impala

![image](https://user-images.githubusercontent.com/60086878/111587295-5b207580-8805-11eb-9181-9b7808fedda0.png){: .align-center}

Apache Impala는 Hadoop에서 실행하는 컴퓨터 클러스터에 저장된 데이터를 오픈소스 **대규모 병렬처리(MPP) SQL 쿼리 엔진**입니다. Hadoop에 스케일링 가능한 병렬 데이터베이스 기술을 도입합으로써 데이터 이동이나 전송 과정 없이 사용자들이 낮은 레이턴시의 SQL 쿼리를 HDFS과 아파치 HBase에 저장된 데이터에 발행할 수 있게 합니다. 또한, Impala는 HiveQL을 통해 질의할 수 있으며, C++로 설계된 **자체 분산 질의 엔진**이 모든 데이터 노드에서 설치되어 MapReduce 프로그래밍이 필요 없습니다. 

## Scheduling

### ZooKeeper

![image](https://user-images.githubusercontent.com/60086878/111484386-0f27ef00-8779-11eb-8b00-582369a5af91.png){: .align-center}

Apache ZooKepper는 공개 분산형 구성 서비스, 동기 서비스 및 대용량 분산 파일시스템을 위한 네이밍 레지스트리를 제공하는 **중앙 집중식 서비스(분산 코디네이터)**입니다. ZooKeeper의 아키텍쳐는 중복 서비스를 이용한 고가용성을 제공합니다. 클라이언트는 JooKeeper 마스터가 응답을 하지 않으면 다른 마스터에 요청합니다. JooKeeper 노드들은 파일 시스템이나 트리 데이터구조와 비슷한 구조의 네임스페이스 안에 데이터들을 저장합니다.

이외에도 JooKeeper는 HBase의 클러스터 마스터를 선출하는데 사용되기도 하고, Kafka에서 서버의 크래시를 감지하거나 새로운 토픽이 생성되었을 때, 토픽의 생성과 소비에 대한 저장을 위해 사용되기도 합니다. 


### Oozie

![image](https://user-images.githubusercontent.com/60086878/111485288-d8060d80-8779-11eb-8f74-4bc324adf392.png){: .align-center}

Apache Oozie는 Hadoop의 Job을 관리하기 위한 **서버 기반 워크플로우 스케쥴링 시스템**입니다. Ooize의 워크플로우는 DAG에서 제어흐름과 액션 노드의 모임으로 정의됩니다. 제어 흐름 노드는 워크플로우의 시작과 끝 그리고 워크플로우 실행 경로를 제어하기 위한 구조를 정의합니다. 액션노드들은 워크플로우가 계산/처리 작업의 실행을 명령하는 매커니즘입니다. Oozie는 Hadoop MapReduce, HDFS 조작, Pig, SSH, 이메일을 포함한 각기 다른 종류의 액션을 제공합니다. 

## Machine Learning

### Mahout

![image](https://user-images.githubusercontent.com/60086878/111487225-8494bf00-877b-11eb-856e-986db069043d.png){: .align-center}

Apache Mahout은 Hadoop 내에서 분산처리가 가능하고 확장성을 가진 **ML 라이브러리**입니다. MapReduce를 이용하여 적용되며, 데이터 전처리, 분류, 회귀, 군집, 협업 필터링 알고리즘을 지원합니다.

# 참고
- [Hadoop Ecosystem](https://www.geeksforgeeks.org/hadoop-ecosystem/)
- [Introduction to the Hadoop Ecosystem for Big Data and Data Engineering](https://www.analyticsvidhya.com/blog/2020/10/introduction-hadoop-ecosystem/)
- 엔터프라이즈 데이터 플랫폼 구축
- 스파크 완벽 가이드