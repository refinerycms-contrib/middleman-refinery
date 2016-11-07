require 'middleman-cli'
require 'yaml'
require 'json'
require 'date'
require 'fileutils'

module Middleman
  module Cli

    class Refinery < Thor::Group
      include Thor::Actions
      include ::MiddlemanRefinery::Status

      # Path where Middleman expects the local data to be stored
      MIDDLEMAN_LOCAL_DATA_FOLDER = 'data'

      check_unknown_options!

      class_option "rebuild",
        aliases: "-r",
        desc: "Rebuilds the site if there were changes in the imported data"

      def self.source_root
        ENV['MM_ROOT']
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      def refinery
        ::Middleman::Application.new

        Dir.mkdir('data') unless File.exists?('data')

        FileUtils.rm_rf(Dir.glob('data/refinery_*'))

        ::Refinery::API.configure do |conf|
          conf.api_token = configs.api_token
          conf.api_url = configs.api_url
          conf.api_path = configs.api_path
        end

        configs.content_types.each do |ct|
          content = eval("::Refinery::API::#{ct[:content_type]}.new")
          content_index_body = JSON.parse(content.index.body)
          content_type_param = ct[:content_type].parameterize
          destination = "#{ct[:destination] || 'data'}/#{content_type_param}"
          format = ct[:format] || '.yml'
          node = ct[:node]

          if content_index_body.has_key?("error")
            say_status "Skip: `#{content_index_body}`" 
          else
           
            FileUtils.mkdir_p destination

            content_index_body[node].each do |content|
              if node == 'posts'
                content = MiddlemanRefinery::BlogPostMapper.map(content)
                date = Date.strptime(content[:date], '%Y-%m-%d')
                filename = "#{date}-#{content[:url]}#{format}"
              else
                filename = "#{content[:url].parameterize}#{format}"
              end
              
              File.open("#{destination}/#{filename}", 'w') do |f|
                f.write(content.to_yaml + ("---" if format == '.html.md') )
              end
            end
          end
        end

        Middleman::Cli::Build.new.build if options[:rebuild]
        say_status 'Refinery content import: Done!'
      end

      private

      def configs
        MiddlemanRefinery.options
      end

      Base.register(self, 'refinery', 'refinery [--rebuild]', 'Import Refinery data to your Data folder')

    end
  end
end
