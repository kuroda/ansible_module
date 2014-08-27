AnsibleModule
=============

[![Gem Version](https://badge.fury.io/rb/ansible_module.svg)](http://badge.fury.io/rb/ansible_module)

AnsibleModule is a Ruby class that provides basic functionalities as an [Ansible](http://ansible.com) module.

It is distributed as a gem package under the [MIT-LICENSE](MIT-LICENSE).

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

Example (1)
-----------

### `library/calc`:

```ruby
#!/usr/bin/ruby

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

The values of attributes `x` and `y` are set during instantiation process by `AnsibleModule`.

Note that you can validate them with `validates` class method derived from `ActiveModel`.

#### `calc.yml`

```yaml
- hosts: web-servers
  tasks:
  - name: Make a calculation
    calc: x=50 y=50
    register: result
  - debug: >
      msg="sum = {{ result['sum'] }}"
```


Example (2)
-----------

### `library/mysql_change_master`

```ruby
#!/usr/bin/ruby

require 'ansible_module'

class MysqlChangeMaster < AnsibleModule
  attribute :host, String
  attribute :port, Integer, default: 3306
  attribute :user, String
  attribute :password, String
  attribute :mysql_root_password, String

  validates :port, inclusion: { in: 0..65535 }

  def main
    statement = %Q{
      STOP SLAVE;
      CHANGE MASTER TO
        MASTER_HOST='#{host}',
        MASTER_PORT=#{port},
        MASTER_USER='#{user}',
        MASTER_PASSWORD='#{password}',
        MASTER_AUTO_POSITION=1;
      START SLAVE;
    }.squish

    command = %Q{
      /usr/bin/mysql -u root -p#{mysql_root_password} -e "#{statement}"
    }.squish

    system(command)

    exit_json(statement: statement, changed: true)
  end
end

MysqlChangeMaster.instance.run
```

Note that you can use methods added by `ActiveSupport` like `String#squish`.

### `slave.yml`

```yaml
- hosts: mysql-slave
  tasks:
  - name: Change master to the db1
    mysql: >
      host="db1"
      user="repl"
      password="{{ mysql_repl_password }}"
      mysql_root_password="{{ mysql_root_password }}"
```


License
-------

AnsibleModule is distributed under the [MIT-LICENSE](MIT-LICENSE).
