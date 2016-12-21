_ = require 'underscore'
Q = require 'bluebird-q'
Backbone = require 'backbone'
Items = require '../collections/items.coffee'
LayoutSyle = require './mixins/layout_style.coffee'

module.exports = class OrderedSet extends Backbone.Model
  _.extend @prototype, LayoutSyle

  fetchItems: (cache = false) ->
    dfd = Q.defer()
    items = new Items null, id: @id, item_type: @get('item_type')
    @set items: items
    Q.allSettled(items.fetch(cache: cache).then ->
      items.map (item) ->
        if _.isFunction(item.fetchItems) then item.fetchItems(cache) else item
    ).finally dfd.resolve
    dfd.promise
