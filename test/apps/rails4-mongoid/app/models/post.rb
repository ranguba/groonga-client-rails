class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :body, type: String
  field :tags, type: Array

  PostsSearcher.source(self).title = :title
  PostsSearcher.source(self).body = lambda do |model|
    model.body.gsub(/<.*?>/, "")
  end
  PostsSearcher.source(self).tags = true
  PostsSearcher.source(self).updated_at = true

  def tags=(value)
    super(value.reject(&:blank?))
  end
end
