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

module Groonga
  class Client
    class Searcher
      class Schema
        attr_reader :table
        attr_reader :columns
        def initialize(table)
          @table = table
          @columns = {}
        end

        def table=(name)
          name = name.to_s if name.is_a?(Symbol)
          @table = name
        end

        def column(name, options)
          name = normalize_name(name)
          @columns[name] = Column.new(name, options)
        end

        def have_column?(name)
          name = normalize_name(name)
          @columns.key?(name)
        end

        private
        def normalize_name(name)
          if name.is_a?(Symbol)
            name.to_s
          else
            name
          end
        end

        class Column
          attr_reader :name
          def initialize(name, options)
            @name = name
            @options = options
          end

          def type
            @options[:type] || "Text"
          end

          def normalizer
            @options[:normalizer]
          end

          def text_family_type?
            case type
            when "ShortText", "Text", "LongText"
              true
            else
              false
            end
          end

          def vector?
            @options[:vector]
          end

          def reference?
            @options[:reference]
          end

          def have_index?
            @options[:index]
          end

          def have_full_text_search_index?
            have_index? and @options[:index_type] == :full_text_search
          end
        end
      end
    end
  end
end
