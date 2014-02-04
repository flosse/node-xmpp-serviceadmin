# node-xmpp-serviceadmin

Jabber Service Administration
[XEP-0133](http://xmpp.org/extensions/xep-0133.html) library for
[node-xmpp](https://github.com/astro/node-xmpp).

[![Build Status](https://secure.travis-ci.org/flosse/node-xmpp-serviceadmin.png)](http://travis-ci.org/flosse/node-xmpp-serviceadmin)
[![Dependency Status](https://gemnasium.com/flosse/node-xmpp-serviceadmin.png)](https://gemnasium.com/flosse/node-xmpp-serviceadmin.png)
[![NPM version](https://badge.fury.io/js/node-xmpp-serviceadmin.png)](http://badge.fury.io/js/node-xmpp-serviceadmin)

## Installation

With package manager [npm](http://npmjs.org/):

    npm install node-xmpp-serviceadmin

## Usage

First of all make sure your server is configured correctly
(see "Configuring your server").
Then you can require and use the module like that:

```javascript
var xmpp          = require("node-xmpp");
var ServiceAdmin  = require("node-xmpp-serviceadmin");

// define the host
var service = "example.org";

// define the JID that has the admin privileges
var root = "root@mycomponent.example.org";

// create the xmpp connection
var comp = new xmpp.Component({
  jid       : "mycomponent",
  password  : "secret",
  host      : "127.0.0.1",
  port      : "8888"
});

var sa = new ServiceAdmin(root, comp, service);

// wait until the component is online
comp.on("online", function(){

  // creating a new user
  sa.addUser(
    "jid@example.org",
    "secret",
    { name: "Der Weihnachtsmann" },
    function(err){ /*...*/ }
  );

  // changing a user password
  sa.changeUserPassword(
    "jid@example.org",
    "newSecret",
    function(err){ /*...*/ }
  );

  // delete a user
  sa.deleteUser(
    "jid@example.org",
    function(err){ /*...*/ }
  );

  // delete multiple users at once
  sa.deleteUser(
    ["jid@example.org","jid2@example.org"],
    function(err){ /*...*/ }
  );

});
```
## Configuring your server

Make sure that:

1. The server supports [XEP-0133](http://xmpp.org/extensions/xep-0133.html)
2. The JID of your component has admin privileges
3. XEP-0133 is enabled

### Prosody

```lua
admins = { "root@example.org", "admin@component.example.org" }

modules_enabled = {
  --
  "admin_adhoc";
  --
};
```

### ejabberd

#### v2.13 and older

```txt
{acl, admin, {user, "root", "example.org"}}.
{acl, admin, {user, "admin", "component.example.org"}}.
```
#### v13.10 and newer

```yml
acl:
  admin:
    user:
      - "root":  "example.org"
      - "admin": "component.example.org"
```

## Running tests

```shell
npm install
npm test
```

## License

node-xmpp-serviceadmin is licensed under the MIT-Licence
(see LICENSE.txt)
