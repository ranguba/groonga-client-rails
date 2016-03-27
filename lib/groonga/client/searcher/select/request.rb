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

require "groonga/client/searcher/raw_request"

module Groonga
  class Client
    class Searcher
      module Select
        class Request < RawRequest
          def initialize(table_or_parameters)
            if table_or_parameters.respond_to?(:to_parameters)
              parameters = table_or_parameters
            else
              table_name = table_or_parameters
              parameters = RequestParameter.new(:table, table_name)
            end
            super("select", parameters)
          end

          def result_set
            @result_set ||= ResultSet.new(response)
          end

          def match_columns(value)
            add_parameter(OverwriteMerger,
                          MatchColumnsParameter.new(value))
          end

          def query(value)
            add_parameter(QueryMerger,
                          RequestParameter.new(:query, value))
          end

          private
          def create_request(parameters)
            self.class.new(parameters)
          end
        end

        # @private
        class QueryMerger < ParameterMerger
          def to_parameters
            params1 = @parameters1.to_parameters
            params2 = @parameters2.to_parameters
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

        # @private
        class MatchColumnsParameter
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
      end
    end
  end
end
