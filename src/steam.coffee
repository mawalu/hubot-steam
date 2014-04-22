{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require 'hubot'

Steam = require('steam');

class SteamBot extends Adapter


  constructor: ( robot ) ->
    @robot = robot

  run: ->
    @bot = new Steam.SteamClient
    @bot.logOn({ 
      accountName: process.env.HUBOT_STEAM_NAME,
      password: process.env.HUBOT_STEAM_PASSWORD
      });
    @robot.logger.info "Running!1"
    
    @bot.on 'loggedOn', @.loggedOn
    @bot.on 'friendMsg', @.gotMessage
    @bot.on 'friend', @.gotFriendRequest
    @bot.on 'relationships', @.relationshipChanged

  gotMessage: (source, message, type, chatter) =>
    if message != ""
      user = id: source, name: 'Steam', room: 'priv' 
      @receive new TextMessage user, message, 1


  relationshipChanged: () =>
    @logger.info @friends

  gotFriendRequest: (source, type) =>
    if type == Steam.EFriendRelationship.PendingInvitee
      #@bot.sendMessage("76561197963067124", "Got friended by someone", Steam.EChatEntryType.ChatMsg)
      @bot.addFriend(source)

  loggedOn: (source, message, type, chatter) =>
    @bot.setPersonaState(Steam.EPersonaState.Online)
    @emit("connected")
    @emit("relationships")

  send: (envelope, messages...) =>
     for message in messages
       @bot.sendMessage(envelope.user.id,message, Steam.EChatEntryType.ChatMsg)     

  reply: (envelope, messages...) =>
    for message in messages
       @bot.sendMessage(envelope.user.id,message, Steam.EChatEntryType.ChatMsg)
    
    

exports.use = (robot) ->
  new SteamBot robot

