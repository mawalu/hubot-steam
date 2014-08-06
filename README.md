#Hubot steam
[![NPM version](https://badge.fury.io/js/hubot-steam.svg)](http://badge.fury.io/js/hubot-steam)  
A hubot adapter for the steam network.

##Installation
Add `hubot-steam` to your package.json dependencies and run
```
npm install
```
or, if you didn't modify ./bin/hubot, it should do this automatically when you start hubot the 
next time.
##Usage
```
./bin/hubot -a steam
```
##Configuration
If your account is not protected by steamguard, these two variables are enought:

* `HUBOT_STEAM_NAME` The steam account name of the bot account.
* `HUBOT_STEAM_PASSWORD` The password for the steam account.

otherwise it's a bit more complicated.

1. Set the two variables mentioned above and start hubot. You should see an login error.
2. Look into your steam accounts email adresse and get the authcode they sended you.
3. Save the authcode as `HUBOT_STEAM_CODE`.
4. Set `HUBOT_STEAM_SENTRY_HASH` to a random sha1 hash. For example you could visit this [website](http://www.sha1-online.com/) and let your cat walk over the keyboard.
5. Restart hubot. After you logged in, the hash should be registered with your account.
6. Unset `HUBOT_STEAM_CODE` and restart hubot. You will now be able to log into your steamguard protect account, as long as you set `HUBOT_STEAM_SENTRY_HASH` to the registered value.

###Groupchats
!!! Important: You can only use groupchats if you *BOUGHT* at least one game on you bot account!

To use groupchats, set `HUBOT_STEAM_CHATS` to a comma seperated list of group IDs. To obtain these, follow the three steps here:

* Go to your `GROUPS` page on steam
* Right click on a group name and chose `Copy Link Address`
* And there is your group ID

##About
This was original created by [derdobs](https://github.com/derdobs). At the moment it gets 
improved and extended by me.
