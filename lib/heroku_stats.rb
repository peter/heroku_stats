require "json"
require "heroku_stats/version"
require "heroku_stats/line_parser"
require "heroku_stats/logger"
require "heroku_stats/requests/stats"
require "heroku_stats/requests/kpi"
require "heroku_stats/requests/text_output"

module HerokuStats
  def self.run(log_data, config)
    data = get_data(log_data, config)
    if config[:stats_format] == "text" && request_config = config[:events][:requests]
      Requests::TextOutput.print(data[:requests], request_config)
    end
    if config[:stats_format] == "json"
      puts JSON.generate(data)
    end
    data
  end

  def self.get_data(log_data, config)
    logger = Logger.new(config[:verbose])
    logger.info("\nParsing request lines...")
    data = LineParser.parse(log_data, config)
    result = {}
    if requests = data[:requests]
      requests_count = requests.size
      requests_config = config[:events][:requests]
      logger.info("\nNumber of request lines: #{requests_count}")
      logger.info("Start time: #{requests[0][:time]}")
      logger.info("End time: #{requests[-1][:time]}")

      logger.info("\nCalculating request stats...")
      stats = Requests::Stats.stats(requests, requests_config)
      result[:requests] = {
        requests_count: requests_count,
        requests: requests,
        stats: stats,
        requests_by_status: requests.group_by { |request| request[:status] },
        requests_by_code: requests.group_by { |request| request[:code] },
        kpi: Requests::KPI.calculate(requests, stats)
      }
    end
    result
  end
end
