assert = require("chai").assert
PojoView = require '../src/PojoView'
sinon = require 'sinon'

_ = require 'lodash'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $

# Renders literal model string
class SimpleView extends Backbone.View
  initialize: () ->
    @render()

  render: ->
    @$el.html(@model)

class SimplePojoView extends PojoView
  template: ->
    'xyz<div id="a"></div><div id="b"></div>'

describe "PojoView", ->
  beforeEach ->
    @model = {a: {x:1}}
    @pview = new SimplePojoView(model: @model).render()

  it "adds subviews", ->
    @pview.addSubView "a", -> 
      new SimpleView(model:"A")
    , (model) -> model.a

    @pview.addSubView "b", -> 
      new SimpleView(model:"B")

    @pview.render()

    assert.match @pview.$el.html(), /A/

  it "does not re-render on unchanged model", ->
    spy = sinon.spy(@pview, "template")

    @pview.render()

    assert not spy.called

  it "does re-render on changed model", ->
    spy = sinon.spy(@pview, "template")

    @pview.model.b = 2
    @pview.render()

    assert spy.calledOnce

  it "respects scope unchanged", ->
    @pview.scope = -> {x:1}
    @pview.render()

    spy = sinon.spy(@pview, "template")

    @pview.model.b = 2
    @pview.render()

    assert not spy.called

  it "respects scope changed", ->
    @pview.scope = -> {x:1}
    @pview.render()

    spy = sinon.spy(@pview, "template")

    @pview.scope = -> {x:2}
    @pview.render()

    assert spy.calledOnce

  context "with subViews", ->
    beforeEach ->
      @pview.addSubView "a", -> 
        new SimpleView(model:"A")
      , (model) -> model.a

      @pview.addSubView "b", -> 
        new SimpleView(model:"B")

      @pview.render()

    it "preserves subviews if submodel same object", ->
      @pview.model.a.x = 2

      oldSubView = @pview.subViews[0].view
      @pview.render()
      assert oldSubView == @pview.subViews[0].view

    it "recreates subviews if submodel different object", ->
      @pview.model.a = { x: 2 }

      oldSubView = @pview.subViews[0].view
      @pview.render()
      assert oldSubView != @pview.subViews[0].view

    it "recreates subviews with no modelFunc", ->
      oldSubView = @pview.subViews[1].view

      @pview.model.a = { x: 2 }
      @pview.render()
      assert oldSubView != @pview.subViews[1].view

    it "rerenders subviews on render", ->
      spy = sinon.spy(@pview.subViews[0].view, "render")      

      @pview.render()
      assert spy.calledOnce

    it "renders all except subview on change event", ->
      spy1 = sinon.spy(@pview.subViews[0].view, "render")      
      spy2 = sinon.spy(@pview.subViews[1].view, "render")      

      @pview.subViews[0].view.trigger("change")

      assert not spy1.called
      assert spy2.calledOnce

    it "renders self on change event", ->
      spy1 = sinon.spy(@pview, "render")      

      @pview.subViews[0].view.trigger("change")
      assert spy1.calledOnce

    it "rerenders all when dirty is called", ->
      spy1 = sinon.spy(@pview.subViews[0].view, "render")      
      spy2 = sinon.spy(@pview.subViews[1].view, "render")      

      @pview.dirty()

      assert spy1.calledOnce
      assert spy2.calledOnce

    it "removes subviews on parent remove", ->
      spy1 = sinon.spy(@pview.subViews[0].view, "remove")      
      spy2 = sinon.spy(@pview.subViews[1].view, "remove")      

      @pview.remove()

      assert spy1.calledOnce
      assert spy2.calledOnce

    it "replaces subviews with same name", ->
      spy1 = sinon.spy(@pview.subViews[1].view, "remove")

      @pview.addSubView "b", -> 
        new SimpleView(model:"C")

      @pview.render()

      # Remove should be called
      assert spy1.calledOnce

      # Only 2 subviews
      assert.equal @pview.subViews.length, 2

  it "triggers change when dirty is called", ->
    changed = false
    @pview.on 'change', -> changed = true

    @pview.dirty()

    assert changed

  it "executes action when dirty is called with function", ->
    changed = false
    @pview.on 'change', -> changed = true

    actioned = false
    @pview.dirty =>
      assert not changed, "Should not have changed prematurely"
      actioned = true

    assert actioned, "Action should have run"
    assert changed, "Change should have happened"

  context "with null subView", ->
    beforeEach ->
      @pview.addSubView "a", -> 
        return null
      , (model) -> model.a

      @pview.render()

    it "does renders fine", ->
      assert.match @pview.$el.html(), /xyz/
