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

    $modal_image_area.children("div.modal_wrapper").bind("click", function () {
        $modal_image_area.addClass("hide");
    });

    let $go_search = $("#go_search");
    let $modal_search_area = $("#modal_search_area");

    $go_search.bind("click", function () {
        $modal_search_area.removeClass("hide");
    });

    $modal_search_area.children("div.modal_wrapper").bind("click", function (e) {
        if (this === e.target) {
            $modal_search_area.addClass("hide");
        }
    });

    $(document).keydown(function (e) {
        if (e.keyCode === 27 || e.which === 27) {
            if (!$modal_image_area.hasClass("hide")) {
                $modal_image_area.addClass("hide");
            }

            if (!$modal_search_area.hasClass("hide")) {
                $modal_search_area.addClass("hide");
            }
        }
    });

    let search_indexes = [];

    function create_array(start, end) {
        let array = [];
        for (let i = start; i <= end; i++) {
            array.push(i);
        }
        return array
    }

    function distinct_index(indexes, nums) {
        let contents_range_array = [];
        let distinct = [];

        nums.forEach(function (num) {
            let contains = contents_range_array.filter(function (contents_range) {
                return contents_range.includes(num)
            }).length > 0;

            if (!contains) {
                let start = Math.max(num - 1, 0);
                let end = Math.min(start + 2, indexes.length - 1);
                contents_range_array.push(create_array(start, end));
                distinct.push(num);
            }
        })

        return distinct;
    }

    function select_contents(indexes, num) {
        let start = Math.max(num - 1, 0)
        return indexes.slice(start, start + 3)
    }

    function select_content_hash_indexes(indexes, keyword) {
        let filter = indexes
            .map(function (index, indexes_index) {
                if (new RegExp(keyword, "i").test(index)) {
                    return indexes_index;
                } else {
                    return -1;
                }
            })
            .filter(function (hash_indexes) {
                return hash_indexes >= 0;
            });

        return distinct_index(indexes, filter)
            .map(function (hash_index) {
                return select_contents(indexes, hash_index);
            });
    }

    function select_hashes(hashes, keyword) {
        return hashes
            .map(function (hash) {
                let hash_indexes = select_content_hash_indexes(hash.indexes, keyword);

                if (hash_indexes.length > 0) {
                    return hash_indexes.map(function (contents) {
                        return {
                            "hash": (hash.hash === "") ? "" : "#" + hash.hash,
                            "title": hash.title,
                            "contents": contents
                        };
                    })
                } else {
                    return [];
                }
            })
            .filter(function (hash) {
                return hash.length > 0;
            });
    }

    function select_search_result(search_indexes, keyword) {
        return [].concat.apply(
            [],
            search_indexes
                .map(function (page) {
                    let hashes = select_hashes(page.hashes, keyword);

                    if (hashes.length > 0) {
                        return [].concat.apply([], hashes).map(function (hash) {
                            return {
                                "url": page.url + hash.hash,
                                "title": hash.title,
                                "contents": hash.contents
                            };
                        });
                    } else {
                        return [];
                    }
                })
                .filter(function (hashes) {
                    return hashes.length > 0;
                })
        );
    }

    $.getJSON($("meta[property='search-indexes-location']").attr("content"), function (data) {
        let keyword = "Developers"
        search_indexes = data;

        let indexes = select_search_result(search_indexes, keyword);
        console.log(indexes)
    });

    updateTab();
    updateImage();
});