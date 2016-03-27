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

require_relative "test_helper"

class MatchColumnsRequestTest < Test::Unit::TestCase
  def match_columns_request(match_columns)
    Groonga::Client::Searcher::MatchColumnsRequest.new(match_columns)
  end

  def test_nil
    assert_equal({},
                 match_columns_request(nil).to_parameters)
  end

  def test_string
    assert_equal({
                   :match_columns => "title",
                 },
                 match_columns_request("title").to_parameters)
  end

  def test_empty_string
    assert_equal({},
                 match_columns_request("").to_parameters)
  end

  def test_symbol
    assert_equal({
                   :match_columns => "title",
                 },
                 match_columns_request(:title).to_parameters)
  end

  def test_array
    assert_equal({
                   :match_columns => "title, body",
                 },
                 match_columns_request(["title", "body"]).to_parameters)
  end

  def test_empty_array
    assert_equal({},
                 match_columns_request([]).to_parameters)
  end
end
