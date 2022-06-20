module Potion
  class Logger
    def initialize(caller)
      @section = caller.class.name
    end

    def self.trace(section, *args)
      puts "\e[32m[Potion]\e[0m [\e[m\e[1m#{section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end

    def trace(*args)
      puts "\e[32m[Potion]\e[0m [\e[m\e[1m#{@section}\e[0m] \e[m\e[1m#{args.join(" ")}\e[0m"
    end
  end
end