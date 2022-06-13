---
description: 디바이스 위치 정보를 Play 로 전달하기 위한 규격
---

# Location

## Version

최신 버전은 1.0 입니다.

| Version | Date       | Description |
| ------- | ---------- | ----------- |
| 1.0     | 2019.12.04 | 규격 추가       |

## SDK Interface

### LocationAgent 사용

Location interface 규격에 따른 디바이스의 동작 제어는 LocationAgent 가 처리합니다.

{% tabs %}
{% tab title="Android" %}
NuguAndroidClient instance 를 통해 LocationAgent instance 에 접근할 수 있습니다.

```
val locationAgent = nuguAndroidClient.getAgent(LocationAgent.NAMESPACE)
```
{% endtab %}

{% tab title="iOS" %}
NuguClient instance 를 통해 LocationAgent instance 에 접근할 수 있습니다.

```
let locationAgent = nuguClient.locationAgent
```
{% endtab %}

{% tab title="Linux" %}
CapabilityFactory::makeCapability 함수로 LocationAgent 를 생성하고 NuguClient 에 추가해 주어야합니다.

```
auto location_handler(std::shared_ptr<ILocationHandler>(
        CapabilityFactory::makeCapability<LocationAgent, ILocationHandler>()));

nugu_client->getCapabilityBuilder()
    ->add(location_handler.get())
    ->construct();
```
{% endtab %}
{% endtabs %}

### Context 구성

Play 에서 위치 정보 기반의 정보를 제공 받기 위해서는 디바이스의 위치 정보를 [Context](location.md#context) 에 포함시켜 주어야 합니다.

{% tabs %}
{% tab title="Android" %}
LocationProvider 를 추가합니다.

```
val provider = object: LocationProvider {
    override fun getLocation(): Location? {
        ...
    }
}
NuguAndroidClient.Builder(...)
    .enableLocation(provider)
```
{% endtab %}

{% tab title="iOS" %}
LocationAgentDelegate 를 추가합니다.

```
class MyLocationAgentDelegate: LocationAgentDelegate {
    func locationAgentRequestLocationInfo() -> LocationInfo? {
        ...
    }
}
locationAgent.delegate = MyLocationAgentDelegate()
```
{% endtab %}

{% tab title="Linux" %}
ILocationListener를 추가합니다.

```
class LocationListener : public ILocationListener {
public:
    ...

    void requestContext(LocationInfo& location_info) override;
    {
        ...
    }
};
auto location_listener(std::make_shared<LocationListener>());
```
{% endtab %}
{% endtabs %}

## Context

```
{
  "Location": {
    "version": "1.0",
    "current": {
      "latitude": "{{STRING}}",
      "longitude": "{{STRING}}"
    }
  }
}
```

| parameter         | type   | mandatory | description |
| ----------------- | ------ | --------- | ----------- |
| current           | object | N         | 현재 위치의 정보   |
| current.latitude  | string | Y         | 위도          |
| current.longitude | string | Y         | 경도          |
