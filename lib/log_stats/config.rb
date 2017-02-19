module LogStats
  module Config
    def self.default_config
      {
        events: {
          requests: {
            # NOTE: matches Heroku router lines. Also matches Papertrails slightly modified lines.
            line_pattern: /\s(heroku\/router)|(heroku\[router\]:)\s/,
            fields: [
              {
                name: :time,
                parse: Proc.new { |line| line[/\b20\d\d-\d\d-\d\dT\d\d:\d\d:\d\d/] }
              },
              {name: :method},
              {name: :host},
              {name: :path},
              {name: :status, numeric: true},
              {name: :code, optional: true},
              {name: :service, numeric: true}
            ],
            top_list_limit: 100,
            apdex: {tolerating: 500, frustrated: 2000},
            apdex_goal: 0.9,
          }
        },
        output_format: "text",
        verbose: true
      }
    end

    def self.env_config
      default_config.keys.reduce({}) do |acc, key|
        value = env_value(key)
        if !value.nil?
          acc[key] = value
        end
        acc
      end
    end

    def self.env_value(key)
      env_key = key.to_s.upcase
      value = ENV[env_key]
      if !value.nil? && boolean?(default_config[key])
        ['1', true, 'true', 't', 'TRUE'].include?(value)
      else
        value
      end
    end

    def self.boolean?(value)
      !!value == value
    end
  end
end
