# 기본구성

기본적으로 전체 페이지는 구분이 가능한 명확한 영역을 가지도록 구성해야 합니다. Jekyll은 liquid include 기능을 이용해 페이지를 쪼갤 수 있는데, 각 영역은 envelop된 태그 영역으로 구성하는 것이 좋습니다.

prototype은 아래와 같은 구성으로 되어 있습니다.

{% code title="default.html" %}
```html
<!doctype html>
<html lang="en">
<head>
    {% raw %}
{% include {{ site.data.potion.theme_path }}/head.html %}
</head>
<body>
{% include {{ site.data.potion.theme_path }}/header.html %}
{% include {{ site.data.potion.theme_path }}/navigation.html %}
<section id="section">
    {% include {{ site.data.potion.theme_path }}/container.html %}
</section>
{% include {{ site.data.potion.theme_path }}/footer.html %}
{% endraw %}
</body>
</html>

```
{% endcode %}

{% code title="head.html" %}
```html
<meta charset="utf-8">
<meta content="text/html; charset=utf-8" http-equiv="Content-Type">

{% raw %}
{%- if page.title -%}
<title>{{ page.title | escape }}</title>
{%- else -%}
<title>{{ site.title | escape }}</title>
{%- endif -%}
{% endraw %}

<link rel="stylesheet" href="/assets/css/style.css">
<link rel="stylesheet" href="/assets/css/syntax.css">
<script type="text/javascript" src="/assets/js/jquery-3.6.0.js"></script>
<script type="text/javascript" src="/assets/js/jquery-ui.js"></script>
<script type="text/javascript" src="/assets/js/main.js"></script>

```
{% endcode %}

{% code title="header.html" %}
```html
<header>
    {{ site.data.potion.title }}
</header>

```
{% endcode %}

{% code title="navigation.html" %}
```html
<nav>
    <div class="nav_container">
        {% raw %}
{% assign pages = site.data.potion.pages %}
        {% pages pages="pages" class="nav" %}
{% endraw %}
    </div>
</nav>

```
{% endcode %}

{% code title="container.html" %}
```html
<div id="container" class="container">
    <div class="title">
        <h1>{{ page.title }}</h1>
        {{ page.description }}
    </div>
    <div class="content">
        {{ content | markdownify }}
        {% raw %}
{% include {{ site.data.potion.theme_path }}/empty.html %}
    </div>
    {% include {{ site.data.potion.theme_path }}/pagination.html %}
{% endraw %}
</div>
```
{% endcode %}

{% code title="empty.html" %}
```html
{% raw %}
{% if site.data.potion.is_show_empty_to_child_pages? %}
{% if page.potion.empty_content? %}
<div class="pagination">
    {% for child in page.potion.child_pages %}
    <a class="left" href="{{ child.url }}">
        <div class="block left">
            <div class="thumb"></div>
            <div class="content">
                <div class="title">{{ child.title }}</div>
                <div class="description">{{ child.description }}</div>
            </div>
        </div>
    </a>
    {% endfor %}
</div>
{% endif %}
{% endif %}
{% endraw %}
```
{% endcode %}

{% code title="pagination.html" %}
```html
{% raw %}
{% if site.data.potion.is_show_pagination? %}
<div class="pagination">
    {% if page.potion.has_prev? %}
    <a href="{{ page.potion.prev_page.url }}">
        <div class="block left">
            <div class="thumb"></div>
            <div class="content">
                <div class="title">{{ page.potion.prev_page.title }}</div>
                <div class="description">{{ page.potion.prev_page.description }}</div>
            </div>
        </div>
    </a>
    {% endif %}
    {% if page.potion.has_next? %}
    <a href="{{ page.potion.next_page.url }}">
        <div class="block right">
            <div class="content">
                <div class="title">{{ page.potion.next_page.title }}</div>
                <div class="description">{{ page.potion.next_page.description }}</div>
            </div>
            <div class="thumb"></div>
        </div>
    </a>
    {% endif %}
</div>
{% endif %}
{% endraw %}
```
{% endcode %}

{% code title="footer.html" %}
```html
<footer>
</footer>
```
{% endcode %}
