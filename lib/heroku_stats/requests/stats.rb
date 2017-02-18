module HerokuStats
  module Requests
    module Stats
      def self.stats(requests, event_config)
        requests.reduce({}) do |acc, request|
          id = (request[:method] == "GET" ? '' : "#{request[:method]} ") + [request[:host], request[:path]].join('')
          acc[id] ||= {
            id: id,
            method: request[:method],
            path: request[:path],
            count: 0,
            success_count: 0,
            error_count: 0,
            timeout_count: 0,
            code_count: Hash.new(0),
            satisfied_count: 0,
            tolerating_count: 0,
            frustrated_count: 0,
            service: 0
          }
          acc[id][:count] += 1
          if error_status?(request[:status])
            acc[id][:error_count] += 1
            acc[id][:frustrated_count] += 1
          else
            acc[id][:success_count] += 1
            if request[:service] <= event_config[:apdex][:tolerating]
              acc[id][:satisfied_count] += 1
            elsif request[:service] <= event_config[:apdex][:frustrated]
              acc[id][:tolerating_count] += 1
            else
              acc[id][:frustrated_count] += 1
            end
          end
          if request[:code]
            acc[id][:code_count][request[:code]] += 1
          end
          if request[:code] == "H12"
            acc[id][:timeout_count] += 1
          end
          acc[id][:service] += request[:service]
          acc
        end.values
      end

      def self.error_status?(status)
        status / 100 == 5
      end

      def self.requests_by_duration(requests)
        requests.sort_by { |request| -request[:service].to_i }
      end

      def self.duration_metric(stat)
        stat[:service].to_f/stat[:count]
      end

      def self.error_rate_metric(stat)
        stat[:error_count].to_f/stat[:count]
      end

      def self.timeout_metric(stat)
        stat[:timeout_count]
      end

      def self.popularity_metric(stat)
        stat[:count]
      end

      def self.apdex_metric(stat)
        (stat[:satisfied_count] + stat[:tolerating_count].to_f/2)/stat[:count]
      end

      def self.stats_by_metric(stats, metric, direction = 1)
        stats.sort do |stat1, stat2|
          metric1 = -1 * direction * metric.call(stat1)
          metric2 = -1 * direction * metric.call(stat2)
          if metric1 == metric2
            0
          elsif metric1.nil? || metric2.nil?
            metric1.nil? ? -1 : 1
          else
            metric1 > metric2 ? 1 : -1
          end
        end
      end
    end
  end
end
