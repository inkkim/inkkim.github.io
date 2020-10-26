---
id: 1
title: "💻맥북으로 딥러닝하기(Feat. Ubuntu 18.04 LTS)"
subtitle: "리눅스와 친해지기 1 | 우분투는 처음이라.."
date: "2020.10.26"
tags: "우분투, 서버"
---

# 노트북이 힘들어해 🤬
지난 7월 엔코아 플레이데이터에서 '데이터 과학자 양성과정'을 수강중 일이다. 일전에 Python, R을 비롯한 프로그래밍 언어 기초를 막 떼고나서 Sckit-learn과 Tensorflow 실습 중 강사님은 AWS서버를 대여해서 강의를 진행하셨는데, 어떤 무거운 모델링에도 압도적인 퍼포먼스에 나를 비롯한 모든 수강생들은 하드웨어의 중요성을 몸으로 체감한다. 


그나마 CUDA 가속을 지원하는 Nvidia GPU를 품은 노트북들은(당시 본인 노트북 2018 Samsung Always 9, Geforce mx150) 용케 설치해서 흉내라도 내봤는데 어림도 없었다. 아쉬운대로 딱 학습용으로 제격인 [Colab](https://colab.research.google.com/)을 통해 진행해보지만, 수시로 끊기는 세션 때문에 여간 스트레스가 아니다.


이맘때쯤 노트북을 바꿀 계획을 하고 있었는데, 잠시 게이밍 노트북도 구매를 고려해봤으나 노트북 자원으로 딥러닝 할 생각은 일찍이 단념하고 사실은 0순위였던 2020 Macbook Pro 13인치를 구매했다. 마침 형이 집에 RTX 2070 Super를 품은 데스크탑을 장만했는데, 여기에 기생하면 되겠다는 막연한 생각이었다.


# 서버, 그냥 윈도우로 하면 되는거 아니야? 😒
해도 된다. 하지만 이건 내 데스크탑이 아니라서 안 된다. 기생하는 입장에서 개발환경을 구축한답시고 이것저것 설치했다가 이상이라도 생기면 바로 쫓겨날게 뻔하다. 어떻게 하면 얌전하게 기생할 수 있을까 머리를 굴려보다가 생각해낸 방법은 Docker를 이용해보자! 듣기로는 Docker Hub에서 Tensorflow-gpu만 Pull 하면 되고 쉽다던데 금방 하겠지라고 생각했다.

하지만 이게 웬걸 Windows에서는 Docker에서 Host의 GPU 자원을 쓸 수 없단다...


근데 WSL2에서는 지원한다고 하네? 
![nvidia-docker](https://user-images.githubusercontent.com/60086878/97198496-3560e880-17f2-11eb-9fef-c54bd61f4de0.png)


이름하야 [CUDA on WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html). GPU Paravirtualization을 통해 GPU 자원을 WSL2에 올려서 쓸 수 있게 해준다는 멋있는 구상인데..🤔
![CUDA on WSL](https://user-images.githubusercontent.com/60086878/97198687-7658fd00-17f2-11eb-8189-13f60c9f2112.png)


![Required Build](https://user-images.githubusercontent.com/60086878/97199132-039c5180-17f3-11eb-9dee-146f50026b08.png)
Microsoft Windows Insider Program Build를 받으라네?


![Windows Insider Program](https://user-images.githubusercontent.com/60086878/97199439-5aa22680-17f3-11eb-9839-de60ff7265a2.png)
대충 개발자 버전이고, 위험할 수 있다는 뜻.. 전혀 얌전하지 못하므로 기각.


아.. 이래서 다들 우분투로 하는구나..


# 안녕, 우분투? 👋
우분투는 짝수년도 2년마다 4월에 LTS(Long Term Support)버전을 공개하는 것 같다. 마침 올해 4월에도 20.04 LTS 버전이 출시되었다. 새 버전이라 탐나기도 하지만 소프트웨어는 새 버전은 잠시 미뤄두는게 속 편한듯 하다. 이리저리 탐구해보고 싶었지만 내 데스크탑이 아니고, 안정적인 서버용으로 사용해야 하니 레퍼런스가 많고 안정적인 18.04 LTS 버전으로 선택했다.

![Ubuntu Release Cycle](https://user-images.githubusercontent.com/60086878/97201415-c4bbcb00-17f5-11eb-8f9d-343eb5f4c524.png)
출시년도로부터 데스크탑 버전은 5년, 서버 버전은 10년을 업데이트 지원해준다고 한다.



# 출처
- [nvidia-docker](https://github.com/NVIDIA/nvidia-docker/wiki)
- [CUDA on WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)
- [Windows Insider Program](https://insider.windows.com/en-us/getting-started#register)
- [Ubuntu Release Cycle](https://ubuntu.com/about/release-cycle)



