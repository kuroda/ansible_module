$LOAD_PATH << File.expand_path('classes', File.dirname(__FILE__))

require 'bundler/setup'
Bundler.setup

require 'ansible_module'

I18n.enforce_available_locales = false

RSpec.configure do |config|
end
