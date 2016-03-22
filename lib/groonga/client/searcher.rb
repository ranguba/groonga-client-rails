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

require "groonga/client/searcher/request"
require "groonga/client/searcher/result_set"
require "groonga/client/searcher/schema"
require "groonga/client/searcher/schema_synchronizer"
require "groonga/client/searcher/source_definition"

module Groonga
  class Client
    class Searcher
      class << self
        def schema
          @schema ||= Schema.new(default_table_name)
        end

        def add_source(model_class, columns:)
          sources[model_class] = SourceDefinition.new(model_class, columns)

          searcher_class = self
          model_class.after_create do |model|
            searcher = searcher_class.new
            searcher.create(model)
          end

          model_class.after_update do |model|
            searcher = searcher_class.new
            searcher.update(model)
          end

          model_class.after_destroy do |model|
            searcher = searcher_class.new
            searcher.destroy(model)
          end
        end

        def fetch_source_definition(source)
          sources.fetch(source.class)
        end

        def sync
          sync_schema
          sync_records
        end

        private
        def sources
          @sources ||= {}
        end

        def default_table_name
          name.gsub(/Searcher\z/, "").tableize
        end

        def sync_schema
          current_schema = Client.open do |client|
            client.schema
          end
          syncher = SchemaSynchronizer.new(schema, current_schema)
          syncher.sync
        end

        def sync_records
          ensure_model_classes_loaded
          sources.each do |model_class, definition|
            all_records = model_class.all
            if all_records.respond_to?(:find_each)
              enumerator = all_records.find_each
            else
              enumerator = all_records.each
            end
            searcher = new
            enumerator.each do |model|
              searcher.upsert(model)
            end
          end
        end

        def ensure_model_classes_loaded
          ::Rails.application.eager_load!
        end
      end

      def inititalize
      end

      def upsert(source)
        definition = self.class.fetch_source_definition(source)
        record = {}
        definition.columns.each do |name, _|
          record[name.to_s] = source.__send__(name)
        end
        record["_key"] = source_key(source)
        Client.open do |client|
          client.load(:table => self.class.schema.table,
                      :values => [record])
        end
      end

      def create(source)
        upsert(source)
      end

      def update(source)
        upsert(source)
      end

      def destroy(source)
        Client.open do |client|
          client.delete(table: self.class.schema.table,
                        key: source_key(source))
        end
      end

      def search
        TableRequest.new(self.class.schema.table)
      end

      private
      def source_key(source)
        "#{source.class.name}-#{source.id}"
      end
    end
  end
end
