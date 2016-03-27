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

require "groonga/client"

module Groonga
  class Client
    # @private
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "groonga/client/railties/groonga.rake"
      end

      initializer "groonga-client.eager_load" do |app|
        app.paths.add("app/searchers",
                      eager_load: true,
                      glob: "**/*_searcher.rb")
      end

      initializer "groonga-client.configure" do |app|
        config_name = :groonga_client
        config_path = Pathname(app.paths["config"].existent.first)
        yaml_path = config_path + "#{config_name}.yml"
        unless yaml_path.exist?
          yaml_path.open("w") do |yaml|
            yaml.puts(<<-YAML)
default: &default
  protocol: http
  # protocol: https
  host: 127.0.0.1
  port: 10041
  # user: alice
  # password: secret
  read_timeout: -1
  # read_timeout: 3
  backend: synchronous

development:
  <<: *default

test:
  <<: *default
  port: 20041

production:
  <<: *default
  host: 127.0.0.1
  read_timeout: 10
            YAML
          end
        end
        Groonga::Client.default_options =
          app.config_for(:groonga_client).deep_symbolize_keys
      end
    end
  end
end
