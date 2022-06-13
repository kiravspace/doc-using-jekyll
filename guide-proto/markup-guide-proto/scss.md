# SCSS

Jekyll은 기본적으로 SCSS를 지원합니다 일반 CSS를 지원하기는 하지만 되도록 SCSS로 작업하는 것을 권장합니다

기본 theme는 아래와 같습니다

```css
nav {
  width: 20%;
  float: left;
  background-color: white;

  div.nav_container {
    width: 95%;

    ul.nav_menu {
      display: block;
      margin-inline-start: 0;
      margin-inline-end: 0;
      padding-inline-start: 0;
      width: 100%;
    }

    li {
      display: block;
      padding-inline-start: 15px;

      div.nav_link {
        display: flex;
        padding-top: 0.2em;
        padding-bottom: 0.2em;
        padding-left: 0.3em;
        color: black;

        &:hover {
          background-color: gray;
          color: white;
        }

        a.nav_href {
          flex: auto;
          width: 90%;
          color: inherit;
          text-decoration: none;
        }

        span.nav_unfold {
          flex: auto;
          display: none;
          color: inherit;

          &:hover {
            cursor: pointer;
          }
        }

        span.nav_fold {
          flex: auto;
          display: none;
          color: inherit;

          &:hover {
            cursor: pointer;
          }
        }

        &.has_child {
          span.nav_unfold {
            display: none;
          }

          span.nav_fold {
            display: block;
          }

          + ul.nav_menu {
            display: block;
          }

          &.fold {
            span.nav_unfold {
              display: block;
            }

            span.nav_fold {
              display: none;
            }

            + ul.nav_menu {
              display: none;
            }
          }
        }

        &.selected {
          background-color: lightgray;
          border-top: 1px solid lightgray;
          border-bottom: 1px solid lightgray;
          color: blue;
        }
      }
    }
  }
}

section {
  width: 80%;
  float: left;

  div.container {
    table:not(.rouge-table) {
      display: table;
      width: 95%;
      margin: auto;
      border-collapse: collapse;
      color: black;

      tr {
        border-top: 1px solid lightgray;
        border-bottom: 1px solid lightgray;
      }

      thead {
        tr {
          background-color: #cccccc;

          th {
            height: 2em;
            padding: 0.5em;
          }
        }
      }

      tbody {
        tr {
          td {
            height: 2em;
            padding: 0.5em;
          }
        }
      }
    }

    %boxed {
      display: block;
      margin: 2px;

      img {
        width: auto;
        height: 6em;
      }
    }

    %bordered_boxed {
      @extend %boxed;
      border: 1px solid lightgray;
    }

    %clicked_boxed {
      @extend %bordered_boxed;

      &:hover {
        border-color: dimgray;
      }
    }

    .block {
      @extend %clicked_boxed;
      margin: 0.2em;
      width: calc(100% - (0.2em * 2));
      height: 4em;
      float: left;
      color: black;

      &.left {
        .thumb {
          float: left;
        }

        .content {
          text-align: left;
          float: right;
        }
      }

      &.right {
        .thumb {
          float: right;
        }

        .content {
          text-align: right;
          float: left;
        }
      }

      .thumb {
        padding: 0.2em;
        width: calc(4em - (0.2em *2));
        height: calc(100% - (0.2em *2));
        float: left;
      }

      .content {
        @extend %boxed;
        margin: 0;
        padding: 0.2em;

        width: calc(100% - 4em - (0.2em *2));
        height: calc(100% - (0.2em *2));
        float: right;

        div.title {
          font-weight: bold;
        }
      }
    }

    div.pagination {
      @extend %boxed;

      a {
        float: left;
        width: calc(100% / 2);
      }

      a:first-child:nth-last-child(1) {
        width: 100%;
      }
    }

    div.alerts {
      @extend %bordered_boxed;
      margin: 0.2em;
      width: calc(100% - (0.2em * 2));

      position: relative;
      padding-top: 0.5em;
      padding-bottom: 0.5em;
      padding-left: 0.8em;

      &::before {
        content: ' ';
        position: absolute;
        top: 0;
        left: 0;
        width: 0.3em;
        height: 100%;
      }

      &.info::before {
        background-color: lawngreen;
      }

      &.warning::before {
        background-color: orange;
      }

      &.danger::before {
        background-color: red;
      }

      &.success::before {
        background-color: dodgerblue;
      }
    }

    .media {
      display: block;
      width: 90%;
      margin: auto;
    }

    img {
      display: block;
      width: 90%;
      height: auto;
      margin: auto;
    }

    div.code {
      margin: 0 2em;
      overflow: auto;
    }

    div.api {
      @extend %bordered_boxed;
      margin-top: 3em;

      div.api_header {
        display: flex;
        padding: 1em;

        div.api_method {
          flex: auto;
          max-width: 10%;
        }

        div.api_url {
          flex: auto;
          max-width: 90%;
        }
      }

      div.api_summary {
        font-weight: bold;
        padding: 1em;
        background-color: #f0f0f0;
      }

      div.api_parameter_title, div.api_response_title {
        font-weight: bold;
        padding: 0.5em 1em;
      }

      div.api_description {
        padding: 1em;
        border-bottom: 1px solid lightgray;
      }

      div.api_parameter_category_title {
        padding: 1em;
      }

      div.api_parameters {
        padding: 0.5em 1em;

        div.api_parameter {
          display: flex;
          padding: 0.5em;
          border-bottom: 1px solid lightgray;

          &:hover {
            background-color: #f0f0f0;
            cursor: pointer;
          }

          div.api_parameter_name {
            flex: auto;
            max-width: 15%;
          }

          div.api_parameter_description {
            flex: auto;
            max-width: 85%;
          }
        }
      }

      div.api_response {
        padding: 0.5em 1em;

        div.api_response_header {
          display: flex;
          padding: 0.5em;

          div.api_response_status {
            flex: auto;
            max-width: 15%;
          }

          div.api_response_description {
            flex: auto;
            max-width: 85%;
          }
        }

        div.api_response_body {
          border: 1px solid lightgray;

          .code {
            margin: 0 0.5em;
          }
        }
      }
    }

    .tabs {
      @extend %boxed;
      display: block;

      ul {
        display: flex;
        padding: 0;
        margin: 0;

        li.tab_title {
          display: block;
          padding: 0.3em 2em;
          border: 1px solid lightgray;
          border-bottom-style: none;
          margin-inline-end: 0.5em;
          text-align: center;

          &.selected {
            background-color: #f0f0f0;
          }

          &:hover {
            cursor: pointer;
          }
        }
      }

      div.tab_content {
        border: 1px solid lightgray;
        padding: 0.5em;
        display: none;

        &.selected {
          display: block;
        }

        .code {
          margin: 0 0.5em;
        }
      }
    }
  }

  .content {
    %box {
      border: 1px solid lightgray;
      width: 95%;
      position: relative;
      margin: 16px auto;
      padding-top: 10px;
      padding-bottom: 10px;
    }

    %default_box {
      @extend %box;
      padding-left: 10px;

      &::before {
        content: ' ';
        position: absolute;
        top: 0;
        left: 0;
        width: 2px;
        height: 100%;
      }
    }
  }
}

footer {
  clear: both;
}
s
```
