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

require "groonga/client/test-helper"
require "groonga/client/rails/test_synchronizer"

module Groonga
  class Client
    module Rails
      module TestHelper
        extend ActiveSupport::Concern

        included do
          include Groonga::Client::TestHelper

          setup do
            syncher = TestSynchronizer.new
            options = {}
            if self.class.respond_to?(:fixture_table_names)
              fixture_table_names = self.fixture_table_names
              options[:sync_records] = true unless fixture_table_names.empty?
            end
            syncher.sync(options)
          end
        end
      end
    end
  end
end
