module HerokuStats
  class Logger
    def initialize(verbose)
      @verbose = verbose
    end

    def info(message)
      puts(message) if @verbose
    end
  end
end
