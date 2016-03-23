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

require "groonga/client/rails/groonga_server_runner"

module Groonga
  class Client
    module Rails
      module Fixture
        extend ActiveSupport::Concern

        included do
          if singleton_class.method_defined?(:setup)
            setup do
              setup_groonga
            end

            teardown do
              teardown_groonga
            end
          elsif singleton_class.method_defined?(:before)
            before(:each) do
              setup_groonga
            end

            after(:each) do
              teardown_groonga
            end
          end
        end

        def setup_groonga
          @groonga_server_runner = GroongaServerRunner.new
          @groonga_server_runner.run
        end

        def teardown_groonga
          return if @groonga_server_runner.nil?
          @groonga_server_runner.stop
        end
      end
    end
  end
end
