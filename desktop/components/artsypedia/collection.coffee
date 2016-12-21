_ = require 'underscore'
Backbone = require 'backbone'
Item = require './model.coffee'

module.exports = class Items extends Backbone.Collection
  model: Item

  parse: (items) ->
    _.filter items, (item) ->
      item[Item::imgAttr] isnt null
