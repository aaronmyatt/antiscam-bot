# hubot = require 'hubot'
hubot = require 'hubot-slack'
Helper = require 'hubot-test-helper'
sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect
request = require('request')

helper = new Helper('../scripts/messageDeleter.coffee')

describe 'Message Deleter', ->
  stubPost = sinon.stub(request, 'post')

  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  it 'does nothing to unoffending messages', ->
    @room.user.say('alice', 'this is an innocent message').then =>
      expect(@room.messages.pop()).to.eql ['alice', 'this is an innocent message']

  context 'websiteRegex', ->
    url = 'https://some.url'

    it 'responds properly to messages that include links', ->
      @room.user.say('alice', url).then =>
        expect(@room.messages.pop()).to.eql ['hubot', '@alice No URLs for now']

    it 'sends delete message request to slack api', ->
      @room.user.say('alice', url).then =>
        expect(stubPost.called).to.eql true

    it 'flags user in hubots brain', ->
      @room.user.say('alice', url).then =>
        expect(@room.robot.brain.get('alice').flagged).to.be.at.most(new Date().getTime())

  # context 'ensNameRegex', ->
  #   ensName = 'daveappleton.eth'
  #
  #   it 'responds properly to messages that include links', ->
  #     @room.user.say('alice', ensName).then =>
  #       expect(@room.messages.pop()).to.eql ['hubot', '@alice No ENS names for now']
  #
  #   it 'sends delete message request to slack api', ->
  #     @room.user.say('alice', ensName).then =>
  #       expect(stubPost.called).to.eql true
  #
  #   it 'flags user in hubots brain', ->
  #     @room.user.say('alice', ensName).then =>
  #       expect(@room.robot.brain.get('alice').flagged).to.be.at.most(new Date().getTime())
  #
  # context 'bitcoinRegex', ->
  #   bitcoinAddress = '1Mz7153HMuxXTuR2R1t78mGSdzaAtNbBWX'
  #
  #   it 'responds properly to messages that include bitcoin addresses', ->
  #     @room.user.say('alice', bitcoinAddress).then =>
  #       expect(@room.messages.pop()).to.eql ['hubot', '@alice No token sale addresses in here']
  #
  #   it 'sends delete message request to slack api', ->
  #     @room.user.say('alice', bitcoinAddress).then =>
  #       expect(stubPost.called).to.eql true
  #
  #   it 'flags user in hubots brain', ->
  #     @room.user.say('alice', bitcoinAddress).then =>
  #       expect(@room.robot.brain.get('alice').flagged).to.be.at.most(new Date().getTime())
  #
  # context 'etherRegex', ->
  #   etherAddress = '0x31EFd75bc0b5fbafc6015Bd50590f4fDab6a3F22'
  #
  #   it 'responds properly to messages that include ether addresses', ->
  #     @room.user.say('alice', etherAddress).then =>
  #       expect(@room.messages.pop()).to.eql ['hubot', '@alice No token sale addresses in here']
  #
  #   it 'sends delete message request to slack api', ->
  #     @room.user.say('alice', etherAddress).then =>
  #       expect(stubPost.called).to.eql true
  #
  #   it 'flags user in hubots brain', ->
  #     @room.user.say('alice', etherAddress).then =>
  #       expect(@room.robot.brain.get('alice').flagged).to.be.at.most(new Date().getTime())
