require 'shellwords'
require 'json'
require 'virtus'
require 'active_support/all'
require 'active_model'

class AnsibleModule
  include Virtus.model
  include ActiveModel::Validations

  def main
    raise "Not implemented."
  end

  def run
    if valid?
      main
    else
      invalid_json
    end
  rescue StandardError => e
    fail_json(msg: "Failed: #{e.to_s}")
  end

  private

    def exit_json(hash)
      hash = ActiveSupport::HashWithIndifferentAccess.new(hash)
      print JSON.dump(hash)
      exit 0
    end

    def fail_json(hash)
      hash = ActiveSupport::HashWithIndifferentAccess.new(hash)
      hash[:failed] = true
      hash[:msg] ||= "No error message."
      print JSON.dump(hash)
      exit 1
    end

    def invalid_json
      message = 'Invalid parameters: '
      message += errors.full_messages.map { |m| "#{m}." }.join(' ')
      fail_json(msg: message)
    end

  class << self
    def instance
      @instance ||= new(params)
      @instance
    end

    def params
      return @params if @params
      @params = ActiveSupport::HashWithIndifferentAccess.new
      File.open(ARGV[0]) do |fh|
        fh.read().shellsplit.each do |word|
          (key, value) = word.split('=', 2)
          @params[key] = value
        end
      end
      @params
    end
  end
end
