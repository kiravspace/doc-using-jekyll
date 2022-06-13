---
description: 디바이스의 디스플레이를 제어하기 위한 규격
---

# Screen

## Version

최신 버전은 1.0 입니다.

| Version | Date | Description |
| :--- | :--- | :--- |
| 1.0 | 2020.03.02 | 규격 추가 |

## SDK Interface

### ScreenAgent 사용

Screen interface 규격에 따른 디바이스의 동작 제어는 ScreenAgent 가 처리합니다.

{% hint style="warning" %}
iOS/Linux 는 ScreenAgent 를 지원하지 않습니다.
{% endhint %}

{% tabs %}
{% tab title="Android" %}
NuguAndroidClient instance 를 통해 ScreenAgent instance 에 접근할 수 있습니다.

```text
val screenAgent = nuguAndroidClient.getAgent(DefaultScreenAgent.NAMESPACE)
```

NuguAndroidClient 생성시 Screen 을 추가합니다.

```text
class MyScreen: Screen {
    ...
}
NuguAndroidClient.Builder(...)
    .enableScreen(MyScreen())
```
{% endtab %}
{% endtabs %}

### Context 구성

디바이스의 디스플레이 상태를 [Context](screen.md#context) 에 포함시켜 주어야 합니다.

{% tabs %}
{% tab title="Android" %}
Screen 을 구현합니다.

```text
class MyScreen: Screen {
    override fun getSettings(): Settings {
        ...
    }
    ...
}
```
{% endtab %}
{% endtabs %}

### 디스플레이 제어

디바이스의 디스플레이 제어가 [TurnOn](screen.md#turnon)/[TurnOff](screen.md#turnoff)/[SetBrightness](screen.md#setbrightness) directive 로 요청될 수 있습니다.

{% tabs %}
{% tab title="Android" %}
Screen 을 구현합니다.

```text
class MyScreen: Screen {
    override fun turnOn(brightness: Long): Boolean {
        ...
    }

    override fun turnOff(): Boolean {
        ...
    }

    override fun setBrightness(brightness: Long): Boolean {
        ...
    }

    ...
}
```
{% endtab %}
{% endtabs %}

## Context

```text
{
  "Screen": {
    "version": "1.0",
    "state": "{{STRING}}",
    "brightness": {{LONG}}
  }
}
```

| parameter | type | mandatory | description |
| :--- | :--- | :--- | :--- |
| state | enum | Y | **ON, OFF** |
| brightness | long | Y | 0 ~ 100 |

## Directive

### TurnOn

```text
{
  "header": {
    "namespace": "Screen",
    "name": "TurnOn",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "brightness": {{LONG}}
  }
}
```

| parameter | type | mandatory | description |
| :--- | :--- | :--- | :--- |
| brightness | long | Y | 1 ~ 100 |

### TurnOff

```text
{
  "header": {
    "namespace": "Screen",
    "name": "TurnOff",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### SetBrightness

```text
{
  "header": {
    "namespace": "Screen",
    "name": "SetBrightness",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "brightness": {{LONG}}
  }
}
```

| parameter | type | mandatory | description |
| :--- | :--- | :--- | :--- |
| brightness | long | Y | 1 ~ 100 |

