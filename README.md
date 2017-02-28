# Log Stats

A rubygem for extracting response time and error stats based on log files such as
the Heroku router log. Example usage with Heroku addon papertrail:

```
gem install papertrail
PAPERTRAIL_API_TOKEN=... papertrail --min-time "yesterday 22:00" --max-time "yesterday 22:30" > tmp/papertrail.log
gem install log_stats
log_stats /tmp/papertrail.log
```

To download longer timeperiods, like a whole day, download and gunzip a Papertrail log archive file,
see [examples/papertrail_download](examples/papertrail_download).

You can extract not only web requests but any events you are interested in from your logs.
Here is the API call stats output from the [examples/log_stats](examples/log_stats) script:

```
"requests": {
  "request_count": 265325,
  "response_time_avg": 694.01984,
  "response_time_95p": 2647,
  "apdex": 0.7886,
  "error_rate": 0.00024,
  "timeout_rate": 0.00017
}
"api_calls": {
    "count": 410207,
    "fields": {
      "response_time": {
        "min": 9,
        "max": 17016,
        "avg": 151.11675324896942,
        "median": 136,
        "percentiles": {
          "0.05": 100,
          "0.1": 104,
          "0.15": 108,
          "0.2": 111,
          "0.25": 115,
          "0.3": 119,
          "0.35": 122,
          "0.4": 127,
          "0.45": 131,
          "0.5": 136,
          "0.55": 140,
          "0.6": 145,
          "0.65": 149,
          "0.7": 154,
          "0.75": 162,
          "0.8": 172,
          "0.85": 188,
          "0.9": 211,
          "0.95": 244,
          "0.99": 394,
          "0.999": 1116
        },
        "events": [
          {
            "time": "2017-02-27T14:49:12",
            "url": "https://account.example.se/operators?client=web&country_code=se",
            "method": "get",
            "response_time": 17016
          },
          {
            "time": "2017-02-27T18:56:48",
            "url": "http://sumore02.example.se/api/tve_web/user",
            "method": "get",
            "response_time": 15164
          },
          ...
```

Example Heroku success log line:

```
768004272804798492	2017-02-14T03:41:49	2017-02-14T03:41:49Z	505641143	example-web-prod	54.144.85.82	Local3	Info	heroku/router	at=info method=GET path="/filmer/med/glenn-erland-tosterud" host=www.example.se request_id=29cb0a66-23f9-4ef4-999a-65f8de089208 fwd="216.244.66.238,23.54.19.54" dyno=web.5 connect=0ms service=210ms status=200 bytes=52867
```

Example Heroku error log line:

```
768277650920906757	2017-02-14T21:48:07	2017-02-14T21:48:08Z	505641143	example-web-prod	54.196.126.116	Local3	Info	heroku/router	at=error code=H12 desc="Request timeout" method=GET path="/serie/74763-alvinnn-og-gjengen-tv-serien/sesong-1/episode-2/3282212-alvinnn-og-gjengen-tv-serien-forelsket-i-rektor-norsk-tale" host=www.example.no request_id=f5c2921a-3974-4522-8fdf-d9bfff8b1db9 fwd="163.172.66.89,80.239.216.108" dyno=web.5 connect=0ms service=30001ms status=503 bytes=0
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Resources:

* Heroku Logging: https://devcenter.heroku.com/articles/logging
* Heroku Error Codes: https://devcenter.heroku.com/articles/error-codes
* Papertrail archives: https://papertrailapp.com/account/archives
* Papertrail archive download: http://help.papertrailapp.com/kb/how-it-works/permanent-log-archives/#downloading-multiple-archives
