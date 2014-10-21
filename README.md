# Sidekiq::Squelch

Turns down the noise when executing Sidekiq jobs. Shit happens, its a fact. Sidekiq is pretty good at dealing with that by requing when an uncaught exception is thrown. And if you're monitoring errors using something like [Sentry](https://getsentry.com/) this can be a bit noisy when executing something that has a regular failures and recovery (i.e. network calls). Squelch allows you to set thresholds for common errors that occur so that you can cut down the noise and see when something is really going wrong.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-squelch'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-squelch

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sidekiq-squelch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
