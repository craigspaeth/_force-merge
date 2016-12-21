_ = require 'underscore'
sd = require('sharify').data
Backbone = require 'backbone'
bootstrap = require '../../../components/layout/bootstrap.coffee'
CurrentUser = require '../../../models/current_user.coffee'
Sale = require '../../../models/sale.coffee'
SaleArtwork = require '../../../models/sale_artwork.coffee'
RegistrationForm = require './registration_form.coffee'

module.exports.AuctionRouter = class AuctionRouter extends Backbone.Router

  routes:
    'auction-registration/:id': 'register'

  initialize: (options) ->
    { @sale, @registered, @bidderPositions, @redirectTo } = options

  register: ->
    new RegistrationForm
      el: $('#auction-registration-page')
      model: @sale
      success: =>
        if @redirectTo
          window.location = @redirectTo
        else
          window.location = @sale.registrationSuccessUrl()

module.exports.init = ->
  bootstrap()

  new AuctionRouter
    sale: sale = new Sale sd.SALE
    registered: sd.REGISTERED
    redirectTo: sd.REDIRECT_URI

  Backbone.history.start(pushState: true)
