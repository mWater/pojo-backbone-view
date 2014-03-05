_ = require 'lodash'
$ = require 'jquery'
Backbone = require 'backbone'

TemplateStatePreserver = require './TemplateStatePreserver'

module.exports = class PojoView extends Backbone.View
  constructor: (options) ->
    super(options)

    # Save ctx option as nested views often need a context
    @ctx = options.ctx
    
    @statePreserver = new TemplateStatePreserver()

    @subViews = []  # Each contains id, factory, modelFunc, model, view

    @renderNeeded = false  # Set true when render is needed due to subview manipulation

  # Add a subView. Render must be called after.
  # id is the DOM id where the subview will be inserted
  # factory takes a submodel parameter (from modelFunc) and produces a view
  # modelFunc is a function which produces the model object used to determine
  #  if the subview should be recreated. If not specified, subview will always
  #  be recreated on render
  addSubView: (id, factory, modelFunc) ->
    # Check for existing id
    existing = _.find(@subViews, { id: id })
    if existing?
      if existing.view?
        existing.view.remove()
      @subViews.splice(@subViews.indexOf(existing), 1)

    subView =  { 
      id: id
      factory: factory
      modelFunc: modelFunc
      model: undefined
      view: undefined
    }

    @subViews.push subView
    @renderNeeded = true

  _processSubView: (subView, $el, renderOnlySelf = false) ->
    # If model changed object, recreate view
    subModel = if subView.modelFunc? then subView.modelFunc(@model) else null
    if not subModel? or subView.model != subModel
      # Remove old view
      if subView.view?
        subView.view.remove()

      subView.view = subView.factory(subModel)

      # Listen to change events
      if subView.view?
        subView.view.on 'change', =>
          changedView = subView

          # Render all other views
          for sv in @subViews
            if sv.view? and sv != changedView 
              sv.view.render()

          # Render only self
          @render(true)

          @trigger 'change'
    else
      # Just render existing subView
      if subView.view? and not renderOnlySelf
        subView.view.render()

    # Insert view
    if subView.view?
      subViewEl = $el.find("#" + subView.id)
      subViewEl.replaceWith(subView.view.$el.detach())

    # Save subview model
    subView.model = subModel

  renderSubViews: ->
    for subView in @subViews
      if subView.view?
        subView.view.render()

  forceRender: ->
    @renderNeeded = true
    @render()

  render: (renderOnlySelf = false) ->
    # Check if model changed
    if not @renderNeeded and _.isEqual(@model, @savedModel)
      # Just render subViews
      if not renderOnlySelf
        @renderSubViews()
      return this

    @renderNeeded = false

    # Save focused element
    focused = document.activeElement

    # Turn off transitions on focused element
    if focused?
      $(focused).css("transition", "none")
      $(focused).css("-webkit-transition", "none")

    # Detach all subviews
    for subView in @subViews
      if subView.view?
        subView.view.$el.detach()

    # Apply template, preserving state
    @statePreserver.apply(@$el, @template(@model))

    # For each subview
    for subView in @subViews
      @_processSubView subView, @$el, renderOnlySelf

    if focused?
      # Set focus back
      $(focused).focus()
  
      # Turn back on transitions on focused element
      $(focused).css("transition", "")
      $(focused).css("-webkit-transition", "")

    # Save model
    @savedModel = _.cloneDeep(@model)

    return this

  # Must be called when model is altered
  dirty: (action) =>
    if action?
      action()

    @render()
    @trigger 'change'

  remove: ->
    for subView in @subViews
      if subView.view?
        subView.view.remove()
    super()