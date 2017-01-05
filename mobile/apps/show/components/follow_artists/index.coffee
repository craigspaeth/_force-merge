_ = require 'underscore'
CurrentUser = require '../../../../models/current_user.coffee'
FollowButtonView = require '../../../../components/follow_button/view.coffee'
FollowArtists = require '../../../../collections/follow_artists.coffee'

module.exports = (artists) ->
  user = CurrentUser.orNull()
  @followArtists = new FollowArtists []

  ids = artists.map (artist) ->
    $el = $(".artist-follow[data-id='#{artist.id}']")
    followButtonView = new FollowButtonView
      collection: @followArtists
      el: $el
      type: 'Artist'
      followId: artist.get 'id'
      isLoggedIn: not _.isNull CurrentUser.orNull()
      _id: artist.get '_id'
      context_module: 'Show page'

    artist.id

  @followArtists.syncFollows ids if user
