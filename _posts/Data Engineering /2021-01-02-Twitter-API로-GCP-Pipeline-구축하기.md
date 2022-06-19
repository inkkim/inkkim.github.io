---
title: "Twitter API로 GCP Pipeline 구축하기"
categories: 
  - Data Engineering
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
excerpt: "Twitter Streaming Data를 이용한 GCP Pipeline을 구축해본다."
readtime: true
tags:
  - 데이터 파이프라인
  - 클라우드
---

# 들어가며
![](https://user-images.githubusercontent.com/60086878/103449597-aa1e3a80-4ced-11eb-8c6b-592cbe5f8a67.png){: .align-center}

이번 글에서는 T Academy의 '[데이터 엔지니어링 기초](https://tacademy.skplanet.com/live/player/onlineLectureDetail.action?seq=187#sec2)' 강좌에 대해 정리하는 글입니다. 실습의 대략적인 개요는 다음과 같습니다.

- Twitter API로부터 실시간으로 발생하는 Tweets Text를 요청
- Pub/Sub Topic으로 전송 (Apache Kafka와 흡사)
- Publish Trigger에 의해 BigQuery로 데이터를 전송하는 Cloud Functions를 실행
- Data Studio와 BigQuery를 연동하여 시각화
- GKE로 위 작업들을 실행하는 컨테이너 배포

# 데이터 수집
Twitter는 Streaming Data를 수집하기 아주 좋은 예시입니다. Twitter Developer에서 개발자들에게 분석 혹은 서비스에 필요한 API를 제공합니다. 물론 사용량에따라 티어가 있지만 프리티어도 예제로 활용하기에 충분합니.

1. Twitter Developer 회원 등록

먼저 [Twitter Developer](https://developer.twitter.com/en)에서 회원가입을 진행합니다.

기본 개인정보를 기입하고 다음과 같이 데이터를 어디에 사용할 것인지 적으라고 합니다. 200자 이상 영어로 적으라고 하는데 대충 공부하는데 쓴다는 내용으로 채우고 넘어가면 되겠습니다. 주의할 점은 Twitter Developer 계정은 기존 Twitter 계정을 기반으로 등록하는 과정입니다. 이후 Twitter 계정에 등록된 이메일 계정으로 확인 이메일이 전송되니 기존에 설정된 이메일 계정이 없다면 첫 번째 절차에서 이메일을 수정해야 합니다.

![](https://user-images.githubusercontent.com/60086878/103474496-d5855000-4de7-11eb-88e4-2052b0863b9c.png){: .align-center}


2. 확인 이메일 회신

아래 처럼 등록에 성공했다는 페이지와 함께 확인 이메일을 보냈다는 문구가 나옵니다.

![](https://user-images.githubusercontent.com/60086878/103474502-e2a23f00-4de7-11eb-8353-b916f3ca7fe2.png){: .align-center}

등록된 이메일 계정에서 확인 메일에 Confirm 버튼을 눌러줍니5.다.

![](https://user-images.githubusercontent.com/60086878/103474592-d23e9400-4de8-11eb-8490-910edc7f87e0.png){: .align-center}


3. API Key와 Access Token 발급

![](https://user-images.githubusercontent.com/60086878/103474682-b38ccd00-4de9-11eb-8b01-449777e0167a.png){: .align-center}

Twitter Developer에 로그인 후 Developer Portal에 접근하면 프로젝트 생성 절차가 진행되며 위와 같은 대시보드가 나옵니다.  

![](https://user-images.githubusercontent.com/60086878/103474744-2dbd5180-4dea-11eb-8d8a-110d3e75c612.png){: .align-center}

화면 중앙에 열쇠 아이콘으로 보안 페이지에 접근하면 API Key와 Access Token을 발급할 수 있는 페이지가 나옵니다. 계정 가입일 기준 약 2주 이후에는 보안상 더 이상 조회가 불가능하니 미리 저장해두어야 합니다. 

![](https://user-images.githubusercontent.com/60086878/103474833-031fc880-4deb-11eb-9473-cfcd5d6de4ff.png){: .align-center}

필자의 경우 편의를 위해 위와 같이 각 Value들을 .zshrc (혹은 .bashrc)에 환경변수로 저장해 두었습니다.

# Google Cloud Platform (GCP) 계정 설정

Google Cloud Platform(이하 GCP)에서는 모든 구글 계정 사용자에게 1년 안에 사용 가능한 $300 달러 상당의 크레딧을 제공하고 있습니다. 최초 이용 시 결제수단 등록이 필요할 수 있습니다.

1.새 프로젝트 생성

![](https://user-images.githubusercontent.com/60086878/103475014-c5bc3a80-4dec-11eb-9834-718284026a2b.png){: .align-center}

기존에 사용하시던 프로젝트와 혼재되지 않도록 새로운 프로젝트를 생성합니다.

2.서비스 계정 생성

![](https://user-images.githubusercontent.com/60086878/103475077-7f1b1000-4ded-11eb-86eb-ed65860adba1.png){: .align-center}

햄버거 버튼 - ID 및 보안 - 서비스 계정 - 서비스 계정 만들기에 접근하여 위와 같이 BigQuery 데이터 편집자, 게시 구독 편집자 권한을 부여 해줍니다.

3.서비스 계정 키 생성

![](https://user-images.githubusercontent.com/60086878/103475155-e8028800-4ded-11eb-9163-d64916ed271e.png){: .align-center}

해당 서비스 계정의 옵션에서 키 만들기를 눌러 JSON 타입의 비공개 키를 생성 해줍니다.

# Pub/Sub 주제 생성

Pub/Sub은 Apache Kafka와 유사한 기능을 제공하는 GCP의 관리형 서비스입니다. 실시간으로 대량의 데이터를 한 곳에 저장하여 Publisher와 Subscriber 형태로 여러 서비스에 특정 주제의 데이터만 Listen하게 해주는 기능을 제공합니다.

하지만 이 실습에서는 Cloud Function의 Trigger 역할로만 사용됩니다.

![](https://user-images.githubusercontent.com/60086878/103475184-52b3c380-4dee-11eb-89ea-9ee5ee390a8f.png){: .align-center}

햄버거 버튼 - 빅데이터 - Pub/Sub - 주제 만들기에 접근하여 twitter라는 이름의 주제를 생성해줍니다.

# BigQuery 테이블 생성

BigQuery는 AWS RedShift, Snowflake와 같은 GCP의 DW 서비스입니다. SQL 쿼리를 분산 처리 매우 빠른 속도와 성능을 자랑하며 쿼리 데이터 수에 따라 비용이 부과되는 특징이 있습니다.

![](https://user-images.githubusercontent.com/60086878/103477125-d1186180-4dfe-11eb-9b99-e5c00bb8cf52.png){: .align-center}

햄버거 버튼 - 빅데이터 - BigQuery에 접근하여 데이터 세트와 테이블을 생성 해줍니다.여기서 데이터 세트는 상용 RDBMS의 데이터베이스(스키마)에 해당하고, 테이블은 동일합니다. 테이블 스키마는 위와 같이 생성해줍니다.

# Cloud Functions 설정

GCP Cloud Functions는 특정 요청이 들어올 경우 정의된 함수를 실행시켜주는 기능입니다. 이번 실습에서는 Pub/Sub에 데이터가 들어오면 해당 데이터를 BigQuery에 정의된 테이블로 insert하는 함수입니다.

1.구성

![](https://user-images.githubusercontent.com/60086878/103477893-6cf99b80-4e06-11eb-873a-5888d7315589.png){: .align-center}

Pub/Sub의 twitter Topic - Cloud 함수 트리거에 접근합니다. Topic을 경유해서 Cloud Functions를 생성했기 때문에 트리거 유형과 주제 유형은 원하는대로 설정되어 있으니 그대로 저장 후 다음으로 넘어갑니다.

2.코드

![](https://user-images.githubusercontent.com/60086878/103477873-3e7bc080-4e06-11eb-8c62-bc507051d891.png){: .align-center}

런타임은 Python 3.7 진입점은 기존 코드를 활용할 것이니 그대로 유지합니다. 

```python
# main.py
import base64
import json
from google.cloud import bigquery

def tweets_to_bq(tweet):
    client = bigquery.Client()
    dataset_ref = client.dataset('twitter_data') # BigQuery 데이터 세트
    table_ref = dataset_ref.table('twitter') # BigQuery 테이블
    table = client.get_table(table_ref)

    tweet_dict = json.loads(tweet)
    rows_to_insert = [
    (tweet_dict['id'], tweet_dict['created_at'], tweet_dict['text'])
    ]

    error = client.insert_rows(table, rows_to_insert)
    print(error)

def hello_pubsub(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(pubsub_message)
    tweets_to_bq(pubsub_message)
```

requirements.txt에는 함수 실행에 필요한 패키지를 적어줍니다.
```python
# requirements.txt
google-cloud-bigquery
```

# Python 코드 작성

이번 실습에서는 Twitter API와 GCP 서비스들과 상호작용 하기위해 Python 코드를 사용합니다. 코드를 작성하기에 앞서 이전에 발급받은 Tiwtter API Key와 Access Token에 대한 정보를 환경변수로 작성합니다. 또한 GCP 계정 설정과정에서 발급한 서비스 계정에 대한 JSON 타입의 비공개 키 또한 Python 파일과 동일한 디렉토리에 위치시킵니다.

1.Twitter API, Access ToKen, GCP SA Credentials 환경변수 설정

```bash
# .zshrc (혹은 .bashrc) 안에서 작성
export GOOGLE_APPLICATION_CREDENTIALS="./twitter-300412-3f24e09c59ef.json"
export TWITTER_API="TWITTER API KEY"
export TWITTER_API_SECRET="TWITTER API SECRET KEY"
export TWITTER_ACCESS_TOKEN="TWITTER ACCESS TOKEN"
export TWITTER_ACCESS_TOKEN_SECRET="TWITTER ACCESS TOKEN SECRET"

$ source ~/.zshrc 
```

2.Python 코드 작성

```python
import json
import os
import tweepy
from google.cloud import pubsub_v1
from google.oauth2 import service_account

# GCP 서비스 계정 비공개 키
key_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']

# GCP 계정 인증
credentials = service_account.Credentials.from_service_account_file(
    key_path,
    scopes=["https://www.googleapis.com/auth/cloud-platform"]
)

# Pub/Sub 인증
client = pubsub_v1.PublisherClient(credentials=credentials)

# Pub/Sub Topic 지정 (프로젝트 ID, Topic)
topic_path = client.topic_path('twitter-300412', 'twitter')

# Twitter API Key / Access Token
twitter_api_key = os.environ['TWITTER_API']
twitter_api_secret_key = os.environ['TWITTER_API_SECRET']
twitter_access_token = os.environ['TWITTER_ACCESS_TOKEN']
twitter_access_token_secret = os.environ['TWITTER_ACCESS_TOKEN_SECRET']

# json 파일은 BigQuery에서 생성한 테이블의 스키마 정보와 일치하게 작성 
class SimpleStreamListener(tweepy.StreamListener):
    def on_status(self, status):
        print(status)
        # status가 실제로 받는 데이터 객체이므로, BigQuery에서 생성한 테이블의 스키마 정보에 맞춰 파일 생성
        tweet = json.dumps({'id': status.id, 'created_at': status.created_at, 'text': status.text}, default=str)
        client.publish(topic_path, data=tweet.encode('utf-8'))

    def on_error(self, status_code):
        print(status_code)
        if status_code == 420:
            return False

stream_listener = SimpleStreamListener()

# Twitter API 계정 및 액세스 인증
auth = tweepy.OAuthHandler(twitter_api_key, twitter_api_secret_key)
auth.set_access_token(twitter_access_token, twitter_access_token_secret)

# tweepy.Stream 객체 선언
twitterStream = tweepy.Stream(auth, stream_listener)

# 특정 주제어가 포함된 Tweets Streaming
twitterStream.filter(track=['data'])
```

또한 Python과 Twitter API와 GCP 서비스와 상호작용하기 위한 패키지를 설치합니다.

```bash
$ pip3 install tweepy==3.8.0 google-cloud-pubsub==1.6.0
```

![](https://user-images.githubusercontent.com/60086878/103477806-7b938300-4e05-11eb-934a-4f0dfb0862e8.png){: .align-center}


위 파이썬 파일을 실행하면 다음과 같이 실시간 Tweets 데이터들을 확인할 수 있습니다. 이 데이터들이 Pub/Sub의 twitter Topic로 스트리밍 되면서 동시에 Cloud Functions에 정의된 함수에 의해 BigQuery로 데이터가 들어가고 있는것입니다.

![](https://user-images.githubusercontent.com/60086878/103478229-62400600-4e08-11eb-9d63-88440a706e43.png){: .align-center}

BigQuery에서 쿼리를 조회해보면 테이블에 정의된 스키마에 맞춰 데이터가 적재되고 있음을 확인할 수 있습니다.

# GKE에 컨테이너 배포

이제 위 Python 코드를 Docker Container로 말아서 최종적으로 GKE에 배포하여 무인으로 동작하게 할 것입니다.

1.Dockerfile 작성

```Dockerfile
# Base Image 설정
FROM python:3.7-slim

# Working Directory 설정
WORKDIR /app

# 실행에 필요한  파일 복사
## Twitter.py / GCP SA Key.json / requirements.txt
ADD . /app

# 패키지 설치
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# 환경변수 설정
ENV GOOGLE_APPLICATION_CREDENTIALS="./twitter-300412-3f24e09c59ef.json"
ENV TWITTER_API="TWITTER API KEY"
ENV TWITTER_API_SECRET="TWITTER API SECRET KEY"
ENV TWITTER_ACCESS_TOKEN="TWITTER ACCESS TOKEN"
ENV TWITTER_ACCESS_TOKEN_SECRET="TWITTER ACCESS TOKEN SECRET"

CMD ["python", "Twitter.py"]
```

위와 같이 Dockerfile을 작성하고, 아래 명령어로 Docker Image를 빌드합니다. 약 1-2분 후 완료되면 정상적으로 빌드되었는지 확인합니다.

```bash
# 약 1-2분 소요
$ docker build -t twitter .
$ docker images
```

2.Google cloud SDK gcloud 설치

GCP는 CLI 환경에서 서비스를 이용할 수 있도록 [gcloud](https://cloud.google.com/sdk/docs/downloads-versioned-archives?hl=ko)라는 자체 SDK를 제공합니다. 수월한 GKE 구축을 위해 다음과 같이 gcloud를 설치합니다.

먼저 아래 명령어로 OS (32/64)비트 버전을 확인하고 패키지를 설치하여 압축을 풀어줍니다. (아래 명령어는 Mac OS를 기준으로 합니다.) 다른 OS의 경우 [gcloud](https://cloud.google.com/sdk/docs/downloads-versioned-archives?hl=ko)에서 해당되는 OS용 패키지를 다운 받으시면 됩니다. 

압축 해제가 완료되면 install.sh 파일을 실행시켜 안내에따라 설치를 진행합니다. 이 과정에는 사용하고자 하는 Google 계정의 인증과 프로젝트를 설정하는 과정이 포함되어 있습니다.

```bash
$ getconf LONG_BIT
$ wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-320.0.0-darwin-x86_64.tar.gz?hl=ko
$ tar -xvzf google-cloud-sdk-320.0.0-darwin-x86_64.tar.gz\?hl=ko
$ cd google-cloud-sdk/ && ./install.sh
$ gcloud init
```

3.GCP Container Registry에 Docker Image Push

GCP에서는 자사 서비스에서 Container가 빠르게 배포될 수 있도록 개인 Container Registry를 제공합니다. 아래 명령어로 Docker Image에 태그를 붙이고, Container Registry에 Push한다.

- `$ docker tag 이미지:태그 gcr.io/프로젝트 ID/이미지:태그`

```bash
$ docker tag twitter gcr.io/twitter-300412/twitter
$ gcloud auth configure-docker # 인증된 Docker 구성
$ docker push gcr.io/twitter-300412/twitter
```

4.GKE에 배포

![](https://user-images.githubusercontent.com/60086878/103479422-d8e10180-4e10-11eb-8cde-a7a43ab461e8.png){: .align-center}

햄버거 버튼 - 도구 - Container Registry에 접근하면 위와 같이 Local에서 Push한 Image가 올라온 것을 확인할 수 있습니다. 

![](https://user-images.githubusercontent.com/60086878/103479539-b13e6900-4e11-11eb-93f7-962021551a03.png){: .align-center}

해당 이미지에 들어가서 `GKE에 배포`를 통해 기존 컨테이너 이미지로 배포를 시작하면 약 5분 정도 기다리면 배포가 완료됩니다.

![](https://user-images.githubusercontent.com/60086878/103479759-30806c80-4e13-11eb-8cfc-de75a492f8ae.png){: .align-center}

손쉽게 GKE 클러스터가 생성되고 우리가 배포한 컨테이너도 `nginx-1-f7f74655b-xkrml`라는 Pod로써 안정적으로 작동되고 있습니다. 이제 GKE에 의해 Twitter API로 Twitter Streaming를 요청하여 Pub/Sub과 BigQuery로 전송하는 일련의 과정들이 자동으로 수행되고 있습니다. 즉, `data`라는 키워드가 포함된 Tweets 데이터가 자동으로 수집되는 데이터 파이프라인이 완성된 것입니다.

# Google Studio로 연결

![](https://user-images.githubusercontent.com/60086878/103480193-3c216280-4e16-11eb-96c6-f4f64d867929.png){: .align-center}

Google Studio에서 보고서 작성을 하면 다른 Google 서비스와 연결 여부를 물어본다. 이때 이전에 생성한 BigQuery의 테이블과 연결하면 바로 데이터를 연결하여 간단한 시각화가 가능하다.

![](https://user-images.githubusercontent.com/60086878/103480234-72f77880-4e16-11eb-9e72-8eae3d92937a.png){: .align-center}

# 마치며 

![](https://user-images.githubusercontent.com/60086878/103449597-aa1e3a80-4ced-11eb-8c6b-592cbe5f8a67.png){: .align-center}

이 글은 2020.09.23(목)에 진행된 제81차 토크ON세미나에서 SOCAR의 김상우님이 강의해주신 내용을 토대로 리마인드 차원에서 작성한 것입니다. Hands-on 강의 동영상과 함께 실습을 진행해보고자 한다면 [T Academy](https://tacademy.skplanet.com/frontMain.action)에서 회원가입 후 [데이터 엔지니어링 기초](https://tacademy.skplanet.com/live/player/onlineLectureDetail.action?seq=187#sec2) 강좌에 수강신청하여 진행해보실 수 있습니다.


# 참고
[T Academy - 데이터 엔지니어링 기초](https://tacademy.skplanet.com/live/player/onlineLectureDetail.action?seq=187#sec2)
