assert = require("chai").assert
PojoListView = require '../src/PojoListView'
sinon = require 'sinon'

_ = require 'lodash'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $

class SimpleView extends Backbone.View

class SimpleListView extends PojoListView
  createItemView: (item) ->
    return new SimpleView(model:item)

describe 'PojoListView', ->
  beforeEach ->
    @list = [{a : 1}, {a : 2}, {a : 3}]
    @listView = new SimpleListView(model:@list).render()

  it 'has correct number of items', ->
    assert @listView.$("li").length == 3

  it 'handles removes items', ->
    # Remove second item and re-render
    @list.splice(1, 1)
    @listView.render()
    assert @listView.$("li").length == 2
    assert @listView.itemViews.length == 2

  it "removes item view on item removal", ->
    spy1 = sinon.spy(@listView.itemViews[0], "remove")      
    spy2 = sinon.spy(@listView.itemViews[1], "remove")      

    # Remove second item and re-render
    @list.splice(1, 1)
    @listView.render()

    assert not spy1.called
    assert spy2.calledOnce

  it 'handles add items', ->
    # Add item and re-render
    @list.push({a:4})
    @listView.render()
    assert @listView.$("li").length == 4

  it 'preserves views on add', ->
    itemViews = _.clone(@listView.itemViews)

    # Add item and re-render
    @list.push({a:4})
    @listView.render()

    # Check that views are same
    assert @listView.itemViews[0] == itemViews[0]

  it 'handles reorders', ->
    # Re-order DOM items (first to last)
    @listView.$el.append($(@listView.$("li")[0]).detach())

    # Indicate reorder
    @listView.reorder()

    # Check model order
    assert.deepEqual _.pluck(@list, 'a'), [2, 3, 1]

  it 'fires change event on reorder', ->
    changed = false
    @listView.on 'change', -> changed = true

    # Re-order DOM items (first to last)
    @listView.$el.append($(@listView.$("li")[0]).detach())

    # Indicate reorder
    @listView.reorder()

    assert changed

  it 'fires change event on item change', ->
    changed = false
    @listView.on 'change', -> changed = true

    # Indicate change
    @listView.itemViews[0].trigger 'change'

    assert changed

  it 'renders on item change', ->
    spy = sinon.spy(@listView, "render")

    # Indicate change
    @listView.itemViews[0].trigger 'change'

    assert spy.calledOnce

  it "rerenders when dirty is called", ->
    spy = sinon.spy(@listView, "render")

    @listView.dirty()
    assert spy.calledOnce

  it "triggers change when changed is called", ->
    changed = false
    @listView.on 'change', -> changed = true

    @listView.dirty()
    assert changed

  it "removes item views on remove", ->
    spy1 = sinon.spy(@listView.itemViews[0], "remove")      
    spy2 = sinon.spy(@listView.itemViews[1], "remove")      

    @listView.remove()

    assert spy1.calledOnce
    assert spy2.calledOnce
