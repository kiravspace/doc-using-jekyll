module SectionMenu
  class Generator < Jekyll::Generator
    MARKDOWN_FILE = /^(([^\/.]+)\.md)$/

    def generate(site)
      self.find_child("", site.collections["sections"].entries)
    end

    def to_file_element(*args)
      path = args[0] == "" ? "" : "#{args[0]}/"
      args[1].scan(MARKDOWN_FILE).first.map!{ |g| "#{path}#{g}" }
    end

    def find_child(prefix, entries)
      path = prefix == "" ? "" : "#{prefix}/"
      entries.each { |entry|
        if entry.start_with?(path)
          check = entry.sub(path, "")
          if check.match? MARKDOWN_FILE
            file = self.to_file_element(prefix, check)
            puts "#{path} ===> #{file.first} #{file.last}"
            self.find_child(file.last, entries)
          end
        end
      }
    end
  end
end
