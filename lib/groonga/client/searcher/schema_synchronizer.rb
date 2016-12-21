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
      class SchemaSynchronizer
        def initialize(schema, current_schema)
          @schema = schema
          @current_schema = current_schema
        end

        def sync
          sync_table
          sync_columns
        end

        private
        def sync_table
          current_table = find_current_table
          return if current_table # TODO: validation

          Client.open do |client|
            client.table_create(:name => @schema.table,
                                :flags => "TABLE_PAT_KEY",
                                :key_type => "ShortText")
          end
        end

        def sync_columns
          current_columns = find_current_columns
          @schema.columns.each do |_, column|
            sync_column(column, current_columns[column.name])
          end
        end

        def sync_column(column, current_column)
          if current_column.nil?
            Client.open do |client|
              flags = []
              if column.vector?
                flags << "COLUMN_VECTOR"
              else
                flags << "COLUMN_SCALAR"
              end
              client.column_create(:table => @schema.table,
                                   :name => column.name,
                                   :type => column.type,
                                   :flags => flags.join("|"))
            end
          end

          sync_column_index(column, current_column)
        end

        def sync_column_index(column, current_column)
          if column.have_index?
            lexicon_name = "lexicon_#{@schema.table}_#{column.name}"
            index_column_name = "index"
            if current_column
              indexes = current_column.indexes
            else
              indexes = []
            end
            indexes.each do |index|
              return if index.full_name == "#{lexicon_name}.#{index_column_name}"
            end
            sync_lexicon(column, lexicon_name)
            create_index_column(column, lexicon_name, index_column_name)
          else
            remove_indexes(current_column)
          end
        end

        def sync_lexicon(column, lexicon_name)
          return if @current_schema.tables[lexicon_name]

          parameters = {
            :name => lexicon_name,
            :flags => "TABLE_PAT_KEY",
          }
          if column.have_full_text_search_index?
            parameters[:key_type] = "ShortText"
            parameters[:default_tokenizer] = "TokenBigram"
            parameters[:normalizer] = "NormalizerAuto"
          else
            parameters[:key_type] = column.type
            if column.text_family_type?
              parameters[:normalizer] = "NormalizerAuto"
            end
          end
          Client.open do |client|
            client.table_create(parameters)
          end
        end

        def create_index_column(column, lexicon_name, index_column_name)
          flags = "COLUMN_INDEX"
          flags += "|WITH_POSITION" if column.have_full_text_search_index?
          Client.open do |client|
            client.column_create(:table => lexicon_name,
                                 :name => index_column_name,
                                 :flags => flags,
                                 :type => @schema.table,
                                 :source => column.name)
          end
        end

        def remove_indexes(current_column)
          return if current_column.nil?
          current_column.indexes.each do |index|
            Client.open do |client|
              clinet.column_remove(:table => index.table.name,
                                   :name => index.name)
            end
          end
        end

        def find_current_table
          @current_schema.tables[@schema.table]
        end

        def find_current_columns
          current_table = find_current_table
          if current_table.nil?
            {}
          else
            current_table.columns
          end
        end
      end
    end
  end
end
