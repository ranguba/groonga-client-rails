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

Dir.glob("#{__dir__}/apps/*") do |test_application|
  env = {
    "BUNDLE_GEMFILE" => "#{test_application}/Gemfile",
  }
  command_line = [
    "bundle",
    "exec",
    RbConfig.ruby,
    "bin/rake",
    "test",
    "TESTOPTS=#{ARGV.join(' ')}",
  ]
  options = {
    :chdir => test_application,
  }
  unless system(env, *command_line, options)
    exit(false)
  end
end
