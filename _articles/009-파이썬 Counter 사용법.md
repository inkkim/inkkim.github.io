---
id: 9
title: "🐍파이썬 Counter 사용법"
subtitle: "Counter function in collections module"
date: "2020.12.30"
tags: "파이썬, Counter, collections"
---

# 완주하지 못한 선수
![](https://user-images.githubusercontent.com/60086878/103338570-22081d00-4ac2-11eb-9c1e-bc934b7dd499.png)

프로그래머스 코딩테스트 연습에 완주하지 못한 선수(Lv.1)라는 문제가 있다. 여느 때와 같이 파이썬으로 문제를 풀이하는데 정확성 테스트는 모두 통과했지만 효율성 검사에서 모두 시간 초과로 실패했다. 내가 처음에 풀이했던 방식은 다음과 같다.

## list.remove()

![](https://user-images.githubusercontent.com/60086878/103338653-6d223000-4ac2-11eb-9473-82d1ed6d6e2c.png)

리스트 요소를 제거하되 중복이 있을 시 최초 발견된 요소만 삭제하는 `list.remove()` 메소드의 특징을 이용해 풀이하려 했다. 정확성 테스트는 모두 통과했지만 역시 효율성에서 모두 시간초과로 실패한다.

왜 그런가 생각해보면 `list.remove()`는 시간복잡도가 O(N)이고, 반복문이 한 번 들어가게 되니 O(N²)이 된다. 아마도 효율성 검사에서 O(N²)이면 실패하게 만드는 케이스가 있는 것으로 추정된다.

## list.sort()
![](https://user-images.githubusercontent.com/60086878/103339676-592bfd80-4ac5-11eb-84da-625403ecc65d.png)

`list.sort()` 메소드를 이용해 정렬하고, 같은 인덱스를 기준으로 비교하면서 다른 요소가 나올 때까지 비교해 구하는 방식으로 풀었더니 정확성과 효율성 모두 통과할 수 있었다.

## collections.Counter()

![image](https://user-images.githubusercontent.com/60086878/103340597-c5a7fc00-4ac7-11eb-98dd-022872c51bde.png)

`collections.Counter()` 메소드는 iterable 객체 즉, list, dict, set, str, bytes, tuple, range와 같은 반복 가능한 객체의 요소를 카운트하여 각각의 빈도 값을 {요소:빈도} 형태인 해쉬 테이블형태(카운터 객체)로 반환한다. 

이 문제를 풀면서 나름 꽤를 생각해내다가 리스트나 딕셔너리 객체도 뺄셈 연산이 되면 좋겠다 생각했다. 안타깝게도 리스트나 딕셔너리를 뺄셈 연산을 지원하지 않지만, 카운터 객체는 추가적인 연산을 지원한다. 

```python
>>> c = Counter(a=3, b=1)       # Counter({'a': 3, 'b': 1})
>>> d = Counter(a=1, b=2)       # Counter({'a': 1, 'b': 2})

>>> c + d                       
Counter({'a': 4, 'b': 3})

>>> c - d                       
Counter({'a': 2})

>>> c & d                       # intersection:  min(c[x], d[x]) 
Counter({'a': 1, 'b': 1})

>>> c | d                       # union:  max(c[x], d[x])
Counter({'a': 3, 'b': 2})
```

이 외에도 `collections.Counter()` 메소드는 자연어 처리 시 Word Count를 쉽게 나타낼 수 있고, 심지어 시간복잡도는 O(N)으로 속도도 빠르다. 앞으로도 다양한 상황에서 잘 써먹을 수 있을 것 같다 😋

# Counter() 객체

## 생성

Counter() 객체를 생성하는 방법은 다음과 같다. count는 0 이하의 음수도 될 수 있으며, dictionary와 같은 구조를 가진다.

```python
>>> c = Counter()                             # 빈 카운터 객체 생성
Counter()

>>> c = Counter('abbcccdddd')                 # iterable 객체로부터 생성
Counter({'d': 4, 'c': 3, 'b': 2, 'a': 1})

>>> c = Counter({'one': 4, 'two': 2})         # mapping을 통해 생성
Counter({'one': 4, 'two': 2})

>>> c = Counter(cats=4, dogs=8)               # 매개변수를 통해 생성 
Counter({'dogs': 8, 'cats': 4})
```

또한, 3 가지 메소드를 통해 필요한 연산을 지원한다.

## 메소드

### Counter.elements()
Counter 객체의 정보에 따른 리스트 반환 (양수만)
```python
>>> c = Counter(a=4, b=2, c=0, d=-2)
Counter({'a': 4, 'b': 2, 'c': 0, 'd': -2})

>>> sorted(c.elements())
['a', 'a', 'a', 'a', 'b', 'b']
```

### Counter.most_common([n])
Counter 객체의 count의 빈도 상위 n개의 값 반환하는 메소드

```python
>>> Counter('abracadabra').most_common(3)
[('a', 5), ('b', 2), ('r', 2)]
```

### Counter.update()
Counter 객체에 대하여 다른 mapping 및 Counter 객체 정보를 덧셈 연산하는 메소드
```python
>>> c = Counter(a=4, b=2, c=0, d=-2)
>>> d = Counter(a=1, b=2, c=3, d=4)
>>> c.update(d)
>>> c
Counter({'a': 5, 'b': 4, 'c': 3, 'd': 2})
```

### Counter.substract()
Counter 객체에 대하여 다른 mapping 및 Counter 객체 정보를 뺄셈 연산하는 메소드
```python
>>> c = Counter(a=4, b=2, c=0, d=-2)
>>> d = Counter(a=1, b=2, c=3, d=4)
>>> c.subtract(d)
>>> c
Counter({'a': 3, 'b': 0, 'c': -3, 'd': -6})
```

### 기타
이외에도 Counter 객체는 딕셔너리와 유사한 메소드를 지원한다.
```python
>>> c = Counter(a=4, b=2, c=0, d=-2)
>>> c.values()                          # count 값 리스트로 반환
>>> c.items()                           # (element, count) 값 튜플로 반환
>>> c.clear()                           # count 값 모두 리셋 (빈 카운터 객체 반환)
>>> list(c)                             # element 값 list로 반환
>>> set(c)                              # element 값 set으로 반환
>>> dict(c)                             # {element, count} 값 딕셔너리로 반환
>>> +c                                  # count 값이 양수 값에 해당하는 쌍만 반환
```


# 참고
- [collections Container datatypes](https://docs.python.org/3/library/collections.html#collections.Counter)