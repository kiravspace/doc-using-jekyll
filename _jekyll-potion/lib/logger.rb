module Jekyll::Potion
  class Logger
    LEVEL = {
      :trace => "[Jekyll::Potion] ",
      :info => "\e[32m[Jekyll::Potion]\e[0m ",
      :warn => "\e[33m[Jekyll::Potion]\e[0m ",
      :error => "\e[31m[Jekyll::Potion]\e[0m "
    }.freeze

    def initialize(caller)
      @section = caller.class.name
    end

    def log(level, *args)
      puts "#{LEVEL[level] ||= LEVEL[:trace]} [\e[m\e[1m#{@section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end

    def self.log(level, section, *args)
      puts "#{LEVEL[level] ||= LEVEL[:trace]} [\e[m\e[1m#{section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end

    def self.trace(section, *args)
      puts "\e[32m[Jekyll::Potion]\e[0m [\e[m\e[1m#{section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end

    def trace(*args)
      puts "\e[32m[Jekyll::Potion]\e[0m [\e[m\e[1m#{@section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end

    def self.warn(section, *args)
      puts "\e[33m[Jekyll::Potion]\e[0m [\e[m\e[1m#{section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end

    def warn(*args)
      puts "\e[33m[Jekyll::Potion]\e[0m [\e[m\e[1m#{@section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end

    def self.error(section, *args)
      puts "\e[31m[Jekyll::Potion]\e[0m [\e[m\e[1m#{section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end

    def error(*args)
      puts "\e[31m[Jekyll::Potion]\e[0m [\e[m\e[1m#{@section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end
  end
end
