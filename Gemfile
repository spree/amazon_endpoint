source 'https://rubygems.org'

gem 'capistrano'
gem 'ruby-mws'

group :development do
  gem 'pry'
end

group :test do
  gem 'vcr'
  gem 'rspec'
  gem 'webmock'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'rack-test'
end

group :production do
  gem 'foreman'
  gem 'unicorn'
end

gem 'endpoint_base', :git => 'git@github.com:spree/endpoint_base.git'
# :path => '../endpoint_base'
