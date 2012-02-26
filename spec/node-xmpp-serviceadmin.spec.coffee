sa    = require "../lib/ServiceAdmin"
ltx   = require "ltx"

describe "Service Admin", ->

  service   = "comp.exmaple.tld"

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
    serviceAdmin = new sa.ServiceAdmin root, xmppComp, service
    (expect typeof serviceAdmin).toEqual "object"
    (expect serviceAdmin.jid).toEqual root
    (expect serviceAdmin.service).toEqual service
    (expect typeof serviceAdmin.addUser).toEqual "function"
    (expect typeof serviceAdmin.deleteUser).toEqual "function"
    (expect typeof serviceAdmin.changeUserPassword).toEqual "function"
