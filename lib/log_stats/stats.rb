module LogStats
  module Stats
    def self.fields(events, event_config)
      event_config[:fields].reduce({}) do |acc, field|
        if field[:numeric]
          acc[field[:name]] = field_stats_numeric(events, field)
        end
        acc
      end
    end

    def self.group_by(events, event_config)
      event_config[:group_by].reduce({}) do |acc, (name, group_by)|
        acc[name] = group_by_stats(events, group_by, event_config)
        acc
      end
    end

    def self.field_stats_numeric(events, field)
      sorted_events = events.sort_by { |event| event[field[:name]] }
      percentile_levels = (5..95).step(5).map { |n| n/100.0 } + [0.99, 0.999]
      percentiles = percentile_levels.reduce({}) do |acc, level|
        acc[level] = percentile(sorted_events, field[:name], level)
        acc
      end
      result = {
        min: sorted_events[0][field[:name]],
        max: sorted_events[-1][field[:name]],
        avg: avg(events, field[:name]),
        median: percentile(sorted_events, field[:name], 0.5),
        percentiles: percentiles
      }
      if field[:events]
        events_options = (field[:events].is_a?(Hash) ? field[:events] : {})
        events_limit = events_options[:limit] || 10
        result[:events] = if events_options[:sort] == "asc"
                            sorted_events[0, events_limit]
                          else
                            events_start_index = [0, sorted_events.size-events_limit].max
                            sorted_events[events_start_index..-1].reverse
                          end
      end
      result
    end

    def self.group_by_stats(events, group_by, event_config)
      total_count = events.size
      events_by_group = events.group_by { |event| group_by[:id].call(event) }.select { |key, _| !key.nil? }
      events_by_group.reduce({}) do |acc, (key, group_events)|
        group_count = group_events.size
        percent = (group_count.to_f*100/total_count).round(4)
        acc[key] = {
          count: group_count,
          percent: percent,
          fields: fields(group_events, event_config)
        }
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
