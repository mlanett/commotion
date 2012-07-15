# -*- encoding: utf-8 -*-
require File.expand_path('../lib/commotion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Lanett"]
  gem.email         = ["mark.lanett@gmail.com"]
  gem.description   = %q{Run multiple small tasks at once}
  gem.summary       = %q{Run multiple small tasks at once}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "commotion"
  gem.require_paths = ["lib"]
  gem.version       = Commotion::VERSION
end
