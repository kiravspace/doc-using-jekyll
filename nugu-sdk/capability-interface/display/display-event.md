---
depth_order: 2
---

# Display-Event

## ElementSelected

{% code %}
```json
{
  "header": {
    "namespace": "Display",
    "name": "ElementSelected",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.0"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "token": "{{STRING}}"
  }
}
```
{% endcode %}

| parameter | type   | mandatory | description |
|:----------|:-------|:----------|:------------|
| token     | string | **Y**     |             |

## CloseSucceeded

{% code %}
```json
{
  "header": {
    "namespace": "Display",
    "name": "CloseSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.1"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```
{% endcode %}

## CloseFailed

{% code %}
```json
{
  "header": {
    "namespace": "Display",
    "name": "CloseFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.1"
  },
  "payload": {
    "playServiceId": "{{STRING}}"
  }
}
```
{% endcode %}

## ControlFocusSucceeded

{% code %}
```json
{
  "header": {
    "namespace": "Display",
    "name": "ControlFocusSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.4"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "direction": "{{STRING}}"
  }
}
```
{% endcode %}

| parameter | type   | mandatory | description    |
|:----------|:-------|:----------|:---------------|
| direction | string | N         | PREVIOUS, NEXT |

## ControlFocusFailed

{% code %}
```json
{
  "header": {
    "namespace": "Display",
    "name": "ControlFocusFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.4"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "direction": "{{STRING}}"
  }
}
```
{% endcode %}

| parameter | type   | mandatory | description    |
|:----------|:-------|:----------|:---------------|
| direction | string | N         | PREVIOUS, NEXT |

## ControlScrollSucceeded

{% code %}
```json
{
  "header": {
    "namespace": "Display",
    "name": "ControlScrollSucceeded",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.4"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "direction": "{{STRING}}"
  }
}
```
{% endcode %}

| parameter | type   | mandatory | description    |
|:----------|:-------|:----------|:---------------|
| direction | string | N         | PREVIOUS, NEXT |

## ControlScrollFailed

{% code %}
```json
{
  "header": {
    "namespace": "Display",
    "name": "ControlScrollFailed",
    "messageId": "{{STRING}}",
    "dialogRequestId": "{{STRING}}",
    "version": "1.4"
  },
  "payload": {
    "playServiceId": "{{STRING}}",
    "direction": "{{STRING}}"
  }
}
```
{% endcode %}

| parameter | type   | mandatory | description    |
|:----------|:-------|:----------|:---------------|
| direction | string | N         | PREVIOUS, NEXT |

