class Post < ApplicationRecord
  PostsSearcher.source(self).title = :title
  PostsSearcher.source(self).body = lambda do |model|
    model.body.gsub(/<.*?>/, "")
  end
  PostsSearcher.source(self).updated_at = true
end
