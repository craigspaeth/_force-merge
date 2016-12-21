Q = require 'bluebird-q'
_ = require 'underscore'
sinon = require 'sinon'
Backbone = require 'backbone'
routes = require '../routes'
{ fabricate } = require 'antigravity'

describe 'Search routes', ->
  describe '#index', ->
    describe 'success', ->
      beforeEach ->
        sinon.stub(Backbone, 'sync').returns Q.resolve()

      afterEach ->
        Backbone.sync.restore()

      it 'makes the appropriate request and removes accents', (done) ->
        req = params: {}, query: term: 'f\uFF4Fob\u00C0r'
        res = render: sinon.stub(), locals: sd: {}
        next = sinon.stub()

        routes.index req, res, next

        Backbone.sync.args[0][0].should.equal 'read'
        Backbone.sync.args[0][2].data.q.should.equal 'foobAr'

        _.defer => _.defer =>
          res.render.called.should.be.true()
          next.called.should.be.false()

          done()

      it 'redirects without query', ->
        req = params: {}, query: {}
        res = render: sinon.stub(), redirect: sinon.stub(), locals: sd: {}
        routes.index req, res
        res.redirect.args[0][0].should.equal '/'

    describe 'error', ->
      beforeEach ->
        sinon.stub(Backbone, 'sync').returns Q.reject()

      afterEach ->
        Backbone.sync.restore()

      it 'doesnt swallow the error', (done) ->
        req = params: {}, query: term: 'foobar'
        res = render: sinon.stub(), redirect: sinon.stub(), locals: sd: {}
        next = sinon.stub()

        routes.index req, res, next

        _.defer => _.defer =>
          res.render.called.should.be.false()
          next.called.should.be.true()

          done()
