$ = require 'jquery'
Backbone = require 'backbone'

# Assumes that order of views might be important, so re-creates all on re-order
# To use, implement createItemView(item, zeroBasedIndex)

module.exports = class PojoListView extends Backbone.View
  tagName: "ul"

  constructor: (options) ->
    super(options)
    
    # Save ctx option as nested views often need a context
    @ctx = options.ctx

    @itemViews = []
    @itemModels = []

  render: ->
    # Save focused element
    focused = document.activeElement

    # Turn off transitions on focused element
    if focused?
      $(focused).css("transition", "none")
      $(focused).css("-webkit-transition", "none")

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

    if focused?
      # Set focus back
      $(focused).focus()
  
      # Turn back on transitions on focused element
      $(focused).css("transition", "")
      $(focused).css("-webkit-transition", "")

    # Save item models
    @itemModels = @model.slice(0)

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