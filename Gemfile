source 'https://rubygems.org'

# Specify your gem's dependencies in commotion.gemspec
gemspec

group :development, :test do
  gem "guard-bundler"
  gem "guard-rspec"
  gem "rake"
  gem "rb-fsevent"      # for guard
  gem "rspec"
  gem "ruby_gntp"       # for guard
  gem "terminal-notifier-guard"
end

group :test do
  gem "mysql2"
  gem "simplecov",      require: false
  gem "timecop"
  gem "bson_ext"
end
