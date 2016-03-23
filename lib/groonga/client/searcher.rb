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
require "groonga/client/searcher/source"

module Groonga
  class Client
    class Searcher
      class << self
        def schema
          @schema ||= Schema.new(default_table_name)
        end

        def source(model_class)
          sources[model_class] ||= create_source(model_class)
        end

        def sync
          sync_schema
          sync_records
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

        private
        def sources
          @sources ||= {}
        end

        def create_source(model_class)
          source = Source.new(schema, model_class)

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

          source
        end

        def default_table_name
          name.gsub(/Searcher\z/, "").tableize
        end

        def ensure_model_classes_loaded
          ::Rails.application.eager_load!
        end
      end

      def inititalize
      end

      def upsert(model)
        source = self.class.source(model.class)
        record = {}
        source.columns.each do |name, reader|
          case reader
          when Symbol
            value = model.__send__(reader)
          when TrueClass
            value = model.__send__(name)
          when NilClass
            next
          else
            value = reader.call(model)
          end
          record[name] = value
        end
        record["_key"] = model_key(model)
        Client.open do |client|
          client.load(:table => self.class.schema.table,
                      :values => [record])
        end
      end

      def create(model)
        upsert(model)
      end

      def update(model)
        upsert(model)
      end

      def destroy(model)
        Client.open do |client|
          client.delete(table: self.class.schema.table,
                        key: model_key(model))
        end
      end

      def search
        TableRequest.new(self.class.schema.table)
      end

      private
      def model_key(model)
        "#{model.class.name}-#{model.id}"
      end
    end
  end
end
