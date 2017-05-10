require "json"
require "log_stats/logger"
require "log_stats/version"
require "log_stats/line_parser"
require "log_stats/logger"
require "log_stats/stats"
require "log_stats/requests/stats"
require "log_stats/requests/kpi"
require "log_stats/requests/text_output"
require "time"

module LogStats
  def self.get_stats(log_data, config)
    events = get_events(log_data, config)
    process_events(events, config)
  end

  def self.get_events(log_data, config)
    Logger.elapsed(config, "\nParsing #{log_data.length} log lines") do
      LineParser.parse(log_data, config)
    end
  end

  def self.process_events(events, config)
    if config[:start_time] || config[:end_time]
      events = Logger.elapsed(config, "\nFiltering by start_time/end_time") do
        events.keys.reduce({}) do |acc, key|
          acc[key] = events[key].select do |event|
            event_time = Time.parse(event[:time])
            (config[:start_time].nil? || config[:start_time] < event_time) &&
            (config[:end_time].nil? || config[:end_time] > event_time)
          end
          acc
        end
      end
    end
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
      }
      # NOTE: the full events list can get very large so don't include it by default
      acc[event_name][:events] = events[event_name] if config[:events][event_name][:events]
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
    kpi = Requests::KPI.calculate(requests, stats)
    requests_by_status = requests.group_by { |request| request[:status] }
    kpi_by_status = requests_by_status.reduce({}) do |acc, (status, requests)|
      acc[status] = Requests::KPI.calculate(requests,
                                            Requests::Stats.stats(requests, requests_config))
      acc
    end
    limit = requests_config[:limit] || 500
    requests_4xx = requests_by_status.reduce({}) do |acc, (status, requests)|
      if status / 100 == 4
        acc[status] = requests.first(limit)
      end
      acc
    end
    requests_5xx = requests_by_status.reduce({}) do |acc, (status, requests)|
      if status / 100 == 5
        acc[status] = requests.first(limit)
      end
      acc
    end
    result = {
      requests_count: requests_count,
      kpi: kpi,
      kpi_by_status: kpi_by_status,
      requests_4xx: requests_4xx.first(limit),
      requests_5xx: requests_5xx.first(limit)
    }
    # NOTE: stats is one entry per request path and can get very large so don't include it by default
    result[:stats] = stats if requests_config[:stats]
    result
  end
end
