# Booker Ruby Client

Client for the Booker API. See https://developers.booker.com for method-level documentation.

**Important:** As of version 2.0 of this gem, support for API v4 methods has been removed. Use of v4 APIs should be migrated to the equivalent v4.1 or v5 methods available as part of Booker's new Developer Portal.

[ ![Codeship Status for HireFrederick/booker_ruby](https://codeship.com/projects/a564c190-a133-0133-48cc-22cba843574f/status?branch=master)](https://codeship.com/projects/128449)

## Setup

Add the gem to your Gemfile:

`gem 'booker_ruby', '~> 2.0.0'`

Configuration may be specified via the environment or when initializing Booker::Client:

Configuring via environment variables:
```
BOOKER_CLIENT_ID = YOUR_CLIENT_ID
BOOKER_CLIENT_SECRET = YOUR_CLIENT_SECRET
BOOKER_API_SUBSCRIPTION_KEY = YOUR API SUBSCRIPTION KEY
BOOKER_API_BASE_URL = https://api.booker.com # Defaults to https://api-staging.booker.com
BOOKER_DEFAULT_PAGE_SIZE = 10 # Default
BOOKER_API_DEBUG = false # Set to true to print request details to the log
```

To ease development, **the gem points to Booker's API Sandbox at apicurrent-app.booker.ninja by default**.
For production, you must set BOOKER_API_BASE_URL to https://api.booker.com.

## Using Booker::Client

A client subclass is available for each API:
* [Booker::V5::Availability](lib/booker/v5/availability.rb)
* [Booker::V41::Availability](lib/booker/v4.1/availability.rb)
* [Booker::V41::Booking](lib/booker/v4.1/booking.rb)
* [Booker::V41::Merchant](lib/booker/v4.1/merchant.rb)

### Authentication

The client supports both refresh_token and client_credentials authorization flows. If a `refresh_token` is provided
or `auth_with_client_credentials` is set to `true`, the client will attempt to request a new access token as needed.

If your API subscription permits, an access token and refresh token for a specific merchant may be retrieved via OAuth.

Access token scopes:
* An access token scope may be provided to instruct the client what type of token should be requested.
You most likely want to use the `public` (default) or `merchant` scope depending on your use case.

```
# Use Booker::V41::Booking to look up a location's details

client = Booker::V41::Booking.new(
  temp_access_token: 'MY TOKEN',
  refresh_token: 'MY REFRESH TOKEN'
)

location = client.location(id: 45678)

location.ID
# => 45678

location.BusinessName
# => 'My Booker Spa'

# Get available services

services = client.services(location_id: location.ID)

# etc..
```

## Available Methods

For available methods, see the API documentation at https://developers.booker.com
* If an API you want to use has not been added to this gem, please contribute via a Pull Request!

## Handling dates and times

* Booker's v5 API is timezone-aware. This gem will parse returned Dates and Times for you and they remain in the offset provided by Booker.
* Booker's v4.1 API is not timezone-aware, so this gem will convert any date-time values from Booker into your current timezone offset per the thread-local `Time.zone`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HireFrederick/booker_ruby.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
