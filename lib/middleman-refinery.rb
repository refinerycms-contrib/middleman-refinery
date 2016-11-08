require 'refinery/api'
require 'middleman-refinery/version'
require 'middleman-refinery/status'
require 'middleman-refinery/mappers/blog_post'
require 'middleman-refinery/commands/refinery'

module MiddlemanRefinery
  class << self
    attr_reader :options
  end

  class Core < Middleman::Extension
    option :api_token, nil, 'The Refinery CMS API token'
    option :api_url, nil, 'The Refinery CMS API url'
    option :api_path, '/api/v1', 'The Refinery CMS API path'
    option :content_types, [], 'Content types'

    def initialize(app, options_hash={}, &block)
      super

      MiddlemanRefinery.instance_variable_set('@options', options)
    end
  end

end

::Middleman::Extensions.register(:refinery, MiddlemanRefinery::Core)