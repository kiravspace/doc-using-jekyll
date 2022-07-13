(($) => {
  class Code {
    constructor(options) {
      this.options = options
    }

    init() {
      let copy_codes = $('.{{ code_class }}').find('[data-code-copy-target-id]:not([data-potion-handled])')

      copy_codes.attr('data-potion-handled', 'true')
        .on('click', e => {
          e.preventDefault()

          let $clicked = $(e.currentTarget)

          parent = $clicked.parents('.{{ code_class }}')
          let code = parent.find('td.rouge-code').text().trim()

          navigator.clipboard.writeText(code).then(() => {
            let $success = parent.find('.{{ success_class }}')

            if ($success[0]) {
              $success.addClass('{{ success_show_class }}')
              setTimeout(() => $success.removeClass('{{ success_show_class }}'), 1000)
            }
          })
        })

      return copy_codes
    }
  }

  $.code = (options) => {
    return new Code(options)
  }
})(jQuery)

