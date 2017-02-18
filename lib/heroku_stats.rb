require "heroku_stats/version"
require "heroku_stats/line_parser"
require "heroku_stats/logger"
require "heroku_stats/stats"
require "heroku_stats/kpi"

module HerokuStats
  def self.run(log_data, config)
    logger = Logger.new(config[:verbose])
    logger.info("\nParsing request lines...")
    lines = LineParser.parse(log_data, config)
    lines_count = lines.size
    logger.info("Number of request lines: #{lines_count}")
    logger.info("Start time: #{lines[0][:time]}")
    logger.info("End time: #{lines[-1][:time]}")

    logger.info("\nCalculating stats...")
    stats = Stats.stats(lines, config)
    data = {
      stats: stats,
      lines_by_status: lines.group_by { |line| line[:status] },
      lines_by_code: lines.group_by { |line| line[:code] },
      kpi: KPI.calculate(lines, stats)
    }

    #
    # Output::Text.output(lines, stats)
    # puts output
    # print_heading("KPIs")
    # KPI.print(kpi)
    #
    # print_heading("STATUS CODES")
    # print_percentages(lines_count, lines_by_status)
    #
    # print_heading("HEROKU ERROR CODES")
    # print_percentages(lines_count, lines_by_code)
    #
    # print_heading("POPULARITY TOP LIST")
    # print_top_list(stats, method(:popularity_metric))
    #
    # print_heading("APDEX TOP LIST")
    # print_top_list(stats, method(:apdex_metric), -1)
    #
    # print_heading("DURATION TOP LIST")
    # print_top_list(stats, method(:duration_metric))
    #
    # print_heading("ERROR RATE TOP LIST")
    # print_top_list(stats, method(:error_rate_metric))
    #
    # print_heading("TIMEOUT TOP LIST")
    # print_top_list(stats, method(:timeout_metric))
    #
    # lines_by_status.each do |status, lines|
    #   print_heading("REQUESTS - STATUS #{status}")
    #   lines_by_duration(lines).each do |line|
    #     print_line(line)
    #   end
    # end
  end
end
