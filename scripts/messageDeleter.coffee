# Description
#   Delete messages that contain content which is not permitted
#
# Configuration:
#   HUBOT_SLACK_TOKEN
#   ADMIN_SLACK_TOKEN
#   HUBOT_BOT_NAME
#
# Commands:
#
# Author:
#   Toby Hoenisch <tobias@hoenisch.at>
#   Aaron Myatt <aaronmyatt@gmail.com>

request = require('request')

console.log "Message Deleter Started"

token = process.env.HUBOT_SLACK_TOKEN
admin_token = process.env.ADMIN_SLACK_TOKEN
botname = process.env.HUBOT_BOT_NAME
baseURL = 'https://slack.com/api'
robot = null

bitcoinRegex = /.*[13][a-km-zA-HJ-NP-Z1-9]{25,34}.*/i
etherRegex = /.*(0x)?[0-9a-fA-F]{40}.*/i
lyonessRegex = /.*(lyoness).*/i
websiteRegex = /.*https?\:\/\/.*/i
ensNameRegex = /.*\.eth.*/g # etherium name service

deleteMessage = (channel, ts) ->
  console.log "Deleting #{ts} on #{channel}"
  request.post {url: "#{baseURL}/chat.delete?token=#{admin_token}&channel=#{channel}&ts=#{ts}", json: true}, (err, res, deleted) ->
    throw err if err
    console.log deleted

censor = (message) ->
  ts = message.rawMessage.ts
  channel = message.rawMessage.channel
  console.log "Censoring message in channel: #{channel}, at time: #{ts}"
  deleteMessage  channel, ts

flagUser = (user) ->
  console.log "Flagging user: #{user}"
  flaggedUser = robot.brain.get user.id
  if (!flaggedUser)
    flaggedUser = {}
  flaggedUser.flagged = new Date().getTime()
  robot.brain.set user.id, flaggedUser

listenForWebsitePosts = (robot) ->
  robot.listen(
    (message) ->
      try
        if message.text.match(websiteRegex)
          console.log "Website detected"
          flagUser message.user
          censor message
          true
      catch
        false
    (response) ->
      response.reply "No URLs for now"
  )

listenForENSPosts = (robot) ->
  robot.listen(
    (message) ->
      try
        if message.text.match(ensNameRegex)
          console.log "ENS Name detected"
          flagUser message.user
          censor message
          true
      catch
        false
    (response) ->
      response.reply "No ENS names for now"
  )

listenForTokenAddressPosts = (robot) ->
  robot.listen(
    (message) ->
      try
        if message.text.match(bitcoinRegex)
          console.log "Bitcoin address detected"
          flagUser message.user
          censor message
          true
        else if message.text.match(etherRegex)
          console.log "Ether address detected"
          flagUser message.user
          censor message
          true
      catch
        false
    (response) ->
      response.reply "No token sale addresses in here"
  )

module.exports = (r) ->
  robot = r
  listenForWebsitePosts robot
  listenForENSPosts robot
  listenForTokenAddressPosts robot
