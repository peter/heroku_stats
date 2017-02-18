module HerokuStats
  module Output
    module Text
      def self.print_line(line)
        parts = [(line[:method] == "GET" ? nil : line[:method]),
                  line[:path],
                  line[:service],
                  line[:code]
                ].compact
        if parts.size > 1
          puts parts.join(" ")
        end
      end

      def self.print_percentages(total_lines_count, grouped_lines)
        grouped_lines.select { |key, _| !key.nil? }.each do |key, lines|
          percent = (lines.size.to_f*100/total_lines_count).round(4)
          puts "#{key} #{percent}%"
        end
      end

      def self.print_top_list(stats, metric, direction = 1)
        stats_by_metric(stats, metric, direction)[0, TOP_LIST_LIMIT].each do |stat|
          apdex = apdex_metric(stat).round(2)
          puts [stat[:id],
                metric.call(stat),
                "count=#{stat[:count]}",
                "apdex=#{apdex}",
                (apdex >= APDEX_GOAL ? "OK" : "SLOW")
               ].join(' ')
        end
      end

      def self.print_heading(heading)
        puts "\n-----------------------------------------------------------"
        puts heading
        puts "-----------------------------------------------------------\n\n"
      end
    end
  end
end
