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
      module Select
        class ResultSet
          def initialize(response)
            @response = response
          end

          def n_hits
            @response.n_hits
          end
          # For Kaminari
          alias_method :total_count, :n_hits

          # For Kaminari
          def limit_value
            (@response.command[:limit] || 10).to_i
          end

          # For Kaminari
          def offset_value
            (@response.command[:offset] || 0).to_i
          end

          def records
            @records ||= build_records
          end

          def sources
            @sources ||= fetch_sources
          end

          def drilldowns
            @response.drilldowns
          end

          private
          def build_records
            @response.records.collect.with_index do |record, i|
              Record.new(self, i, record)
            end
          end

          def fetch_sources
            source_ids = {}
            records.collect do |record|
              model_name, id = record["_key"].split(/-/, 2)
              source_ids[model_name] ||= []
              source_ids[model_name] << id
            end
            sources = {}
            source_ids.each do |model_name, ids|
              model_name.constantize.find(ids).each_with_index do |model, i|
                sources["#{model_name}-#{ids[i]}"] = model
              end
            end
            records.collect do |record|
              sources[record["_key"]]
            end
          end

          class Record
            def initialize(result_set, nth, raw_record)
              @result_set = result_set
              @nth = nth
              @raw_record = raw_record
            end

            def source
              @result_set.sources[@nth]
            end

            def [](name)
              @raw_record[normalize_name(name)]
            end

            def method_missing(name, *args, &block)
              return super unless args.empty?
              return super unless @raw_record.key?(name.to_s)

              self[name]
            end

            def respond_to_missing?(name, *args, &block)
              return super unless args.empty?
              return super unless @raw_record.key?(name.to_s)

              @raw_record.key?(normalize_name(name))
            end

            private
            def normalize_name(name)
              name.to_s
            end
          end
        end
      end
    end
  end
end
