_ = require 'underscore'
Artworks = require '../../collections/artworks'
Artist = require '../../models/artist'
PartnerShows = require '../../collections/partner_shows'
Partner = require '../../models/partner'
Profile = require '../../models/profile'
Articles = require '../../collections/articles'
Article = require '../../models/article'
embed = require 'embed-video'
{ stringifyJSONForWeb } = require '../../components/util/json.coffee'
{ resize } = require '../../components/resizer/index.coffee'
{ EOY_2016_SLUGS } = require '../../config.coffee'

partnerFromProfile = (req) ->
  if req.profile?.isPartner()
    new Partner req.profile.get('owner')
  else
    false

module.exports.fetchArtworksAndRender = (label) ->
  return (req, res, next) ->
    return next() unless partner = partnerFromProfile(req)
    artworks = new Artworks []
    artworks.url = "#{partner.url()}/artworks"
    params =
      page: 1
      published: true
      size: 25
    switch label
      when "Works" then params.not_for_sale = true
      when "Shop" then params.for_sale_sold_on_hold = true
    artworks.fetch
      cache: true
      data: params
      success: (artworks) ->
        res.locals.sd.ARTWORKS = artworks.toJSON()
        res.locals.sd.PARAMS = params
        res.locals.sd.PARTNER_URL = partner.url()
        res.render 'artworks',
          sectionLabel: label
          artworkColumns: artworks.groupByColumnsInOrder()
          profile: req.profile

      error: res.backboneError

module.exports.index = (req, res, next) ->
  return next() unless partner = partnerFromProfile(req)
  partner.fetch
    cache: true
    error: res.backboneError
    success: ->
      new Articles().fetch
        data: partner_id: partner.get('_id'), published: true
        error: res.backboneError
        success: (articles) ->
          res.locals.sd.PARTNER_PROFILE = req.profile
          res.render 'index',
            profile: req.profile
            partner: partner
            articles: articles

module.exports.articles = (req, res, next) ->
  return next() unless partner = partnerFromProfile(req)
  res.render 'articles',
    sectionLabel: "Articles"
    profile: req.profile

module.exports.article = (req, res, next) ->
  return next() if req.params.articleId.match(EOY_2016_SLUGS)?.length
  article = new Article id: req.params.articleId
  article.fetch
    cache: true
    error: (article, err) ->
      if (err.status is 404 or err.status is 401) then next() else res.backboneError(err, next)
    success: =>
      article.fetchRelated
        success: (data) ->
          res.locals.sd.ARTICLE = article
          res.locals.sd.RELATED_ARTICLES = data.relatedArticles?.toJSON()
          res.locals.sd.INFINITE_SCROLL = false
          res.render 'article',
            article: article
            footerArticles: data.footerArticles if data.footerArticles
            relatedArticles: data.article.relatedArticles
            calloutArticles: data.article.calloutArticles
            embed: embed
            resize: resize
            jsonLD: stringifyJSONForWeb(article.toJSONLD())
            videoOptions: { query: { title: 0, portrait: 0, badge: 0, byline: 0, showinfo: 0, rel: 0, controls: 2, modestbranding: 1, iv_load_policy: 3, color: "E5E5E5" } }

module.exports.shows = (req, res, next) ->
  return next() unless partner = partnerFromProfile(req)
  shows = new PartnerShows [], partnerId: req.profile.get('owner').id
  shows.fetch
    success: (shows) ->
      res.render 'shows_page',
        currentShows: shows.filter (show) -> show.get('status') is 'running' or show.get('status') is 'upcoming'
        pastShows: shows.where(status: 'closed')
        profile: req.profile
    error: res.backboneError

module.exports.artists = (req, res, next) ->
  return next() unless partner = partnerFromProfile(req)
  partner.fetchArtistGroups
    success: (representedArtists, unrepresentedArtists) ->
      res.render 'artists',
        unrepresented: unrepresentedArtists.models
        represented: _.filter representedArtists.models, (a) -> a.has('image_versions') and a.has('image_url')
        profile: req.profile
        partner: partner

    error: res.backboneError

module.exports.artist = (req, res, next) ->
  return next() unless partner = partnerFromProfile(req)
  artist = new Artist id: req.params.artistId
  artist.fetch
    cache: true
    success: (artist) ->
      res.locals.sd.ARTIST = artist.toJSON()
      res.locals.sd.PARTNER = partner.toJSON()
      res.render 'artist',
        artist: artist
        partner: partner
        profile: req.profile
    error: res.backboneError

module.exports.contact = (req, res, next) ->
  return next() unless partner = partnerFromProfile(req)
  partner.fetch
    cache: true
    success: ->
      partner.fetchLocations
        success: (locations) ->
          res.render 'contact',
            profile: req.profile
            partner: partner
            locationGroups: locations.groupBy('city')
        error: res.backboneError
