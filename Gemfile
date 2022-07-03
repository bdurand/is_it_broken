source "https://rubygems.org"

# Cover security vulnerability of not loading github gems over HTTPS (just in case...)
git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development, :test do
  gem "rake"
  gem "rspec", "~> 3.10"
  gem "webmock", "~> 3.14"
  gem "standard", "1.0"
  gem "simplecov", "~> 0.21", require: false
end

group :doc do
  gem "yard"
end
