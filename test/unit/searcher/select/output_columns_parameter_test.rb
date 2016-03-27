# Copyright (C) 2016  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "test_helper"

class SearcherSelectOutputColumnsParameterTest < Test::Unit::TestCase
  def output_columns_parameter(output_columns)
    Groonga::Client::Searcher::Select::OutputColumnsParameter.new(output_columns)
  end

  def test_nil
    assert_equal({},
                 output_columns_parameter(nil).to_parameters)
  end

  def test_string
    assert_equal({
                   :output_columns => "title",
                 },
                 output_columns_parameter("title").to_parameters)
  end

  def test_empty_string
    assert_equal({},
                 output_columns_parameter("").to_parameters)
  end

  def test_symbol
    assert_equal({
                   :output_columns => "title",
                 },
                 output_columns_parameter(:title).to_parameters)
  end

  def test_array
    assert_equal({
                   :output_columns => "title, body",
                 },
                 output_columns_parameter(["title", "body"]).to_parameters)
  end

  def test_empty_array
    assert_equal({},
                 output_columns_parameter([]).to_parameters)
  end

  def test_function
    parameter = output_columns_parameter(["title", "snippet_html(body)"])
    assert_equal({
                   :output_columns => "title, snippet_html(body)",
                   :command_version => "2",
                 },
                 parameter.to_parameters)
  end
end
