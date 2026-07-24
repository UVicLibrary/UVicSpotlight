source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Must be a version that supports image transformation with VIPS
gem 'riiif', '>= 2.8.1'
gem 'ruby-vips'

gem 'rails', '~> 7.2.0'

# Bot protection
gem 'bot_challenge_page', github: 'UVicLibrary/bot_challenge_page', branch: 'altcha'
gem 'rack-attack', '~> 6.8'
gem 'reversed'

# Gems for thumbnail generation
gem 'video_thumbnailer'
gem 'streamio-ffmpeg'
gem 'rest-client'

gem 'httparty'
gem 'sortable-rails'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
gem 'mysql2'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'solr_wrapper', '>= 0.3'
  gem 'rspec'
end

group :development do
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 2.15'
  # gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  # gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


gem 'blacklight-spotlight', '4.7.1'
gem 'blacklight', '8.3.0'

gem "bootstrap", "~> 4.0"
gem 'bootstrap_form', '~> 4.0'
# Replaces deprecated icons in Bootstrap 4
gem 'font-awesome-rails'
gem "sassc-rails", "~> 2.1"

gem 'rsolr', '>= 1.0', '< 3'

gem 'jquery-rails'
gem 'sitemap_generator'
gem 'blacklight-gallery'
gem 'blacklight-oembed'
gem 'devise_invitable'

gem 'sidekiq', '~> 7.0'
gem 'redis', '<5'

gem 'down'
gem "posix-spawn" # omit if on JRuby
gem "http_parser.rb"

gem 'ruby-oembed'
gem "psych", '~> 3.3'
gem 'net-http'

# New for Ruby 3
gem 'matrix'


