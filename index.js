require('coffee-script/register')
const express = require('express')
const newrelic = require('artsy-newrelic')
const artsyXapp = require('artsy-xapp')
const desktop = require('./desktop')
const mobile = require('./mobile')
const cache = require('./lib/cache')

const app = express()
const { API_URL, CLIENT_ID, CLIENT_SECRET, PORT } = process.env

app.use(newrelic)
app.use((...args) => {
  const [req] = args
  const ua = req.get('user-agent')
  const isPhone = (
    (ua.match(/iPhone/i) && !ua.match(/iPad/i)) ||
    (ua.match(/Android/i) && ua.match(/Mobile/i)) ||
    (ua.match(/Windows Phone/i)) ||
    (ua.match(/BB10/i)) ||
    (ua.match(/BlackBerry/i))
  )
  isPhone ? mobile(...args) : desktop(...args)
})

// Attempt to connect to Redis. If it fails, no worries, the app will move on
// without caching.
cache.setup(() => {
  // Get an xapp token
  artsyXapp.init({ url: API_URL, id: CLIENT_ID, secret: CLIENT_SECRET }, () => {
    // Start server
    app.listen(PORT, () => {
      console.log(`Force listening on port ${PORT}`)
    })
  })
})
