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
  template: require('./TestTemplate.hbs')

describe "PojoView", ->
  beforeEach ->
    @model = {a: {x:1}}
    @pview = new SimplePojoView(model: @model).render()

  it "adds subviews", ->
    @pview.addSubView { id: "a", factory: -> new SimpleView(model:"A") }
    @pview.addSubView { id: "b", factory: -> new SimpleView(model:"B") }
    @pview.render()

    assert.match @pview.$el.html(), /A/

  it "renders template with data", ->
    @model.x = "alpha"
    @model.y = "beta"
    @pview.render()
    assert.match @pview.$el.html(), /alpha/
    assert.match @pview.$el.html(), /beta/

  it "re-renders on changed data", ->
    @model.x = "alpha"
    @model.y = "beta"
    @pview.render()
    @model.x = "gamma"
    @pview.render()
    assert.match @pview.$el.html(), /gamma/

  it "does not re-render on unchanged data", ->
    @model.x = "alpha"
    @model.y = "beta"
    @pview.render()
    @pview.template = null # Make erroneous
    @pview.render()

  it "calls postTemplate if present", ->
    called = false
    @pview.postTemplate = ->
      called = true

    @model.x = "alpha"
    @pview.render()
    assert.isTrue called

  it "uses data function if specified", ->
    @pview.data = ->
      return { x: "theta" }

    @pview.render()
    assert.match @pview.$el.html(), /theta/    

  context "with subViews", ->
    beforeEach ->
      @pview.addSubView { id: "a", factory: (-> new SimpleView(model:"A")), scope: (model) -> model.a }
      @pview.addSubView { id: "b", factory: -> new SimpleView(model:"B") }

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

    it "does not recreate subviews with no scope", ->
      oldSubView = @pview.subViews[1].view

      @pview.model.a = { x: 2 }
      @pview.render()
      assert oldSubView == @pview.subViews[1].view

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

      @pview.addSubView { id: "b", factory: -> new SimpleView(model:"C") }

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
      @pview.addSubView { id: "a", factory: -> return null }
      @pview.render()

    it "does renders fine", ->
      assert.match @pview.$el.html(), /xyz/
