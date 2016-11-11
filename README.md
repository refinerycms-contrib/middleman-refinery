# Middleman Refinery


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'middleman-refinery' git: 'https://github.com/refinerycms-contrib/middleman-refinery', branch: 'master'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install middleman-refinery

## Configuration

To configure the extension, add the following configuration block to Middleman's config.rb:


Parameter     | Description
----------    |------------
api_url       | the single endpoint of your content repository
api_token     | Refinery API OAuth2 based access token (optional)
api_path      | Refinery API path (optional)
content_types | Content type configuration

For instance:

```ruby
activate :refinery do |f|
  f.api_url = 'http://localhost:3000'
  f.api_token = ENV['REFINERY_API_TOKEN']
  f.content_types = [
    { 
      content_type: 'Blog::Posts', 
      node: 'posts', 
      destination: 'source/blog/data', 
      format: '.html.md',
      mapper: MiddlemanRefinery::BlogPostMapper 
    },
    { content_type: 'Pages' }
  ]
end
```

## Usage

Run `bundle exec middleman refinery --rebuild` in your terminal. 

This will fetch entries for the configured content types and put the resulting data in the specified `destination` folder or [local data folder](https://middlemanapp.com/advanced/local-data/) as yaml files or other `format`s. Finally, it will rebuild the middleman website.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/middleman-refinery/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
