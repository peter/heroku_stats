module LogStats
  module Requests
    module KPI
      PRECISION = 5

      def self.calculate(requests, stats)
        {
          request_count: requests.size,
          response_time_avg: avg(:service, requests),
          response_time_95p: percentile(:service, 0.95, requests),
          apdex: avg(Stats.method(:apdex_metric), stats),
          error_rate: rate(method(:error?), requests),
          timeout_rate: rate(method(:timeout?), requests)
        }
      end

      def self.rate(predicate, requests)
        (count(predicate, requests).to_f/requests.size).round(PRECISION)
      end

      def self.count(predicate, requests)
        requests.select(&predicate).size
      end

      def self.avg(metric, requests)
        sum = requests.reduce(0) do |acc, request|
          value = metric.respond_to?(:call) ? metric.call(request) : request[metric]
          acc + value
        end
        (sum/requests.size.to_f).round(PRECISION)
      end

      def self.percentile(field, percentile, requests)
        index = (requests.size*percentile).round - 1
        request = requests.sort_by { |request| request[field] }[index]
        request && request[field]
      end

      def self.error?(request)
        Stats.error_status?(request[:status])
      end

      def self.timeout?(request)
        request[:code] == "H12"
      end
    end
  end
end
