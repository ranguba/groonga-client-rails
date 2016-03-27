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

  test "should be searchable by a filter" do
    create(:post, body: "Hello World")
    create(:post, body: "Hello Rails")
    result_set = @searcher.
      search.
      filter("body @ %{keyword}", {keyword: "World"}).
      result_set
    assert_equal(["Hello World"],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should be searchable by filters" do
    create(:post, body: "Hello World")
    create(:post, body: "Hello Rails")
    create(:post, body: "Hi World")
    result_set = @searcher.
      search.
      filter("body @ %{keyword}", {keyword: "Hello"}).
      filter("body @ %{keyword}", {keyword: "World"}).
      result_set
    assert_equal(["Hello World"],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should be searchable with special characters by a filter" do
    create(:post, body: "Hello \"Wo\\rld\"")
    create(:post, body: "Hello Rails")
    result_set = @searcher.
      search.
      filter("body @ %{keyword}", {keyword: "\"Wo\\rld\""}).
      result_set
    assert_equal(["Hello \"Wo\\rld\""],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should support snippet_html in output_columns" do
    create(:post, body: "Hello World")
    create(:post, body: "Hi Rails! Hello!")
    result_set = @searcher.
      search.
      query("Hello").
      output_columns("snippet_html(body)").
      result_set
    snippet_htmls = result_set.records.collect do |record|
      record["snippet_html"]
    end
    assert_equal([
                   ["<span class=\"keyword\">Hello</span> World"],
                   ["Hi Rails! <span class=\"keyword\">Hello</span>!"],
                 ],
                 snippet_htmls)
  end

  test "should support Array for output_columns" do
    post = create(:post, body: "Hello World")
    result_set = @searcher.
      search.
      query("World").
      output_columns(["_key", "body"]).
      result_set
    data = result_set.records.collect do |record|
      [
        record["_id"],
        record["_key"],
        record["body"],
      ]
    end
    assert_equal([
                   [
                     nil,
                     "#{post.class}-#{post.id}",
                     "Hello World",
                   ],
                 ],
                 data)
  end
end
