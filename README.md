# 전환 계획

1. Developers 문서 jekyll standalone으로 변경
   1. gitbook 컴포넌트 -> liquid custom tag 전환
      1. hint
      2. embed
      3. file
      4. 
   2. gitbook 지원요소 -> standalone으로 사용할 수 있도록 전환
      1. 메뉴트리
      2. 빈 페이지
      3. pagination
      4. 검색
      5. google analytics
2. 가이드 공유
   > 초기 디자인, 마크업 작업을 어떻게 해야 하는지에 대한 가이드
3. initial-document 생성
   > 1번중 문서부분 제거
   > liquid custom tag 사용법 및 jekyll-spaceship 사용 가이드 추가
   > 2번 문서를 정리하여 theme 생성 가이드 추가
4. 디자인, 마크업 적용
5. 검증
6. 상용 배포

![](.gitbook/assets/readme-01.png)

{% embed url="https://www.youtube.com/watch?v=1PB5j7FM0EE" %}

{% embed url="https://nugu-developers.github.io/nugu-ios/index.html" %}

{% hint style="info" %}
Play 생성 시에 이 호출 이름을 정의해야 하고, 호출 이름에 대한 자세한 내용은 [호출 이름 정의하기](nugu-play/play-registration-and-review/register-a-play.md#define-an-invocation-name)를 참고하면 됩니다.
{% endhint %}

{% code title="NuguCentralManager.swift " %}
```bash
     private init() { 
         NuguServerInfo.l4SwitchAddress = "https://review-dghttp.sktnugu.com"
     }
```
{% endcode %}

> 들여쓰기

{% tabs %}
{% tab title="First Tab" %}
NuguAndroidClient instance 를 통해 SoundAgent instance 에 접근할 수 있습니다.

```
class MySoundProvider: SoundProvider {
    ...
}
NuguAndroidClient.Builder(...)
    .enableSound(MySoundProvider())
```
{% endtab %}

{% tab title="Second Tab" %}
NuguAndroidClient 생성시 SoundProvider 를 추가합니다.

```
val soundAgent = nuguAndroidClient.getAgent(DefaultSoundAgent.NAMESPACE)
```
{% endtab %}
{% endtabs %}

<details>

<summary>Expandable</summary>

content

</details>

$$
f(x) = x * e^{2 pi i \xi x}
$$

{% swagger method="get" path="" baseUrl="https://test.com" summary="설명셜명" %}
{% swagger-description %}
description
{% endswagger-description %}

{% swagger-parameter in="path" required="true" %}
desc
{% endswagger-parameter %}

{% swagger-parameter in="query" %}
desc
{% endswagger-parameter %}

{% swagger-parameter in="header" %}
desc
{% endswagger-parameter %}

{% swagger-parameter in="cookie" %}
123321
{% endswagger-parameter %}

{% swagger-parameter in="body" %}

{% endswagger-parameter %}

{% swagger-response status="200: OK" description="desc" %}
```javascript
{
    // Response
}
```
{% endswagger-response %}

{% swagger-response status="201: Created" description="" %}
```javascript
{
    // Response
}
```
{% endswagger-response %}

{% swagger-response status="400: Bad Request" description="" %}
```javascript
{
    // Response
}
```
{% endswagger-response %}

{% swagger-response status="500: Internal Server Error" description="" %}
```javascript
{
    // Response
}
```
{% endswagger-response %}
{% endswagger %}

inline image ![](.gitbook/assets/readme-01.png) inline math $$f(x) = x * e^{2 pi i \xi x}$$
