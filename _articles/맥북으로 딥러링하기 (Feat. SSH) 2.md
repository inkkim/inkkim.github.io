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

# Tensorflow-gpu 도커 이미지 설치 🐳

Docker Hub에서는 수 많은 유저들이 각자 필요에 의해서 제작해놓은 도커 이미지가 공유되고 있다. 도커 이미지는 쉽게 말해서 특정 프로그램이나 서비스를 구동하기 위해서 필요한 모든 설치나 환경설정이 완료되어있는 상태를 박제한 것이다. 우리는 이 이미지를 다운받아 도커 데몬을 이용해 이것을 공유한 사람과 완벽하게 같은 환경을 실행할 수 있게 된다.

특정 OS의 구속되지 않고 컨테이너로써 Host OS와 다른 컨테이너로부터 독립된 환경을 구성할 수 있다. 심지어 성능 저하가 거의 없이 동일한 환경을 구성해주어 많은 개발자들의 큰 수고를 덜어주고 있다. 나 역시 이 편리한 툴을 이용하여 Tensorflow-gpu를 설치하여 딥러닝 개발환경을 구축하려고 한다. 

1. 먼저 Docker Hub에서 원하는 Tensorflow 이미지를 선택한다. Tensorflow Official Repository에서는 Tensorflow 버전별로 다양한 이미지를 제공하고 있다. 무려 천만 건 이상의 다운로드를 기록중이다. ❗😲❗
![Docker Hub](https://user-images.githubusercontent.com/60086878/97440883-687ab780-196b-11eb-8fea-5568c959c430.png)

- 이렇게 버전에 따라 태그를 나눠 배포하고 있다. 
![Tensorflow Tag](https://user-images.githubusercontent.com/60086878/97441942-a0cec580-196c-11eb-9ab9-ef6746dce720.png)
- CLI환경에서도 명령어로 찾을 수 있다. 특별한 케이스가 아닌 경우 STAR 개수를 많이 받은 것으로 받으면 된다.
![CLI Command](https://user-images.githubusercontent.com/60086878/97451551-30797180-1977-11eb-9df3-948f7ce81933.png)

```
docker search <이미지 이름>
```

2. 아래 명령어로 도커 데몬으로 실행시킨다.
```
$ cd $HOME/Desktop && mkdir docker
$ docker run --runtime=nvidia -d -it \ 
--mount type=bind,source=$HOME/Desktop/docker,target=/tf \
-p 8888:8888 \
-p 6006:6006 \
--name tf-gpu-py3 \
--restart always \
tensorflow/tensorflow:2.2.1-gpu-py3
```

- docker run --runtime=nvidia // nvidia-docker와 함께 도커 데몬을 실행
- -d // 백그라운드에서 실행
- -it // tty 가상콘솔 할당
- -mount type=bind, source=<호스트 경로>, target=<컨테이너 경로> 

// 호스트와 컨테이너 저장소 바인딩 (원래 컨테이너는 휘발성이므로 컨테이너가 삭제되어도 호스트에 파일이 남도록 설정)
- -p : 호스트 포트:컨테이너포트 // 호스트->컨테이너 포트 포워딩
- --name // 컨테이너 이름 명명
- --restart always // 도커 데몬이 실행되면 항상 실행
- \<Repositor Name>/\<Image Name>:\<Tag Name>
- <exec> (optional) // default값은 jupyter notebook 서버 실행
- 컨테이너 내 CLI(Command Line Interface)환경으로 진입하려면? /bin/bash

3. 아래 명령어로 도커 내 실행되고 있는 jupyter notebook 서버의 토큰값을 확인한다.
```
$ docker ps
$ docker exec <Container ID> jupyter notebook list
```
![token](https://user-images.githubusercontent.com/60086878/97458797-68d07e00-197e-11eb-9cae-8f68aefcd873.png)

4. 주소창에서 localhost:8888로 접근하고, Setup a Password에서 token값을 넣고 이용해 비밀번호를 설정한다.
![jupyter notebook](https://user-images.githubusercontent.com/60086878/97459020-a46b4800-197e-11eb-9e68-30bf57c3d461.png)
- 성공!
![main](https://user-images.githubusercontent.com/60086878/97459618-4d19a780-197f-11eb-99ad-5f8873398063.png)

5. 아래 명령어로 GPU가 정상적으로 작동하는지 확인한다.
```
from tensorflow.python.client import device_lib
device_lib.list_local_devices()
```
- 목록에 GPU가 출력되면 성공 🎉
![Check GPU](https://user-images.githubusercontent.com/60086878/97460098-cdd8a380-197f-11eb-8b56-0749930cf1a5.png)

- Tensorflow CNN 예제를 돌려보면서 GPU 활성도 모니터링도 해봤는데, 정상적으로 작동하는 것을 확인했다.
![Tensorflow ready](https://user-images.githubusercontent.com/60086878/97323747-76b9cc80-18b4-11eb-9e01-a896c3780395.png)
![Tensorflow action](https://user-images.githubusercontent.com/60086878/97326005-e466f800-18b6-11eb-8953-54899d40676f.png)

# 우분투 방화벽 설정
외부에서 우분투로 접속하게 하려면 방화벽을 설정하고 22번 포트만 열어줘야 한다. 그러기 위해 먼저 이름값 제대로 하는 ufw(Uncomplicated FireWall)을 설치해줘야 한다.

1. 아래 명령어로 ufw를 설치하고 실행한다.
```
sudo apt-get install ufw
sudo service ufw start
sudo service ufw enable
```

2. 아래 명령어로 22번 포트를 허용하고 확인한다.
```
sudo ufw allow 22
sudo ufw status
```

![ufw status](https://user-images.githubusercontent.com/60086878/97461289-fb721c80-1980-11eb-8089-8de63c0c5376.png)

# ssh 접속 환경 설정
맥에서 우분투를 접속하기 위해 ssh를 통해 맥북의 public key를 우분투로 보내서 등록 할 것이다. 즉, 우분투에게 맥북이 관계자라고 증명하는 key를 등록하는 셈이다.

1. 아래 명령어로 우분투에서 ssh를 설치한다.
```
sudo apt-get install ssh
```

2. 맥 (혹은 다른 기기) 에서 ssh-keygen을 한 후 Enter를 연타한다.
```
ssh-keygen
```
- 필자는 이미 있어서 있다고 나온다..
![ssh-keygen](https://user-images.githubusercontent.com/60086878/97464021-bdc2c300-1983-11eb-88e7-14e49fb9fcbc.png)

3. ssh key가 정상적으로 생성되었는지 확인한다.
```
cd ~/.ssh
ls -al
```
- ![check ssh key](https://user-images.githubusercontent.com/60086878/97464338-227e1d80-1984-11eb-95c7-fc837f99d816.png)

4. Public Key (id_rsa.pub) 를 우분투로 복사한다.
```
ssh-copy <User ID>@<유동 IP>
```




# 참고
[Ubuntu/Linux ssh 공개키의 모든 것](https://storycompiler.tistory.com/112)
