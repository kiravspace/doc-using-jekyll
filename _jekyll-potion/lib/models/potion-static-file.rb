module Jekyll::Potion
  class PotionStaticFile < Jekyll::StaticFile
    def initialize(site, base, dir, name, target)
      super(site, base, dir, name)
      @target = target
    end

    def destination(dest)
      @site.in_dest_dir(File.join(@target, @dir, @name))
    end
  end
end
