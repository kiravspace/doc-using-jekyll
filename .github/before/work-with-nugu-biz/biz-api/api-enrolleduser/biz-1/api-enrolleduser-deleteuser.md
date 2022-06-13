# Biz 사용자 삭제

등록된 사용자를 삭제하는 기능입니다.

## 1. URL <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xC0AD;&#xC81C;v1-1.URL"></a>

```text
[DELETE] https://biz-api.sktnugu.com/api/v1/enrolledUser/user/{userId}
```

## 2. Request <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xC0AD;&#xC81C;v1-2.Request"></a>

| 이름 | 유형 | 필수 | 설명 |
| :--- | :--- | :--- | :--- |
| Publisher-Token | Header | Y | 퍼블리셔가 보유한 토큰 |
| userId | path | Y | 삭제하고자 하는 사용자 ID |

## 3. Response <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xC0AD;&#xC81C;v1-3.Response"></a>

### 3.1 HTTP Status <a id="Biz&#xC0AC;&#xC6A9;&#xC790;&#xC0AD;&#xC81C;v1-3.1HTTPStatus"></a>

| HTTP Status | 설명 |
| :--- | :--- |
| 204 | 정상 삭제시 응답 |
| 403 | 퍼블리셔 API Token이 유효하지 않거나, 유효하지 않은 자원에 접근할 경우 리턴 |
| 404 | 삭제대상 사용자를 찾을 수 없을 때 응답 |

