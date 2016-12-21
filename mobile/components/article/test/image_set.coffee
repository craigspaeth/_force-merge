_ = require 'underscore'
benv = require 'benv'
sinon = require 'sinon'
Backbone = require 'backbone'
fixtures = require '../../../test/helpers/fixtures.coffee'
sd = require('sharify').data
{ resolve } = require 'path'
{ fabricate } = require 'antigravity'

describe 'ImageSetView', ->

  before (done) ->
    benv.setup =>
      benv.expose
        $: benv.require 'jquery'
        Element: window.Element
      Backbone.$ = $
      @ImageSetView = benv.requireWithJadeify(
        resolve(__dirname, '../client/image_set')
        ['template' ]
      )
      @ImageSetView.__set__ 'resize', (url) -> url
      @ImageSetView.__set__ 'Flickity', sinon.stub()
      @user = sinon.stub()
      @items = [
        { type: 'image', caption: 'This is a caption', url: 'http://image.com/img.png' }
        {
          type: 'artwork',
          artist: name: 'Van Gogh', slug: 'van-gogh'
          partner: name: 'Partner Gallery'
          title: 'Starry Night'
          image: 'http://partnergallery.com/image.png'
          slug: 'van-gogh-starry-night'
          date: '1999'
        }
      ]
      done()

  after ->
    benv.teardown()

  beforeEach ->
    sinon.stub Backbone, 'sync'
    @view = new @ImageSetView
      el: $('body')
      items: @items
      user: @user

  afterEach ->
    Backbone.sync.restore()

  describe 'slideshow sets up flickity', ->

    it 'calls flickity', ->
      @ImageSetView.__get__('Flickity').called.should.be.ok

  describe '#close', ->

    it 'enables scrolling', ->
      @view.close()
      $('body').hasClass('is-scrolling-disabled').should.be.false()

    it 'destroys the view', ->
      @view.close()
      @view.$el.html().should.not.containEql '.image-set-modal'

  describe '#setupFollowButton', ->

    it 'creates a follow button for artists', ->
      $('.artist-follow').data('state').should.containEql 'follow'


  describe '#render', ->

    it 'renders a regular image', ->
      @view.render()
      @view.$el.html().should.containEql '1/2'
      @view.$el.html().should.containEql 'This is a caption'
      @view.$el.html().should.containEql 'http://image.com/img.png'

    it 'renders an artwork', ->
      @view.render()
      @view.$el.html().should.containEql '2/2'
      @view.$el.html().should.containEql 'Starry Night'
      @view.$el.html().should.containEql 'Partner Gallery'
      @view.$el.html().should.containEql 'van-gogh-starry-night'
      @view.$el.html().should.containEql '1999'
      @view.$el.html().should.containEql 'http://partnergallery.com/image.png'

    it 'disables vertical scroll on open', ->
      $('body').hasClass('is-scrolling-disabled').should.be.true()
