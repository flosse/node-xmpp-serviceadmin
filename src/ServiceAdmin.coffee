###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

xmpp = require "node-xmpp-core"

NS        = "http://jabber.org/protocol/admin"
CMD_NS    = "http://jabber.org/protocol/commands"
A_JID     = "accountjid"
A_JIDS    = "accountjids"
EMAIL     = "email"
NAME      = "given_name"
SURNAME   = "surname"
PASS      = "password"
PASS_VERY = "password-verify"

class ServiceAdmin

  constructor: (@jid, @comp, @service) ->

  runOneStageCmd: (cmd, fields, next) ->

    id = "exec#{(new Date).getTime()}"
    comp = @comp

    handler = (stanza) ->

      if stanza.is('iq') and stanza.attrs.id is id

        if stanza.attrs.type is 'error'
          comp.removeListener "stanza", handler
          next? new Error "could not execute command"
          
        else if stanza.attrs.type is 'result'
              
          switch stanza.getChild("command").attrs.status

            when "executing"
              ServiceAdmin.switchAddr stanza
              ServiceAdmin.fillForm stanza, fields
              comp.send stanza

            when 'completed'
              comp.removeListener "stanza", handler
              next?()

    @comp.on 'stanza', handler
    cmdIq = ServiceAdmin.createCmdIq @jid, @service, id, cmd
    @comp.send cmdIq
                      
  @createCmdIq: (from, to, id, cmd) ->
    iq = new xmpp.Stanza.Iq { type:'set', from, to, id }
    iq.c "command",
      xmlns: CMD_NS
      node: "#{NS}##{cmd}"
      action:'execute'
    iq

  @switchAddr: (stanza) ->
     me = stanza.attrs.to
     stanza.attrs.to = stanza.attrs.from
     stanza.attrs.from = me

  @fillForm: (stanza,fields) ->
    stanza.attrs.type = "set"
    c = stanza.getChild "command"
    delete c.attrs.status
    x = c.getChild "x"
    req = c.getChildren "required"
    x.attrs.type = "submit"
    for xF in x.getChildren "field"
      if (val = fields[xF.attrs.var])?
        xF.children = []
        xF.c("value").t val

  addUser: (jid, pw, prop={}, next) ->
    data = {}
    data[A_JID]     = [jid]
    data[PASS]      = [pw]
    data[PASS_VERY] = [pw]
    data[EMAIL]     = prop.email   if prop.email
    data[NAME]      = prop.name    if prop.name
    data[SURNAME]   = prop.surname if prop.surname
    @runOneStageCmd "add-user", data, next

  deleteUser: (jid, next) ->
    data = {}
    if typeof jid is "string"
      data[A_JIDS] = [jid]
    else if jid instanceof Array
      data[A_JIDS] = jid
    @runOneStageCmd "delete-user", data, next

  changeUserPassword: (jid, pw, next) ->
    data = {}
    data[A_JID] = jid
    data[PASS] = pw
    @runOneStageCmd "change-user-password", data, next

module.exports = ServiceAdmin
