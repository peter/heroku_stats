module HerokuStats
  module LineParser
    def self.parse(log_data, config)
      lines = []
      log_data.split("\n").each do |line_string|
        if router_line?(line_string, config)
          lines.push(parse_line(line_string, config))
        end
      end
      lines
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

    def self.parse_field(field, line_string, config)
      if field[:pattern]
        value = line_string[field[:pattern]]
      else
        value = config[:field_parse].call(line_string, field)
      end
      puts "Parsing failed field=#{field} line=#{line_string}" unless (value || field[:optional])
      value = strip_quotes(value)
      value = parse_numeric(value) if field[:numeric]
      value
    rescue Exception => e
      puts "Parsing failed field=#{field} line=#{line_string}: #{e.message}"
      nil
    end

    def self.parse_line(line_string, config)
      config[:fields].reduce({}) do |acc, field|
        if value = parse_field(field, line_string, config)
          acc[field[:name]] = value
        end
        acc
      end
    end

    def self.router_line?(line_string, config)
      line_string =~ config[:papertrail_line] || line_string =~ config[:heroku_line]
    end
  end
end
