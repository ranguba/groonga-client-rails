#!/usr/bin/env ruby
#
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

require "rbconfig"

unless system(RbConfig.ruby, "test/unit/run-test.rb", *ARGV)
  exit(false)
end

def unbundler
  ENV["GEM_HOME"] = nil
  ENV["GEM_PATH"] = nil
  ENV["RUBYOPT"]  = nil
end

unbundler

Dir.glob("#{__dir__}/apps/*") do |test_application|
  Dir.chdir(test_application) do
    unless system(RbConfig.ruby, "-S", "bin/rake",
                  "test", "TESTOPTS=#{ARGV.join(' ')}")
      exit(false)
    end
  end
end
