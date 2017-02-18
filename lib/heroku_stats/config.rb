module HerokuStats
  module Config
    def self.default_config
      {
        events: {
          requests: {
            # NOTE: matches Heroku router lines. Also matches Papertrails slightly modified ones.
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
        verbose: true,
        output: "text"
      }
    end
  end
end
