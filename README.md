AnsibleModule
=============

[![Gem Version](https://badge.fury.io/rb/ansible_module.svg)](http://badge.fury.io/rb/ansible_module)

AnsibleModule is a Ruby class that provides basic functionalities as an [Ansible](http://ansible.com) module.

It is distributed as a gem package under the MIT license.

Installation
------------

Add the following to your Ansible playbook:

```yaml
- hosts: web-servers
  tasks:
  - name: Install ansible_module gem
    gem: name=ansible_module user_install=false state=present
```

Note that you should install a Ruby (2.0 or later) on your hosts.

Synopsis
--------

Create the following Ruby script as `library/calc`:

```ruby
require 'ansible_module'

class Calc < AnsibleModule
  attribute :x, Integer
  attribute :y, Integer, default: 100

  validates :x, presence: true, numericality: { only_integer: true }
  validates :y, numericality: { only_integer: true }

  def main
    sum = x + y

    exit_json(x: x, y: y, sum: sum, changed: true)
  end
end

Calc.instance.run
```

Add the following to your Ansible playbook:

```yaml
- hosts: web-servers
  tasks:
  - name: Make a calculation
    calc: x=50 y=50
    register: result
  - debug: >
      msg="sum = {{ result['sum'] }}"
```

License
-------

AnsibleModule is distributed under the MIT license. ([MIT-LICENCE](MIT-LICENCE))
