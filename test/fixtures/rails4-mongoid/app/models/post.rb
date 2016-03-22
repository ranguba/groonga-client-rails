class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :body, type: String

  # PostsSearcher.add_source(self, columns: [:title, :body, :updated_at])
end
