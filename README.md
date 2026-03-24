# Logcast

[![Gem Version](https://badge.fury.io/rb/logcast.svg)](https://rubygems.org/gems/logcast)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Ship your Rails logs to [Logcast](https://www.logcast.sh) with zero external dependencies.

Logcast is a drop-in Rails logger that buffers log entries in memory and flushes them in batches to the Logcast ingest API via a background thread. Your existing Rails logging continues to work as normal — Logcast simply taps into it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "logcast"
```

Then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install logcast
```

## Quick Start

1. Get your API key from [logcast.dev](https://www.logcast.sh)

2. Create an initializer:

```ruby
# config/initializers/logcast.rb
Logcast.configure do |config|
  config.api_key = ENV["LOGCAST_API_KEY"]
end
```

That's it. Your Rails logs now flow to Logcast automatically — no other code changes needed.

## Configuration

| Option           | Default                      | Description                                          |
|------------------|------------------------------|------------------------------------------------------|
| `api_key`        | `nil`                        | **Required.** Your Logcast project API key.          |
| `url`            | `"https://www.logcast.sh"`  | Logcast ingest endpoint.                             |
| `flush_interval` | `5`                          | Seconds between background flushes.                  |
| `batch_size`     | `100`                        | Max entries buffered before an immediate flush.       |
| `enabled`        | `true`                       | Enable or disable log shipping.                      |

```ruby
Logcast.configure do |config|
  config.api_key        = ENV["LOGCAST_API_KEY"]
  config.url            = "https://www.logcast.sh"  # default
  config.flush_interval = 5                          # seconds, default
  config.batch_size     = 100                        # default
  config.enabled        = true                         # default
end
```

### Per-Environment Usage

Use `enabled` to control which environments ship logs:

```ruby
Logcast.configure do |config|
  config.api_key = ENV["LOGCAST_API_KEY"]
  config.enabled = Rails.env.production? || Rails.env.staging?
end
```

When `enabled` is `false`, no background thread is started and log entries are silently discarded.

## How It Works

1. **Intercepts** — Wraps `Rails.logger` to capture every log call.
2. **Buffers** — Stores entries in a thread-safe in-memory array.
3. **Flushes** — A background thread sends batches to the Logcast API every `flush_interval` seconds, or immediately when `batch_size` is reached.
4. **Passes through** — All logs still go to the original Rails logger, so your existing output (console, file, etc.) is unaffected.
5. **Shuts down gracefully** — Remaining buffered logs are flushed on process exit via `at_exit`.

Logcast never raises exceptions that could crash your application. Transport errors are silently logged to `STDERR`.

## Requirements

- Ruby >= 3.0
- Rails (auto-configures via Railtie)
- **Zero external dependencies** — uses only Ruby stdlib (`net/http`, `json`, `uri`)

## Development

```bash
# Run the test suite
bundle exec rspec

# Build the gem locally
bundle exec rake build

# Install the gem locally
bundle exec rake install
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/chrisjeon/logcast-rb).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
