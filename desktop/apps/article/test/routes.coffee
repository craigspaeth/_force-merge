_ = require 'underscore'
sinon = require 'sinon'
moment = require 'moment'
Backbone = require 'backbone'
Article = require '../../../models/article'
Articles = require '../../../collections/articles'
rewire = require 'rewire'
routes = rewire '../routes'
fixtures = require '../../../test/helpers/fixtures.coffee'

describe 'Article routes', ->

  beforeEach ->
    sinon.stub Backbone, 'sync'
    @req = { params: {} }
    @res = { render: sinon.stub(), locals: { sd: {} }, redirect: sinon.stub() }
    @next = sinon.stub()
    sinon.stub Article.prototype, 'fetchWithRelated'
    routes.__set__ 'topParselyArticles', sinon.stub().yields []

  afterEach ->
    Backbone.sync.restore()
    Article::fetchWithRelated.restore()

  describe '#article', ->

    it 'redirects old slugs', ->
      @req.params.slug = 'foo'
      routes.article @req, @res
      Article::fetchWithRelated.args[0][0].success(
        article: new Article(_.extend fixtures.article, title: 'Foo', slug: 'bar')
        footerArticles: new Articles([_.extend fixtures.article, title: 'Bar'])
      )
      @res.redirect.args[0][0].should.equal '/article/bar'

   it 'fetches an article, its related content, and renders it', ->
      @req.params.slug = 'bar'
      routes.articleItem = new Article
      routes.article @req, @res
      Article::fetchWithRelated.args[0][0].success(
        article: new Article(_.extend fixtures.article, title: 'Foo', slug: 'bar')
        superArticles: new Articles([_.extend fixtures.article, title: 'Super'])
      )
      @res.render.args[0][0].should.equal 'article'
      @res.render.args[0][1].article.get('title').should.equal 'Foo'
      @res.render.args[0][1].superArticles.first().get('title')
        .should.equal 'Super'

  describe '#redirectPost', ->

    it 'redirects posts to articles', ->
      @req.url = 'post/foo'
      routes.redirectPost @req, @res, @next
      @res.redirect.args[0][1].should.containEql 'article/foo'
