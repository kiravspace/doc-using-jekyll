module Jekyll::Potion
  class PotionSourceMapPage < Jekyll::SourceMapPage
    def initialize(css_page, target)
      super(css_page)
      @target = target
    end

    def destination(dest)
      @site.in_dest_dir(File.join(@target, @dir, @name))
    end
  end
end
