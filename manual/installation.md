Installation is pretty standard:
```sh
gem install rspec-tap-formatters
```

You can install using `bundler` also but do not require it in `Gemfile`.
Make sure to use it as a test dependency:
```ruby
group :test do
  # other gems
  gem 'rspec-tap-formatters', '~> 0.1.0', require: false
end
```

You can also install using the GitHub package registry:
```ruby
source 'https://rubygems.pkg.github.com/avmnu-sng' do
  gem 'rspec-tap-formatters', '~> 0.1.0', require: false
end
```
