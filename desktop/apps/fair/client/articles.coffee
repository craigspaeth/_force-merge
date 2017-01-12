ArticlesFeedView = require '../../../components/articles_feed/view.coffee'
Articles = require '../../../collections/articles.coffee'

module.exports = class ArticlesAdapter
  constructor: ({ model, fair, el }) ->
    collection = new Articles
    view = new ArticlesFeedView
      el: el
      collection: collection
      fetchWith:
        published: true
        fair_id: fair.get('_id')
        sort: '-published_at'
        limit: 5
    el.html '<div class="loading-spinner"></div>'
    el.addClass view.className
    collection.fetch
      data:
        published: true
        fair_id: fair.get('_id')
        sort: '-published_at'
        limit: 5
    view
