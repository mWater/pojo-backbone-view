PojoListView = require('../../index.js').PojoListView
Backbone = require 'backbone'
$ = require 'jquery'
Backbone.$ = $

fruits = ['apple', 'orange', 'banana']

# Make a simple class to render a fruit
class FruitView extends Backbone.View
  render: ->
    @$el.html("<div>" + @model + "</div>")
    return this

# Make a class to render a list
class FruitListView extends PojoListView
  createItemView: (item, index) ->
    return new FruitView(model:item).render()

view = new FruitListView(model:fruits)
view.render()

$("body").append(view.el)