source "https://rubygems.org"

# Cover security vulnerability of not loading github gems over HTTPS (just in case...)
git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :runtime do
  gemspec
end

group :development, :test do
  gem "rake"
  gem "rspec", "~> 3.9"
end

group :analysis
  # Lock standard to a particular version, esp. cause it's still 0.x.x according to Semver
  gem "standard", "0.4.7"
end

group :doc do
  gem "yard"
end
