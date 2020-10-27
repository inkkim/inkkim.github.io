---
id: 2
title: "💻맥북으로 딥러닝하기 (Feat. SSH) 2"
subtitle: "리눅스와 친해지기 2 | 너에게 닿기를"
date: "2020.10.27"
tags: "SSH, iptime, Tensorflow-gpu"
---

# 🧲 [💻맥북으로 딥러닝하기(Feat. Ubuntu 18.04 LTS) 1](https://inkkim.github.io/article/1.html)에서는 . . .
이전 글에서는 데스크탑에 우분투를 설치하고, 꽤나 까다로운 Nvidia driver 설치를 거쳐 최종적으로 nvidia-docker를 이용해 Docker 내에서도 GPU 자원을 사용할 수 있는 환경을 구성해보았다.

이번 글에서는 이어서 docker를 이용하여 손쉽게 딥러닝 개발환경을 구축해보고, 최종적으로 SSH(Secure Shell Protocol)를 통해 맥북에서 접근이 가능하도록 만들어보겠다.

# Tensorflow-gpu 설치
조만간 한 번 다뤄야겠지만 Docker는 정말로 강력한 툴인 것 같다. 특정 OS의 구속되지 않고 컨테이너로써 Host OS와 독립되면서도 성능 저하없이 동일한 환경을 구성해주어 많은 개발자들의 큰 수고를 덜어준다. 

나 역시 이 편리한 툴을 이용하여 Tensorflow-gpu를 설치하여 딥러닝 개발환경을 구축하려고 한다.

1. 



![Tensorflow ready](https://user-images.githubusercontent.com/60086878/97323747-76b9cc80-18b4-11eb-9e01-a896c3780395.png)
![Tensorflow action](https://user-images.githubusercontent.com/60086878/97326005-e466f800-18b6-11eb-8953-54899d40676f.png)

# 출처
