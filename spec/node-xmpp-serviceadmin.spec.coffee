chai        = require 'chai'
should      = chai.should()

ServiceAdmin = require "../lib/ServiceAdmin"

describe "Service Admin", ->

  service = "comp.exmaple.tld"

  xmppClient =
    send: (data) -> xmppComp.channels.stanza data
    onData: (data, cb) ->

  xmppComp =
    channels: {}
    send: (data) -> xmppClient.onData data
    onData: (data) ->
    on: (channel, cb) ->
      @channels[channel] = cb
    jid: service

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
