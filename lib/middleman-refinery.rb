require 'refinery/api'
require 'middleman-refinery/version'
require 'middleman-refinery/commands/refinery'

module MiddlemanRefinery
  class << self
    attr_reader :options
  end

  class Core < Middleman::Extension

    option :api_url, nil, 'The Refinery CMS API url'
    option :release, 'master', 'Content release'
    option(
      :link_resolver,
      ->(link) {"http://www.example.com/#{link.type.pluralize}/#{link.slug}"},
      'The link resolver'
    )
    option :custom_queries, {}, 'Custom queries'

    def initialize(app, options_hash={}, &block)
      super

      MiddlemanRefinery.instance_variable_set('@options', options)
    end

    helpers do
      Dir["data/refinery_*"].each do |file|
        define_method(file.gsub('data/refinery_','')) do
          YAML::load(File.read(file)).values
        end
      end

      def reference
        ref = YAML::load(File.read('data/refinery_reference'))
        ref.class.send(
          :define_method, :link_to, MiddlemanRefinery.options.link_resolver
        )

        return ref
      end
    end
  end

end

::Middleman::Extensions.register(:refinery, MiddlemanRefinery::Core)
