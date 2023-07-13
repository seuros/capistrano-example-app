# -*- encoding: utf-8 -*-
# stub: sd_notify 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sd_notify".freeze
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Agis Anastasopoulos".freeze]
  s.date = "2021-02-27"
  s.description = "sd_notify can be used to notify systemd about various service status changes of Ruby programs".freeze
  s.email = "agis.anast@gmail.com".freeze
  s.homepage = "https://github.com/agis/ruby-sdnotify".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.33".freeze
  s.summary = "Pure Ruby implementation of systemd's sd_notify(3)".freeze

  s.installed_by_version = "3.2.33" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  else
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  end
end
