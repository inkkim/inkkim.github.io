---
id: 4
title: "📊오픈소스 시각화 툴 Superset 설치하기"
subtitle: "Made by Airbnb"
date: "2020.12.19"
tags: "시각화, Apache Superset, 오픈소스"
---

# Apache Superset 이란 ? 
![Apache Superset](https://user-images.githubusercontent.com/60086878/102607092-0d935e80-416b-11eb-8529-6f266ab80d04.png)
- Airbnb에서 개발해 오픈소스로 공개한 Apache Incubator 프로젝트
- 2020.12.19 기준 31,5700 GitHub Star, Release v0.38.0
- 직관적인 시각화 및 반응형 대쉬보드 제공
- 다수 상용 RDBMS와 호환
    - Amazon Redshift, Google BigQuery, Snowflake, Presto
    - Oracle, PostgreSQL, MySQL, MariaDB, SQL Server, IBM DB2
    - SQLite, Sysbase, Vertica, Druid, Greenplum  

![Gallery](https://user-images.githubusercontent.com/60086878/102608095-b098a800-416c-11eb-98ba-35aa40e8ee66.png)

# 설치

## 방법
- __Docker Compose를 이용한 방법__
- apt-get을 이용한 방법
- Python 가상환경에서 pip를 이용한 방법
- Kubernetes 환경에서 Helm 차트를 이용한 방법

본 포스팅에서는 연습용으로 설치하는 것이기 때문에 간편하고 가장 빠르게 설치할 수 있는 **Docker Compose를 이용한 방법**으로 안내한다.

## Docker Compose 설치
- Mac OS  
Docker 설치 후 기본 할당 메모리가 2GB이기 때문에 Superset 실행 시 오류가 날 수 있다. 그러므로 Docker Resources에서 할당 메모리를 6GB로 수정 해야한다.

- Windows
아쉽게도 Superset은 윈도우에서 공식적으로 지원하진 않는다. 공식 문서에서도 VirtualBox나 VMWare와 같은 가상 머신 툴을 이용한 방법으로 시도해보길 권장하고 있다. 또한 원활한 구동을 위해 해당 VM에 최소한 8GB RAM과 40GB 스토리지 할당을 권장한다.

- __Linux__  
Docker 설치 docker-compose가 설치되어 있지 않으므로, 각 OS에 맞게 별도의 설치가 필요하다. 본 포스팅에서는 **Ubuntu 18.04 LTS 기준**으로 설치를 안내한다.  

1. 아래 명령어로 Docker Compose의 최신 stable releases를 설치한다.

```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```


2. Binary 파일에 실행 권한을 부여한다.

```
$ sudo chmod +x /usr/local/bin/docker-compose
```


3. 아래 명령어로 Docker Compose의 버전을 확인한다.
```
$ docker-compose --version
```

![](https://user-images.githubusercontent.com/60086878/102610642-e3dd3600-4170-11eb-9b2b-a2ed021f4c10.png)


4. Superset Repository를 Clone한다. 
```
$ git clone https://github.com/apache/incubator-superset.git
```


5. 아래 명령어로 Superset 인스턴스를 실행한다.
```
$ cd incubator-superset
$ docker-compose up
```
![](https://user-images.githubusercontent.com/60086878/102612471-13da0880-4174-11eb-906b-e4e677555538.png)


6. 아래 localhost:8088로 접근하여 로그인한다.
```
USERNAME : admin
PASSWORD : admin
```
![](https://user-images.githubusercontent.com/60086878/102612898-ed689d00-4174-11eb-941d-98a41f5091d5.png)


7. Superset 메인화면  


![Main Page](https://user-images.githubusercontent.com/60086878/102612917-f48fab00-4174-11eb-8c45-f6faf6650d80.png)

8. Sample Dashboard 

- USA Births Names  
모던한 디자인에 여타 시각화 툴에 비해 꿇리지 않는 기능들을 볼 수 있다. 파스텔 톤의 색감도 Superset만의 특장점인 것 같아서 좋았다. 또한 대시보드 컴포넌트에 임의로 이미지를 삽입할 수 있게 해 높은 커스텀 자유도를 보장다는 점
도 매력적이었다.

![Sample 1](https://user-images.githubusercontent.com/60086878/102613328-a202be80-4175-11eb-85da-a106023e96da.png)

- Sales Dashboard

대시보드에 이모지가 나와서 당황했는데 꽤나 잘 어울린다 🤣
![image](https://user-images.githubusercontent.com/60086878/102613361-ad55ea00-4175-11eb-9e92-3d79ce4ab802.png)

# 첫인상
- Apache 프로젝트답게 꽤 완성도 높음
- 설치가 쉽고 UI는 투박하지만 트렌디한 대시보드 구성
- 아직 V0.X 단계지만 바로 사용해도 될 것 같은 퀄리티

# 참고
- [Installing Superset Locally Using Docker Compose](https://superset.apache.org/docs/installation/installing-superset-using-docker-compose)
- [Install Docker Compose](https://docs.docker.com/compose/install/)