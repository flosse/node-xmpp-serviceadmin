###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

xmpp = require "node-xmpp-core"

NS        = "http://jabber.org/protocol/admin"
CMD_NS    = "http://jabber.org/protocol/commands"
JID       = "accountjid"
JIDS      = "accountjids"
EMAIL     = "email"
NAME      = "given_name"
SURNAME   = "surname"
PASS      = "password"
PASS_VERY = "password-verify"

class ServiceAdmin

  constructor: (@jid, @comp, @service) ->

  runOneStageCmd: (cmd, fields, next=->) ->

    id = "exec#{(new Date).getTime()}"
    comp = @comp

    handler = (stanza) ->
      if stanza.is('iq') and stanza.attrs?.id is id

        if stanza.attrs.type is 'error'
          comp.removeListener "stanza", handler
          next new Error "could not execute command"

        else if stanza.attrs.type is 'result'

          switch (c = stanza.getChild "command").attrs?.status

            when "executing"
              ServiceAdmin.switchAddr stanza
              ServiceAdmin.fillForm stanza, fields
              comp.send stanza

            when 'completed'
              comp.removeListener "stanza", handler
              if (n = c.getChild "note")?.attrs?.type is "error"
                next new Error n.children?[0]
              else next undefined, c

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

  @fillForm: (stanza, fields) ->
    stanza.attrs.type = "set"
    c = stanza.getChild "command"
    delete c.attrs.status
    x = c.getChild "x"
    x.attrs.type = "submit"
    for xF in x.getChildren "field"
      if (val = fields[xF.attrs.var])?
        xF.remove("value") if xF.getChild("value")?
        if val instanceof Array
          xF.c("value").t(v).up() for v in val
        else
          xF.c("value").t val.toString()

  @getJID: (jid) ->
    if jid instanceof Array
      (ServiceAdmin.getJID x for x in jid)
    else if jid instanceof xmpp.JID
      jid
    else
      jid = new xmpp.JID(jid).bare().toString()

  addUser: (jid, pw, prop={}, next) ->
    data = {}
    data[JID]       = ServiceAdmin.getJID jid
    data[PASS]      = pw
    data[PASS_VERY] = pw
    data[EMAIL]     = prop.email   if prop.email
    data[NAME]      = prop.name    if prop.name
    data[SURNAME]   = prop.surname if prop.surname
    @runOneStageCmd "add-user", data, next

  deleteUser: (jid, next) ->
    data = {}
    data[JIDS] = ServiceAdmin.getJID jid
    @runOneStageCmd "delete-user", data, next

  disableUser: (jid, next) ->
    data = {}
    data[JIDS] = ServiceAdmin.getJID jid
    @runOneStageCmd "disable-user", data, next

  changeUserPassword: (jid, pw, next) ->
    data = {}
    data[JID]   = ServiceAdmin.getJID jid
    data[PASS]  = pw
    @runOneStageCmd "change-user-password", data, next

  getUserPassword: (jid, next) ->
    data = {}
    data[JID]   = ServiceAdmin.getJID jid
    @runOneStageCmd "get-user-password", data, (err, c) ->
      return next err if err
      next undefined, c.getChildByAttr("var", "password", null, true)?.
        getChild("value")?.
        getText()

  endUserSession: (jids, next) ->
    data = {}
    data[JIDS] = ServiceAdmin.getJID jids
    @runOneStageCmd "end-user-session", data, next

module.exports = ServiceAdmin
