require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!

  # Filter sensitive data
  config.filter_sensitive_data("<API_KEY>") { ENV["API_KEY"] }
end
