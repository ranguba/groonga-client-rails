# -*- mode: ruby -*-
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

require "rubygems"
require "bundler/gem_helper"
require "packnga"

task :default => :test

helper = Bundler::GemHelper.new(__dir__)
def helper.version_tag
  version
end

helper.install
spec = helper.gemspec

Packnga::DocumentTask.new(spec) do |task|
  task.original_language = "en"
  task.translate_languages = ["ja"]
end

Packnga::ReleaseTask.new(spec) do
end

desc "Run tests"
task :test do
  ruby("test/run-test.rb")
end
