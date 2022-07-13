module Jekyll::Potion
  class PotionPage < Jekyll::Page
    attr_reader :target

    def initialize(site, base, dir, name, target)
      @site = site
      @base = base
      @dir = dir
      @name = name
      @target = target
      self.process(@name)
      self.data ||= {}
    end

    def relative_path
      File.join(@target, super)
    end

    def destination(dest)
      @site.in_dest_dir(File.join(@target, @dir, @name))
    end
  end
end
