{ DISABLE_IMAGE_PROXY, IMAGE_PROXY } = require('sharify').data

module.exports =
  enabled: DISABLE_IMAGE_PROXY isnt 'true'
  proxy: IMAGE_PROXY or 'EMBEDLY' # Fallback for specs (sigh)
  defaults:
    quality: 95
    color: 'fff'
