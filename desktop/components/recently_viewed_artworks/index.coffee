Cookies = require '../cookies/index.coffee'
metaphysics = require '../../lib/metaphysics.coffee'
query = require './artwork_query.coffee'
_ = require 'underscore'
CurrentUser = require '../../models/current_user.coffee'
Artwork = require '../../models/artwork.coffee'
SaveControls = require '../artwork_item/save_controls/view.coffee'
blacklist = require './blacklist.coffee'
COOKIE_NAME = 'recently-viewed-artworks'
COOKIE_EXPIRY = 60 * 60 * 24 * 365
ARTWORK_COUNT = 8

template = -> require('./index.jade') arguments...

cookieValue = ->
  JSON.parse(Cookies.get(COOKIE_NAME) or '[]')

module.exports =
  setCookie: (artworkId) ->
    uniqueArtworkIds = _.without(cookieValue(), artworkId)
    uniqueArtworkIds.unshift(artworkId)
    artworkIdsToStore = uniqueArtworkIds.slice(0, ARTWORK_COUNT)
    Cookies.set COOKIE_NAME, JSON.stringify(artworkIdsToStore), expires: COOKIE_EXPIRY

  shouldShowRVARail: ->
    !blacklist.check() && cookieValue().length > 0

  reInitRVARail: ($el) ->
    return unless $el.find('.rva-container').length > 0
    $el.find('.rva-container').fillwidthLite
      gutterSize: 30
      targetHeight: 150
      dontResizeUp: true

  setupRail: ($el) ->
    send = method: 'post', query: query, variables: ids: cookieValue()
    metaphysics send
      .then (data) ->
        $el.html template
          artworks: data.artworks
        $el.find('.rva-container').fillwidthLite
          gutterSize: 30
          targetHeight: 150
          dontResizeUp: true
          done: =>
            user = CurrentUser.orNull()
            user?.initializeDefaultArtworkCollection()
            savedArtworks = user?.defaultArtworkCollection()
            _.map(data.artworks, (artwork) ->
              $artworkEl = $el.find("div[data-artwork-id=#{artwork._id}] .overlay-container")
              new SaveControls
                el: $artworkEl
                artworkCollection: savedArtworks
                model: new Artwork(artwork)
                context_module: 'recently_viewed_artworks'
            )
            savedArtworks?.addRepoArtworks data.artworks
            savedArtworks?.syncSavedArtworks()
