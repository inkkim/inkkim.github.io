---
id: 5
title: "📚GitBook으로 나만의 책 펴내기"
subtitle: "유용한 깃허브 연동 전자책"
date: "2020.12.23"
tags: "GitBook, 책, 깃북"
---

# GitBook이란 ?
GitBook은 개인이나 팀이 내부 지식을 쉽게 공동 저작물을 문서화 할 수 있게 도와주는 최신 문서 플랫폼이다.
![](https://user-images.githubusercontent.com/60086878/102992242-38602700-455e-11eb-800e-e930be982c34.png)

주로 기업에서는 사용 설명서 정도로 많이 활용을 하고, 팀 단위로 내부 지식공유에도 많이 활용된다. 요즘엔 개인들이 자신이 배운 내용(TIL)들을 기록하는 용도로도 종종 만나볼 수 있다.

필자의 경우도 Git 블로그에 포스팅하면서 생겼던 고민이 배웠던 개념을 정리한 내용과 실습했던 내용에 대한 구분을 두고 싶었다. 카테고리 기능을 추가하여 해결하려던 찰나에 GitBook이라는 툴을 발견하여 앞으로 개념 정리 관련된 내용은 Gitbook에 정리할 생각이다.

## 특징
- __GitHub 연동 기능__
- 공동 수정을 위한 Draft 기능
- 팀 관리 기능으로 접근 권한 제어 기능
- 마크다운 및 이모지 기능
- 페이지와 그룹을 통한 문서 구조화 기능
- 코드 블럭, 테이블, 힌트 탭 지원

## 활용사례
- [Elastic 가이드북](https://esbook.kimjmin.net)
- [벨로퍼트와 함께하는 모던 리액트](https://react.vlpt.us)
- [Data-Engineering-Note](https://sda1547.gitbook.io/data-engineering/)

# 사용법

1. GitBook에 회원가입 한다.
- GitHub 계정을 이용한 간편 회원가입을 지원한다.

![](https://user-images.githubusercontent.com/60086878/102995711-fb4b6300-4564-11eb-875b-a5339af50778.png)

2. Create a new space를 눌러 첫 Space를 생성한다.
- Space는 GitBook의 책 제목과 같은 격

![](https://user-images.githubusercontent.com/60086878/102995880-52513800-4565-11eb-8c7a-f1df8b79e3d8.png)

3. New 버튼으로 새로운 Page, Group 등을 생성할 수 있다.

![](https://user-images.githubusercontent.com/60086878/102996701-e7a0fc00-4566-11eb-8001-3c137b26e08d.png)

4. 다양한 소스로부터 import 기능도 지원한다.
- Google Docs
- Github Wiki
- Dropbox Paper
- Notion

![](https://user-images.githubusercontent.com/60086878/102996850-28991080-4567-11eb-99f1-7ab24a0128ba.png)

5. 팀으로 활용 시 계정별 수정 로그가 남아 이력 관리가 가능하다.

![](https://user-images.githubusercontent.com/60086878/102997101-a2c99500-4567-11eb-9c17-b47c893e4055.png)

6. GitHub의 특정 Repository와 연동이 가능하다. 즉, GitHub와 GitBook 어디에서 문서를 작성하더라도 양방향으로 동시에 반영되어 수정이 될 수 있다.
- TIL을 기록하고자 한다면 GitHub에 그냥 마크다운으로 하는 것보다 보기 쉽게 구조화 할 수 있고, 쉽게 이미지를 삽입할 수 있어 편리한 것 같다.
- GitBook에서 수정 시 GitHub에도 commit으로 반영되므로 잔디심기에도 유용하다.
![](https://user-images.githubusercontent.com/60086878/102997166-c7257180-4567-11eb-88eb-1b4591c559bd.png)

7. 도메인은 기본적으로 `https://ID.gitbook.io/Space Name` 으로 생성되며, GitHub Page와 같이 커스텀 도메인 기능도 지원하고있다.

# 참고
[What is GitBook](https://docs.gitbook.com)
