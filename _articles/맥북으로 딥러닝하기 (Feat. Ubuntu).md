---
id: 1
title: "💻맥북으로 딥러닝하기(Feat. Ubuntu 18.04 LTS) 1"
subtitle: "리눅스와 친해지기 1 | 우분투는 처음이라.."
date: "2020.10.26"
tags: "우분투, 서버, 도커"
---

# TL, DR
- 코랩으로 딥러닝하려면 많은 인내가 필요하다.
- 그렇다고 GPU달린 게이밍 노트북을 들고다니긴 자신 없다.
- 우분투 데스크탑으로 개인용 서버를 구축하여 원격 개발환경을 구성하자.
- 도커를 통해 간편하게 개발환경을 구축하자.


# 노트북이 힘들어해 🤬
지난 7월 엔코아 플레이데이터에서 '데이터 과학자 양성과정'을 수강하던 중의 일이다. 일전에 Python, R을 비롯한 프로그래밍 언어 기초를 막 떼고나서 Sckit-learn과 Tensorflow 실습 중 강사님은 AWS서버를 대여해서 강의를 진행하셨는데, 어떤 무거운 모델링에도 압도적인 퍼포먼스에 나를 비롯한 모든 수강생들은 하드웨어의 중요성을 몸으로 체감한다. 


