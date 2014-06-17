_ = require 'lodash'
$ = require 'jquery'
Backbone = require 'backbone'
htmlPreserver = require './htmlPreserver'

module.exports = class PojoView extends Backbone.View
  constructor: (options) ->
    super(options)

    # Save ctx option as nested views often need a context
    @ctx = options.ctx
    
    @subViews = []  # Each contains id, factory, scope, model, view

    @renderNeeded = false  # Set true when render is needed due to subview manipulation

  data: -> return @model

  # Add a subView. Render must be called after.
  # id is the DOM id where the subview will be inserted
  # factory takes a submodel parameter (from modelFunc) and produces a view
  # scope is a function which produces the model object used to determine
  #  if the subview should be recreated. If not specified, subview will always
  #  be recreated on render. scope object is tested for === equality, not deep equal
  addSubView: (options) ->
    if not options.id
      throw new Error("id required")

    if not options.factory
      throw new Error("factory required")

    # Check for existing id
    existing = _.find(@subViews, { id: options.id })
    if existing?
      if existing.view?
        existing.view.remove()
      @subViews.splice(@subViews.indexOf(existing), 1)

    subView =  { 
      id: options.id
      factory: options.factory
      scope: options.scope
      model: undefined
      view: undefined
      scopeObj: if options.scope then options.scope(@model) else null
    }

    @subViews.push subView
    @renderNeeded = true

  getSubView: (id) ->
    return _.findWhere(@subViews, { id: id }).view

  _processSubView: (subView, $el, renderOnlySelf, reattach) ->
    # If scope changed, recreate view
    newScopeObj = if subView.scope then subView.scope(@model) else null
    
    # If model changed object, or view doesn't exist, recreate view
    if subView.scopeObj != newScopeObj or not subView.view?
      # Remove old view
      if subView.view?
        subView.view.remove()

      # Create new view
      subView.view = subView.factory(newScopeObj)

      if subView.view?
        # Listen to change events
        @listenTo subView.view, 'change', =>
          changedView = subView

          # Render all other views
          for sv in @subViews
            if sv.view? and sv != changedView 
              sv.view.render()

          # Render only self
          @render(true)

          # Bubble change event up
          @trigger 'change'

      # Insert view
      if subView.view
        subViewEl = $el.find("#" + subView.id)
        subViewEl.append(subView.view.$el)
    else
      # Render existing subView
      if subView.view? and not renderOnlySelf
        subView.view.render()

      # Detach and reattach
      if subView.view? and reattach
        subViewEl = $el.find("#" + subView.id)
        subViewEl.append(subView.view.$el.detach())

    # Save subview scope
    subView.scopeObj = newScopeObj

  renderSubViews: ->
    for subView in @subViews
      if subView.view?
        subView.view.render()

  forceRender: ->
    @renderNeeded = true
    @render()

  render: (renderOnlySelf = false) ->
    # Check if data changed
    currentData = @data()

    if not @renderNeeded and _.isEqual(currentData, @savedData)
      # Just process subviews
      if not renderOnlySelf
        # For each subview
        for subView in @subViews
          @_processSubView subView, @$el, renderOnlySelf, false
      return this

    @renderNeeded = false

    # Save focus and scroll
    htmlPreserver.preserveFocus =>
      # Detach all subviews
      for subView in @subViews
        if subView.view?
          subView.view.$el.detach()

      if @preTemplate
        @preTemplate(currentData)

      # Apply template, preserving state
      htmlPreserver.replaceHtml(@$el, @template(currentData))

      # For each subview
      for subView in @subViews
        @_processSubView subView, @$el, renderOnlySelf, true

      if @postTemplate
        @postTemplate(currentData)

    # Save model scope
    @savedData = _.cloneDeep(currentData)

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