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

          def filter(expression, values=nil)
            add_parameter(FilterMerger,
                          FilterParameter.new(expression, values))
          end

          def output_columns(value)
            add_parameter(OverwriteMerger,
                          OutputColumnsParameter.new(value))
          end

          def sortby(value)
            add_parameter(OverwriteMerger,
                          SortbyParameter.new(value))
          end
          alias_method :sort, :sortby

          def offset(value)
            parameter(:offset, value)
          end

          def limit(value)
            parameter(:limit, value)
          end

          def paginate(page, per_page: 10)
            page ||= 1
            page = page.to_i
            return self if page < 0

            offset(per_page * page).limit(per_page)
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
        class FilterMerger < ParameterMerger
          def to_parameters
            params1 = @parameters1.to_parameters
            params2 = @parameters2.to_parameters
            params = params1.merge(params2)
            filter1 = params1[:filter]
            filter2 = params2[:filter]
            if filter1.present? and filter2.present?
              params[:filter] = "(#{filter1}) && (#{filter2})"
            else
              params[:filter] = (filter1 || filter2)
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

        # @private
        class FilterParameter
          def initialize(expression, values)
            @expression = expression
            @values = values
          end

          def to_parameters
            if @expression.blank?
              {}
            else
              if @values.blank?
                expression = @expression
              else
                escaped_values = {}
                @values.each do |key, value|
                  escaped_values[key] = escape_filter_value(value)
                end
                expression = @expression % escaped_values
              end
              {
                filter: expression,
              }
            end
          end

          private
          def escape_filter_value(value)
            case value
            when Numeric
              value
            when TrueClass, FalseClass
              value
            when NilClass
              "null"
            when String
              ScriptSyntax.format_string(value)
            when Symbol
              ScriptSyntax.format_string(value.to_s)
            when ::Array
              escaped_value = "["
              value.each_with_index do |element, i|
                escaped_value << ", " if i > 0
                escaped_value << escape_filter_value(element)
              end
              escaped_value << "]"
              escaped_value
            when ::Hash
              escaped_value = "{"
              value.each_with_index do |(k, v), i|
                escaped_value << ", " if i > 0
                escaped_value << escape_filter_value(k.to_s)
                escaped_value << ": "
                escaped_value << escape_filter_value(v)
              end
              escaped_value << "}"
              escaped_value
            else
              value
            end
          end
        end

        # @private
        class OutputColumnsParameter
          def initialize(output_columns)
            @output_columns = output_columns
          end

          def to_parameters
            if @output_columns.blank?
              {}
            else
              case @output_columns
              when ::Array
                output_columns = @output_columns.join(", ")
              when Symbol
                output_columns = @output_columns.to_s
              else
                output_columns = @output_columns
              end
              parameters = {
                output_columns: output_columns,
              }
              if output_columns.include?("(")
                parameters[:command_version] = "2"
              end
              parameters
            end
          end
        end

        # @private
        class SortbyParameter
          def initialize(sortby)
            @sortby = sortby
          end

          def to_parameters
            if @sortby.blank?
              {}
            else
              case @sortby
              when ::Array
                sortby = @sortby.collect(&:to_s).join(", ")
              when Symbol
                sortby = @sortby.to_s
              else
                sortby = @sortby
              end
              {
                sortby: sortby,
              }
            end
          end
        end
      end
    end
  end
end
