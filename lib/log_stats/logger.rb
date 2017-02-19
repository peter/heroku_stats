module LogStats
  class Logger
    def self.info(config, message)
      puts(message) if config[:verbose]
    end
  end
end
