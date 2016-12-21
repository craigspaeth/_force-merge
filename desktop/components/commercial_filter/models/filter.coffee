Backbone = require 'backbone'
Q = require 'bluebird-q'
Aggregations = require '../collections/aggregations.coffee'
Artworks = require '../../../collections/artworks.coffee'
Artists = require '../../../collections/artists.coffee'
User = require '../../../models/user.coffee'
metaphysics = require '../../../lib/metaphysics.coffee'

module.exports = class Filter extends Backbone.Model
  defaults:
    loading: false

  initialize: ({ @params } = {}) ->
    throw new Error 'Requires a params model' unless @params?
    @artworks = new Artworks()
    @popular_artists = new Artists()
    @aggregations = new Aggregations()

    @params.on 'change', @fetch, @

  includeAggregations: ->
    @params.get('page') is 1 or @aggregations.length == 0

  aggregationSelector: ->
    if @includeAggregations()
      require '../queries/aggregations_selector.coffee'
    else
      ''

  aggregationFragment: ->
    if @includeAggregations()
      require '../queries/aggregations.coffee'
    else
      ''

  query: ->
    query = """
      query filterArtworks(
        $aggregations: [ArtworkAggregation],
        $for_sale: Boolean,
        $height: String,
        $width: String
        $page: Int,
        $size: Int,
        $color: String,
        $price_range: String,
        $gene_id: String,
        $medium: String,
        $sort: String,
        $extra_aggregation_gene_ids: [String],
        $major_periods: [String],
        $partner_cities: [String],
        $aggregation_partner_cities: [String],
        $include_artworks_by_followed_artists: Boolean
      ){
        filter_artworks(
          aggregations: $aggregations,
          for_sale: $for_sale,
          page: $page,
          size: $size,
          width: $width,
          height: $height,
          color: $color,
          price_range: $price_range,
          gene_id: $gene_id,
          medium: $medium,
          sort: $sort,
          extra_aggregation_gene_ids: $extra_aggregation_gene_ids,
          major_periods: $major_periods,
          partner_cities: $partner_cities,
          aggregation_partner_cities: $aggregation_partner_cities,
          include_artworks_by_followed_artists: $include_artworks_by_followed_artists
        ){
          total
          followed_artists_total
          #{@aggregationSelector()}
          hits {
            ... artwork
          }
          merchandisable_artists {
            ... artist
          }
        }
      }
      #{require '../queries/artwork.coffee'}
      #{require '../queries/artist.coffee'}
      #{@aggregationFragment()}
    """

  fetch: ->
    @set loading: true
    Q.promise (resolve, reject) =>
      metaphysics query: @query(), variables: @params.current(), req: user: User.instantiate()
        .then ({ filter_artworks }) =>
          if filter_artworks.hits.length
            @artworks.reset filter_artworks.hits
          @set loading: false
          @set total: filter_artworks.total
          @set followed_artists_total: filter_artworks.followed_artists_total
          @popular_artists.reset filter_artworks.merchandisable_artists
          @aggregations.reset filter_artworks.aggregations if filter_artworks.aggregations
          resolve @
        .catch (error) ->
          reject error
