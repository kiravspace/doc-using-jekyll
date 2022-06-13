---
description: 디바이스의 블루투스를 제어하기 위한 규격
---

# Bluetooth

## Version

최신 버전은 1.1 입니다.

| Version | Date       | Description                      |
| ------- | ---------- | -------------------------------- |
| 1.0     | 2020.03.03 | 규격 추가                            |
| 1.1     | 2020.06.22 | Context 의 device 에 profile 필드 추가 |

## SDK Interface

### BluetoothAgent 사용

Bluetooth interface 규격에 따른 디바이스의 동작 제어는 BluetoothAgent 가 처리합니다.

{% hint style="warning" %}
iOS 는 BluetoothAgent 를 지원하지 않습니다.
{% endhint %}

{% tabs %}
{% tab title="Android" %}
NuguAndroidClient instance 를 통해 BluetoothAgent instance 에 접근할 수 있습니다.

```
val bluetoothAgent = nuguAndroidClient.bluetoothAgent
```

NuguAndroidClient 생성시 BluetoothProvider 을 추가합니다.

```
class MyBluetoothProvider: BluetoothProvider {
    ...
}
NuguAndroidClient.Builder(...)
    .enableBluetooth(MyBluetoothProvider())
```
{% endtab %}

{% tab title="Linux" %}
CapabilityFactory::makeCapability 함수로 BluetoothAgent 를 생성하고 NuguClient 에 추가해 주어야합니다.

```
auto bluetooth_handler(std::shared_ptr<IBluetoothHandler>(
        CapabilityFactory::makeCapability<BluetoothAgent, IBluetoothHandler>()));

nugu_client->getCapabilityBuilder()
    ->add(bluetooth_handler.get())
```
{% endtab %}
{% endtabs %}

### Context 구성

