# CLAUDE.md

## Project Overview

Logcast is a Ruby gem that ships logs from Rails applications to the Logcast platform (www.logcast.dev). It provides a drop-in Rails logger that buffers log entries in memory and flushes them in batches to the Logcast ingest API via a background thread.

**Zero dependencies** — uses only `Net::HTTP` from Ruby stdlib.

## Ingest API

The gem posts to the Logcast ingest API:

- **Endpoint:** `POST /api/logs`
- **Auth:** `X-Api-Key` header with the project's API key
- **Content-Type:** `application/json`
- **Payload:**
```json
{
  "logs": [
    {
      "level": "info",
      "message": "Started GET / for 127.0.0.1",
      "metadata": { "request_id": "abc123" },
      "timestamp": "2026-03-17T14:30:00Z"
    }
  ]
}
```
- **Response:** `201 Created` on success, `401 Unauthorized` on invalid API key

## Architecture

- **`Logcast`** — top-level module. Holds configuration, manages the buffer and background flush thread via singleton methods.
- **`Logcast::Buffer`** — thread-safe in-memory array. Accepts log entries, returns and clears batch on flush.
- **`Logcast::LogSubscriber`** — wraps `Rails.logger#add` to intercept log calls, writes to the buffer, and passes through to the original logger.
- **`Logcast::Transport`** — delivers batches to the Logcast ingest API via `Net::HTTP`.
- **`Logcast::Railtie`** — auto-configures in Rails apps. Wires up the logger when `api_key` is present.

## Expected Usage

```ruby
# config/initializers/logcast.rb
Logcast.configure do |config|
  config.api_key = ENV["LOGCAST_API_KEY"]
  config.url = "https://www.logcast.dev"       # optional, this is the default
  config.flush_interval = 5                 # seconds, optional, default 5
  config.batch_size = 100                   # optional, default 100
end
```

Once configured, Rails logs automatically flow to Logcast. No other code changes needed.

## Design Constraints

- Zero external dependencies — only `net/http`, `json`, `uri` from stdlib
- Thread-safe buffer (Mutex)
- Background thread flushes on interval OR when batch_size is reached
- Graceful shutdown — flush remaining buffer on `at_exit`
- Silent failures — never raise exceptions that crash the host app. Log errors to STDERR.
- Works with Ruby 3.0+

## Common Commands

- `bundle exec rspec` — run tests
- `bundle exec rake build` — build the gem
- `bundle exec rake install` — install locally
- `bundle exec rake release` — release to RubyGems

## Code Style

- Use double quotes (`"`)
- No external dependencies
- Keep it minimal — this gem should be small and focused
