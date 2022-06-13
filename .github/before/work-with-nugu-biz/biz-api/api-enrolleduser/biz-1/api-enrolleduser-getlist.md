# Biz 사용자 목록 조회

초대되어 퍼블리셔에 등록된 Biz 사용자 목록을 조회하는 기능입니다.

## 1. URL <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xBAA9;&#xB85D;&#xC870;&#xD68C;v1-1.URL"></a>

```text
[GET] https://biz-api.sktnugu.com/api/v1/enrolledUser/user?page=1&pageSize=20
```

## 2. Request <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xBAA9;&#xB85D;&#xC870;&#xD68C;v1-2.Request"></a>

| 이름 | 유형 | 필수 | 설명 |
| :--- | :--- | :--- | :--- |
| Publisher-Token | Header | Y | 퍼블리셔가 보유한 토큰 |
| page | query param |  | default : 1 |
| pageSize | query param |  | default : 20 |

## 3. Response <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xBAA9;&#xB85D;&#xC870;&#xD68C;v1-3.Response"></a>

### 3.1 Http Status <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xBAA9;&#xB85D;&#xC870;&#xD68C;v1-3.1HttpStatus"></a>

| HTTP Status | 설명 |
| :--- | :--- |
| 200 | 정상 응답 |
| 403 | 퍼블리셔 API Token이 유효하지 않을 경우의 응답 |

### 3.2 Body <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xBAA9;&#xB85D;&#xC870;&#xD68C;v1-3.2Body"></a>

```text
{
    "totalPages": 10,
    "totalElements": 100
    "users": [
        {
            "id": "XXX",
            "name": "XXX",
            "email": "XXX",
            "alias": "XXX",
            "phone": "XXX",
            "group": {
                "id": "XXX"
                "name": "XXX"
            },
            "serviceType": "SERVICE",
            "apiAgreeType": "AGREE",
            "authType": "ALL",
            "acceptedDateTime": "2021-0804T16:34:30.388"
        }
    ]
}퍼블리셔가 보유한 Biz 사용자 정보를 조회
```

### 3.3 설명 <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xBAA9;&#xB85D;&#xC870;&#xD68C;v1-3.3&#xC124;&#xBA85;"></a>

| 이름 | 속성 | 설명 |
| :--- | :--- | :--- |
| 이름 | 속성 | 설명 |
| totalPages | int | 총 페이지 갯수 |
| totalElements | long | 총 Biz 사용자 수 |
| users | array of object | Biz 사용자 목록 |
| users\[\].id | string | Biz 사용자 ID |
| users\[\].name | string | Biz 사용자 이름 |
| users\[\].email | string | Biz 사용자 이메일 |
| users\[\].alias | string | Biz 사용자 추가 정보 |
| users\[\].phone | string | Biz 사용자 전화번호 |
| users\[\].group | string | Biz 사용자 소속 그룹 정보 미분류일 경우 null |
| users\[\].group.id | string | Biz 사용자 소속 그룹 ID |
| users\[\].group.name | string | Biz 사용자 소속 그룹 이름 |
| users\[\].serviceType | enum | 사용자 초대 유형 SERVICE : 서비스 PLAY : play |
| users\[\].apiAgreeType | enum | Biz API 수신 동의 유형 ALL : 동의 SOME : 일부 동의 NONE : 미동의 |
| users\[\].authType | enum | 제휴사 인증 여부 유형 ALL : 인증 SOME : 일부 인증 NONE : 미인증 |
| users\[\].acceptedDateTime | string | 초대 승인일\(ISO-8601\) |

