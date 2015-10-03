# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'anti-captcha/version'

Gem::Specification.new do |spec|
  spec.name          = "anti-captcha"
  spec.version       = AntiCaptcha::VERSION
  spec.authors       = ["debbbbie"]
  spec.email         = ["debbbbie@163.com"]
  spec.summary       = "AntiCaptcha api ruby wrapper"
  spec.description   = "AntiCaptcha api ruby wrapper"
  spec.homepage      = "https://github.com/debbbbie/anti-captcha"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"

  spec.add_dependency "httpi"
  spec.add_dependency "activesupport"
end
