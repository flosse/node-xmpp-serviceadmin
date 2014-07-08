chai          = require 'chai'
should        = chai.should()
xmpp          = require "node-xmpp-core"
ServiceAdmin  = require "../src/ServiceAdmin"

describe "The Service Admin", ->

  service = "comp.exmaple.tld"

  xmppClient =
    send: (data) -> xmppComp.channels.stanza data
    onData: (data, cb) ->

  xmppComp =
    channels: {}
    send: (data) -> xmppClient.onData data
    onData: (data) ->
    on: (channel, cb) -> @channels[channel] = cb
    connection: { jid: service }
    removeListener: ->

  beforeEach -> @admin = new ServiceAdmin "admin@xy.tld", xmppComp, service

  describe "constructor", ->

    it "creates a new ServiceAdmin object", ->

      # define the JID that has the admin privileges
      root = "root@#{service}"
      serviceAdmin = new ServiceAdmin root, xmppComp, service
      serviceAdmin                    .should.be.an.  object
      serviceAdmin.jid                .should.equal   root
      serviceAdmin.service            .should.equal   service
      serviceAdmin.addUser            .should.be.a.   function
      serviceAdmin.deleteUser         .should.be.a.   function
      serviceAdmin.changeUserPassword .should.be.a.   function

  describe "'addUser' method", ->

    it "takes a JID, a password, optinal properties \
        and a callback as parameters", (done) ->

      @admin.runOneStageCmd = (cmd, data, next) =>

        cmd.should.equal "add-user"
        data.accountjid           .should.equal "foo@bar"
        data.password             .should.equal "baz"
        data['password-verify']   .should.equal "baz"

        should.not.exist data.email
        should.not.exist data.given_name
        should.not.exist data.surname

        @admin.runOneStageCmd = (cmd, data, next) =>

          cmd                     .should.equal "add-user"
          data.accountjid         .should.equal "x@y"
          data.password           .should.equal "z"
          data['password-verify'] .should.equal "z"
          data.email              .should.equal "foo@bar.baz"
          data.given_name         .should.equal "no"
          data.surname            .should.equal "name"
          done()

        @admin.addUser "x@y", "z",
          email:    "foo@bar.baz"
          name:     "no"
          surname:  "name"

      @admin.addUser "foo@bar/res", "baz", ->

  describe "'deleteUser' method", ->

    it "takes one or multiple JIDs and a callback as parameters", (done) ->

      @admin.runOneStageCmd = (cmd, data, next) =>
        cmd.should.equal "delete-user"
        data.accountjids.should.eql "foo@bar"

        @admin.runOneStageCmd = (cmd, data, next) =>
          cmd.should.equal "delete-user"
          data.accountjids.should.eql ["x@y", "z@a"]
          done()

        @admin.deleteUser ["x@y/a", "z@a/b"], ->

      @admin.deleteUser "foo@bar/x", ->

  describe "'changeUserPassword' method", ->

    it "takes the JID, the new password and a callback as parameters", (done) ->

      @admin.runOneStageCmd = (cmd, data, next) =>
        cmd.should.equal "change-user-password"
        data.accountjid.should.eql "b@r"
        data.password.should.eql "new"
        done()

      @admin.changeUserPassword "b@r/t", "new", ->

  describe "'getUserPassword' method", ->

    it "takes the JID and a callback as parameters", (done) ->

      xmppClient.onData = (x) ->

        s = new xmpp.Stanza.Iq {type: 'result', id: x.attrs.id}
        s.c("command", status: "completed")
          .c("x",{type: 'result'})
            .c("field", type: "hidden", var:"FORM_TYPE")
              .c("value")
                .t("http://jabber.org/protocol/admin")
              .up()
            .up()
            .c("field", var:"accountjid")
              .c("value")
                .t("b@r/t")
              .up()
            .c("field", var:"password")
              .c("value")
                .t("topSecret")
              .up()
        xmppClient.send s

      @admin.getUserPassword "b@r/t", (err, pw) ->
        should.not.exist err
        pw.toString().should.equal "topSecret"
        done()

  describe "'endUserSession' method", ->

    it "takes an array of JIDs and a callback as parameters", (done) ->

      xmppClient.onData = (x) ->

        s = new xmpp.Stanza.Iq {type: 'result', id: x.attrs.id}
        s.c("command", status: "completed")
        xmppClient.send s

      @admin.endUserSession ["b@r/t", "foo@bar.baz"], (err, res) ->
        should.not.exist err
        res.children.length.should.equal 0
        done()

  describe "'disableUser' method", ->

    it "takes an array of JIDs and a callback as parameters", (done) ->

      xmppClient.onData = (x) ->

        s = new xmpp.Stanza.Iq {type: 'result', id: x.attrs.id}
        s.c("command", status: "completed")
        xmppClient.send s

      @admin.disableUser ["b@r/t", "foo@bar.baz"], (err, res) ->
        should.not.exist err
        res.children.length.should.equal 0
        done()

  describe "'fillForm' helper method", ->

    it "takes the request stanza and converts is to a response stanza", ->
      s = new xmpp.Stanza.Iq {type: 'result'}
      s.c("command", status: "executing").c("x")
        .c("field", var: "foo").up()
        .c("field", var: "bar").c("required").up().up()
        .c("field", var: "baz").up()

      fields =
        foo: "a"
        bar: ["b"]
        baz: ["c", "d"]

      ServiceAdmin.fillForm s, fields
      s.attrs.type.should.equal "set"
      should.not.exist (c = s.getChild "command").attrs.status
      (x = c.getChild "x").attrs.type.should.equal "submit"
      (f = x.getChildren "field").length.should.equal 3
      f[0].getChild("value").children[0].should.equal "a"
      f[1].getChild("value").children[0].should.equal "b"
      f[2].getChildren("value")[0].children[0].should.equal "c"
      f[2].getChildren("value")[1].children[0].should.equal "d"

    it "removes existing values", ->
      s = new xmpp.Stanza.Iq {type: 'result'}
      s.c("command", status: "executing").c("x")
        .c("field", var: "foo")
          .c("value").t("an existing value").up()
          .c("value").t("an other existing value")

      ServiceAdmin.fillForm s, foo: "a"
      f = s.getChild("command").getChild("x").getChildren "field"
      f[0].getChild("value").children[0].should.equal "a"

  describe "'runOneStageCmd' helper method", ->

    it "catches errors", (done) ->

      xmppClient.onData = (x) ->
        s = new xmpp.Stanza.Iq {type: 'result', id: x.attrs.id}
        s.c("command", status: "completed")
          .c("note",{type: 'error'}).t("foo bar baz")
        xmppClient.send s

      @admin.runOneStageCmd "foo", {}, (err) ->
        err.message.should.equal "foo bar baz"
        done()
