source 'https://rubygems.org'

gem 'capistrano', '>= 3.0.0.pre13'
gem 'ruby-mws'
gem 'model_un'

group :development do
  gem 'shotgun'
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
end

group :test do
  gem 'vcr'
  gem 'rspec'
  gem 'webmock'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'rack-test'
  gem 'timecop'
end

group :production do
  gem 'foreman'
  gem 'unicorn'
end

gem 'endpoint_base', :git => 'git@github.com:spree/endpoint_base.git'
gem 'capistrano-spree', :git => 'git@github.com:spree/capistrano-spree.git', :require => nil
