$(function () {
  class Page {
    static HASH_REGEX = new RegExp('([^#]*)#([^#]*)')

    constructor() {
      this.main = $('main')
      this.nav = $('nav')

      this.is_hide_mobile_menu = true

      this.modal_image_area = $('#modal_image_area > div.modal-wrapper')
      this.modal_image = $('#modal_image')

      this.modal_search_area = $('#modal_search_area > div.modal-wrapper')
      this.search_input = $('#search_keyword')
      this.search_contents = $('#search_contents')

      this.keyupEventHandlers = []

      this.navigation = $.navigation()
      this.header = $.header()
      this.search = $.search()
      this.tabs = $.tabs()
      this.code = $.code()
    }

    init() {
      let context = this
      $(document).keydown(e => {
        this.keyupEventHandlers.forEach(handler => {
          if (e.keyCode === handler.keyCode || e.which === handler.keyCode) {
            if (handler.condition && handler.condition.call(context)) {
              handler.accept.call(context, e)
            } else {
              handler.accept.call(context, e)
            }
          }
        })
      })

      Page.on(this, this.modal_image, 'load', () => this.modal_image_area.parent().removeClass('hide'))
      Page.on(
        this,
        this.modal_image_area,
        'click',
        e => {
          e.preventDefault()
          if (e.currentTarget === this.modal_image_area[0]) {
            this.modal_image_area.parent().addClass('hide')
          }
        }
      )

      Page.on(this, $('.show_search'), 'click', () => {
        this.search_contents.children().remove()
        this.modal_search_area.parent().removeClass('hide')
      })

      Page.on(this, this.modal_search_area.children(), 'click', e => e.stopPropagation())
      Page.on(
        this,
        this.modal_search_area,
        'click',
        e => {
          e.preventDefault()
          if (e.currentTarget === this.modal_search_area[0]) {
            this.search_contents.children().remove()
            this.modal_search_area.parent().addClass('hide')
          }
        }
      )

      Page.on(this, this.search_input, 'keyup', e => {
        if (e.keyCode === 13 || e.which === 13) {
          this.search_keyword()
        }
      })

      this.keyupEventHandlers.push({
        'keyCode': 27,
        'condition': () => !this.modal_search_area.parent().hasClass('hide'),
        'accept': () => this.modal_search_area.parent().addClass('hide')
      })

      Page.on(this, $('[data-nav-link]'), 'click', this.updateMainContent)

      Page.on(this, $(window), 'popstate', () => {
        this.loadPage($(location).attr('pathname') + $(location).attr('hash'))
      })

      Page.on(this, $('.show_menu'), 'click', () => {
        if (this.is_hide_mobile_menu) {
          this.is_hide_mobile_menu = false
          this.nav.addClass('show')
          this.main.addClass('hide')
        } else {
          this.is_hide_mobile_menu = true
          this.nav.removeClass('show')
          this.main.removeClass('hide')
        }
      })

      this.navigation.init($(location).attr('pathname'))
      this.header.init()
      this.tabs.init()
      this.code.init()

      this.updateMainImages()
      this.updateMainLinks()

      if ($(location).attr('hash')) {
        Page.goHash($(location).attr('hash'))
      }
    }

    updateMainImages() {
      let expandableImages = $('img.img-internal:not(.img-inline):not([data-handled])')

      Page.on(this, expandableImages, 'click', e => {
        this.modal_image.attr('src', $(e.currentTarget).attr('src'))
      })

      expandableImages.attr('data-handled', true)
    }

    updateMainLinks() {
      // #, /로 시작하는 내부링크의 경우 페이지내 전환을 위해 click 이벤트를 조작한다.
      let absolute_links = $('a.a-internal[href]:not([data-nav-link]):not([data-handled])')
      let only_hash_links = $('a.hash-internal[href]:not([data-nav-link]):not([data-handled])')

      Page.on(this, absolute_links, 'click', this.updateMainContent)
      Page.on(this, only_hash_links, 'click', this.updateHash)

      absolute_links.attr('data-handled', true)
      only_hash_links.attr('data-handled', true)
    }

    loadPage(pathname, callback) {
      this.main.load(pathname + ' #container', (html, status) => {
        if (status !== 'success') {
          return
        }
        this.main.scrollTop(0)
        let title = html.match('<title>(.*?)</title>')[1]
        document.title = title

        if (Page.hasHash(pathname)) {
          Page.goHash(Page.getHash(pathname))
        }

        this.header.init()
        this.tabs.init()
        this.code.init()

        this.updateMainImages()
        this.updateMainLinks()

        if (callback) {
          callback.call(this, title)
        }
      })
    }

    updateMainContent(e) {
      e.preventDefault()

      let pathname = $(e.currentTarget).attr('href')

      if (Page.matchPath($(location).attr('pathname'), pathname)) {
        return
      }

      this.loadPage(pathname, title => {
        if (typeof (history.pushState) !== 'undefined') {
          history.pushState(null, title, pathname)
        }

        this.navigation.init($(location).attr('pathname'))

        if (!this.is_hide_mobile_menu) {
          this.is_hide_mobile_menu = true
          this.nav.removeClass('show')
          this.main.removeClass('hide')
        }
      })
    }

    updateHash(e) {
      e.preventDefault()

      let hash = $(e.currentTarget).attr('href')

      Page.goHash(hash)

      if (typeof (history.pushState) !== 'undefined') {
        history.pushState(null, document.title, $(location).attr('pathname') + hash)
      }
    }

    search_keyword() {
      if (this.search_input.val().trim().length >= 2) {
        this.search_contents.children().remove()

        this.search.search(this.search_input.val(), this, results => {
          this.search_contents.html($.templates('#search_contents_tmpl').render(results))
        })
      }
    }

    static matchPath(path, requestPath) {
      return new RegExp(path + '(/|/?#([^/]*))?$').test(requestPath)
    }

    static hasHash(path) {
      return Page.HASH_REGEX.test(path)
    }

    static getHash(path) {
      return path.replace(Page.HASH_REGEX, '#$2')
    }

    static goHash(hash) {
      let $hash = $(decodeURI(hash))
      if ($hash.length) {
        $hash[0].scrollIntoView()
      }
    }

    static on(context, selector, eventType, func) {
      selector.off(eventType)
      selector.on(eventType, e => func.call(context, e))
    }
  }

  let page = new Page()
  page.init()
})
