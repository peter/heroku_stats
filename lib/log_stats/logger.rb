module LogStats
  class Logger
    def self.info(config, message)
      return if !config[:verbose]
      puts(message)
    end

    def self.elapsed(config, message)
      if config[:verbose]
        start_at = Time.now
        print(message + '...')
        result = yield
        elapsed = ((Time.now - start_at) * 1000.0).round
        puts(" #{elapsed} ms")
        result
      else
        yield
      end
    end
  end
end
