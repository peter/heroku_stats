module HerokuStats
  module KPI
    PRECISION = 5

    def self.calculate(lines, stats)
      {
        request_count: lines.size,
        response_time_avg: avg(:service, lines),
        response_time_95p: percentile(:service, 0.95, lines),
        apdex: avg(Stats.method(:apdex_metric), stats),
        error_rate: rate(method(:error?), lines),
        timeout_rate: rate(method(:timeout?), lines)
      }
    end

    def self.rate(predicate, lines)
      (count(predicate, lines).to_f/lines.size).round(PRECISION)
    end

    def self.count(predicate, lines)
      lines.select(&predicate).size
    end

    def self.avg(metric, lines)
      sum = lines.reduce(0) do |acc, line|
        value = metric.respond_to?(:call) ? metric.call(line) : line[metric]
        acc + value
      end
      (sum/lines.size.to_f).round(PRECISION)
    end

    def self.percentile(field, percentile, lines)
      index = (lines.size*percentile).round - 1
      line = lines.sort_by { |line| line[field] }[index]
      line && line[field]
    end

    def self.error?(line)
      Stats.error_status?(line[:status])
    end

    def self.timeout?(line)
      line[:code] == "H12"
    end

    def self.print(kpi)
      kpi.each do |key, value|
        puts "#{key}: #{value}"
      end
    end
  end
end
