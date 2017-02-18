# Log Stats

A rubygem for extracting response time and error stats based on log files such as
the Heroku router log. Example usage with Heroku addon papertrail:

```
gem install papertrail
PAPERTRAIL_API_TOKEN=... papertrail --min-time "yesterday 22:00" --max-time "yesterday 22:30" > tmp/papertrail.log
gem install log_stats
log_stats /tmp/papertrail.log
```

To download longer timeperiods, like a whole day, download and gunzip a Papertrail log archive file.

Example Heroku success log line:

```
768004272804798492	2017-02-14T03:41:49	2017-02-14T03:41:49Z	505641143	cmore-web-prod	54.144.85.82	Local3	Info	heroku/router	at=info method=GET path="/filmer/med/glenn-erland-tosterud" host=www.cmore.se request_id=29cb0a66-23f9-4ef4-999a-65f8de089208 fwd="216.244.66.238,23.54.19.54" dyno=web.5 connect=0ms service=210ms status=200 bytes=52867
```
 Example Heroku error log line:

```
768277650920906757	2017-02-14T21:48:07	2017-02-14T21:48:08Z	505641143	cmore-web-prod	54.196.126.116	Local3	Info	heroku/router	at=error code=H12 desc="Request timeout" method=GET path="/serie/74763-alvinnn-og-gjengen-tv-serien/sesong-1/episode-2/3282212-alvinnn-og-gjengen-tv-serien-forelsket-i-rektor-norsk-tale" host=www.cmore.no request_id=f5c2921a-3974-4522-8fdf-d9bfff8b1db9 fwd="163.172.66.89,80.239.216.108" dyno=web.5 connect=0ms service=30001ms status=503 bytes=0
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Resources:

* Heroku Logging: https://devcenter.heroku.com/articles/logging
* Heroku Error Codes: https://devcenter.heroku.com/articles/error-codes
* Papertrail archives: https://papertrailapp.com/account/archives
* Papertrail archive download: http://help.papertrailapp.com/kb/how-it-works/permanent-log-archives/#downloading-multiple-archives
