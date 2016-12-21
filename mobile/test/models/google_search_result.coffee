_ = require 'underscore'
sinon = require 'sinon'
Backbone = require 'backbone'
{ fabricate } = require 'antigravity'
GoogleSearchResult = require '../../models/google_search_result.coffee'

describe 'GoogleSearchResult', ->

  describe '#initialize', ->
    it 'handles post', ->
      result = new GoogleSearchResult({
        link: 'https://artsy.net/post/cool-post'
        title: "Post Title | Post Author | Artsy"
        snippet: 'cool post snippet'
        pagemap:
          metatags: [{'og:type': 'article'}]
          cse_thumbnail: [{ src: 'imgurl' }]
      })
      result.get('about').should.equal 'cool post snippet'
      result.get('display').should.equal 'Post Title'
      result.get('image_url').should.equal 'https://i.embed.ly/1/display/crop?url=imgurl&width=100&height=100&quality=95'
      result.get('location').should.equal '/post/cool-post'
      result.get('display_model').should.equal 'article'

    it 'handles gene', ->
      result = new GoogleSearchResult({
        link: 'https://artsy.net/gene/cool-gene'
        title: "Gene Title | Artsy"
        snippet: 'cool gene snippet'
        pagemap:
          metatags: [{'og:type': 'gene', 'og:description': 'gene description'}]
          cse_thumbnail: [{ src: 'imgurl' }]
      })
      result.get('display').should.equal 'Gene Title'
      result.get('image_url').should.equal 'https://i.embed.ly/1/display/crop?url=imgurl&width=100&height=100&quality=95'
      result.get('location').should.equal '/gene/cool-gene'
      result.get('display_model').should.equal 'category'

    it 'handles show', ->
      result = new GoogleSearchResult({
        link: 'https://artsy.net/show/cool-show'
        title: "Show Title | Artsy"
        snippet: 'cool show snippet'
        pagemap:
          metatags: [{'og:type': 'gene', 'og:description': 'show description'}]
          cse_thumbnail: [{ src: 'imgurl' }]
      })
      result.get('about').should.equal 'show description'
      result.get('display').should.equal 'Show Title'
      result.get('image_url').should.equal 'https://i.embed.ly/1/display/crop?url=imgurl&width=100&height=100&quality=95'
      result.get('location').should.equal '/show/cool-show'
      result.get('display_model').should.equal 'show'

    it 'handles artwork', ->
      result = new GoogleSearchResult({
        link: 'https://artsy.net/artwork/cool-artwork'
        title: "Artwork Title | Artist | Artsy"
        snippet: 'cool artwork snippet'
        pagemap:
          metatags: [{'og:type': 'artwork', 'og:description': 'artwork description'}]
          cse_thumbnail: [{ src: 'imgurl' }]
      })
      result.get('display').should.equal 'Artwork Title, Artist'
      result.get('image_url').should.equal 'https://i.embed.ly/1/display/crop?url=imgurl&width=100&height=100&quality=95'
      result.get('location').should.equal '/artwork/cool-artwork'
      result.get('display_model').should.equal 'artwork'

    it 'handles artist', ->
      result = new GoogleSearchResult({
        link: 'https://artsy.net/artist/cool-artist'
        title: "Artist Name | Artsy"
        snippet: 'cool artist snippet'
        pagemap:
          metatags: [{'og:type': 'artist', 'og:description': 'artist description'}]
          cse_thumbnail: [{ src: 'imgurl' }]
      })
      result.get('display').should.equal 'Artist Name'
      result.get('image_url').should.equal 'https://i.embed.ly/1/display/crop?url=imgurl&width=100&height=100&quality=95'
      result.get('location').should.equal '/artist/cool-artist'
      result.get('display_model').should.equal 'artist'

    it 'works without a pagemap', ->
      result = new GoogleSearchResult
        link: 'https://artsy.net/post/cool-post'
        title: "Post Title | Post Author | Artsy"
        snippet: 'cool post snippet'
        pagemap: null
      _.isUndefined(result.ogType()).should.be.true()

  describe '#href', ->
    beforeEach ->
      @results = [
        new GoogleSearchResult link: 'https://artsy.net/artist/cool-artist'
        new GoogleSearchResult link: 'https://www.artsy.net/artist/cool-artist'
        new GoogleSearchResult link: 'http://artsy.net/artist/cool-artist'
        new GoogleSearchResult link: 'http://www.artsy.net/artist/cool-artist'
      ]

    it 'replaces http, https, www. and bare artsy domains', ->
      _.invoke(@results, 'href').should.eql [
        '/artist/cool-artist'
        '/artist/cool-artist'
        '/artist/cool-artist'
        '/artist/cool-artist'
      ]
