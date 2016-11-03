require 'middleman-cli'

require 'yaml'
require 'json'
require 'fileutils'
require 'logger'

module Middleman
  module Cli

    class Refinery < Thor::Group
      include Thor::Actions

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

        reference = MiddlemanRefinery.options.release

        Dir.mkdir('data') unless File.exists?('data')

        FileUtils.rm_rf(Dir.glob('data/refinery_*'))

        ::Refinery::API.configure do |conf|
          conf.api_token = MiddlemanRefinery.options.api_token
          conf.api_url = MiddlemanRefinery.options.api_url
          conf.api_path = MiddlemanRefinery.options.api_path
        end

        # api = ::Refinery::API.configure(MiddlemanRefinery.options.api_url)
        # response = api.form('everything').submit(api.ref(reference))

        client = ::Refinery::API::Pages.new
        pages = client.index.body

        File.open('data/refinery_page.yml', 'w') do |f|
          f.write(JSON.parse(pages).to_yaml)
        end

        client = ::Refinery::API::Blog::Posts.new
        posts = client.index.body

        File.open('data/refinery_blog_post.yml', 'w') do |f|
          f.write(JSON.parse(posts).to_yaml)
        end

        Middleman::Cli::Build.new.build if options[:rebuild]
        logger.info 'Refinery content import: Done!'

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

      def logger
        ::Middleman::Logger.singleton
      end

      Base.register(self, 'refinery', 'refinery [--rebuild]', 'Import Refinery data to your Data folder')

    end
  end
end
