class PostsSearcher < ApplicationSearcher
  schema.column :title, {
    type: "ShortText",
    index: true,
    index_type: :full_text_search,
  }
  schema.column :body, {
    type: "Text",
    index: true,
    index_type: :full_text_search,
  }
  schema.column :tags, {
    type: "ShortText",
    vector: true,
    index: true,
  }
  schema.column :updated_at, {
    type: "Time",
    index: true,
  }
end
