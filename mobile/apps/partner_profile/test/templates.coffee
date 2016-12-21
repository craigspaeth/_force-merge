jade = require 'jade'
path = require 'path'
fs = require 'fs'
cheerio = require 'cheerio'
Backbone = require 'backbone'
Profile = require '../../../models/profile'
Partner = require '../../../models/partner'
{ fabricate } = require 'antigravity'
Artists = require '../../../collections/artists'
fixtures = require '../../../test/helpers/fixtures'

render = (templateName) ->
  filename = path.resolve __dirname, "../templates/#{templateName}.jade"
  jade.compile(
    fs.readFileSync(filename),
    { filename: filename }
  )

describe 'Partner page templates', ->

  it 'doesnt show represented if they dont exist', ->
    render('artists')(
      profile: new Profile fabricate 'profile'
      represented: []
      unrepresented: new Artists([fabricate 'artist']).models
      sd: {}
    ).should.not.containEql 'Represented Artists'

  it 'changes copy for gagosian', ->
    html = render('artists')
      profile: new Profile fabricate 'profile', id: 'gagosian-gallery'
      represented: new Artists([fabricate 'artist']).models
      unrepresented: new Artists([fabricate 'artist']).models
      sd: {}
    html.should.not.containEql 'Works Available By'
    html.should.containEql 'Artists'

  it 'renders a follow button', ->
    profile = new Profile fabricate 'profile', id: 'gagosian-gallery', icon: null
    html = render('index')
      partner: new Partner profile.get('owner')
      profile: profile
      articles: []
      sd:
        PARTNER_PROFILE: profile
    $ = cheerio.load html
    $('.follow-button').should.have.lengthOf 1

  it 'works for partners without icons', ->
    profile = new Profile fabricate 'profile', id: 'gagosian-gallery', icon: null
    html = render('index')
      profile: profile
      partner: new Partner profile.get('owner')
      articles: []
      represented: new Artists([fabricate 'artist']).models
      unrepresented: new Artists([fabricate 'artist']).models
      sd: {}

  it 'creates links to profile slugs, not partner slugs', ->
    partner = new Partner fabricate 'partner', id: 'the-gagosian-gallery'
    profile = new Profile fabricate 'profile', id: 'gagosian-gallery', icon: null
    html = render('index')
      partner: partner
      profile: profile
      articles: []
      represented: new Artists([fabricate 'artist']).models
      unrepresented: new Artists([fabricate 'artist']).models
      sd: {}
    $ = cheerio.load html
    $("a[href*='#{partner.get('id')}']").length.should.equal 0
    $("a[href*='#{profile.get('id')}']").length.should.be.above 0

  it 'hides missing telephone numbers', ->
    loc = new Backbone.Model fabricate 'location', phone: null
    loc.gmapImageUrl = ->
    locationGroups = { 'Foo': [loc]  }
    profile = new Profile fabricate 'profile', id: 'gagosian-gallery', icon: null
    html = render('contact')
      locationGroups: locationGroups
      profile: profile
      partner: new Partner profile.get('owner')
      sd: {}
    html.should.not.containEql 'Tel:'

  it 'invites users to email galleries that have a contact email address', ->
    profile = new Profile fabricate 'profile', id: 'gagosian-gallery', icon: null, owner_type: 'PartnerGallery'
    partner = new Partner fabricate 'partner', email: 'info@gagosian.com'
    html = render('contact')
      locationGroups: {}
      profile: profile
      partner: partner
      sd: {}
    $ = cheerio.load html
    $("a[href^='mailto:#{partner.get('email')}']").length.should.be.above 0

  it 'renders a link to the partner\s website', ->
    profile = new Profile fabricate 'profile', id: 'gagosian-gallery', icon: null, owner_type: 'PartnerGallery'
    partner = new Partner fabricate 'partner', website: "http://www.gagosian.com"
    html = render('contact')
      locationGroups: {}
      profile: profile
      partner: partner
      sd: {}
    $ = cheerio.load html
    $("a[href='#{partner.get('website')}']").length.should.be.above 0
    $("a[href='#{partner.get('website')}']").text().should == partner.getSimpleWebsite()

  it 'hides articles link if no articles', ->
    profile = new Profile fabricate 'profile', id: 'gagosian-gallery', icon: null
    html = render('index')
      profile: profile
      partner: new Partner profile.get('owner')
      articles: []
      represented: new Artists([fabricate 'artist']).models
      unrepresented: new Artists([fabricate 'artist']).models
      sd: {}
    $ = cheerio.load html
    $(".partner-profile-nav a[href*=articles]").length.should.equal 0

  it 'shows articles link if has articles', ->
    profile = new Profile fabricate 'profile', id: 'gagosian-gallery', icon: null
    html = render('index')
      profile: profile
      partner: new Partner profile.get('owner')
      articles: [ fixtures.article ]
      represented: new Artists([fabricate 'artist']).models
      unrepresented: new Artists([fabricate 'artist']).models
      sd: {}
    $ = cheerio.load html
    $(".partner-profile-nav a[href*=articles]").length.should.be.above 0

  it 'renders the cover image', ->
    profile = new Profile fabricate 'profile',
      id: 'gagosian-gallery'
      cover_image:
        image_versions: ['wide']
        image_url: ':version-foobarbaz.jpg'
        image_urls: wide: 'foobarbaz.jpg'
    html = render('index')
      profile: profile
      partner: new Partner profile.get('owner')
      articles: [ fixtures.article ]
      represented: new Artists([fabricate 'artist']).models
      unrepresented: new Artists([fabricate 'artist']).models
      sd: {}
    html.should.containEql 'foobarbaz.jpg'
