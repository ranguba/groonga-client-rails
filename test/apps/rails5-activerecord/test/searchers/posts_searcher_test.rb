require 'test_helper'

class PostsSearcherTest < ActionController::TestCase
  include Groonga::Client::Rails::TestHelper

  setup do
    Post.destroy_all
    @searcher = PostsSearcher.new
  end

  test "should be untagged" do
    Post.create!(title: "Title", body: "<p>Hello <em>World</em></p>")
    result_set = @searcher.search.result_set
    assert_equal(["Hello World"],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should be searchable without match_columns" do
    Post.create!(title: "Title", body: "Hello World")
    Post.create!(title: "Title", body: "Hello Rails")
    result_set = @searcher.search.query("World").result_set
    assert_equal(["Hello World"],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should be searchable by a filter" do
    Post.create!(title: "Title", body: "Hello World")
    Post.create!(title: "Title", body: "Hello Rails")
    result_set = @searcher.
      search.
      filter("body @ %{keyword}", {keyword: "World"}).
      result_set
    assert_equal(["Hello World"],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should be searchable by filters" do
    Post.create!(title: "Title", body: "Hello World")
    Post.create!(title: "Title", body: "Hello Rails")
    Post.create!(title: "Title", body: "Hi World")
    result_set = @searcher.
      search.
      filter("body @ %{keyword}", {keyword: "Hello"}).
      filter("body @ %{keyword}", {keyword: "World"}).
      result_set
    assert_equal(["Hello World"],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should be searchable with special characters by a filter" do
    Post.create!(title: "Title", body: "Hello \"Wo\\rld\"")
    Post.create!(title: "Title", body: "Hello Rails")
    result_set = @searcher.
      search.
      filter("body @ %{keyword}", {keyword: "\"Wo\\rld\""}).
      result_set
    assert_equal(["Hello \"Wo\\rld\""],
                 result_set.records.collect {|record| record["body"]})
  end

  test "should support snippet_html in output_columns" do
    Post.create!(title: "Title", body: "Hello World")
    Post.create!(title: "Title", body: "Hi Rails! Hello!")
    result_set = @searcher.
      search.
      query("Hello").
      output_columns(["_key", "snippet_html(body)"]).
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
    post = Post.create!(title: "Title", body: "Hello World")
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

  test "should support pagination" do
    100.times do |i|
      Post.create!(title: "Title", body: "Hello #{i}")
    end
    result_set = @searcher.search.paginate(3, per_page: 5).result_set
    data = result_set.records.collect do |record|
      record["body"]
    end
    assert_equal([
                   "Hello 10",
                   "Hello 11",
                   "Hello 12",
                   "Hello 13",
                   "Hello 14",
                 ],
                 data)
  end
end
