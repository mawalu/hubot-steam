{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require 'hubot'

Steam   = require 'steam'
request = require 'request'

class SteamBot extends Adapter

  constructor: ( robot ) ->
    @robot = robot

  run: ->
    login =
      account_name: process.env.HUBOT_STEAM_NAME,
      password: process.env.HUBOT_STEAM_PASSWORD,

    if process.env.HUBOT_STEAM_CODE
      login.authCode = process.env.HUBOT_STEAM_CODE

    if process.env.HUBOT_STEAM_SENTRY_HASH
      login.shaSentryfile = process.env.HUBOT_STEAM_SENTRY_HASH

    @robot.logger.info login

    @steamClient = new Steam.SteamClient()
    @steamClient.connect();
    @steamUser = new Steam.SteamUser(@steamClient)
    @steamFriends = new Steam.SteamFriends(@steamClient)
    @steamClient.on 'connected', () =>
      @robot.logger.info "Connected"
      @steamUser.logOn login
    @robot.logger.info "Running!1"
    
    @steamFriends.on 'friendMsg', @gotFriendMessage
    @steamClient.on 'logOnResponse', @logOnResponse
    @steamFriends.on 'logOnResponse', @logOnResponse
    @steamUser.on 'logOnResponse', @logOnResponse
    @steamClient.on 'loggedOff', () =>
      @robot.logger.info "You have been logged off"
    @steamFriends.on 'chatMsg', @gotGroupMessage
    @steamFriends.on 'friend', @gotFriendActivity
    @steamClient.on 'error', @error
    @on 'connected', @joinChats

  logOnResponse: () =>
    @steamFriends.setPersonaState(Steam.EPersonaState.Online)
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
      @robot.logger.info "Received friend request"
      @steamFriends.addFriend(source)

  send: (envelope, messages...) =>
     for message in messages
      @steamFriends.sendMessage(envelope.user.id,message, Steam.EChatEntryType.ChatMsg)

  reply: (envelope, messages...) =>
    for message in messages
      @steamFriends.sendMessage(envelope.user.id,message, Steam.EChatEntryType.ChatMsg)

  error: (e) =>
    @robot.logger.error e.cause

  joinChats: () =>
    for room in process.env.HUBOT_STEAM_CHATS.split ","
      @robot.logger.info "Joining groupchat #{room}"
      @steamFriends.joinChat room unless room is ""

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
