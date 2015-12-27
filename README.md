# AntiCaptcha [![Build Status](https://secure.travis-ci.org/debbbbie/anti-captcha.png)](http://travis-ci.org/debbbbie/anti-captcha)

anti-captcha.com ruby api wrapper

## Installation

Add this line to your application's Gemfile:

    gem 'anti-captcha'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install anti-captcha

## Usage example

Configure with api params

```ruby
AntiCaptcha.configure do |config|
  config.key = 'api_key'
  config.min_len = 6
  config.max_len = 10
end
```

```ruby
@client = AntiCaptcha::Client.new(retries_count: 5, phrase: 1)
code = @client.decode(image_content)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
