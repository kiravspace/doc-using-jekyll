---
depth_order: 3
---

# Biz 사용자 그룹별 Announcement 전송

등록된 Biz 사용자의 그룹 토큰을 기준으로, Biz 사용자가 수신 지정한 디바이스에 Announcement API를 발송 할 수 있습니다.

## 1. URL

{% code %}
```
[POST] https://biz-api.sktnugu.com/api/v1/enrolledUser/group/{groupApiToken}/announcement?callBack={callBackUrl}
```
{% endcode %}

## 2. Request <a href="#biz-announcement-v1-2request" id="biz-announcement-v1-2request"></a>

### 2.1 Body <a href="#biz-announcement-v1-2.1body" id="biz-announcement-v1-2.1body"></a>

{% code %}
```json
{
    "playServiceId": "XXX",
    "tts": {
        "text": "발송 내용",
        "speed": "100",
        "pause1": "600",
        "pause2": "300"
    },
    "display" : {
        "type": "imageText2",
        "title": "타이틀",
        "header": "헤더",
        "body": "본문",
        "footer": "부가설명",
        "image": "http://imageUrl",
        "grammarGuide": ["발화문1", "발화문2"]
    }
}
```
{% endcode %}

### 2.2 설명 <a href="#biz-announcement-v1-2.2" id="biz-announcement-v1-2.2"></a>

| 이름                   | 유형     | 속성              | 필수 | 설명                                                                                                                        |
| -------------------- | ------ | --------------- | -- | ------------------------------------------------------------------------------------------------------------------------- |
| Publisher-Token      | Header | string          | Y  | 퍼블리셔가 보유한 토큰                                                                                                              |
| groupApiToken        | path   | string          | Y  | 발송할 그룹의 API 토큰                                                                                                            |
| playServiceId        | body   | string          | Y  | <p>발송 대상 play<br>대상 play의 합성음, TTS Domain을 기준으로 SKML을 생성</p>                                                              |
| tts                  | body   | object          |    | TTS를 구성하는 객체                                                                                                              |
| tts.text             | body   | string          | Y  | <p>발화문장<br>발화문장, Display 객체 중 반드시 1개 이상은 존재해야 한다.</p>                                                                     |
| tts.speed            | body   | string          |    | <p>발화속도<br>85, 90... 120까지의 5단위 값<br>기본값은 100</p>                                                                         |
| tts.pause1           | body   | string          |    | <p>문장 사이 묵음 구간 길이<br>300, 400... 900까지의 100단위 값<br>기본값은 600</p>                                                           |
| tts.pause2           | body   | string          |    | <p>100, 200... 500까지의 100단위 값<br>기본값은 300</p>                                                                             |
| display              | body   | object          | Y  | <p>Display 객체<br>발화문장, Display 객체 중 반드시 1개 이상은 존재해야 한다.</p>                                                               |
| display.type         | body   | string          | Y  | <p>사용할 Display Template<br>FullText1, ImageText2중 하나</p>                                                                  |
| display.title        | body   | string          | Y  | 화면 타이틀                                                                                                                    |
| display.header       | body   | string          | Y  | 본문 제목                                                                                                                     |
| display.body         | body   | string          | Y  | 본문 내용                                                                                                                     |
| display.footer       | body   | string          |    | 본문 부가 설명                                                                                                                  |
| display.image        | body   | string          |    | <p>이미지<br>ImageText Type에서 이미지가 없을 경우, 디폴트 이미지 노출<br><img src="/assets/images/img_notification.png" alt=""></p> |
| display.grammarGuide | body   | array of string |    | 가이드 발화문                                                                                                                   |

## 3. Response <a href="#biz-announcement-v1-3response" id="biz-announcement-v1-3response"></a>

### 3.1 HTTP Status <a href="#biz-announcement-v1-3.1httpstatus" id="biz-announcement-v1-3.1httpstatus"></a>

| HTTP Status | errorCode | 설명                                              |
| ----------- | --------- | ----------------------------------------------- |
| 202         |           | 정상 요청                                           |
| 403         |           | 퍼블리셔 API Token이 유효하지 않거나, 유효하지 않은 자원에 접근할 경우 리턴 |
| 404         |           | 발송 요청한 그룹이 존재하지 않을 때 응답값                        |
| 400         | V1ANN001  | body 값을 파싱할 수 없음                                |
| 400         | V1ANN002  | playServiceId 없음                                |
| 400         | V1ANN101  | tts 객체가 모두 존재하지 않음                              |
| 400         | V1ANN102  | tts.text 없음                                     |
| 400         | V1ANN103  | tts.speed 값이 잘못됨                                |
| 400         | V1ANN104  | tts.pause1 값이 잘못됨                               |
| 400         | V1ANN105  | tts.pause2 값이 잘못됨                               |
| 400         | V1ANN201  | display.type 값이 잘못됨                             |
| 400         | V1ANN202  | display.title 값이 없음                             |
| 400         | V1ANN203  | display.header 값이 없음                            |
| 400         | V1ANN204  | display.body 값이 없음                              |
| 400         | V1ANN204  | 허용되지 않는 playServiceId                           |

### 3.2 Body <a href="#id-announcement-v1-3.2body" id="id-announcement-v1-3.2body"></a>

* callback URL을 입력했을 경우에만 전달받음

{% code %}
```json
{
    "users": [
        {
            "id": "XXX",
            "name": "XXX",
            "email": "XXX",
            "resultCode": "OK",
            "deviceResults": [
                {"code": "XXX"}
            ]
        }
    ]
}
```
{% endcode %}

### 3.3 설명 <a href="#id-announcement-v1-3.3" id="id-announcement-v1-3.3"></a>

| 이름                             | 속성              | 설명                                                                                                                                                                                                                                        |
| ------------------------------ | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| users                          | array of object | 발송 요청 그룹내 사용자들의 발송 결과                                                                                                                                                                                                                     |
| users\[].id                    | string          | 발송 대상 Biz 사용자 ID                                                                                                                                                                                                                          |
| users\[].name                  | string          | 발송 대상 Biz 사용자 이름                                                                                                                                                                                                                          |
| users\[].email                 | string          | 발송 대상 Biz 사용자 이메일                                                                                                                                                                                                                         |
| users\[].resultCode            | enum            | <p>발송 결과</p><p>OK : 발송 대상 기기 모두 성공</p><p>SOME_OK : 발송 대상 기기 일부 성공</p><p>FAIL : 발송 대상 기기 모두 실패</p><p>NOT_AGREE : API 수신 거부</p><p>NO_DEVICE : API 수신 허용 기기 없음</p>                                                                           |
| users\[].deviceResults         | array of object | 기기별 응답값                                                                                                                                                                                                                                   |
| users\[].deviceResults\[].code | enum            | <p>기기별 발송 결과</p><p>OK : 발송 성공</p><p>NOT_CONNECTED : 사용자에 연결되지 않은 기기</p><p>TIMEOUT : 기기와의 연결 실패</p><p>CONNECT<em>ERROR : 기기가 꺼져 있거나, 네트워크에 문제가 있음</em><br><em></em>NOT<em>_</em>SUPPORTED : 지원하지 않는 기기<br>ERROR : 알 수 없는 에러(개발팀 문의 필요)</p> |