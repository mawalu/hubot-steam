{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require 'hubot'

Steam = require 'steam'

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

    @bot = new Steam.SteamClient   
    @bot.logOn(login);
    @robot.logger.info "Running!1"
    
    @bot.on 'loggedOn', @.loggedOn
    @bot.on 'friendMsg', @.gotMessage
    @bot.on 'friend', @.gotFriendRequest
    @bot.on 'relationships', @.relationshipChanged
    @bot.on 'error', @.error

  gotMessage: (source, message, type, chatter) =>
    if message != ""
      user = id: source, name: 'Steam', room: 'priv' 
      @receive new TextMessage user, message, 1

  relationshipChanged: () =>
    @logger.info @friends

  gotFriendRequest: (source, type) =>
    if type == Steam.EFriendRelationship.PendingInvitee
      @robot.logger.info "Recived friend request"
      @bot.addFriend(source)

  loggedOn: (source, message, type, chatter) =>
    @bot.setPersonaState(Steam.EPersonaState.Online)
    @robot.logger.info "Connected"
    @emit("connected")
    @emit("relationships")

  send: (envelope, messages...) =>
     for message in messages
       @bot.sendMessage(envelope.user.id,message, Steam.EChatEntryType.ChatMsg)     

  reply: (envelope, messages...) =>
    for message in messages
       @bot.sendMessage(envelope.user.id,message, Steam.EChatEntryType.ChatMsg)

  error: (e) =>
    @robot.logger.info e
   
exports.use = (robot) ->
  new SteamBot robot
