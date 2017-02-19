require "json"
require "log_stats/version"
require "log_stats/line_parser"
require "log_stats/logger"
require "log_stats/stats"
require "log_stats/requests/stats"
require "log_stats/requests/kpi"
require "log_stats/requests/text_output"

module LogStats
  def self.run(log_data, config)
    data = get_data(log_data, config)
    if config[:output_format] == "text" && request_config = config[:events][:requests]
      Requests::TextOutput.print(data[:requests], request_config)
    end
    if config[:output_format] == "json"
      puts JSON.generate(data)
    end
    data
  end

  def self.get_data(log_data, config)
    Logger.info(config, "\nParsing log lines...")
    events = LineParser.parse(log_data, config)
    result = {}
    if requests = events[:requests]
      result[:requests] = get_requests_data(requests, config)
    end
    other_event_names = events.keys.reject { |k| k == :requests }
    other_result = other_event_names.reduce({}) do |acc, event_name|
      acc[event_name] = {
        count: events[event_name].size,
        fields: Stats.fields(events[event_name], config[:events][event_name]),
        group_by: Stats.group_by(events[event_name], config[:events][event_name]),
        events: events[event_name]
      }
      acc
    end
    result.merge(other_result)
  end

  def self.get_requests_data(requests, config)
    requests_count = requests.size
    requests_config = config[:events][:requests]
    Logger.info(config, "\nNumber of request lines: #{requests_count}")
    Logger.info(config, "Start time: #{requests[0][:time]}")
    Logger.info(config, "End time: #{requests[-1][:time]}")

    Logger.info(config, "\nCalculating request stats...")
    stats = Requests::Stats.stats(requests, requests_config)
    {
      requests_count: requests_count,
      requests: requests,
      stats: stats,
      requests_by_status: requests.group_by { |request| request[:status] },
      requests_by_code: requests.group_by { |request| request[:code] },
      kpi: Requests::KPI.calculate(requests, stats)
    }
  end
end
