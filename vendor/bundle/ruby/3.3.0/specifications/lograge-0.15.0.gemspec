# -*- encoding: utf-8 -*-
# stub: lograge 0.15.0 ruby lib

Gem::Specification.new do |s|
  s.name = "lograge".freeze
  s.version = "0.15.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/roidrage/lograge/blob/master/CHANGELOG.md", "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mathias Meyer".freeze, "Ben Lovell".freeze, "Michael Bianco".freeze]
  s.date = "1980-01-02"
  s.description = "Tame Rails' multi-line logging into a single line per request".freeze
  s.email = ["meyer@paperplanes.de".freeze, "benjamin.lovell@gmail.com".freeze, "mike@mikebian.co".freeze]
  s.homepage = "https://github.com/roidrage/lograge".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "4.0.14".freeze
  s.summary = "Tame Rails' multi-line logging into a single line per request".freeze

  s.installed_by_version = "4.0.6".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<base64>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<bigdecimal>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<mutex_m>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rdoc>.freeze, ["< 8".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.1".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.23".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.21".freeze])
  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 4".freeze])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4".freeze])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 4".freeze])
  s.add_runtime_dependency(%q<request_store>.freeze, ["~> 1.0".freeze])
end
