module LogStats
  module Stats
    def self.fields(events, event_config)
      event_config[:fields].reduce({}) do |acc, field|
        if field[:numeric]
          acc[field[:name]] = field_stats_numeric(events, field)
        elsif field[:enum]
          acc[field[:name]] = field_stats_enum(events, field)
        end
        acc
      end
    end

    def self.field_stats_numeric(events, field)
      sorted_events = events.sort_by { |event| event[field[:name]] }
      percentile_levels = (5..95).step(5).map { |n| n/100.0 }
      percentiles = percentile_levels.reduce({}) do |acc, level|
        acc[level] = percentile(sorted_events, field[:name], level)
        acc
      end
      {
        min: sorted_events[0][field[:name]],
        max: sorted_events[-1][field[:name]],
        avg: avg(events, field[:name]),
        median: percentile(sorted_events, field[:name], 0.5),
        percentiles: percentiles
      }
    end

    def self.field_stats_enum(events, field)
      total_count = events.size
      events_by_field = events.group_by { |event| event[field[:name]] }.select { |key, _| !key.nil? }
      events_by_field.reduce({}) do |acc, (key, group_events)|
        percent = (group_events.size.to_f*100/total_count).round(4)
        acc[key] = percent
        acc
      end
    end

    def self.avg(events, field_name)
      sum = events.lazy.map { |event| event[field_name] }.reduce(&:+)
      sum/events.size.to_f
    end

    def self.percentile(sorted_events, field_name, level)
      index = (sorted_events.size*level).round - 1
      event = sorted_events[index]
      event && event[field_name]
    end
  end
end
