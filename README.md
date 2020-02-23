AnsibleModule
=============

[![Gem Version](https://badge.fury.io/rb/ansible_module.svg)](http://badge.fury.io/rb/ansible_module)

AnsibleModule is a Ruby class that provides basic functionalities as an [Ansible](http://ansible.com) module.

It is distributed as a gem package under the [MIT-LICENSE](MIT-LICENSE).

Installation
------------

### Manual Installation

Install Ruby (2.0 or later) and `ansible_module` gem on your *remote* hosts.

The following is a typical procedure on Ubuntu Server 14.04:

```
$ sudo add-apt-repository -y ppa:brightbox/ruby-ng
$ sudo apt-get update
$ sudo apt-get -y install ruby2.1 ruby2.1-dev
$ sudo gem install ansible_module
```

### Installation with Ansible

Create an Ansible [playbook](http://docs.ansible.com/playbooks.html) to install Ruby and `ansible_module` gem.

The following is an example for Ubuntu Server 14.04:

```yaml
- hosts: servers
  sudo: yes
  tasks:
  - name: Add ppa for ruby
    apt_repository: repo='ppa:brightbox/ruby-ng' state=present
  - name: Install ruby 2.1
    apt: name=ruby2.1 state=present
  - name: Install ruby 2.1 headers
    apt: name=ruby2.1-dev state=present
  - name: Install ansible_module gem
    gem: name=ansible_module user_install=false state=present
```

If you named this file `ruby_environment.yml`, then run the following command on your *local* host:

```
$ ansible-playbook -i hosts ruby_environment.yml
```

In the above example, the `hosts` file is an [inventory](http://docs.ansible.com/intro_inventory.html) which lists up host names or IP addresses.


Example (1) -- Simple Calculation
---------------------------------

### Module

Create a file named `calc` on the `library` directory as follows:

```ruby
#!/usr/bin/ruby
# WANT_JSON

require 'ansible_module'

class Calc < AnsibleModule
  attribute :x, Integer
  attribute :y, Integer

  validates :x, :y, presence: true, numericality: { only_integer: true }

  def main
    sum = x + y

    exit_json(x: x, y: y, sum: sum, changed: true)
  end
end

Calc.instance.run
```

The values of attributes `x` and `y` are set during instantiation process by `AnsibleModule`.

Note that you can validate them with `validates` class method derived from `ActiveModel`.

The class method `instance` returns a singleton instance of `Calc` class,
and its `run` method calls the `main` method if validations are successful.

So, the author of an Ansible module must implement the `main` method at least.


### Playbook

Now, you can use the `calc` module in your playbook.
For example, create a file named `calc.yml` as follows:

```yaml
- hosts: servers
  tasks:
  - name: Make a calculation
    calc: x=50 y=50
    register: result
  - debug: msg="sum = {{ result['sum'] }}"
```

Then, run the following command on your local host:

```
$ ansible-playbook -i hosts calc.yml
```


Example (2) -- MySQL 5.6 Replication Management
-----------------------------------------------

### Prerequisites

Install MySQL 5.6 Server, MySQL 5.6 Client, MySQL 5.6 development files and `mysql2` gem.

The following is a typical procedure on Ubuntu Server 14.04:

```
$ sudo add-apt-repository -y ppa:ondrej/mysql-5.6
$ sudo apt-get update
$ sudo apt-get -y install mysql-server-5.6 mysql-client-5.6 libmysqlclient-dev
$ sudo gem install mysql2
```

You can also install them with the following playbook:

```yaml
- hosts: servers
  sudo: yes
  tasks:
  - name: Add ppa for mysql 5.6
    apt_repository: repo='ppa:ondrej/mysql-5.6' state=present
  - name: Install mysql server 5.6
    apt: name=mysql-server-5.6 state=present
  - name: Install mysql client 5.6
    apt: name=mysql-client-5.6 state=present
  - name: Install libmysqlclient-dev
    apt: name=libmysqlclient-dev state=present
  - name: Install mysql2 gem
    gem: name=mysql2 user_install=false state=present
```


### Module

Create a file named `mysql_change_master` on the `library` directory as follows:

```ruby
#!/usr/bin/ruby
# WANT_JSON

require 'ansible_module'
require 'mysql2'

class MysqlChangeMaster < AnsibleModule
  attribute :host, String
  attribute :port, Integer, default: 3306
  attribute :user, String
  attribute :password, String
  attribute :mysql_root_password, String

  validates :host, :user, :password, presence: true
  validates :port, inclusion: { in: 0..65535 }
  validates :password, maximum: 32

  def main
    done? && exit_json(changed: false)

    statement = %Q{
      CHANGE MASTER TO
        MASTER_HOST='#{host}',
        MASTER_PORT=#{port},
        MASTER_USER='#{user}',
        MASTER_PASSWORD='#{password}',
        MASTER_AUTO_POSITION=1
    }.squish

    mysql_client.query('STOP SLAVE')
    mysql_client.query(statement)
    mysql_client.query('START SLAVE')
    sleep(1)

    if done?
      exit_json(statement: statement, changed: true)
    else
      fail_json(msg: "Last Error: #{@last_error}")
    end
  end

  private

    def done?
      status = mysql_client.query('SHOW SLAVE STATUS').first || {}

      @last_error = [ status['Last_IO_Error'], status['Last_SQL_Error'] ]
        .compact.join(' ').squish

      status['Master_Host'] == host &&
        status['Master_User'] == user &&
        status['Master_Port'].to_i == port &&
        status['Auto_Position'].to_i == 1 &&
        status['Slave_IO_State'] != '' &&
        status['Last_IO_Error'] == '' &&
        status['Last_SQL_Error'] == ''
    end

    def mysql_client
      @client ||= Mysql2::Client.new(
        host: 'localhost',
        username: 'root',
        password: mysql_root_password,
        encoding: 'utf8'
      )
    end
end

MysqlChangeMaster.instance.run
```

Note that you can use methods added by `ActiveSupport` like `String#squish`.

### Playbook

Then, create a file named `replication.yml` as follows:

```yaml
- hosts: mysql-slave
  vars_files:
    - shared/secret.yml
  tasks:
  - name: Change master to the db1
    mysql: >
      host="db1"
      user="repl"
      password="{{ mysql_repl_password }}"
      mysql_root_password="{{ mysql_root_password }}"
```

Next, create a file named `secret.yml` on the `shared` directory as follows:

```secret.yml
mysql_repl_password: p@ssw0rd
mysql_root_password: p@ssw0rd
```

Note that you should replace `p@ssw0rd` with real passwords.

And run the following command on your local host:

```
$ ansible-playbook -i hosts replication.yml
```

You might want to encrypt the `secret.yml` with [ansible-vault](http://docs.ansible.com/playbooks_vault.html).
In that case, you must add `--ask-vault-pass` option to the above command:

```
$ ansible-playbook -i hosts --ask-vault-pass replication.yml
```


License
-------

AnsibleModule is distributed under the [MIT-LICENSE](MIT-LICENSE).
