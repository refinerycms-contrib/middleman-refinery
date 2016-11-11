module MiddlemanRefinery
  class BlogPostMapper
    class << self
      def map(entry)
        title = entry.delete("title")
        url = title.parameterize

        {
          title: title,
          url: url,
          date: entry.delete("published_at"),
          author: entry.delete("user_id"),
          tags: entry.delete("tag_list"),
          post: entry.delete("body"),
        }
      end
    end
  end
end