require 'date'

module MiddlemanRefinery
  class BlogPostMapper
    class << self
      def map(entry)
        id = entry.delete("id")
        title = entry.delete("title")
        url = title.parameterize
        date = Date.strptime(entry["published_at"], '%Y-%m-%d').to_s

        {
          "title" => title,
          "url" => url,
          "date" => date,
          "author" => entry.delete("user_id"),
          "tags" => entry.delete("tag_list"),
          "post" => entry.delete("body"),
        }.merge(entry)
      end
    end
  end
end