module HerokuStats
  module Config
    def self.default_config
      {
        fields: [
          {name: :time, pattern: /\b20\d\d-\d\d-\d\dT\d\d:\d\d:\d\d/},
          {name: :method},
          {name: :host},
          {name: :path},
          {name: :status, numeric: true},
          {name: :code, optional: true},
          {name: :service, numeric: true}
        ],
        field_parse: Proc.new { |line_string, field|
          /\b#{field[:name]}=(\S+)/.match(line_string).to_a[1]
        },
        top_list_limit: 100,
        papertrail_line: /\sheroku\/router:?\s/, # NOTE: Papertrails log format differs slightly from Herokus
        heroku_line: /\sheroku\[router\]:\s/,
        apdex: {tolerating: 500, frustrated: 2000},
        apdex_goal: 0.9,
        verbose: true
      }
    end
  end
end
