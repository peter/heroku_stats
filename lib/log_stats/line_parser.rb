module LogStats
  module LineParser
    def self.parse(log_data, config)
      data = {}
      log_data.split("\n").each do |line_string|
        config[:events].each do |event, event_config|
          if event_config[:line_pattern] =~ line_string
            data[event] ||= []
            data[event].push(parse_line(line_string, event_config))
          end
        end
      end
      data
    end

    def self.strip_quotes(value)
      if value && value.start_with?('"')
        value[1..-2]
      else
        value
      end
    end

    def self.parse_numeric(value)
      value[/\d+/].to_i
    end

    def self.parse_field(field, line_string, event_config)
      if field[:parse]
        value = field[:parse].call(line_string)
      else
        value = /\b#{field[:name]}=(\S+)/.match(line_string).to_a[1]
        value = strip_quotes(value)
        value = parse_numeric(value) if field[:numeric]
      end
      puts "Parsing failed field=#{field} line=#{line_string}" unless (value || field[:optional])
      value
    rescue Exception => e
      puts "Parsing failed field=#{field} line=#{line_string}: #{e.message}"
      nil
    end

    def self.parse_line(line_string, event_config)
      event_config[:fields].reduce({}) do |acc, field|
        if value = parse_field(field, line_string, event_config)
          acc[field[:name]] = value
        end
        acc
      end
    end
  end
end
