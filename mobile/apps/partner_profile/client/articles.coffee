bootstrap = require '../../../components/layout/bootstrap.coffee'
Articles = require '../../../collections/articles.coffee'
articleFigureTemplate = -> require('../../../components/article_figure/template.jade') arguments...

$ ->
  bootstrap()
  new Articles().fetch
    data: partner_id: sd.PROFILE.owner._id, published: true
    success: (articles) ->
      $('#profile-page-articles').html articles.map((article) ->
        articleFigureTemplate article: article
      ).join ''
