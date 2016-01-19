# Booker

Private client to interact with Booker business and customer rest api

## Set-up

Environment Vars that can be set: 
```
ENV['BOOKER_BUSINESS_SERVICE_URL'] can be set for Business Client to not use the sandbox api url
ENV['BOOKER_CUSTOMER_SERVICE_URL'] can be set for Customer Client to not use the sandbox api url
ENV['BOOKER_API_DEBUG'] can be set so that more info about requests will be outputted
ENV['BOOKER_DEFAULT_PAGE_SIZE'] can be set to change the default page size for paginated requests
```

Custom logging can be configured, for example:
```
Booker.config[:log_message] = -> (message, extra_info) { Raven.capture_message(message, extra: extra_info) }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HireFrederick/booker_ruby.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
