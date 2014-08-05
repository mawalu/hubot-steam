{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require 'hubot'

Steam   = require 'steam'
request = require 'request'

class SteamBot extends Adapter

  constructor: ( robot ) ->
    @robot = robot

  run: ->
    login =
      accountName: process.env.HUBOT_STEAM_NAME,
      password: process.env.HUBOT_STEAM_PASSWORD,

    if process.env.HUBOT_STEAM_CODE
      login.authCode = process.env.HUBOT_STEAM_CODE

    if process.env.HUBOT_STEAM_SENTRY_HASH
      login.shaSentryfile = process.env.HUBOT_STEAM_SENTRY_HASH

    @robot.logger.info login

    @steam = new Steam.SteamClient
    @steam.logOn login
    @robot.logger.info "Running!1"
    
    @steam.on 'friendMsg', @gotFriendMessage
    @steam.on 'loggedOn', @loggedOn
    @steam.on 'chatMsg', @gotGroupMessage
    @steam.on 'friend', @gotFriendActivity
    @steam.on 'error', @error
    @on 'connected', @joinChats

  loggedOn: () =>
    @steam.setPersonaState(Steam.EPersonaState.Online)
    @robot.logger.info "Connected"
    @emit "connected"
    @emit "relationships"

  gotFriendMessage: (source, message, type) =>
    if message != ""
      @getProfileUrl source, () ->
        user = id: source, name: @steamurl, room: 'priv'
        @receive new TextMessage user, message, 1

  gotGroupMessage: (source, message, type, chatter) =>
    if message != ""
      @getProfileUrl chatter, () ->
        details = id: source, name: @steamurl, room: source
        @receive new TextMessage details, message, 1

  gotFriendActivity: (source, type) =>
    if type == Steam.EFriendRelationship.PendingInvitee
      @robot.logger.info "Recived friend request"
      @steam.addFriend(source)

  send: (envelope, messages...) =>
     for message in messages
      @steam.sendMessage(envelope.user.id,message, Steam.EChatEntryType.ChatMsg)

  reply: (envelope, messages...) =>
    for message in messages
      @steam.sendMessage(envelope.user.id,message, Steam.EChatEntryType.ChatMsg)

  error: (e) =>
    @robot.logger.error e.cause

  joinChats: () =>
    for room in process.env.HUBOT_STEAM_CHATS.split ","
      @robot.logger.info "Joining groupchat #{room}"
      @steam.joinChat room unless room is ""

  getProfileUrl: (id, callback) =>
    if @robot.brain.userForId(id).name isnt id
      @steamurl = @robot.brain.userForId(id).name
      callback.call @
    else
      parent = @
      request
        uri: "https://steamcommunity.com/profiles/#{id}"
        followRedirect: false
        , (err, res, body) ->

          parent.steamurl = "noname"

          if res.statusCode is 302
            parent.robot.logger.error err if err
            redirect = res.headers.location.split "/"
            parent.steamurl = redirect[4] unless redirect[3] is "profiles"
            parent.robot.brain.userForId id, { name: parent.steamurl, room: "steam"  }

          callback.call parent
      .call @

exports.use = (robot) ->
  new SteamBot robot