그나마 CUDA 가속을 지원하는 Nvidia GPU를 품은 노트북들은(당시 본인 노트북 2018 Samsung Always 9, Geforce mx150) 용케 설치해서 흉내라도 내봤는데 어림도 없었다. 아쉬운대로 딱 학습용으로 제격인 [Colab](https://colab.research.google.com/)을 통해 진행해보지만, 수시로 끊기는 세션 때문에 여간 스트레스가 아니다.


이맘때쯤 노트북을 바꿀 계획을 하고 있었는데, 잠시 게이밍 노트북도 구매를 고려해봤으나 노트북 자원으로 딥러닝 할 생각은 일찍이 단념하고 사실은 0순위였던 2020 Macbook Pro 13인치를 구매했다. 마침 형이 집에 RTX 2070 Super를 품은 데스크탑을 장만했는데, 여기에 기생하면 되겠다는 막연한 생각이었다.


# 서버, 그냥 윈도우로 하면 되는거 아니야? 😒
해도 된다. 하지만 이건 내 데스크탑이 아니라서 안 된다. 기생하는 입장에서 개발환경을 구축한답시고 이것저것 설치했다가 이상이라도 생기면 바로 쫓겨날게 뻔하다. 어떻게 하면 얌전하게 기생할 수 있을까 머리를 굴려보다가 생각해낸 방법은 Docker를 이용해보자! 듣기로는 Docker Hub에서 Tensorflow-gpu만 Pull 하면 되고 쉽다던데 금방 하겠지라고 생각했다.

하지만 이게 웬걸 Windows에서는 Docker에서 Host의 GPU 자원을 쓸 수 없단다...


근데 WSL2에서는 지원한다고 하네? 
![nvidia-docker](https://user-images.githubusercontent.com/60086878/97198496-3560e880-17f2-11eb-9fef-c54bd61f4de0.png)


이름하야 [CUDA on WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html). 


GPU Paravirtualization을 통해 GPU 자원을 WSL2에 올려서 쓸 수 있게 해준다는 멋있는 구상인데..🤔
![CUDA on WSL](https://user-images.githubusercontent.com/60086878/97198687-7658fd00-17f2-11eb-8189-13f60c9f2112.png)


![Required Build](https://user-images.githubusercontent.com/60086878/97199132-039c5180-17f3-11eb-9dee-146f50026b08.png)


Microsoft Windows Insider Program Build를 받으라네?


![Windows Insider Program](https://user-images.githubusercontent.com/60086878/97199439-5aa22680-17f3-11eb-9839-de60ff7265a2.png)


대충 개발자 버전이고, 위험할 수 있다는 뜻.. 전혀 얌전하지 못하므로 기각.


아.. 이래서 다들 우분투로 하는구나..


# 안녕, 우분투? 👋
얌전하게 기생하기 위해 여러 방법을 고민해보다가 결국 기존 Windows를 유지한 채 우분투를 설치하는 듀얼부팅 방법으로 귀결되었다. 기존 데스크탑 SSD는 Samsung 970 EVO M.2 NVMe 512GB인데, 이미 절반 이상은 차있었고 거기서 파티션을 나눠 설치하기에는 여유롭지 못했다. 결국 퀘이사존에서 많은 후기들을 눈팅한 결과 __가성비 좋은__ WD Blue SN550 NVMe SSD 1TB를 구매했고, 완전히 독립된 공간에 우분투를 설치하여 듀얼부팅이 되도록 구성할 것이다.

![Danawa](https://user-images.githubusercontent.com/60086878/97249042-6e2aad00-1846-11eb-9343-4b1cf9fc013c.png)


공교롭게도 이 둘은 각각 다나와 M.2 NVMe 부문 1, 2위다.

![Western Digital](https://user-images.githubusercontent.com/60086878/97247983-15f2ab80-1844-11eb-846b-b5324c9bcef0.png)


우분투는 짝수년도 2년마다 4월에 LTS(Long Term Support)버전을 공개하는 것 같다. 마침 올해 4월에도 20.04 LTS 버전이 출시되었다. 새 버전이라 탐나기도 하지만 소프트웨어는 새 버전은 잠시 미뤄두는게 속 편한듯 하다. 이리저리 탐구해보고 싶었지만 내 데스크탑이 아니고, 안정적인 서버용으로 사용해야 하니 레퍼런스가 많고 안정적인 18.04 LTS 버전으로 선택했다.

![Ubuntu Release Cycle](https://user-images.githubusercontent.com/60086878/97201415-c4bbcb00-17f5-11eb-8f9d-343eb5f4c524.png)


출시년도로부터 데스크탑 버전은 __5년__, 서버 버전은 __10년__ 업데이트 지원해준다고 한다.

## 부팅 USB 만들기
1. 먼저 [Ubuntu 18.04 LTS Download Link](https://releases.ubuntu.com/bionic/)에서 Desktop 버전 iso 이미지를 다운받는다.
2. [Rufus](https://rufus.ie)를 다운받아 부팅 USB를 만든다.
* HiSEON님이 정리해주신 [우분투 부팅 USB 만들기](https://hiseon.me/linux/ubuntu/ubuntu-install-usb/)를 참고하여 만들었습니다.

## 부팅 우선순위 변경
설치 전에 알아보니 2개의 SSD에 독립적으로 OS를 설치하여 멀티부팅을 하려면 설치 과정에서 다른 SSD는 물리적으로 제거하고 설치를 진행하지 않으면 부트로더가 한 쪽에 설치되어 부팅이 되지 않는 문제가 있을 수 있다고 한다. 안전하게 제거하고 설치를 진행했다.

1. 부팅 시 F2나 DEL키를 통해 BIOS에 진입한다. (BIOS 진입 키는 각 메인보드 제조사마다 상이하니 확인 후 진행)
2. 부팅 우선순위(Boot Prioriy)에서 드래그를 통해 부팅 USB를 가장 상위로 위치시킨 후 재부팅한다.

## 설치
1. 편한 언어로 선택하고 Install Ubuntu 클릭한다.
![Ubuntu Install 1](https://user-images.githubusercontent.com/60086878/97251824-fb243500-184b-11eb-81c6-b622e10b3eee.png)

2. 특이사항 없으니, Continue를 클릭한다.
![Ubuntu Install 2](https://user-images.githubusercontent.com/60086878/97252001-581feb00-184c-11eb-9f60-afc1e7280266.png)

3. 기존에 파티션을 나누어 설치하시는 분들은 Something else, 필자처럼 깨끗한 SSD에 설치하는 경우 Erase disk and install Ubuntu 선택 후 Install Now를 클릭한다.
![Ubuntu Install 3](https://user-images.githubusercontent.com/60086878/97252135-9ae1c300-184c-11eb-9616-f639f60b9480.png)

4. 위치를 설정한다.
![Ubuntu Install 4](https://user-images.githubusercontent.com/60086878/97252722-01b3ac00-184e-11eb-9d40-edde20707ca3.png)

5. 유저 기본정보를 입력한다.
![Ubuntu Install 5](https://user-images.githubusercontent.com/60086878/97252749-13954f00-184e-11eb-91ac-ac132ae42629.png)


# Nvidia 드라이버 설치
우분투에서 GPU가 제대로 작동하려면 해당 모델에 맞는 드라이버가 적절하게 설치되어야 한다. 처음에는 ubuntu-drivers를 이용한 자동설치 방법을 보고는 쉽게 생각하고 설치했는데, 처음에는 잘 작동하는가 싶더니 재부팅하니 아예 GPU를 인식하지 못하고, default graphic마저 disabled되어서 터미널창만 반복적으로 부팅되는 문제가 발생했다.
![Error](https://user-images.githubusercontent.com/60086878/97261708-b952b900-1862-11eb-97d0-7714f56a5697.png)

설치 전에 우분투와 신나게 놀다가 이것저것 많이 설치해놓은 상황이었는데, 구글에서 해답을 얻지 못한채 빠르게 다시 설치하기로 했다. 이러한 이슈가 있으니 다른 유틸리티나 설정보다도 Nvidia 드라이버 설치를 완료하고 하길 추천한다..

만약 필자와 같은 오류를 만난 이들을 위해 내가 Nvidia 드라이버를 수동으로 설치한 방법을 소개한다.
 
1. [Nvidia Download Driver](https://www.nvidia.com/Download/index.aspx)에서 해당 GPU 모델에 맞는 드라이버를 받는다.
- 우분투는 Linux 64-bitd이다.
- Type은 Long Lived와 Short Lived는 각각 minor, major 업데이트 위주
![Nvidia Driver 1](https://user-images.githubusercontent.com/60086878/97253330-7c30fb80-184f-11eb-92a8-5d99d8b9c149.png)
![Nvidia Driver 2](https://user-images.githubusercontent.com/60086878/97261447-35003600-1862-11eb-8e3a-13094b3f77d3.png)

2. 혹시 이전에 설치했던 Nvidia driver 파일을 삭제하고, Nvida driver 설치에 필요한 Development Package gcc, make를 설치한다.
```
$ sudo apt --purge autoremove nvidia*
$ sudo apt-get update
$ sudo apt-get install gcc
$ sudo apt-get install make
```

3. Nvidia driver 설치 과정에서 충돌을 피하기 위해 nouveau를 blacklist 추가한다.
```
$ sudo nano /etc/modprobe.d/blacklist.conf
```
![blacklist](https://user-images.githubusercontent.com/60086878/97263549-90342780-1866-11eb-9ead-4c832d3160c3.png)
- blacklist를 추가 하고서도 설치과정에서 nouveau 관련 오류를 마주하는 경우가 있는데, 이 때는 Nvidia driver installer가 동의 시 자동으로 생성해주는 방법으로 하면 된다.

4. Ctrl + Alt + F3를 눌러 가상콘솔로 이동하여 Nvidia driver가 설치된 경로로 이동하여 installer를 실행한다.
```
$ sudo bash YOUR_DIR/NVIDIA-Linux-x86_64-450.80.02.run
```

5. 설치가 완료되면 재부팅한다.
```
$ sudo reboot
```

6. 아래 명령어를 통해 Nvidia driver가 GPU 자원을 제대로 인식하는지 확인한다.
```
$ nvidia-smi
```

++ 필자의 경우 로그인 화면에서 그래픽이 깨지는 현상이 있는데, 로그인하여 데스크톱 화면으로 들어가면 정상작동한다.

# Docker 설치
1. apt-get 업그레이드 및 업데이트를 한다.
```
$ sudo apt update
$ sudo apt upgrade
```

2. 도커 설치에 필요한 필수 패키지 다운로드를 한다.
```
$ sudo apt-get install curl apt-transport-https ca-certificates software-properties-common
```

3. 도커 Repository를 추가한다.
- GPG Key 추가
```
$ sudo apt-get install curl
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
- Repository 추가
```
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
- Repository 정보 업데이트
```
$ sudo apt update
```
- Docker Community Edition으로 지정
```
$ apt-cache policy docker-ce
```

4. 최종적으로 도커를 설치한다.
```
$ sudo apt install docker-ce
```

5. 도커의 실행상태를 확인한다.
```
$ sudo systemctl status docker
```
- 시스템 시작 시 항상 켜져있도록 유지하려면 아래 명령어 실행
```
$ sudo systemctl enable docker
```

6. 도커 명령어 실행할 때마다 sudo 권한을 묻지 않도록 도커 권한을 부여한다.
```
$ sudo usermod -aG docker $USER
```

# Nvidia-Docker 2.0 설치
1. 혹시 이전에 설치되어있는 nvidia-docker 1.0이 있다면 삭제한다.
```
$ docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 
$ docker ps -q -a -f volume={} | xargs -r docker rm -f
$ sudo apt-get purge nvidia-docker
```

2. Repository 설정 및 업데이트를 해준다.
```
$ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -

$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)

$ curl -s -L https://nvidia.github.io/nvidia-docker/

$ distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

$ sudo apt-get update
```

3. nvidia-docker 2.0를 설치한다.

```
$ sudo apt-get install nvidia-docker2
$ sudo pkill -SIGHUP dockerd
```

4. 도커 내부에서 nvidia-smi 명령어가 제대로 작동하는지 확인한다. 이 명령어를 입력하고 아래와 같은 화면이 나오면 성공이다.
```
$ docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
```
![nvidia-smi in Docker](https://user-images.githubusercontent.com/60086878/97267697-e8225c80-186d-11eb-95b0-5df5d1c899d6.png)


여기까지가 우분투를 설치하고 도커 내에 nvidia-docker를 설치하여 GPU 자원을 사용할 수 있도록 하는 과정이다. 글이 너무 길어지는 관계로 이만 줄이고, [💻맥북으로 딥러닝하기(Feat. Ubuntu 18.04 LTS) 2](https://inkkim.github.io/article/2.html)에서 글을 이어가겠다.


다음 글에서는 Docker 내에서 Tensorflow-gpu를 설치하고, ssh를 통한 우분투 서버 접속에 대해 다뤄보겠다.

# 참고
- [nvidia-docker](https://github.com/NVIDIA/nvidia-docker/wiki)
- [CUDA on WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)
- [Windows Insider Program](https://insider.windows.com/en-us/getting-started#register)
- [Ubuntu Release Cycle](https://ubuntu.com/about/release-cycle)
- [Install Ubuntu desktop](https://ubuntu.com/tutorials/install-ubuntu-desktop#7-begin-installation)
- [How to install NVIDIA driver on Ubuntu 18.04](https://medium.com/@antonioszeto/how-to-install-nvidia-driver-on-ubuntu-18-04-7b464bab43e6)
- [How To Install Docker On Ubuntu 18.04](https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04)
- [Docker Tutorial 5: Nvidia-Docker 2.0 Installation in Ubuntu 18.04](https://sh-tsang.medium.com/docker-tutorial-5-nvidia-docker-2-0-installation-in-ubuntu-18-04-cb80f17cac65)
