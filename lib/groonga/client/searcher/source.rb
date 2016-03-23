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
      class Source
        attr_reader :model_class
        attr_reader :columns
        def initialize(schema, model_class)
          @schema = schema
          @model_class = model_class
          @columns = {}
        end

        def []=(name, reader)
          unless @schema.have_column?(name)
            message = "unknown column name: #{name.inspect}"
            available_columns = @schema.columns.keys.join(", ")
            message << "available columns: [#{available_columns}]"
            raise ArgumentError, message
          end
          @columns[name.to_s] = reader
        end

        def method_missing(name, *args, &block)
          return super unless name.to_s.end_with?("=")

          base_name = name.to_s[0..-2]
          if @schema.have_column?(base_name)
            __send__(:[]=, base_name, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(name, include_private)
          return super unless name.to_s.end_with?("=")

          base_name = name.to_s[0..-2]
          @schema.have_column?(base_name)
        end
      end
    end
  end
end
