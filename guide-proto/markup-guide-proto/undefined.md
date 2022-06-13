# 구성 컴포넌트

각 구성요소는 HTML 요소를 변경하지 못하는 경우이 변경이 가능한 경우로 나눌 수 있습니다. 때문에 변경이 불가능한 경우 tag를 기준으로 스타일이 나와야 하며, 변경이 가능한 경우(템플릿 코드가 존재하는 경우 HTML, 스타일이 함께 나와야 합니다

### Title 영역

Title 영역은 본문의 최상단에 위치하며, 본문 제목, 설명으로 구성됩니다. 기본구성의 header.html 페이지를 참조하세요

### 본문 영역

#### 문단 제목

문단 제목은 6level로 구성되어 있으며, 각각은 크기가 다릅니다. 다만 gitbook의 경우 3level이후부터는 동일한 크기로 표현됩니다. 또한 좌측 영역에 복사 아이콘이 포함되어 있습니다.

아래는 기본적으로 지원하는 제목 영역입니다. 각각의 태그는 변경이 불가능하며 class 매핑또한 불가능합니다.

{% tabs %}
{% tab title="markdown" %}
```markdown
#
##
###
####
#####
######
```
{% endtab %}

{% tab title="HTML" %}
```html
<h1>#</h1>
<h2>##</h2>
<h3>###</h3>
<h4>####</h4>
<h5>#####</h5>
<h6>#####</h6>
```
{% endtab %}
{% endtabs %}

#### 문단 본문

문단 본문은 일반적으로 텍스트로 구성되며, 각각의 분단 본문은 `<p></p>` 로 감싸 있습니다. 각각의 태그는 변경이 불가능하며 class 매핑또한 불가능합니다.

#### 리스트

리스트는 `<ol>`, `<li>`로 구성됩니다. 각각의 태그는 변경이 불가능하며 class 매핑또한 불가능합니다.

#### 인용

인용은 `<blockquote>` 로 구성됩니다. 각각의 태그는 변경이 불가능하며 class 매핑또한 불가능합니다.

#### 테이블

테이블은 `<table>`, `<thread>`, `<th>`, `<tbody>`, `<td>` 로 구성됩니다.  각각의 태그는 변경이 불가능하며 class 매핑또한 불가능합니다.

#### 이미지

이미지는 `<img>` 로 구성되며 다른 영역을 추가하거나 삭제할 수 없습니다. 테이블, 문단본문에 있을 경우 최대 height 로서 제한된 사이즈로 노출됩니다

#### 수식

수식은 별도 플러그인으로 사용되며 내부 컨텐츠를 조작하거나 편집할 수 없습니다

#### 구분선

`<hr>` 태그로 구성됩니다.

#### Youtube

`iframe.media` 로 구성됩니다

{% hint style="info" %}
이하 구성요소의 경우 일부 HTML 요소의 편집이 가능합니다.
{% endhint %}

#### 링크

외부 링크를 표현하며, 아래와 같은 템플릿으로 구성되어 있습니다.

```html
<div class="pagination">
    <a class="left" href="{{ link_url }}">
        <div class="block left">
            <div class="thumb"></div>
            <div class="content">
                <div class="title">{{ link_title }}</div>
                <div class="description">{{ link_description }}</div>
            </div>
        </div>
    </a>
</div>
```

#### 코드블럭

코드블럭내의 코드 요소는 HTML요소를 바꿀 수 없으며 [https://github.com/rouge-ruby/rouge](https://github.com/rouge-ruby/rouge) 플러그인을 통해 theme를 결정할 수 있습니다 \<table> 로 구성되며 syntax 별로 커스터마이징이 가능합니다

코드 요소를 감싸고 있는 템플릿은 아래와 같습니다

```html
<div class="code">
    <div class="code_title">{{ code_title }}</div>
    <div class="code_body">{{ code_body }}</div>
</div>

```

#### 내부페이지 링크

외부 링크를 표현하며, 외부 링크와 동일한 템플릿으로 구성되어 있습니다.

#### 힌트

중요사항을 표현하며 아래와 같은 템플릿으로 구성되어 있습니다

```html
<div class="alerts {{ alert_style }}">
    {{ alert_body }}
</div>
```

#### 확장

현재 사용되고 있지는 않으나 향후 필요한 요소입니다. 아래의 템플릿으로 구성되어 있습니다

```html
<div class="expand">
    <div class="expand_title">{{ expand_title }}</div>
    <div class="expand_body">{{ expand_body }}</div>
</div>

```

#### API

API 를 설명하는 block으로 아래와 같은 템플릿으로 구성되어 있습니다.

```html
<div class="api">
    <div class="api_summary">{{ api_summary }}</div>
    <div class="api_header">
        <div class="api_method">{{ api_method }}</div>
        <div class="api_url">{{ api_base_url }}{{ api_path }}</div>
    </div>
    <div class="api_description">
        {{ api_description }}
    </div>
    <div class="api_parameter_title">Parameters</div>
    {% raw %}
{% if api_query_parameters %}
        <div class="api_parameter_category_title">Query</div>
        <div class="api_parameters">
            <div class="api_parameter">
                <div class="api_parameter_name">{{ api_request_name }}</div>
                <div class="api_parameter_type">{{ api_request_type }}</div>
                <div class="api_parameter_description">{{ api_request_description }}</div>
            </div>
        </div>
    {% endif %}
    {% if api_body_parameters %}
        <div class="api_parameter_category_title">Body</div>
        <div class="api_parameters">
            <div class="api_parameter">
                <div class="api_parameter_name">{{ api_request_name }}</div>
                <div class="api_parameter_type">{{ api_request_type }}</div>
                <div class="api_parameter_description">{{ api_request_description }}</div>
            </div>
        </div>
    {% endif %}
{% endraw %}
    <div class="api_response_title">Responses</div>
    <div class="api_responses">
        <div class="api_response">
            <div class="api_response_header">
                <div class="api_response_status">{{ api_response_status }}</div>
                <div class="api_response_description">{{ api_response_description }}</div>
            </div>
            <div class="api_response_body">
                {{ api_response_body }}
            </div>
        </div>
    </div>
</div>
```

#### 파일

파일다운로드를 표현하며, 아래와 같은 템플릿으로 구성되어 있습니다

```html
<div class="pagination">
    <a class="left" href="{{ file_src }}" target="_blank">
        <div class="block left">
            <div class="thumb"></div>
            <div class="content">
                <div class="title">{{ file_caption }}</div>
            </div>
        </div>
    </a>
</div>
```

#### Navigation 영역

페이지 하단에 이전 다음 페이지를 표현하며 아래와 같은 템플릿으로 구성되어 있습니다. 구성요소 pagiantion.html을 참고하세요

#### 좌측 메뉴 영역

\<ul>, \<li> 의 반복으로 구성되어 있으며 아래와 같은 템플릿으로 구성되어 있습니다.

```html
<ul class="nav_menu">
    {% raw %}
{% for page in pages %}
        <li>
            <div class="nav_link fold {% if page.potion.has_child? %} has_child {% endif %}">
                <a href="{{ page.url }}" class="nav_href">{{ page.title }}</a>
                <span class="nav_unfold">+</span>
                <span class="nav_fold">-</span>
            </div>
            <!-- <ul class="nav_menu"> 반복 -->
        </li>
    {% endfor %}
{% endraw %}
</ul>

```

### 빈 본문 영역

페이지가 비워져 있을 경우 노출되며 하위 페이지 목록이 노출됩니다 구성요소 empty.html 페이지를 참고하세요
