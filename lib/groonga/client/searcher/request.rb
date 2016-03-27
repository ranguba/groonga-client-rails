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

require "active_support/core_ext/object/blank"

module Groonga
  class Client
    class Searcher
      class Request
        def result_set
          @result_set ||= Client.open do |client|
            ResultSet.new(client.select(to_parameters))
          end
        end

        def match_columns(value)
          OverwriteRequest.new(self,
                               MatchColumnsRequest.new(value))
        end

        def query(value)
          QueryMergeRequest.new(self,
                                QueryRequest.new(value))
        end
      end

      class TableRequest < Request
        def initialize(table)
          @table = table
        end

        def to_parameters
          {
            table: @table,
          }
        end
      end

      # @private
      class OverwriteRequest < Request
        def initialize(request1, request2)
          @request1 = request1
          @request2 = request2
        end

        def to_parameters
          @request1.to_parameters.merge(@request2.to_parameters)
        end
      end

      # @private
      class QueryMergeRequest < Request
        def initialize(request1, request2)
          @request1 = request1
          @request2 = request2
        end

        def to_parameters
          params1 = @request1.to_parameters
          params2 = @request2.to_parameters
          params = params1.merge(params2)
          query1 = params1[:query]
          query2 = params2[:query]
          if query1.present? and query2.present?
            params[:query] = "(#{query1}) (#{query2})"
          else
            params[:query] = (query1 || query2)
          end
          params
        end
      end

      class MatchColumnsRequest < Request
        def initialize(match_columns)
          @match_columns = match_columns
        end

        def to_parameters
          if @match_columns.blank?
            {}
          else
            case @match_columns
            when ::Array
              match_columns = @match_columns.join(", ")
            when Symbol
              match_columns = @match_columns.to_s
            else
              match_columns = @match_columns
            end
            {
              match_columns: match_columns,
            }
          end
        end
      end

      class QueryRequest < Request
        def initialize(query)
          @query = query
        end

        def to_parameters
          {
            query: @query,
          }
        end
      end
    end
  end
end
