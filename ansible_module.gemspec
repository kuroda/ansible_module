version = File.read(File.expand_path("../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name        = "ansible_module"
  s.version     = version
  s.authors     = [ "Tsutomu KURODA" ]
  s.email       = "t-kuroda@oiax.jp"
  s.homepage    = "https://github.com/kuroda/ansible_module"
  s.description = "AnsibleModule is a Ruby class that provides basic functionalities as an Ansible module."
  s.summary     = "AnsibleModule class for Ruby language."
  s.license     = 'MIT'

  s.required_ruby_version = ">= 2.0.0"

  s.add_runtime_dependency "json", "~> 1.8.1"
  s.add_runtime_dependency "virtus", "~> 1.0.3"
  s.add_runtime_dependency "activesupport", "~> 4.1.5"
  s.add_runtime_dependency "activemodel", "~> 4.1.5"

  s.files = %w(README.md CHANGELOG.md MIT-LICENSE VERSION) + Dir.glob("lib/**/*")
end
