source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails',    '5.0.2'
gem 'mysql2',   '0.4.5'
gem 'puma',     '3.7.1'
gem 'bcrypt',   '3.1.11'
gem 'ancestry', '2.2.2'
gem 'jwt',      '1.5.6'
gem 'pundit',   '1.1.0'

group :development, :test do
  gem 'byebug',      '9.0.6'
  gem 'rspec-rails', '3.5.2'
end

group :test do
  gem 'factory_girl_rails', '4.8.0'
  gem 'faker',              '1.7.3'
end
