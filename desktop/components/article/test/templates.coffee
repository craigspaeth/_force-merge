_ = require 'underscore'
cheerio = require 'cheerio'
path = require 'path'
jade = require 'jade'
fs = require 'fs'
moment = require 'moment'
Article = require '../../../models/article'
Articles = require '../../../collections/articles'

render = (templateName) ->
  filename = path.resolve __dirname, "../templates/#{templateName}.jade"
  jade.compile(
    fs.readFileSync(filename),
    { filename: filename }
  )

describe 'article show template', ->

  it 'renders sectionless articles', ->
    html = render('index')
      article: new Article title: 'hi', sections: [], section_ids: [], contributing_authors: []
      footerArticles: new Articles
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: {}
      asset: ->
    html.should.containEql 'hi'

  it 'renders fullscreen headers with video', ->
    html = render('index')
      article: new Article
        title: 'hi'
        sections: []
        contributing_authors: []
        hero_section:
          type: 'fullscreen'
          background_url: 'http://video.mp4'
      footerArticles: new Articles
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: {}
      asset: ->
    html.should.containEql 'article-fullscreen-video-player'

  it 'renders fullscreen headers with static image', ->
    html = render('index')
      article: new Article
        title: 'hi'
        sections: []
        contributing_authors: []
        hero_section:
          type: 'fullscreen'
          background_image_url: 'http://image.jpg'
      footerArticles: new Articles
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: {}
      asset: ->
    html.should.containEql 'article-fullscreen-image'

  it 'renders a TOC', ->
    html = render('index')
      article: new Article
        title: 'hi'
        sections: [
          {
            type: 'toc'
            links: [ {name: 'Kana Abe', value: 'Kana'}, { name: 'Bob Olsen', value: 'Bob' } ]
          }
        ]
        contributing_authors: []
      footerArticles: new Articles
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: {}
      asset: ->
    html.should.containEql '<a href="#Kana">Kana Abe</a>'

  it 'can optionally exclude share buttons', ->
    html = render('index')
      article: new Article
        title: 'hi'
        sections: [
          {
            type: 'toc'
            links: [ {name: 'Kana Abe', value: 'Kana'}, { name: 'Bob Olsen', value: 'Bob' } ]
          }
        ]
        contributing_authors: []
      footerArticles: new Articles
      hideShare: true
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: {}
      asset: ->

    html.should.not.containEql 'share'

  it 'can optionally exclude subscribe section', ->
    html = render('index')
      article: new Article
        title: 'hi'
        sections: [
          {
            type: 'toc'
            links: [ {name: 'Kana Abe', value: 'Kana'}, { name: 'Bob Olsen', value: 'Bob' } ]
          }
        ]
        contributing_authors: []
      footerArticles: new Articles
      hideSubscribe: true
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: {}
      asset: ->

    html.should.not.containEql 'Subscribe'


  it 'does not render a TOC header if there are no links', ->
    html = render('index')
      article: new Article
        title: 'hi'
        sections: [
          {
            type: 'toc'
            links: []
          }
        ]
        contributing_authors: []
      footerArticles: new Articles
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: {}
      asset: ->
    html.should.not.containEql 'Table Of Contents'

  it 'renders top stories', ->
    html = render('index')
      article: new Article
        title: 'hi'
        sections: [
          {
            type: 'callout'
            top_stories: true
            article: ''
          }
        ]
        contributing_authors: []
      footerArticles: new Articles
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: PARSELY_ARTICLES: [
        {
          url: 'http://artsy.net/article/editorial-cool-article'
          image_url: 'http://artsy.net/image.png'
          title: '5 Must Read Stories'
        }
      ]
      asset: ->
    html.should.containEql 'Top Stories on Artsy'
    html.should.containEql '5 Must Read Stories'
    html.should.containEql 'http://artsy.net/article/editorial-cool-article'
    html.should.containEql 'http://artsy.net/image.png'

  it 'renders artworks', ->
    html = render('index')
      article: new Article
        title: 'hi'
        sections: [
          {
            type: 'artworks',
            ids: ['5321b73dc9dc2458c4000196', '5321b71c275b24bcaa0001a5'],
            layout: 'overflow_fillwidth',
            artworks: [
              {
                type: 'artwork'
                id: '5321b73dc9dc2458c4000196'
                slug: "govinda-sah-azad-in-between-1",
                date: "2015",
                title: "In Between",
                image: "https://d32dm0rphc51dk.cloudfront.net/zjr8iMxGUQAVU83wi_oXaQ/larger.jpg",
                partner: {
                  name: "October Gallery",
                  slug: "october-gallery"
                },
                artists: [{
                  name: "Govinda Sah 'Azad'",
                  slug: "govinda-sah-azad"
                },
                {
                  name: "Andy Warhol",
                  slug: "andy-warhol"
                }]
              },{
                type: 'artwork'
                id: '5321b71c275b24bcaa0001a5'
                slug: "govinda-sah-azad-in-between-2",
                date: "2015",
                title: "In Between 2",
                image: "https://d32dm0rphc51dk.cloudfront.net/zjr8iMxGUQAVU83wi_oXaQ2/larger.jpg",
                partner: {
                  name: "October Gallery",
                  slug: "october-gallery"
                },
                artists: [{
                  name: "Govinda Sah 'Azad'",
                  slug: "govinda-sah-azad"
                }]
              }
            ]
          }
        ]
        contributing_authors: []
      footerArticles: new Articles
      crop: (url) -> url
      resize: (u) -> u
      moment: moment
      sd: {}
      asset: ->
    html.should.containEql '/artwork/govinda-sah-azad-in-between-1'
    html.should.containEql '/artwork/govinda-sah-azad-in-between-2'
    html.should.containEql 'October Gallery'
    html.should.containEql "Govinda Sah 'Azad'"
    html.should.containEql "Andy Warhol"
    html.should.containEql 'In Between 2'
