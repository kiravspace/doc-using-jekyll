# SmartHomeAttribute

NUGU스마트홈을 통해 스마트홈 기기를 제어할 때 Capability나 Directive에 따라 포함되는 Attributes가 있습니다. SmartHome Attributes는 다양한 사용자 발화에 대응하여 아래와 같이 사용자 발화 데이터를 정규화하여 SmartHomeBackendProxy에 제어 요청을 보낼 때 포함합니다. IoT ServiceProvider는 지원하고자 하는 기능에 맞는 Directive가 어떠한 Attribute를 갖는지 확인하고 지원할 Attribute를 선택해야 합니다.

## Attribute List

| SmartHomeAttribute | Description |
| :--- | :--- |
| [airflowType](smarthomeattribute.md#airflowtype) | 설정하고자 하는 airflowType의 사용자 발화 정보. 해당 parameter의 value는 Device Discovery 당시 Response한 supprtedAirflowTypes 중 하나로 요청됩니다. |
| [airflowDelta](smarthomeattribute.md#airflowdelta) | airflowType을 몇 단계 조절할지에 대한 사용자 발화 정보입니다. 해당 parameter가 없을 경우에는 1단계를 올리도록 설정해야 합니다. |
| [brightnessLevel](smarthomeattribute.md#brightnesslevel) | 사용자가 SmartHomeDevice에 설정하고자 하는 밝기의 발화 정보입니다. 1부터 100까지 설정할 수 있습니다. |
| [brightnessDelta](smarthomeattribute.md#brightnessdelta) | 설정 밝기를 몇 단계 조절지에 대한 사용자 발화 정보입니다. 해당 정보가 없을 경우 1단계를 올리도록 설정합니다. |
| [colorType](smarthomeattribute.md#colortype) | 사용자가 SmartHomeDevice에 설정하고자 하는 색상 정보입니다. |
| [deviceTemperatureLevel](smarthomeattribute.md#devicetemperaturelevel) | 사용자가 SmartHomeDevice에 설정하고자 하는 자체설정온도의 발화정보입니다. |
| [humidityLevel](smarthomeattribute.md#humiditylevel) | 사용자가 SmartHomeDevice에 설정하고자 하는 습도의 발화 정보입니다. %단위입니다. |
| [humidityDelta](smarthomeattribute.md#humiditydelta) | 설정습도를 몇 % 조절지에 대한 사용자 발화 정보입니다. 해당 정보가 없을 경우 humidityStep만큼 올리도록 설정합니다. |
| [mode](smarthomeattribute.md#mode) | 설정하고자 하는 mode의 사용자 발화 정보, 해당 parameter의 value는 Device Discovery 당시 응답한 supportedModes 중 하나로 요청됩니다. |
| [temperatureLevel](smarthomeattribute.md#temperaturelevel) | 사용자가 SmartHomeDevice에 설정하고자 하는 온도\(섭씨\)의 발화 정보입니다. |
| [temperatureDelta](smarthomeattribute.md#temperaturedelta) | 설정온도를 몇 도\(섭씨\) 올릴지에 대한 사용자 발화 정보입니다. 해당 정보가 없을 경우에는 temperatureStep만큼 올리도록 설정합니다. |

## Attribute Details

IoT ServiceProvider 및 제품에 따라 지원하는 Attribute 값이 상이할 수 있습니다. 이 경우 하기의 Attribute 중 적합한 값을 선택해 제어할 것을 권장합니다.

### airflowType

설정하고자 하는 풍량 및 풍속의 정보입니다. Device Discovery 당시 응답한 supprtedAirflowTypes 중 하나로 요청됩니다.

지원풍량정보

| AirflowType | AirflowType Code |
| :--- | :--- |
| 미풍 | BREEZE |
| 약풍 | LOW |
| 중풍 | MIDDLE |
| 강풍 | HIGH |
| 터보 | TURBO |
| 파워 | POWERWIND |
| 수면풍, 취침풍 | SLEEPINGWIND |
| 쾌면풍 | PLEASANTSLEEP |
| 자연 | NATURALWIND |
| 자동풍 | AUTOWIND |
| 1단\(계\) | SPEED1 |
| 2단\(계\) | SPEED2 |
| 3단\(계\) | SPEED3 |
| 4단\(계\) | SPEED4 |
| 5단\(계\) | SPEED5 |

Attribute 사용 예시

```scheme
SetAirflow Directive Control Request 예시 (POST, /nugu/v1/capabilities/{Capability}/directives/{Directive})


{
   "version":1,
   "requestId":"20190916109ad8219c251742859c56f6ec3c4700bb",
   "action":{
      "command":{
         "smartHomeCapability":"AirflowControl",
         "smartHomeDirective":"SetAirflow",
         "parameters":{
            "airflowType":"LOW",
            "rawAirflowType":"약풍"
         }
      },
      "smartHomeDevices":[
         {
            "id":"1234567",
            "deviceTypeCode":"AIR_CONDITIONER",
            "deviceTypeName":"에어컨",
            "deviceModelName":"example air_conditioner",
            "friendlyNameSuggestion":"거실",
            "manufacturer":"example manufacturer",
            "supportedCapabilities":{
               "airflowControl":{
                  "supportedAirflowTypes":[
                     "HIGH",
                     "MIDDLE",
                     "LOW",
                     "AUTO"
                  ]
               }
            },
            "customData":{
               "foo":"bar"
            }
         }
      ]
   },
   "context":{
      "session":{
         "id":"example_session_id",
         "accessToken":"example_access_token"
      }
   }
}
```

Related to [AirflowControl Interface](smarthomecapability/airflowcontrol-interface.md)

### airflowDelta

Airflow를 몇 단계 조절할지에 대한 Attribute value입니다. 해당 Attribute가 없을 경우에는 1단계를 조절하도록 설정해야 합니다.

{% hint style="info" %}
**Increase / Decrease를 위한 AirflowType의 세기 단위**  
미풍 &lt; 약풍 &lt; 중풍 &lt; 강풍 &lt; 터보, 1단 &lt; 2단 &lt; 3단 &lt; 4단 &lt; 5단 순으로 조정되며 이외에는 세기 단위에 포함되지 않은 특수풍으로 구분합니다.
{% endhint %}

Attribute 사용 예시

```scheme
IncreaseAirflow Directive Request 예시 (POST, /nugu/v1/capabilities/{Capability}/directives/{Directive})


{
   "version":1,
   "requestId":"20190916109ad8219c251742859c56f6ec3c4700bb",
   "action":{
      "command":{
         "smartHomeCapability":"AirflowControl",
         "smartHomeDirective":"IncreaseAirflow"
      },
      "smartHomeDevices":[
         {
            "id":"1234567",
            "deviceTypeCode":"AIR_CONDITIONER",
            "deviceTypeName":"에어컨",
            "deviceModelName":"example air_conditioner",
            "friendlyNameSuggestion":"거실",
            "manufacturer":"example manufacturer",
            "supportedCapabilities":{
               "airflowControl":{
                  "supportedAirflowTypes":[
                     "HIGH",
                     "MIDDLE",
                     "LOW",
                     "AUTO"
                  ]
               }
            },
            "customData":{
               "foo":"bar"
            }
         }
      ]
   },
   "context":{
      "session":{
         "id":"example_session_id",
         "accessToken":"example_access_token"
      }
   }
}
```

Related to [AirflowControl Interface](smarthomecapability/airflowcontrol-interface.md)

### brightnessLevel

설정하고자 하는 스마트홈 기기의 밝기 정보입니다. 1부터 100 단계 백분율 정보로 설정할 수 있습니다.

Attribute 사용 예시

```scheme
SetBrightness Directive Request 예시 (POST, /nugu/v1/capabilities/{Capability}/directives/{Directive})


{
  "version": 1,
  "requestId": "201909301991140f5a1e97441fa76a699284bc6035",
  "action": {
    "command": {
      "smartHomeCapability": "BrightnessControl",
      "smartHomeDirective": "SetBrightness",
      "brightnessLevel": 30
    },
    "smartHomeDevices": [
      {
        "id": "123456",
        "deviceTypeCode": "LIGHT",
        "friendlyName": "거실",
        "deviceTypeName": "조명",
        "deviceModelName": "example_device_model_name",
        "customData": {
          "foo": "bar"
        },
        "supportedCapabilities": {
          "powerControl": {},
          "colorControl": {},
          "brightnessControl": {}
        }
      }
    ]
  },
  "context": {
    "session": {
      "id": "example_session_id",
      "accessToken": "example_access_token"
    }
  }
}
```

Related to [BrightnessControl Interface](smarthomecapability/brightnesscontrol-interface.md)

### brightnessDelta

스마트홈 기기에 설정된 밝기를 몇 단계 조절할지에 대한 정보입니다. 해당 정보가 없을 경우 1단계를 조절합니다.

Attribute 사용 예시

```scheme
IncreaseBrightness Directive Control Request 예시 (POST, /nugu/v1/capabilities/{Capability}/directives/{Directive})


{
  "version": 1,
  "requestId": "2019093019f78107f1a36147688c699703f5373a56",
  "action": {
    "command": {
      "smartHomeCapability": "BrightnessControl",
      "smartHomeDirective": "IncreaseBrightness",
      "parameters": {
        "brightnessDelta": 3
      }
    },
    "smartHomeDevices": [
      {
        "id": "123456",
        "deviceTypeCode": "LIGHT",
        "friendlyName": "거실",
        "deviceTypeName": "조명",
        "deviceModelName": "example_model_name",
        "customData": {
            "foo": "bar"
        },
        "supportedCapabilities": {
          "powerControl": {},
          "colorControl": {},
          "brightnessControl": {}
        }
      }
    ]
  },
  "context": {
    "session": {
      "id": "example_session_id",
      "accessToken": "example_access_token",
      "userIdentifier": "example_"
    }
  }
}
```

Related to [BrightnessControl Interface](smarthomecapability/brightnesscontrol-interface.md)

### colorType

스마트홈 기기에 설정하고자 하는 색상 정보입니다. RGB 값으로 색 정보를 표현합니다.

| 색상 | 영문코 | 권장 RGB 코드 |
| :--- | :--- | :--- |
| 파란색 | BLUE | \#0000ff |
| 녹색 | GREEN | \#00ff00 |
| 청록색 | CYAN | \#00ffff |
| 민트색 | MINT | \#4affee |
| 하늘색 | SKY\_BLUE | \#94e1ff |
| 보라색 | PURPLE | \#ab23ff |
| 라벤더색 | LAVENDER | \#eaebff |
| 쿨 화이트 | COOL\_WHITE | \#f5f3ff |
| 살색 | SALMON | \#fe8374 |
| 금색 | GOLD | \#fed500 |
| 빨간색 | RED | \#ff0000 |
| 자홍색 | MAGENTA | \#ff00ff |
| 진홍색 | CRIMSON | \#ff1846 |
| 웜 화이트 | WARM\_WHITE | \#ff952b |
| 오렌지색 | ORANGE | \#ffa600 |
| 아이보리색 | SOFTWHITE | \#ffaa57 |
| 핑크색 | PINK | \#ffbfcc |
| 화이트 | WHITE | \#ffd0a4 |
| 주광색 | DAY\_LIGHT | \#ffecde |
| 노란색 | YELLOW | \#ffff00 |
| 터키색 | TURQUOISE | \#4affef |
| 연보라 | LIGHT\_PURPLE | \#eaebfe |

Attribute 사용 예시

```scheme
ChangeColor Directive Request 예시 (POST, /nugu/v1/capabilities/ColorControl/directives/ChangeColor)


{
   "version":1,
   "requestId":"20190930213631c172b5214d4abfdbeb5804d8d80d",
   "action":{
      "command":{
         "smartHomeCapability":"ColorControl",
         "smartHomeDirective":"ChangeColor",
         "parameters":{
            "colorType":"#ffff00"
         }
      },
      "smartHomeDevices":[
         {
            "id":"12345",
            "deviceTypeCode":"LIGHT",
            "friendlyName":"거실",
            "deviceTypeName":"조명",
            "deviceModelName":"example_device_model_name",
            "customData":{
               "foo":"bar"
            },
            "supportedCapabilities":{
               "powerControl":{},
               "colorControl":{},
               "colorControl": {
                   "supportedColorTypes" : [
                       "BLUE",
                       "GREEN",
                       "CYAN",
                       "MINT",
                       "SKYBLUE",
                       "PURPLE",
                       "LAVENDER",
                       "COOL_WHITE",
                       "SALMON",
                       "GOLD",
                       "RED",
                       "MAGENTA",
                       "CRIMSON",
                       "WARM_WHITE",
                       "ORANGE",
                       "SOFTWHITE",
                       "PINK",
                       "WHITE",
                       "DAY_LIGHT",
                       "YELLOW",
                       "TURQUOISE",
                       "LIGHT_PURPLE"
                       ]  // 지원 가능한 ColorType 타입 참고.
                  },
               "brightnessControl":{}
            }
         }
      ]
   },
   "context":{
      "session":{
         "id":"example_session_id",
         "accessToken":"example_access_token"
      }
   }
}
```

Related to [ColorControl Interface](smarthomecapability/colorcontrol-interface.md)

### deviceTemperatureLevel

스마트홈 기기 자체에 설정하고자 하는 온도 정보입니다. 냉장고, 오븐 등과 같이 스마트홈 기기가 자체 온도를 가질 경우를 지원합니다.

Attribute 사용 예시

```scheme
SetDeviceTemperatureLevel Directive Request 예시 (POST, /nugu/v1/capabilities/{Capability}/directives/{Directive})


{
    "version": 1,
    "requestId": "2019071712638a4378649347bdb21643127a0f6d83",
    "action": {
        "command": {
          "smartHomeCapability": "DeviceTemperatureControl",
          "smartHomeDirective": "SetDeviceTemperature",
          "parameters":{
              "temperatureLevel": "120.0"
          }
        },
        "smartHomeDevices": [
          {
           "id":"12345678",
           "deviceTypeCode":"OVEN",
           "deviceModelName":"example oven",
           "friendlyName":"조리실",
           "deviceTypeName":"오븐",
           "customData":{
              "foo": "bar"
           }
        ]
    },
    "context": {
        "session": {
            "id": "example_session_id",
            "accessToken": "example_access_token"
        }
    }
}
```

Related to [DeviceTemperatureControl Interface](smarthomecapability/devicetemperaturecontrol-interface.md)

### humidityLevel

스마트홈 기기에 설정하고자 하는 습도 정보입니다. 백분율 단위로 표현합니다.

Attribute 사용 예시

```scheme
SetHumidity Directive Request 예시 (POST, /nugu/v1/capabilities/HumidityControl/directives/SetHumidity)


{
  "version": 1,
  "requestId": "20190916109ad8219c251742859c56f6ec3c4700bb",
  "action": {
    "command": {
      "smartHomeCapability": "HumidityControl",
      "smartHomeDirective": "SetHumidity",
      "parameters": {
        "humidityLevel": "40"
      }
    },
    "smartHomeDevices": [
      {
        "id": "D1234567",
        "type": "DEHUMIDIFICATION",
        "modelName": "example dehumidification",
        "friendlyNameSuggestion": "거실",
        "manufacturer": "example manufacturer",
        "supportedCapabilities": {
          "humidityControl": {}
        },
        "customData": {
          "foo": "bar"
        }
      }
    ]
  },
  "context": {
    "session": {
      "id": "example_session_id",
      "accessToken": "example_access_token"
    }
  }
}
```

Related to [HumidityControl Interface](smarthomecapability/humiditycontrol-interface.md)

### humidityDelta

스마트홈 기기에 설정된 습도를 몇 % 조절할지에 대한 정보입니다. 백분율 단위로 표현합니다.

Attribute 사용 예시

```scheme
IncreaseHumidity Directive Request 예시 (POST, /nugu/v1/capabilities/HumidityControl/directives/IncreaseHumidity)


{
  "version": 1,
  "requestId": "20190916109ad8219c251742859c56f6ec3c4700bb",
  "action": {
    "command": {
      "smartHomeCapability": "HumidityControl",
      "smartHomeDirective": "IncreaseHumidity",
      "parameters": {
        "humidityDelta": "10"
      }
    },
    "smartHomeDevices": [
      {
        "id": "D1234567",
        "type": "DEHUMIDIFICATION",
        "modelName": "example dehumidification",
        "friendlyNameSuggestion": "거실",
        "manufacturer": "example manufacturer",
        "supportedCapabilities": {
          "humidityControl": {}
        },
        "customData": {
          "foo": "bar"
        }
      }
    ]
  },
  "context": {
    "session": {
      "id": "example_session_id",
      "accessToken": "example_access_token"
    }
  }
}
```

Related to [HumidityControl Interface](smarthomecapability/humiditycontrol-interface.md)

### mode

스마트홈 기기를 특정 모드로 설정하고자 할 때 제어 대상 스마트홈 기기에 설정할 모드 정보입니다. NUGU스마트홈에서 지원하는 SmartHomeDeviceType별 모드 정보는 아래와 같습니다.

| MODE | Code |
| :--- | :--- |
| 냉방모드 | COLD |
| 난방모드 | HEAT |
| 제습모드 | DEHUMIDITY |
| 송풍모드 | AIR\_BLAST |
| 쾌적모드 | COMFORT |
| 쾌적뽀송모드 | COMFORT\_SOFT |
| 스마트쾌적모드 | SMART\_COMFORT |
| 둘레바람모드 | INDIRECT\_WIND |
| 아기모드 | BABY |
| 자동모드 | AUTO |
| 아로마모드 | AROMA |
| 절전모드 | ENERGY\_SAVING |
| 실내난방모드 | HEAT\_ROOM |
| 외출모드 | OUTSIDE |
| 온수전용모드 | HOTWATER\_ONLY |
| 온돌난방모드 | HEAT\_FLOOR |
| 수동모드 | HAND |
| 급속모드 | RAPIDITY |
| 황사모드 | YELLOW\_DUST |
| 취침모드 | SLEEP |
| 청정모드 | CLEAN |
| 정음모드 | SILENT |
| 저소음모드 | LOW\_NOISE |
| 가습청정모드 | HUMIDIFICATION\_AIR\_CLEAN |
| 순환청정모드 | CIRCULAR\_AIR\_CLEAN |
| 베이비케어모드 | BABY\_CARE |
| 듀얼청정모드 | DUAL\_AIR\_CLEAN |
| 공부모드 | STUDY |
| 터보모 | TURBO |
| 에어워셔모드 | AIR\_WASHER |
| HEPA에어워셔모드 | HEPA\_AIR\_WASHER |
| 공기청정모드 | AIR\_CLEAN |
| 포시즌모드 | FOUR\_SEASON |
| 쾌적제습모드 | COMPORT\_DEHUMIDIFICATION |
| 빨래건조모드 | WASHING\_DRY |
| 쾌면모드 | SLEEP |
| 자동제습모드 | AUTO\_DEHUMIDIFICATION |
| 수동제습모드 | HAND\_DEHUMIDIFICATION |
| 의류건조모드 | CLOTHES\_DRY |
| 신발건조모드 | SHOES\_DRY |
| 정숙모드 | QUIET |
| 연속제습모드 | CONTINUITY\_DEHUMIDIFICATION |
| 연속모드 | CONTINUITY |
| 정숙연속모드 | QUIET\_CONTINUITY |
| 급속냉동모드 | RAPID\_FREEZE |
| 특급모드 | EXPRESS |
| 스마트파워모드 | SMART\_POWER |
| 차일드락모드 | CHILD\_LOCK |
| 음소거모드 | MUTE |
| 반복예약난방모드 | REPEAT\_BOOKING\_HEAT |
| 온수모드 | HOTWATER |
| 자동무풍모드 | AUTO\_NOWIND |
| 24시간 예약난방모드 | 24\_PREHEATING |
| 냉방PMV모드 | COOLING\_PMV |
| 쾌속모드 | FAST |
| 스마트 모드 | SMART |

Attribute 사용 예시

```scheme
SetMode Directive Request 예시 (POST, /nugu/v1/capabilities/ModeControl/directives/SetMode)


{
  "version": 1,
  "requestId": "20190916109ad8219c251742859c56f6ec3c4700bb",
  "action": {
    "command": {
      "smartHomeCapability": "ModeControl",
      "smartHomeDirective": "SetMode",
      "parameters": {
        "mode": "COLD"
      }
    },
    "smartHomeDevices": [
      {
        "id": "1234567",
        "deviceTypeCode": "AIR_CONDITIONER",
        "deviceTypeName": "에어컨",
        "deviceModelName": "example air_conditioner",
        "friendlyName": "거실",
        "manufacturer": "example manufacturer",
        "supportedCapabilities": {
          "modeControl": {
            "supportedModes": [
              "COLD",
              "DEHUMIDITY",
              "COMFORT",
              "AIR_BLAST",
              "ENERGY_SAVING"
            ]
          }
        },
        "customData": {
          "foo": "bar"
        }
      }
    ]
  },
  "context": {
    "session": {
      "id": "example_session_id",
      "accessToken": "example_access_token"
    }
  }
}
```

Related to [ModeControl Interface](smarthomecapability/modecontrol-interface.md)

### temperatureLevel

스마트홈 기기에 설정하고자 하는 주변 온도 정보입니다. 섭씨 온도 단위를 지원합니다.

Attribute 사용 예시

```scheme
SetTemperature Directive Request 예시 (POST, /nugu/v1/capabilities/TemperatureControl/directives/SetTemperature)


{
  "version": 1,
  "requestId": "20190916109ad8219c251742859c56f6ec3c4700bb",
  "action": {
    "command": {
      "smartHomeCapability": "TemperatureControl",
      "smartHomeDirective": "SetTemperature",
      "parameters": {
          "temperatureLevel": "20"
      }
    },
    "smartHomeDevices": [
      {
        "id": "1234567",
        "deviceTypeCode": "AIR_CONDITIONER",
        "deviceTypeName": "에어컨",
        "deviceModelName": "example air_conditioner",
        "friendlyName": "거실",
        "manufacturer": "example manufacturer",
        "supportedCapabilities": {
          "temperatureControl": {}
        },
        "customData": {
          "foo": "bar"
        },
        "connectionStatus": true
      }
    ]
  },
  "context": {
    "session": {
      "id": "example_session_id",
      "accessToken": "example_access_token"
    }
  }
}
```

Related to [TemperatureControl Interface](smarthomecapability/temperaturecontrol-interface.md)

### temperatureDelta

스마트홈 기기의 설정된 온도를 조절하기 위한 단위 표현입니다. 섭씨 온도 단위를 지원합니다.

Attribute 사용 예시

```scheme
IncreaseTemperature Directive Request 예시 (POST, /nugu/v1/capabilities/TemperatureControl/directives/IncreaseTemperature)


{
  "version": 1,
  "requestId": "20190916109ad8219c251742859c56f6ec3c4700bb",
  "action": {
    "command": {
      "smartHomeCapability": "TemperatureControl",
      "smartHomeDirective": "IncreaseTemperature",
      "parameters": {
          "temperatureDelta": "3"
      }
    },
    "smartHomeDevices": [
      {
        "id": "1234567",
        "deviceTypeCode": "AIR_CONDITIONER",
        "deviceTypeName": "에어컨",
        "deviceModelName": "example air_conditioner",
        "friendlyName": "거실",
        "manufacturer": "example manufacturer",
        "supportedCapabilities": {
          "temperatureControl": {}
        },
        "customData": {
          "foo": "bar"
        },
        "connectionStatus": true
      }
    ]
  },
  "context": {
    "session": {
      "id": "example_session_id",
      "accessToken": "example_access_token"
    }
  }
}
```

Related to [TemperatureControl Interface](smarthomecapability/temperaturecontrol-interface.md)

