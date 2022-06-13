---
description: 정의되지 않은 기능을 수행하기 위한 규격
---

# Extension

## Version

최신 버전은 1.1 입니다.

| Version | Date | Description |
| :--- | :--- | :--- |
| 1.0 | 2019.11.24 | 규격 추가 |
| 1.1 | 2020.01.08 | CommandIssued event 추 |

## Precondition

Extension interface 를 사용한 Play 를 제작하기 위해서는 제휴담당자에게 요청하여 권한을 획득해야 합니다.

Play 개발자와 Application 개발자는 Context, Directive, Event 의 data 필드에 대한 데이터 구조를 협의해야 합니다.

## SDK Interface

### ExtensionAgent 사용

Extension interface 규격에 따른 디바이스의 동작 제어는 ExtensionAgent 가 처리합니다.

{% tabs %}
{% tab title="Android" %}
NuguAndroidClient instance 를 통해 ExtensionAgent instance 에 접근할 수 있습니다.

```text
val extensionAgent = nuguAndroidClient.extensionAgent
```

NuguAndroidClient 생성시 ExtensionAgentInterface.Client 를 추가합니다.

```text
class MyExtensionAgentClient: ExtensionAgentInterface.Client {
    ...
}
NuguAndroidClient.Builder(...)
    .enableExtension(MyExtensionAgentClient())
```
{% endtab %}

{% tab title="iOS" %}
NuguClient instance 를 통해 ExtensionAgent instance 에 접근할 수 있습니다.

```text
let extensionAgent = nuguClient.extensionAgent
```
{% endtab %}

{% tab title="Linux" %}
CapabilityFactory::makeCapability 함수로 ExtensionAgent 를 생성하고 NuguClient 에 추가해 주어야합니다.

```text
auto extension_handler(std::shared_ptr<IExtensionHandler>(
        CapabilityFactory::makeCapability<ExtensionAgent, IExtensionHandler>()));

nugu_client->getCapabilityBuilder()
    ->add(extension_handler.get())
    ->construct();
```
{% endtab %}
{% endtabs %}

### Context 구성 및 기능 실행

Play 에서 알아야 하는 디바이스/Application 의 정보를 [Context](extension.md#context) 에 포함시켜 주어야 합니다.

특정 기능의 실행이 [Action](extension.md#action) directive 로 요청될 수 있습니다.

{% tabs %}
{% tab title="Android" %}
ExtensionAgentInterface.Client 를 구현합니다.

```text
class MyExtensionAgentClient : ExtensionAgentInterface.Client {
    override fun getData(): String? {
        // json string
        ...
    }

    override fun action(data: String, playServiceId: String): Boolean {
        ...
    }
}
```
{% endtab %}

{% tab title="iOS" %}
ExtensionAgentDelegate 를 추가합니다.

```text
class MyExtensionAgentDelegate: ExtensionAgentDelegate {
    func extensionAgentRequestContext() -> [String: AnyHashable]? {
        ...
    }

    func extensionAgentDidReceiveAction(data: [String: AnyHashable], playServiceId: String, dialogRequestId: String, completion: @escaping (Bool) -> Void) {
        ...
    }
}
extensionAgent.delegate = MyExtensionAgentDelegate()
```
{% endtab %}

{% tab title="Linux" %}
IExtensionListener를 추가합니다.

```text
class ExtensionListener : public IExtensionListener {
public:
    ...

    void receiveAction(const std::string& data, const std::string& ps_id, const std::string& dialog_id) override
    {
        ...
    }
};
auto extension_listener(std::make_shared<ExtensionListener>());
CapabilityFactory::makeCapability<ExtensionAgent, IExtensionHandler>(extension_listener.get());
```
{% endtab %}
{% endtabs %}

### 기능 요청

특정 기능 실행을 [CommandIssued](extension.md#commandissued) event 로 요청할 수 있습니다.

{% tabs %}
{% tab title="Android" %}
```text
extensionAgent.issueCommand(playServiceId, data, callback)
```
{% endtab %}

{% tab title="iOS" %}
```text
extentionAgent.requestCommand(data: data, playServiceId: playServiceId)
```
{% endtab %}

{% tab title="Linux" %}
```text
extension_handler->commandIssued(play_service_id, data)
```
{% endtab %}
{% endtabs %}

## Context

```text
{
  "Extension": {
    "version": "1.1",
    "data": {}
  }
}
```

| parameter | type | mandatory | description |
| :--- | :--- | :--- | :--- |
| data | object | N | 임의의 JSON object |

## Directive

### Action

```text
{
  "header": {
    "namespace": "Extension",
    "name": "Action",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "data": {}
  }
}
```

| parameter | type | mandatory | description |
| :--- | :--- | :--- | :--- |
| data | object | Y | 임의의 JSON object |

## Event

### ActionSucceeded

```text
{
  "header": {
    "namespace": "Extension",
    "name": "ActionSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### ActionFailed

```text
{
  "header": {
    "namespace": "Extension",
    "name": "ActionFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### CommandIssued

```text
{
  "header": {
    "namespace": "Extension",
    "name": "CommandIssued",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.1"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "data": {}
  }
}
```

| parameter | type | mandatory | description |
| :--- | :--- | :--- | :--- |
| data | object | Y | 임의의 JSON object |

