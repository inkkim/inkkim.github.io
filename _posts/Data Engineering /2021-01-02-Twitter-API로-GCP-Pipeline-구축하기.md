---
title: "Twitter API로 GCP Pipeline 구축하기"
categories: 
  - Data Engineering
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
readtime: true
tags:
  - Pub/Sub
  - Cloud Function
  - Big Query
  - GKE
---

# Architecture
![](https://user-images.githubusercontent.com/60086878/103449597-aa1e3a80-4ced-11eb-8c6b-592cbe5f8a67.png)

대략적인 개요는 다음과 같다.

- Twitter API로부터 실시간으로 발생하는 Tweets Text를 요청
- Pub/Sub Topic으로 전송 (Apache Kafka와 흡사)
- Publish Trigger에 의해 Cloud Function

# 나가며 
이 글은 2020.09.23(목)에 진행된 제81차 토크ON세미나에서 SOCAR의 김상우님이 강의해주신 내용을 토대로 리마인드 차원에서 작성한 것이다. Hands-on 강의 동영상과 함께 실습을 진행해보고자 한다면 [T Academy](https://tacademy.skplanet.com/frontMain.action)에서 회원가입 후 '[데이터 엔지니어링 기초](https://tacademy.skplanet.com/live/player/onlineLectureDetail.action?seq=187#sec2)' 강좌에 수강신청하여 진행해보길 바란다.


# 참고
[T Academy - 데이터 엔지니어링 기초](https://tacademy.skplanet.com/live/player/onlineLectureDetail.action?seq=187#sec2)
