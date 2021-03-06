require 'middleman-cli'
require 'yaml'
require 'json'
require 'date'
require 'fileutils'
require 'pry'

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

        ::Refinery::API.configure do |conf|
          conf.api_token = configs.api_token
          conf.api_url = configs.api_url
          conf.api_path = configs.api_path
        end

        configs.content_types.each do |ct|
          client = eval("::Refinery::API::#{ct[:content_type]}.new")
          client_index_body = JSON.parse(client.index.body)
          content_type_param = ct[:content_type].parameterize
          destination = "#{ct[:destination] || 'data'}/refinery/#{content_type_param}"
          format = ct[:format] || '.yml'
          node = ct[:node]

          if client_index_body.has_key?("error")
            say_status "Skip: `#{client_index_body}`" 
          else
            FileUtils.mkdir_p destination unless File.exists?(destination)
            FileUtils.rm_rf(Dir.glob("#{destination}/*"))

            client_index_body[node].each do |client_index|
              content = JSON.parse(client.show(id: client_index["id"]).body)
              
              if content
                if node == 'posts'
                  content = MiddlemanRefinery::BlogPostMapper.map(content)
                  date = Date.strptime(content["date"], '%Y-%m-%d')
                  filename = "#{date}-#{content["url"]}#{format}"
                else
                  filename = "#{content["url"].parameterize}#{format}"
                end
                
                File.open("#{destination}/#{filename}", 'w') do |f|
                  f.write(content.to_yaml + ("---" if format == '.html.md') )
                end
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
