_ = require 'underscore'
Backbone = require 'backbone'
form = require '../../form/utilities.coffee'

module.exports = class StepView extends Backbone.View
  __events__: null

  events: ->
    _.extend @__events__,
      'click .js-nevermind': 'dismiss'

  initialize: ({ @user, @inquiry, @artwork, @state, @trail }) ->
    @__setup__()

  template: ->
    throw new Error 'no template provided'

  next: (e) ->
    e?.preventDefault()
    @state.next()

  dismiss: (e) ->
    e.preventDefault()
    @state.trigger 'abort'

  shouldAutofocus: true

  autofocus: ->
    return unless @shouldAutofocus
    form.autofocus @$el, true

  setup: -> #

  __setup__: ->
    return if @__isSetup__
    @setup()
    @__isSetup__ = true

  render: ->
    @$el.html @template
      user: @user
      inquiry: @inquiry
      artwork: @artwork
      state: @state
      trail: @trail
    @postRender()
    @autofocus()
    this

  postRender: -> #
