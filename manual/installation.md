Installation is pretty standard:
```sh
gem install rspec-tap-formatters
```

You can install using `bundler` also but do not require it in `Gemfile`.
Make sure to use it as a test dependency:
```ruby
group :test do
  # other gems
  gem 'rspec-tap-formatter', '~> 0.1.0', require: false
end
```
