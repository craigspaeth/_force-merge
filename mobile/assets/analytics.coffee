window._ = require 'underscore'
window.Cookies = require 'cookies-js'

require '../lib/analytics_hooks.coffee'
require '../analytics/before_ready.js'
$ -> analytics.ready ->

  if  sd.CURRENT_USER?.id
    whitelist = ['collector_level', 'default_profile_id', 'email', 'id', 'name', 'phone', 'type']
    traits = _.extend _.pick(sd.CURRENT_USER, whitelist), session_id: sd.SESSION_ID
    analytics.identify sd.CURRENT_USER.id, traits
    analyticsHooks.on 'auth:logged-out', -> analytics.reset()

  require '../analytics/global.js'
  require '../analytics/impressions.js'
  require '../analytics/show_page.js'
  require '../analytics/bidding.js'
  require '../analytics/auth.js'
  require '../analytics/articles.js'
  require '../analytics/fairs.js'
  require '../analytics/article_impressions.js'
  require '../analytics/following.js'
  require '../analytics/save.js'
