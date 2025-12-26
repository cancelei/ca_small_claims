require "webmock/rspec"

# Allow connections to localhost for system tests
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [
    /chromedriver/,
    /selenium/
  ]
)
