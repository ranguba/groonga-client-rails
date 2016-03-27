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

clean_white_space = lambda do |entry|
  entry.gsub(/(\A\n+|\n+\z)/, "") + "\n"
end

$LOAD_PATH.unshift(File.join(__dir__, "lib"))
require "groonga/client/rails/version"

Gem::Specification.new do |spec|
  spec.name = "groonga-client-rails"
  spec.version = Groonga::Client::Rails::VERSION
  spec.homepage = "https://github.com/ranguba/groonga-client-rails"
  spec.authors = ["Kouhei Sutou"]
  spec.email = ["kou@clear-code.com"]

  readme = File.read("README.md", :encoding => "UTF-8")
  entries = readme.split(/^\#\#\s(.*)$/)
  clean_white_space.call(entries[entries.index("Description") + 1])
  description = clean_white_space.call(entries[entries.index("Description") + 1])
  spec.summary, spec.description, = description.split(/\n\n+/, 3)
  spec.license = "LGPLv2.1+"
  spec.files = ["README.md", "Rakefile", "Gemfile", "#{spec.name}.gemspec"]
  spec.files += [".yardopts"]
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("doc/text/*")
  spec.test_files += Dir.glob("test/**/*")

  spec.add_runtime_dependency("groonga-client", ">= 0.2.4")
  spec.add_runtime_dependency("rails")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("test-unit")
  spec.add_development_dependency("test-unit-rr")
  spec.add_development_dependency("packnga")
  spec.add_development_dependency("kramdown")
end