디바이스의 블루투스 상태를 [Context](speaker.md#context) 에 포함시켜 주어야 합니다.

[Android reference](https://github.com/nugu-developers/nugu-android/blob/master/nugu-agent/src/main/java/com/skt/nugu/sdk/agent/bluetooth/BluetoothProvider.kt#L21)

{% tabs %}
{% tab title="Android" %}
BluetoothProvider 를 구현합니다.

```
class MyBluetoothProvider: BluetoothProvider {
    override fun device() : BluetoothHost? {
        ...
    }

    override fun activeDevice() : BluetoothDevice? {
        ...
    }

    ...
}
```
{% endtab %}

{% tab title="Linux" %}
IBluetoothListener를 추가합니다.

```
class BluetoothListener : public IBluetoothListener {
public:
    ...

    void requestContext(BTDeviceInfo& device_info) override;
    {
        ...
    }
};
auto bluetooth_listener(std::make_shared<BluetoothListener>());
```
{% endtab %}
{% endtabs %}

### 블루투스 기기 제어

디바이스의 블루투스 기기 제어가 [StartDiscoverableMode](bluetooth.md#startdiscoverablemode)/[FinishDiscoverableMode](bluetooth.md#finishdiscoverablemode) directive 로 요청될 수 있습니다.

디바이스와 연결된 블루투스 기기의 음원 재생이 [Play](bluetooth.md#play)/[Stop](bluetooth.md#stop)/[Pause](bluetooth.md#pause)/[Next](bluetooth.md#next)/[Previous](bluetooth.md#previous) directive 로 요청될 수 있습니다.

{% tabs %}
{% tab title="Android" %}
제어 기능을 실행하려면 BluetoothAgentInterface.Listener 를 추가합니다.

```
val listener = object: BluetoothAgentInterface.Listener {
    fun onDiscoverableStart(durationInSeconds: Long = 0) : DiscoverableStartResult {
        ...
    }

    fun onDiscoverableFinish() : Boolean {
        ...
    }

    fun onAVRCPCommand(command: AVRCPCommand) {
        ...
    }
}
bluetoothAgent.setListener(listener)
```
{% endtab %}

{% tab title="Linux" %}
IBluetoothListener를 추가합니다.

```
class BluetoothListener : public IBluetoothListener {
public:
    ...

    void startDiscoverableMode(long duration_sec) override
    {
        ...
    }
        
    void finishDiscoverableMode() override
    {
        ...
    }
};
auto bluetooth_listener(std::make_shared<BluetoothListener>());
CapabilityFactory::makeCapability<BluetoothAgent, IBluetoothHandler>(bluetooth_listener.get());
```
{% endtab %}
{% endtabs %}

## Context

```
{
  "Bluetooth": {
    "version": "1.0",
    "device": {
      "name": "{{STRING}}",
      "status": "{{STRING}}",
      "profiles": [
        {
          "name": "{{STRING}}",
          "enabled": "{{STRING}}"
        }
      ]
    },
    "activeDevice": {
      "id": "{{STRING}}",
      "name": "{{STRING}}",
      "streaming": "{{STRING}}"
    }
  }
}
```

| parameter              | type   | mandatory | description                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ---------------------- | ------ | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| device                 | object | Y         | 디바이스의 블루투스 정보                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| device.name            | string | Y         | TTS로 읽어줄 때 사용가능한 필드 예: NUGU\_123456                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| device.status          | string | Y         | ON / OFF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| device.profile         | list   | N         | Pairing된 bluetooth device가 있을 경우 지원하는 profile의 목록 해당 목록은 지원하는 profile이 있을 경우 명시됨                                                                                                                                                                                                                                                                                                                                                                                                        |
| device.profile.name    | string | N         | Pairing된 bluetooth device가 있을 경우 해당 device의 지원 profile의 이름을 나타냄 아래는 현재 확인된 profile list이며, 해당 device에서 사용하는 profile은 추가될 수 있음 - **HSP** : Headset Profile(전화 수발신을 위한 profile) - **A2DP** : Advanced Audio Distribution Profile(오디오 재생 profile) - **PBAP** : Phone Book Access Profile(Pairing된 device의 연락처를 수집할 수 있는 profile) - **MAP** : Message Access Profile(문자 수발신을 위한 profile) - **PAN** : Personal Area Networking(블루투스 테더링 profile) Profile 이름은 bluetooth.com에 명시된 profile의 약자임 |
| device.profile.enabled | string | N         | Pairing된 bluetooth device가 있을 경우 해당 device의 지원 profile의 사용 여부를 나타냄 (TRUE/FALSE)                                                                                                                                                                                                                                                                                                                                                                                                         |
| activeDevice           | object | N         | 연결된 블루투스 기기 정보                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| activeDevice.id        | string | N         | ID(pairedDevices 목록 중 하나이어야 함)                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| activeDevice.name      | string | N         | -                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| activeDevice.streaming | string | Y         | streaming 상태 (INACTIVE/ACTIVE/PAUSED/UNUSABLE)                                                                                                                                                                                                                                                                                                                                                                                                                                          |

## Directive

### StartDiscoverableMode

Discoverable mode 활성화 요청입니다.

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "StartDiscoverableMode",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "durationInSeconds": "{{LONG}}"
  }
}
```

| parameter         | type | mandatory | description                                 |
| ----------------- | ---- | --------- | ------------------------------------------- |
| durationInSeconds | long | N         | Discoverable mode 를 지속할 시간(필드가 없는 경우 상시 모드) |

### FinishDiscoverableMode

Discoverable mode 비활성화 요청입니다.

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "FinishDiscoverableMode",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### Play

연결된 블루투스 기기의 음원 재생 요청입니다.

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "Play",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### Stop

연결된 블루투스 기기의 음원 재생 중지 요청입니다.

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "Play",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### Pause

연결된 블루투스 기기의 음원 일시정지 요청입니다.

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "Pause",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### Next

연결된 블루투스 기기의 다음 음원 재생 요청입니다.

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "Next",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### Previous

연결된 블루투스 기기의 이전 음원 재생 요청입니다.

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "Previous",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

## Event

### StartDiscoverableModeSucceeded

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "StartDiscoverableModeSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "hasPairedDevices": "{{BOOLEAN}}"
  }
}
```

| parameter        | type    | mandatory | description      |
| ---------------- | ------- | --------- | ---------------- |
| hasPairedDevices | boolean | Y         | paired device 유무 |

### StartDiscoverableModeFailed

* Discoverable mode 진입 실패

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "StartDiscoverableModeFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "hasPairedDevices": "{{BOOLEAN}}"
  }
}
```

| parameter        | type    | mandatory | description      |
| ---------------- | ------- | --------- | ---------------- |
| hasPairedDevices | boolean | Y         | paired device 유무 |

### FinishDiscoverableModeSucceeded

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "FinishDiscoverableModeSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### FinishDiscoverableModeFailed

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "FinishDiscoverableModeFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### ConnectSucceeded

* paired 이력에서 디바이스 연결이 성공 했을 때 또는 source(스마트폰 등)에서 직접 연결 연결 성공 했을 때 발생

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "ConnectSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### ConnectFailed

* paired 이력에서 디바이스 연결이 실패 했을 때 발생

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "ConnectFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### DisconnectSucceeded

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "DisconnectSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### DisconnectFailed

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "DisconnectFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlPlaySucceeded

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlPlaySucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlPlayFailed

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlPlayFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlStopSucceeded

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlStopSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlStopFailed

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlStopFaile",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlPauseSucceeded

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlPauseSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlPauseFailed

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlPauseFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlNextSucceeded

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlNextSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlNextFailed

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlNextFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlPreviousSucceeded

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlPreviousSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```

### MediaControlPreviousFailed

```
{
  "header": {
    "namespace": "Bluetooth",
    "name": "MediaControlPreviousFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```
