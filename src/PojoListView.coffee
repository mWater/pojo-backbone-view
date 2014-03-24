$ = require 'jquery'
Backbone = require 'backbone'
htmlPreserver = require './htmlPreserver'

# Require in sortable
require '../bower_components/html.sortable/dist/html.sortable.0.1.1.js'

# Assumes that order of views might be important, so re-creates all on re-order
# To use, implement createItemView(item, zeroBasedIndex)
# Set sortable: true to allow drag&drop sorting
# Set sortHAndle to css selector to specify handle

module.exports = class PojoListView extends Backbone.View
  tagName: "ul"

  constructor: (options) ->
    super(options)
    
    # Save ctx option as nested views often need a context
    @ctx = options.ctx

    # Save sorting options
    @sortable = options.sortable || false
    @sortHandle = options.sortHandle

    @itemViews = []
    @itemModels = []

    # Set up sorting
    if @sortable
      @$el.sortable({
        handle: @sortHandle
        forcePlaceholderSize: true
      }).bind('sortupdate', @reorder)

  render: ->
    # Save focus and scroll
    htmlPreserver.preserveFocus =>
      # For each model item
      for i in [0...@model.length]
        # Check if item model is same
        if @itemModels[i] == @model[i]
          # Render itemView
          @itemViews[i].render()

          # Detach element
          @itemViews[i].$el.detach()
        else
          # Remove old view
          if @itemViews[i]?
            @itemViews[i].remove()

          # Create new element
          @itemViews[i] = @createItemView(@model[i], i)

          # Listen to change events
          @itemViews[i].on 'change', =>
            @render()
            @trigger 'change'

      # Remove excess itemViews
      for i in [@model.length...@itemViews.length]
        @itemViews[i].remove()

      # Truncate itemViews array
      if @model.length<@itemViews.length
        @itemViews.splice(@model.length, @itemViews.length - @model.length)

      # Create template for each model item
      @$el.empty()

      for i in [0...@model.length]
        # Create item
        item = $('<li data-index="'+i+'"></li>')
        if @itemClass
          item.addClass(@itemClass)

        # Add itemView to item
        item.append(@itemViews[i].$el)

        @$el.append(item) 

    # Save item models
    @itemModels = @model.slice(0)

    # Set up sorting
    if @sortable
      @$el.sortable('reload')

    return this

  # Call when contents have been reordered in the DOM
  reorder: =>
    # Copy model
    modelCopy = @model.slice(0)

    # For data index in DOM
    for i in [0...@model.length]
      item = @$el.children()[i]

      # Put in correct position
      @model[i] = modelCopy[parseInt($(item).data("index"))]

    # Remove all item views and models to force recreation
    @itemViews.splice(0, @itemViews.length)
    @itemModels.splice(0, @itemModels.length)
    @render()

    @trigger 'change'

  # Must be called when model is altered
  dirty: (action) =>
    if action?
      action()

    @render()
    @trigger 'change'

  remove: ->
    for itemView in @itemViews
      if itemView
        itemView.remove()
    super()