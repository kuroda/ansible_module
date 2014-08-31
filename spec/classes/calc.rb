require 'ansible_module'

class Calc < AnsibleModule
  attribute :x, Integer
  attribute :y, Integer

  validates :x, :y, presence: true, numericality: { only_integer: true, allow_blank: true }

  def main
    sum = x + y

    exit_json(x: x, y: y, sum: sum, changed: true)
  end
end
