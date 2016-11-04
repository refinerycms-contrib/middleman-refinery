require 'middleman-cli'
require 'yaml'
require 'json'
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

        reference = options.release

        Dir.mkdir('data') unless File.exists?('data')

        FileUtils.rm_rf(Dir.glob('data/refinery_*'))

        ::Refinery::API.configure do |conf|
          conf.api_token = options.api_token
          conf.api_url = options.api_url
          conf.api_path = options.api_path
        end

        # api = ::Refinery::API.configure(MiddlemanRefinery.options.api_url)
        # response = api.form('everything').submit(api.ref(reference))


        options.content_types.each do |ct|
          content = eval("::Refinery::API::#{ct[:content_type]}.new")
          content_body = content.index.body

          content_type_param = ct[:content_type].parameterize
          destination = "#{ct[:destination] || 'data'}/#{ct[:content_type].parameterize}"
          FileUtils.mkdir_p destination

          JSON.parse(content_body)[content_type_param].each do |content|
            File.open("#{destination}/#{content["id"]}.yml", 'w') do |f|
              f.write(content.to_yaml)
            end
          end

          File.open("#{ct[:destination] || 'data'}/#{content_type_param}.yml", 'w') do |f|
            f.write(JSON.parse(content_body).to_yaml)
          end
        end

        Middleman::Cli::Build.new.build if options[:rebuild]
        say_status 'Refinery content import: Done!'

        # available_documents = []
        # response.each {|d| available_documents << d.type}

        # available_documents.uniq!

        # available_documents.each do |document_type|
        #   documents = response.select{|d| d.type == document_type}
        #   File.open("data/refinery_#{document_type.pluralize}", 'w') do |f|
        #     f.write(Hash[[*documents.map.with_index]].invert.to_yaml)
        #   end
        # end

        # File.open('data/refinery_reference', 'w') do |f|
        #   f.write(api.master_ref.to_yaml)
        # end

        # MiddlemanRefinery.options.custom_queries.each do |k, v|
        #   response = api.form('everything').query(*v).submit(api.master_ref)
        #   File.open("data/refinery_custom_#{k}", 'w') do |f|
        #     f.write(Hash[[*response.map.with_index]].invert.to_yaml)
        #   end
        # end
      end

      private

      def options
        MiddlemanRefinery.options
      end

      Base.register(self, 'refinery', 'refinery [--rebuild]', 'Import Refinery data to your Data folder')

    end
  end
end
