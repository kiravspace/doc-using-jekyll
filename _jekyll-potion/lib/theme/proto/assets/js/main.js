$(function () {
    class Page {
        static HASH_REGEX = new RegExp("([^#]*)#([^#]*)");

        constructor() {
            this.title = $("header > div.header > a.title");
            this.nav = $("nav > div.nav_container");
            this.section = $("#section");

            this.modal_image_area = $("#modal_image_area > div.modal_wrapper");
            this.modal_image = $("#modal_image");

            this.modal_search_area = $("#modal_search_area > div.modal_wrapper");
            this.search_input = $("#search_keyword");
            this.search_contents = $("#search_contents");

            this.keyupEventHandlers = [];

            Page.load(this, $("meta[property='search-indexes-location']").attr("content"), (data) => {
                this.search_indexes = data;
            });
        }

        init() {
            let context = this;
            $(document).keydown(e => {
                this.keyupEventHandlers.forEach(handler => {
                    if (e.keyCode === handler.keyCode || e.which === handler.keyCode) {
                        if (handler.condition && handler.condition.call(context)) {
                            handler.accept.call(context, e);
                        }
                    }
                });
            });

            this.initTitle();
            this.initNavigation();

            Page.on(this, this.modal_image, "load", () => this.modal_image_area.parent().removeClass("hide"));
            Page.on(
                this,
                this.modal_image_area,
                "click",
                e => {
                    e.preventDefault();
                    if (e.currentTarget === this.modal_image_area[0]) {
                        this.modal_image_area.parent().addClass("hide");
                    }
                }
            );

            this.keyupEventHandlers.push({
                "keyCode": 27,
                "condition": () => !this.modal_image_area.parent().hasClass("hide"),
                "accept": () => this.modal_image_area.parent().addClass("hide")
            });

            Page.on(this, $("#go_search"), "click", () => {
                this.search_contents.children().remove();
                this.modal_search_area.parent().removeClass("hide");
            });

            Page.on(this, this.modal_search_area.children(), "click", e => e.stopPropagation());
            Page.on(
                this,
                this.modal_search_area,
                "click",
                e => {
                    e.preventDefault();
                    if (e.currentTarget === this.modal_search_area[0]) {
                        this.search_contents.children().remove();
                        this.modal_search_area.parent().addClass("hide");
                    }
                }
            );

            Page.on(this, this.search_input, "keyup", e => {
                if ((e.keyCode === 13 || e.which === 13) && this.search_input.val().trim().length >= 2) {
                    let indexes = this.select_search_result(this.search_input.val());
                    this.search_contents.children().remove();
                    this.search_contents.html($.templates("#search_contents_tmpl").render(indexes));
                }
            });

            this.keyupEventHandlers.push({
                "keyCode": 27,
                "condition": () => !this.modal_search_area.parent().hasClass("hide"),
                "accept": () => this.modal_search_area.parent().addClass("hide")
            });

            this.updateSectionTabs();
            this.updateSectionImages();
            this.updateSectionLinks();
            this.updateSectionCopy();
            this.updateSectionCodes();

            Page.on(this, $(window), "popstate", () => {
                this.loadPage($(location).attr("pathname") + $(location).attr("hash"));
            });
        }

        initTitle() {
            Page.on(this, this.title, "click", this.updateSectionContent);
        }

        initNavigation() {
            this.nav.find("span.nav_unfold").bind("click", e => $(e.currentTarget).parent().removeClass("fold"));
            this.nav.find("span.nav_fold").bind("click", e => $(e.currentTarget).parent().addClass("fold"));

            let links = this.nav.find("a.nav_href[href]");
            Page.on(this, links, "click", this.updateSectionContent);

            this.updateNavigationSelected($(location).attr("pathname"))
        }

        updateNavigationSelected(pathname) {
            this.nav.find("div.nav_link").removeClass("selected");

            let selected = this.nav.find("a.nav_href")
                .filter((_, link) => Page.matchPath($(link).attr("href"), pathname));

            selected.parents("ul.nav_menu").children("li").children("div.nav_link.fold.has_child")
                .filter((_, div) => $(div).parent().has(selected).length)
                .removeClass("fold");

            selected.parent().addClass("selected");
        }

        updateSectionTabs() {
            let tabTitles = this.section.find("div.tabs").find("li.tab_title");

            Page.on(this, tabTitles, "click", e => {
                let $clicked = $(e.currentTarget);

                parent = $clicked.parents("div.tabs");
                parent.find("li.tab_title").removeClass("selected");
                parent.find("div.tab_content").removeClass("selected");

                $clicked.addClass("selected");
                $("#" + $clicked.attr("data-content-id")).addClass("selected");
            });
        }

        updateSectionImages() {
            let expandableImages = this.section.find("img.img_internal:not(.img_inline)");

            Page.on(this, expandableImages, "click", e => {
                this.modal_image.attr("src", $(e.currentTarget).attr("src"));
            });
        }

        updateSectionLinks() {
            // #, /로 시작하는 내부링크의 경우 페이지내 전환을 위해 click 이벤트를 조작한다.
            let absolute_links = this.section.find("a.a_internal[href]");
            let only_hash_links = this.section.find("a.hash_internal[href]");

            Page.on(this, absolute_links, "click", this.updateSectionContent);
            Page.on(this, only_hash_links, "click", this.updateHash);
        }

        updateSectionCopy() {
            let copy_links = this.section.find("div.copy_link");

            Page.on(this, copy_links, "click", e => {
                let $copy_link = $(e.currentTarget);

                let url = [$(location).attr("protocol"), $(location).attr("host"), $copy_link.attr("data-copy-link")].join("");

                navigator.clipboard.writeText(url);
            });
        }

        updateSectionCodes() {
            let codeCopy = this.section.find("div.copy");
            Page.on(this, codeCopy, "click", e => {
                e.preventDefault();

                let $copy_click = $(e.currentTarget);

                let code = $copy_click.parent().find("div.code_body").find("td.rouge-code").text().trim();

                navigator.clipboard.writeText(code).then(() => {
                    let $copy_success = $copy_click.parent().find("div.copy_success");
                    $copy_success.addClass("show");
                    setTimeout(() => $copy_success.removeClass("show"), 1000);
                });
            });
        }

        loadPage(pathname, callback) {
            this.section.load(pathname + " #container", (html, status) => {
                if (status !== "success") {
                    return;
                }
                this.section.scrollTop(0);
                let title = html.match("<title>(.*?)</title>")[1];
                document.title = title;

                if (Page.hasHash(pathname)) {
                    Page.goHash(Page.getHash(pathname));
                }

                this.updateSectionTabs();
                this.updateSectionImages();
                this.updateSectionLinks();
                this.updateSectionCopy();
                this.updateSectionCodes();

                this.updateNavigationSelected(pathname);

                if (callback) {
                    callback.call(this, title);
                }
            });
        }

        updateSectionContent(e) {
            e.preventDefault();

            let pathname = $(e.currentTarget).attr("href");

            if (Page.matchPath($(location).attr("pathname"), pathname)) {
                return;
            }

            this.loadPage(pathname, title => {
                if (typeof (history.pushState) !== "undefined") {
                    history.pushState(null, title, pathname);
                }
            });
        }

        updateHash(e) {
            e.preventDefault();

            let hash = $(e.currentTarget).attr("href");

            Page.goHash(hash);

            if (typeof (history.pushState) !== "undefined") {
                history.pushState(null, document.title, $(location).attr("pathname") + hash);
            }
        }

        select_search_result(keyword) {
            let result = Page.flatMap(
                this.search_indexes
                    .map((page) => {
                        let hashes = Page.select_hashes(page.hashes, keyword);

                        if (hashes.length > 0) {
                            return Page.flatMap(hashes).map(hash => {
                                return {
                                    "url": page.url + hash.hash,
                                    "title": hash.title,
                                    "order": page.order,
                                    "line_number": hash.line_number,
                                    "contents": hash.contents
                                };
                            });
                        } else {
                            return [];
                        }
                    })
                    .filter(hashes => hashes.length > 0)
            );

            result.sort((r1, r2) => {
                if (r1.order === r2.order) {
                    return r1.line_number - r2.line_number;
                }

                return r1.order - r2.order;
            });

            return result.map(r => {
                r.contents = r.contents.map(s => s.replace(new RegExp("(" + keyword + ")", "gi"), "<code>$1</code>"));
                return r;
            });
        }

        static create_array(start, end) {
            let array = [];
            for (let i = start; i <= end; i++) {
                array.push(i);
            }
            return array
        }

        static distinct_index(indexes, nums) {
            let contents_range_array = [];
            let distinct = [];

            nums.forEach((num) => {
                let contains = contents_range_array.filter((contents_range) => {
                    return contents_range.includes(num)
                }).length > 0;

                if (!contains) {
                    let start = Math.max(num - 1, 0);
                    let end = Math.min(start + 2, indexes.length - 1);
                    contents_range_array.push(Page.create_array(start, end));
                    distinct.push(num);
                }
            })

            return distinct;
        }

        static select_contents(indexes, num) {
            let start = Math.max(num - 1, 0)
            return {
                "line_number": num,
                "contents": indexes.slice(start, start + 3)
            }
        }

        static select_content_hash_indexes(indexes, keyword) {
            let filter = indexes
                .map((index, indexes_index) => {
                    if (new RegExp(keyword, "i").test(index)) {
                        return indexes_index;
                    } else {
                        return -1;
                    }
                })
                .filter(hash_indexes => hash_indexes >= 0);

            return Page.distinct_index(indexes, filter)
                .map(hash_index => Page.select_contents(indexes, hash_index));
        }

        static select_hashes(hashes, keyword) {
            return hashes
                .map((hash) => {
                    let hash_indexes = Page.select_content_hash_indexes(hash.indexes, keyword);

                    if (hash_indexes.length > 0) {
                        return hash_indexes.map((contents) => {
                            return {
                                "hash": (hash.hash === "") ? "" : "#" + hash.hash,
                                "title": hash.title,
                                "line_number": contents.line_number,
                                "contents": contents.contents
                            };
                        })
                    } else {
                        return [];
                    }
                })
                .filter(hash => hash.length > 0);
        }

        static matchPath(path, requestPath) {
            return new RegExp(path + "(/|/?#([^/]*))?$").test(requestPath);
        }

        static hasHash(path) {
            return Page.HASH_REGEX.test(path);
        }

        static getHash(path) {
            return path.replace(Page.HASH_REGEX, "#$2");
        }

        static goHash(hash) {
            let $hash = $(decodeURI(hash));
            if ($hash.length) {
                $hash[0].scrollIntoView();
            }
        }

        static flatMap(array) {
            return [].concat.apply([], array);
        }

        static load(context, file, func) {
            $.getJSON(file, data => func.call(context, data));
        }

        static on(context, selector, eventType, func) {
            selector.off(eventType);
            selector.on(eventType, e => func.call(context, e))
        }
    }

    let page = new Page();
    page.init();
});
