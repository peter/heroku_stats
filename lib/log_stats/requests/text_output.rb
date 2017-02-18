module LogStats
  module Requests
    module TextOutput
      def self.print(data, event_config)
        print_heading("KPIs")
        print_kpi(data[:kpi])

        print_heading("STATUS CODES")
        print_percentages(data[:requests_count], data[:requests_by_status])

        print_heading("HEROKU ERROR CODES")
        print_percentages(data[:requests_count], data[:requests_by_code])

        top_list_options = {
          direction: 1,
          limit: event_config[:top_list_limit],
          apdex_goal: event_config[:apdex_goal]
        }

        print_heading("POPULARITY TOP LIST")
        print_top_list(data[:stats], Stats.method(:popularity_metric), top_list_options)

        print_heading("APDEX TOP LIST")
        print_top_list(data[:stats], Stats.method(:apdex_metric), top_list_options.merge(direction: -1))

        print_heading("DURATION TOP LIST")
        print_top_list(data[:stats], Stats.method(:duration_metric), top_list_options)

        print_heading("ERROR RATE TOP LIST")
        print_top_list(data[:stats], Stats.method(:error_rate_metric), top_list_options)

        print_heading("TIMEOUT TOP LIST")
        print_top_list(data[:stats], Stats.method(:timeout_metric), top_list_options)

        data[:requests_by_status].each do |status, requests|
          print_heading("REQUESTS - STATUS #{status}")
          Stats.requests_by_duration(requests).each do |request|
            print_request(request)
          end
        end
      end

      def self.print_request(request)
        parts = [(request[:method] == "GET" ? nil : request[:method]),
                  request[:path],
                  request[:service],
                  request[:code]
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

      def self.print_top_list(stats, metric, options = {})
        Stats.stats_by_metric(stats, metric, options[:direction])[0, options[:limit]].each do |stat|
          apdex = Stats.apdex_metric(stat).round(2)
          puts [stat[:id],
                metric.call(stat),
                "count=#{stat[:count]}",
                "apdex=#{apdex}",
                (apdex >= options[:apdex_goal] ? "OK" : "SLOW")
               ].join(' ')
        end
      end

      def self.print_heading(heading)
        puts "\n-----------------------------------------------------------"
        puts heading
        puts "-----------------------------------------------------------\n\n"
      end


      def self.print_kpi(kpi)
        kpi.each do |key, value|
          puts "#{key}: #{value}"
        end
      end
    end
  end
end
