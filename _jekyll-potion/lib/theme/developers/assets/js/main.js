$(function () {
  class Page {
    static HASH_REGEX = new RegExp('([^#]*)#([^#]*)')

    constructor() {
      this.title = $('header > div > a.logo')
      this.nav_container = $('nav > div.nav-container')
      this.main = $('#container')

      this.dimmed_area = $('div.dimmed')

      this.image_area = $('div.popup-md.image')
      this.modal_image = $('#modal_image')

      this.search_area = $('div.popup-md.search')
      this.search_input = $('#search_keyword')
      this.search_results = $('#search_result')

      this.keyupEventHandlers = []

      Page.load(this, $('meta[property=\'search-indexes-location\']').attr('content'), (data) => {
        this.search_indexes = data
      })
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

      this.initTitle()
      this.initNavigation()

      Page.on(this, this.dimmed_area, 'click', e => {
        this.dimmed_area.hide()
        this.image_area.hide()
        this.search_area.hide()
      })

      Page.on(this, this.modal_image, 'load', () => {
        this.dimmed_area.show()
        this.image_area.show()
      })

      Page.on(this, $('.search-round'), 'click', () => {
        this.search_results.children().remove()
        this.dimmed_area.show()
        this.search_area.show()
        this.search_input.focus()
      })

      Page.on(this, this.search_area.find('button.icon--close-lg'), 'click', () => {
        this.search_results.children().remove()
        this.dimmed_area.hide()
        this.search_area.hide()
      })

      Page.on(this, this.search_input, 'keyup', e => {
        if (e.keyCode === 13 || e.which === 13) {
          this.search_keyword()
        }
      })

      Page.on(this, this.search_area.find('button.icon--search'), 'click', () => {
        this.search_keyword()
      })

      this.keyupEventHandlers.push({
        'keyCode': 27,
        'accept': () => {
          this.dimmed_area.hide()
          this.image_area.hide()
          this.search_area.hide()
        }
      })

      this.updateMainTabs()
      this.updateMainImages()
      this.updateMainLinks()
      this.updateMainCopy()
      this.updateMainCodes()

      Page.on(this, $(window), 'popstate', () => {
        this.loadPage($(location).attr('pathname') + $(location).attr('hash'))
      })
    }

    initTitle() {
      Page.on(this, this.title, 'click', this.updateMainContent)
    }

    initNavigation() {
      this.nav_container.find('span.nav-unfold').bind('click', e => $(e.currentTarget).parent().removeClass('fold'))
      this.nav_container.find('span.nav-fold').bind('click', e => $(e.currentTarget).parent().addClass('fold'))

      let links = this.nav_container.find('a.nav-href[href]')
      Page.on(this, links, 'click', this.updateMainContent)

      this.updateNavigationSelected($(location).attr('pathname'))
    }

    updateNavigationSelected(pathname) {
      this.nav_container.find('div.nav-link').parent().removeClass('active')

      let selected = this.nav_container.find('a.nav-href')
        .filter((_, link) => Page.matchPath($(link).attr('href'), pathname))

      selected.parents('ul.nav-menu').children('li').children('div.nav-link.fold.has-child')
        .filter((_, div) => $(div).parent().has(selected).length)
        .removeClass('fold')

      selected.parent().parent().addClass('active')
    }

    updateMainTabs() {
      let tabNavs = this.main.find('div.tabs').find('li')

      Page.on(this, tabNavs, 'click', e => {
        let $clicked = $(e.currentTarget)

        parent = $clicked.parents('div.tabs')
        parent.find('li').removeClass('active')
        parent.find('div.tab-cont').removeClass('active')

        $clicked.addClass('active')
        $('#' + $clicked.attr('data-content-id')).addClass('active')
      })
    }

    updateMainImages() {
      let expandableImages = this.main.find('img.img-internal:not(.img-inline)')

      Page.on(this, expandableImages, 'click', e => {
        this.modal_image.attr('src', $(e.currentTarget).attr('src'))
      })
    }

    updateMainLinks() {
      // #, /로 시작하는 내부링크의 경우 페이지내 전환을 위해 click 이벤트를 조작한다.
      let absolute_links = this.main.find('a.a_internal[href]')
      let only_hash_links = this.main.find('a.hash_internal[href]')

      Page.on(this, absolute_links, 'click', this.updateMainContent)
      Page.on(this, only_hash_links, 'click', this.updateHash)
    }

    updateMainCopy() {
      let copy_links = this.main.find('div.copy-link')

      Page.on(this, copy_links, 'click', e => {
        let $copy_link = $(e.currentTarget)

        let url = [$(location).attr('protocol'), $(location).attr('host'), $copy_link.attr('data-copy-link')].join('')

        navigator.clipboard.writeText(url)
      })
    }

    updateMainCodes() {
      let codeCopy = this.main.find('div.copy')
      Page.on(this, codeCopy, 'click', e => {
        e.preventDefault()

        let $copy_click = $(e.currentTarget)

        let code = $copy_click.parent().parent().find('div.body').find('td.rouge-code').text().trim()

        navigator.clipboard.writeText(code).then(() => {
          let $success = $copy_click.parent().find('div.success')
          $success.addClass('show')
          setTimeout(() => $success.removeClass('show'), 1000)
        })
      })
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

        this.updateMainTabs()
        this.updateMainImages()
        this.updateMainLinks()
        this.updateMainCopy()
        this.updateMainCodes()

        this.updateNavigationSelected(pathname)

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
        let indexes = this.select_search_result(this.search_input.val())
        this.search_results.children().remove()
        this.search_results.html($.templates('#search_contents_tmpl').render(indexes))
      }
    }

    select_search_result(keyword) {
      let result = Page.flatMap(
        this.search_indexes
          .map((page) => {
            let hashes = Page.select_hashes(page.hashes, keyword)

            if (hashes.length > 0) {
              return Page.flatMap(hashes).map(hash => {
                return {
                  'url': page.url + hash.hash,
                  'title': hash.title,
                  'order': page.order,
                  'line_number': hash.line_number,
                  'contents': hash.contents
                }
              })
            } else {
              return []
            }
          })
          .filter(hashes => hashes.length > 0)
      )

      result.sort((r1, r2) => {
        if (r1.order === r2.order) {
          return r1.line_number - r2.line_number
        }

        return r1.order - r2.order
      })

      return result.map(r => {
        r.contents = r.contents.map(s => s.replace(new RegExp('(' + keyword + ')', 'gi'), '<code>$1</code>'))
        return r
      })
    }

    static create_array(start, end) {
      let array = []
      for (let i = start; i <= end; i++) {
        array.push(i)
      }
      return array
    }

    static distinct_index(indexes, nums) {
      let contents_range_array = []
      let distinct = []

      nums.forEach((num) => {
        let contains = contents_range_array.filter((contents_range) => {
          return contents_range.includes(num)
        }).length > 0

        if (!contains) {
          let start = Math.max(num - 1, 0)
          let end = Math.min(start + 2, indexes.length - 1)
          contents_range_array.push(Page.create_array(start, end))
          distinct.push(num)
        }
      })

      return distinct
    }

    static select_contents(indexes, num) {
      let start = Math.max(num - 1, 0)
      return {
        'line_number': num,
        'contents': indexes.slice(start, start + 3)
      }
    }

    static select_content_hash_indexes(indexes, keyword) {
      let filter = indexes
        .map((index, indexes_index) => {
          if (new RegExp(keyword, 'i').test(index)) {
            return indexes_index
          } else {
            return -1
          }
        })
        .filter(hash_indexes => hash_indexes >= 0)

      return Page.distinct_index(indexes, filter)
        .map(hash_index => Page.select_contents(indexes, hash_index))
    }

    static select_hashes(hashes, keyword) {
      return hashes
        .map((hash) => {
          let hash_indexes = Page.select_content_hash_indexes(hash.indexes, keyword)

          if (hash_indexes.length > 0) {
            return hash_indexes.map((contents) => {
              return {
                'hash': (hash.hash === '') ? '' : '#' + hash.hash,
                'title': hash.title,
                'line_number': contents.line_number,
                'contents': contents.contents
              }
            })
          } else {
            return []
          }
        })
        .filter(hash => hash.length > 0)
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

    static flatMap(array) {
      return [].concat.apply([], array)
    }

    static load(context, file, func) {
      $.getJSON(file, data => func.call(context, data))
    }

    static on(context, selector, eventType, func) {
      selector.off(eventType)
      selector.on(eventType, e => func.call(context, e))
    }
  }

  let page = new Page()
  page.init()
})