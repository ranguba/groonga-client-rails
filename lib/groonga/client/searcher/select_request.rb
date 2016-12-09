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
      module SelectRequest
        # For backward compatibility
        def result_set
          response
        end

        private
        def create_response
          response = super
          response.extend(SourcesSupport)
          response
        end

        module SourcesSupport
          def sources
            @sources ||= fetch_sources
          end

          private
          def fetch_sources
            source_ids = {}
            records.collect do |record|
              model_name, id = record._key.split(/-/, 2)
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
              source = sources[record._key]
              record.source = source
              source
            end
          end
        end
      end
    end
  end
end
