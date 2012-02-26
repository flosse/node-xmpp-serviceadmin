# node-xmpp-serviceadmin

Jabber Service Administration
[XEP-0133](http://xmpp.org/extensions/xep-0133.html) library for
[node-xmpp](https://github.com/astro/node-xmpp).

[![Build Status](https://secure.travis-ci.org/flosse/node-xmpp-serviceadmin.png)](http://travis-ci.org/flosse/node-xmpp-serviceadmin)

## Installation

With package manager [npm](http://npmjs.org/):

    npm install node-xmpp-serviceadmin

## Usage

```coffeescript
xmpp  = require "node-xmpp"
sa    = require "node-xmpp-serviceadmin"

# define the host
service = "example.org"

# define the JID that has the admin privileges
root    = "root@mycomponent.example.org"

# creat the xmpp connection
comp = new xmpp.Component
  jid       : "mycomponent"
  password  : "secret"
  host      : "127.0.0.1"
  port      : "8888"

serviceAdmin = new sa.ServieAdmin root, comp, service

# creating a new user
serviceAdmin.addUser "jid@example.org", "secret", { name: "Der Weihnachtsmann" }, (err) ->

# changing a user password
serviceAdmin.changeUserPassword "jid@example.org", "newSecret", (err) ->

# delete a user
serviceAdmin.deleteUser "jid@example.org", (err) ->
```

## Running tests

```shell
jasmine-node --coffee spec/
```

## License

node-xmpp-serviceadmin is licensed under the MIT-Licence
(see LICENSE.txt)
