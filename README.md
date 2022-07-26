# adaptive_alias

[![Gem Version](https://img.shields.io/gem/v/adaptive_alias.svg?style=flat)](http://rubygems.org/gems/adaptive_alias)
[![Build Status](https://github.com/khiav223577/adaptive_alias/workflows/Ruby/badge.svg)](https://github.com/khiav223577/adaptive_alias/actions)
[![RubyGems](http://img.shields.io/gem/dt/adaptive_alias.svg?style=flat)](http://rubygems.org/gems/adaptive_alias)
[![Code Climate](https://codeclimate.com/github/khiav223577/adaptive_alias/badges/gpa.svg)](https://codeclimate.com/github/khiav223577/adaptive_alias)
[![Test Coverage](https://codeclimate.com/github/khiav223577/adaptive_alias/badges/coverage.svg)](https://codeclimate.com/github/khiav223577/adaptive_alias/coverage)

Extend attribute_alias and make it be adaptive with realtime database schema.

When we are going to rename a column, we may want to add a forward-patch so that we can use new column name before migration. And after migration, we may want to add a backward-patch so that those where are still using old column name will not be broken.
Ideally, we switch from forward-patch to backward-patch right after migration:
```rb
                   ForwardPatch           migrate            BackwardPatch
    |----------------------------------------|----------------------------------------|
    
``` 

But in reality, it will take times to deploy and restart server to switch patch. There is a gap between migration and restart. So what will happen when db is migrated but server is not restarted?
We need a way to automatically adjust the patch to adapt current schema.

```rb
                   ForwardPatch           migrate   restart     BackwardPatch
    |----------------------------------------|---@-----|-------------------------------| 
                          
```

This is what this gem wants to achieve. We don't want to do complex migrations, take care of backward-compatibiliy, and have any downtime.
Just rely on this gem.


## Supports
- Ruby 2.6 ~ 2.7, 3.0 ~ 3.1
- Rails 6.0, 6.1, 7.0

## Installation

```ruby
gem 'adaptive_alias'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adaptive_alias

## Usage


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khiav223577/adaptive_alias. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

