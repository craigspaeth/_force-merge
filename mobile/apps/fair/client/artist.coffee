_ = require 'underscore'
bootstrap = require '../../../components/layout/bootstrap.coffee'
Backbone = require 'backbone'
CurrentUser = require '../../../models/current_user.coffee'
sd = require('sharify').data
Artist = require '../../../models/artist.coffee'
FollowArtists = require '../../../collections/follow_artists.coffee'
FollowButtonView = require '../../../components/follow_button/view.coffee'

module.exports.FairArtistView = class FairArtistView extends Backbone.View

  initialize: (options) ->
    @setupFollowButton()
    @followArtists.syncFollows [ @model.get 'id' ]

  setupFollowButton: ->
    @followArtists = new FollowArtists []
    @followButtonView = new FollowButtonView
      collection: @followArtists
      el: @$ '.fair-artist-follow'
      type: 'Artist'
      followId: @model.get 'id'
      isLoggedIn: not _.isNull CurrentUser.orNull()
      _id: @model.get '_id'
      context_module: 'Artist page in fair microsite'

module.exports.init = ->
  bootstrap()
  new FairArtistView
    el: $('#fair-artist')
    model: new Artist sd.ARTIST
