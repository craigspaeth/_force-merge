_ = require 'underscore'
benv = require 'benv'
Backbone = require 'backbone'
sinon = require 'sinon'
rewire = require 'rewire'
CurrentUser = require '../../../../../models/current_user'
{ fabricate, fabricate2 } = require 'antigravity'
{ resolve } = require 'path'

describe 'ArtworkImageView', ->

  before (done) ->
    benv.setup =>
      benv.expose
        $: benv.require 'jquery'
        Element: window.Element
      Backbone.$ = $
      done()

  after ->
    benv.teardown()

  beforeEach (done) ->
    @artwork = fabricate('artwork', { image: url: '/image.png' } )
    @artwork.artists = [ fabricate('artist', name: 'Andy Warhol') ]
    benv.render resolve(__dirname, '../templates/index.jade'), {
      artwork: @artwork
      sd: ARTWORK: @artwork
      asset: (->)
    }, =>
      ArtworkImageView = rewire '../view.coffee'
      ArtworkImageView.__set__ 'ShareView', sinon.stub()
      ArtworkImageView.__set__ 'Flickity', sinon.stub()
      sinon.stub Backbone, 'sync'
      @view = new ArtworkImageView
        artwork: @artwork
        el: $('.artwork-image-module')

      done()

  afterEach ->
    Backbone.sync.restore()

  describe '#renderSave without a user', ->

    it 'is in unsaved state', ->
      @view.renderSave()
      @view.$('.artwork-header-module__favorite').data('state').should.equal 'unsaved'
      @view.$('.artwork-header-module__favorite').data('action').should.equal 'save'

    it 'adds link to signup page', ->
      @view.renderSave()
      @view.$('.artwork-header-module__favorite').attr('href').should.containEql "/sign_up?action=artwork-save"

  describe '#saveArtwork', ->

    beforeEach ->
      @e = new $.Event('click')
      @spy = sinon.spy(CurrentUser.prototype, 'saveArtwork')

    afterEach ->
      CurrentUser.prototype.saveArtwork.restore()

    describe 'with a user', ->
      beforeEach ->
        @view.user = new CurrentUser fabricate 'user'
        @view.$('.artwork-header-module__favorite').attr('data-action', 'save')
        @view.savedArtwork(@e)

      it 'saves the artwork', ->
        @view.renderSave()
        @spy.calledOnce.should.be.ok()

      it 'toggles button state', ->
        _.last(Backbone.sync.args)[2].success { id: 'saved-masterpiece' }
        @view.$('.artwork-header-module__favorite').attr('data-action').should.equal 'remove'
        @view.$('.artwork-header-module__favorite').attr('data-state').should.equal 'saved'

    describe 'without a user', ->

      it 'does nothing', ->
        @spy.called.should.not.be.ok()
