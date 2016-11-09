# node-xmpp-serviceadmin

Jabber Service Administration
[XEP-0133](http://xmpp.org/extensions/xep-0133.html) library for
[node-xmpp](https://github.com/astro/node-xmpp).

[![Build Status](https://secure.travis-ci.org/flosse/node-xmpp-serviceadmin.svg)](http://travis-ci.org/flosse/node-xmpp-serviceadmin)
[![Dependency Status](https://gemnasium.com/flosse/node-xmpp-serviceadmin.svg)](https://gemnasium.com/flosse/node-xmpp-serviceadmin.png)
[![NPM version](https://badge.fury.io/js/node-xmpp-serviceadmin.svg)](http://badge.fury.io/js/node-xmpp-serviceadmin)

## Installation

With package manager [npm](http://npmjs.org/):

    npm install --save node-xmpp-serviceadmin

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

  // receive a user's password
  sa.getUserPassword(
    "jid@example.org",
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

```erlang
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

## Implemented methods

- 4.1. Add User
- 4.2. Delete User
- 4.5. End User Session
- 4.6. Get User Password
- 4.7. Change User Password

## Missing methods

- 4.3. Disable User
- 4.4. Re-Enable User
- 4.8. Get User Roster
- 4.9. Get User Last Login Time
- 4.10. Get User Statistics
- 4.11. Edit Blacklist
- 4.12. Edit Whitelist
- 4.13. Get Number of Registered Users
- 4.14. Get Number of Disabled Users
- 4.15. Get Number of Online Users
- 4.16. Get Number of Active Users
- 4.17. Get Number of Idle Users
- 4.18. Get List of Registered Users
- 4.19. Get List of Disabled Users
- 4.20. Get List of Online Users
- 4.21. Get List of Active Users
- 4.22. Get List of Idle Users
- 4.23. Send Announcement to Online Users
- 4.24. Set Message of the Day
- 4.25. Edit Message of the Day
- 4.26. Delete Message of the Day
- 4.27. Set Welcome Message
- 4.28. Delete Welcome Message
- 4.29. Edit Admin List
- 4.30. Restart Service
- 4.31. Shut Down Service

## Running tests

```shell
npm install
npm test
```

## License

node-xmpp-serviceadmin is licensed under the MIT-Licence
(see LICENSE.txt)
