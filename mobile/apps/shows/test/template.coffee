_ = require 'underscore'
benv = require 'benv'
moment = require 'moment'
{ resolve } = require 'path'
{ fabricate } = require 'antigravity'
Show = require '../../../models/show'
{Cities, FeaturedCities} = require 'places'

describe 'Shows template', ->
  before (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      done()

  describe '#index with cities and featured show', ->
    before ->
      benv.render resolve(__dirname, '../templates/index.jade'),
        sd: {}
        cities: Cities
        featuredCities: FeaturedCities
        featuredShow: new Show fabricate 'show'

    xit 'renders correctly', ->
      $('.shows-header').length.should.equal 1
      $('.shows-page-featured-cities a').length.should.equal 11

  describe '#cities with single city and shows', ->
    before ->
      @currentShow = new Show fabricate 'show', status: 'running', id: 'running-show', name: 'running-show'
      @upcomingShow = new Show fabricate 'show', status: 'upcoming', id: 'upcoming-show', name: 'upcoming-show'
      @pastShow = new Show fabricate 'show', status: 'closed', id: 'closed-show', name: 'closed-show'

      benv.render resolve(__dirname, '../templates/city.jade'),
        sd: {}
        city: {name: 'New York'}
        opening: []
        upcoming: [@upcomingShow]
        current: [@currentShow]
        past: [@pastShow]

    it 'renders correctly', ->
      $('.shows-city--current-shows').length.should.equal 1
      $('.shows-city--upcoming-shows').length.should.equal 1
      $('.shows-city--past-shows').length.should.equal 1

  describe '#all-cities with every city', ->
    before ->
      benv.render resolve(__dirname, '../templates/all_cities.jade'),
        sd: {}
        cities: Cities

    after ->
      benv.teardown()

    it 'renders correctly', ->
      $('.all-cities-page-all-cities a').length.should.be.above 83
