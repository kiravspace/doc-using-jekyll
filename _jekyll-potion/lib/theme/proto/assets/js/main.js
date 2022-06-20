$(function () {
    let pathname = $(location).attr("pathname").endsWith("/") ?
        $(location).attr("pathname").substring(0, $(location).attr("pathname").length - 1) : $(location).attr("pathname");

    pathname = (pathname === "") ? "/" : pathname;

    let $nav = $("nav > div.nav_container");

    $nav.find("span.nav_unfold").bind("click", function (e) {
        $(this).parent().removeClass("fold");
    });

    $nav.find("span.nav_fold").bind("click", function (e) {
        $(this).parent().addClass("fold");
    });

    $nav.find("a.nav_href").each(function (index, href) {
        let $href = $(href);

        if (pathname === $href.attr("href")) {
            $href.parents("ul.nav_menu").each(function (_, nav_menu) {
                $(nav_menu).children("li").each(function (_, li) {
                    let $li = $(li);

                    if ($li.has($href).length) {
                        $li.children("div.nav_link").removeClass("fold");
                    }
                });
            });
            $href.parent().addClass("selected").addClass("fold");
        }

        $href.bind("click", function (e) {
            let $clicked = $(this);

            e.preventDefault();

            $("#section").load($clicked.attr("href") + " #container", function (html) {
                $(this).scrollTop(0);
                document.title = html.match("<title>(.*?)</title>")[1];

                if (typeof (history.pushState) !== "undefined") {
                    history.pushState(null, null, $clicked.attr("href"));
                }

                $nav.find("div.nav_link").removeClass("selected");
                $clicked.parent().addClass("selected").removeClass("fold");

                updateTab();
                updateImage();
            });
        });
    });

    function updateTab() {
        $("div.tabs").each(function (_, tabs) {
            let $tabs = $(tabs);

            $tabs.find("div.tab_content").removeClass("selected");
            $tabs.find("li.tab_title")
                .removeClass("selected")
                .bind("click", function () {
                    let $clicked = $(this);

                    parent = $clicked.parents("div.tabs");
                    parent.find("li.tab_title").removeClass("selected");
                    parent.find("div.tab_content").removeClass("selected");

                    $clicked.addClass("selected");
                    $("#" + $clicked.attr("data-content-id")).addClass("selected");
                });

            let first = $($tabs.find("li.tab_title:first-child"));
            first.addClass("selected");
            $("#" + first.attr("data-content-id")).addClass("selected");
        });
    }

    function updateImage() {
        $("img").each(function (_, img) {
            let $img = $(img);

            if ($img.attr("id") === "modal_image") {
                return;
            }

            if ($img.parent().text().trim().length) {
                $img.addClass("img_inline");
            } else {
                $img.addClass("expandable")
                    .bind("click", function () {
                        $("#modal_image")
                            .attr("src", $img.attr("src"))
                            .bind("load", function () {
                                $("#modal_image_area").removeClass("hide");
                            });
                    });
            }
        });
    }

    let $modal_image_area = $("#modal_image_area");

    $modal_image_area.bind("click", function () {
        $(this).addClass("hide");
    });

    $(document).keydown(function (e) {
        if (e.keyCode === 27 || e.which === 27) {
            if (!$modal_image_area.hasClass("hide")) {
                $modal_image_area.addClass("hide");
            }
        }
    });

    updateTab();
    updateImage();
});