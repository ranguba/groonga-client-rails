require 'test_helper'

class PostsSearcherTest < ActionController::TestCase
  include Groonga::Client::Rails::Fixture

  setup do
    @searcher = PostsSearcher.new
  end

  test "should be untagged" do
    create(:post, body: "<p>Hello <em>World</em></p>")
    result_set = @searcher.search.result_set
    assert_equal(["Hello World"],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should be searchable without match_columns" do
    create(:post, body: "Hello World")
    create(:post, body: "Hello Rails")
    result_set = @searcher.search.query("World").result_set
    assert_equal(["Hello World"],
                 result_set.records.collect {|record| record["body"]})
  end
end
