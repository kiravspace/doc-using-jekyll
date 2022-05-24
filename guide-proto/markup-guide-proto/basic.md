# 기본구성

기본적으로 전체 페이지는 구분이 가능한 명확한 영역을 가지도록 구성해야 합니다. Jekyll은 liquid include 기능을 이용해 페이지를 쪼갤 수 있는데, 각 영역은 envelop된 태그 영역으로 구성하는 것이 좋습니다.

prototype은 아래와 같은 구성으로 되어 있습니다.

{% code title="default.html" %}
{% raw %}
```HTML
<!doctype html>
<html lang="en">
<head>
    {% include head.html %}
</head>
<body>
{% include header.html %}
<section>
    <div class="container">
        <div style="width:20%;float:left;">
            {{ site.data.meta.render }}
        </div>
        <div id="content" style="width:80%;float:left;">{% include content.html %}</div>
    </div>
</section>
{% include footer.html %}
</body>
</html>
```
{% endraw %}
{% endcode %}
