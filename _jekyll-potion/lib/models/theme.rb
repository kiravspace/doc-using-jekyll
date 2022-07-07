module Jekyll::Potion
  class Theme
    # `
    #       - developers:
    #       path: "/a/b/c"
    #       layouts-dir: "_layouts"
    #       includes-dir: "_includes"
    #       default-layout: "default"
    #       assets:
    #         source-dir: "assets"
    #         target-root-path: "/assets"
    #       sass-files:
    #         - "main.scss"
    #       content-x-path:
    # `
    #
    PATH_KEY = "path"
    LAYOUT_KEY = "layouts-dir"
    INCLUDES_DIR_KEY = "includes-dir"
    DEFAULT_LAYOUT_KEY = "default-layout"
    ASSETS_KEY = "assets"
    SOURCE_DIR_KEY = "source-dir"
    TARGET_ROOT_PATH_KEY = "target-root-path"
    SCSS_SOURCE_DIR_KEY = "scss-source-dir"
    SCSS_FILES_KEY = "scss-files"
    CONTENT_X_PATH_KEY = "content-x-path"

    TAGS_KEY = "tags"

    DEFAULT_THEME_SCHEMA = {
      PATH_KEY => "",
      LAYOUT_KEY => "_layout",
      INCLUDES_DIR_KEY => "_includes",
      DEFAULT_LAYOUT_KEY => "default",
      ASSETS_KEY => {
        SOURCE_DIR_KEY => "assets",
        TARGET_ROOT_PATH_KEY => "/_assets",
        SCSS_SOURCE_DIR_KEY => "_scss",
        SCSS_FILES_KEY => []
      },
      CONTENT_X_PATH_KEY => "main",
      TAGS_KEY => {
        "alerts" => {
          "info" => "info",
          "warning" => "warning",
          "danger" => "danger",
          "success" => "success"
        },
        "code" => {
          "base-class" => "code",
          "copy-class" => "copy",
          "success-class" => "success",
          "success-show-class" => "show"
        },
        "tabs" => {
          "active-class" => "active"
        }
      }
    }

    attr_reader :name

    def self.default(name, base_path, schema = DEFAULT_THEME_SCHEMA)
      Theme.new(true, name, base_path, schema)
    end

    def self.custom(name, schema)
      Theme.new(false, name, "", schema)
    end

    def initialize(is_default, name, base_path, schema)
      @is_default = is_default
      @name = name
      @base_path = base_path
      @schema = Merger.fill(schema, DEFAULT_THEME_SCHEMA)
    end

    def is_default?
      @is_default
    end

    def theme_path
      if is_default?
        File.join(@base_path, "theme", @name)
      else
        @schema[PATH_KEY]
      end
    end

    def _includes
      File.join(theme_path, @schema[INCLUDES_DIR_KEY])
    end

    def _layouts
      File.join(theme_path, @schema[LAYOUT_KEY])
    end

    def default_layout
      @schema[DEFAULT_LAYOUT_KEY]
    end

    def assets_source_dir
      File.join(theme_path, @schema[ASSETS_KEY][SOURCE_DIR_KEY])
    end

    def assets_target_root_path
      @schema[ASSETS_KEY][TARGET_ROOT_PATH_KEY]
    end

    def scss_source_dir
      File.join(theme_path, @schema[ASSETS_KEY][SCSS_SOURCE_DIR_KEY])
    end

    def scss_scss_files
      @schema[ASSETS_KEY][SCSS_FILES_KEY]
    end

    def content_x_path
      @schema[CONTENT_X_PATH_KEY]
    end

    def tag_config(tag_name)
      @schema[TAGS_KEY][tag_name]
    end
  end
end
