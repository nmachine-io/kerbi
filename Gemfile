source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem "activesupport"
gem "thor"
gem 'colorize'
gem 'kubeclient'
gem 'terminal-table'
gem 'spicy-proton'

group :test do
  gem 'rspec', '~> 3.0'
  gem 'codecov'
end

group :test, :development do
  gem 'pry', '~> 0.12.2'
  gem 'yard'
end