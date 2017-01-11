Backbone = require 'backbone'
qs = require 'qs'
_ = require 'underscore'
Form = require '../mixins/form.coffee'
mediator = require '../../lib/mediator.coffee'
LoggedOutUser = require '../../models/logged_out_user.coffee'
AuthModalView = require '../auth_modal/view.coffee'
template = -> require('./templates/index.jade') arguments...
overlayTemplate = -> require('./templates/overlay.jade') arguments...

module.exports = class ArtistPageCTAView extends Backbone.View
  _.extend @prototype, Form

  className: 'artist-page-cta'

  events:
    'click': 'fullScreenOverlay'
    'submit .artist-page-cta-overlay__register': 'submit'
    'click .auth-toggle': 'triggerLoginModal'

  initialize: ({ artist }) ->
    @artist = artist
    @user = new LoggedOutUser
    @$window = $ window
    @desiredScrollPosition = @$window.height() * 2
    @alreadyDismissed = false
    @afterAuthPath = "#{@artist.get('href')}/payoff"
    @$window.on 'scroll', _.throttle(@maybeShowOverlay, 200)
    
  maybeShowOverlay: (e) =>
    @fullScreenOverlay() if @$window.scrollTop() > @desiredScrollPosition and not @alreadyDismissed

  triggerLoginModal: (e) ->
    e.stopPropagation()
    new AuthModalView
      width: '500px'
      mode: 'login'
      redirectTo: @afterAuthPath

  currentParams: ->
    params = qs.parse(location.search.replace(/^\?/, ''))
    _.omit(params, 'show_artist_cta_code')

  fullScreenOverlay: (e) ->
    return if @$el.hasClass 'fullscreen'
    fragment = qs.stringify @currentParams()
    @afterAuthPath += "?#{fragment}" if fragment
    @$el.addClass 'fullscreen'
    @$('.main-layout-container').html overlayTemplate
      artist: @artist
      afterAuthPath: @afterAuthPath
    @$('.artist-page-cta-overlay__close').on 'click', @closeOverlay

  closeOverlay: (e) =>
    e.stopPropagation()
    @$el.removeClass 'fullscreen'
    @alreadyDismissed = true
    @render()

  submit: (e) ->
    return unless @validateForm()
    return if @formIsSubmitting()

    e.preventDefault()

    @$('button').attr 'data-state', 'loading'

    @user.set (data = @serializeForm())
    @user.signup
      success: @onRegisterSuccess
      error: (model, response, options) =>
        @reenableForm()
        message = @errorMessage response
        @$('button').attr 'data-state', 'error'
        @$('.auth-errors').text message
        mediator.trigger 'auth:error', message

  onRegisterSuccess: (model, response, options) =>
    window.location = @afterAuthPath

  render: ->
    @$el.html template
      artist: @artist 
    @
