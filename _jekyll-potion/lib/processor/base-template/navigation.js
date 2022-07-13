(($) => {
  class Navigation {
    constructor(options) {
      this.options = options
    }

    static matchPath(path, requestPath) {
      return new RegExp(path + '(/|/?#([^/]*))?$').test(requestPath)
    }

    init(pathname) {
      $('[data-unfold-id]:not([data-potion-handled])')
        .attr('data-potion-handled', 'true')
        .on('click', e => {
          $('[data-fold-target-id=\'' + $(e.currentTarget).attr('data-unfold-id') + '\']').removeClass('{{ fold_class }}')
        })

      $('[data-fold-id]:not([data-potion-handled])')
        .attr('data-potion-handled', 'true')
        .on('click', e => {
          $('[data-fold-target-id=\'' + $(e.currentTarget).attr('data-fold-id') + '\']').addClass('{{ fold_class }}')
        })

      let all_links = $('[data-nav-link-id]')
      all_links.removeClass('{{ active_class }}')

      let $selected = all_links.filter((_, nav_link) => Navigation.matchPath($(nav_link).attr('data-nav-link-id'), pathname))

      $selected.addClass('{{ active_class }}')
      $('[data-fold-target-id=\'' + pathname + '\']').removeClass('{{ fold_class }}')

      $selected.parents('[data-nav-link-id]').filter((_, p) => $(p).has($selected).length)
        .each((_, nav_link) => $('[data-fold-target-id=\'' + $(nav_link).attr('data-nav-link-id') + '\']').removeClass('{{ fold_class }}'))
    }
  }

  $.navigation = (options) => {
    return new Navigation(options)
  }
})(jQuery)
