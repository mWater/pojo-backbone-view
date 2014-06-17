$ = require 'jquery'
Backbone = require 'backbone'
htmlPreserver = require './htmlPreserver'

# Require in sortable
require './html.sortable.js'

# Assumes that order of views might be important, so re-creates all on re-order
# To use, implement factory(itemList, zeroBasedIndex)
# Set sortable: true to allow drag&drop sorting
# Set sortHandle to css selector to specify handle

module.exports = class PojoListView extends Backbone.View
  tagName: "ul"

  constructor: (options) ->
    super(options)
    
    # Save ctx option as nested views often need a context
    @ctx = options.ctx

    @itemViews = []
    @itemModels = []

    # Set up sorting
    if options.sortable
      @makeSortable(handle: options.sortHandle)

  # Make the list drag sortable. Pass handle to options as css selector if should
  # only drag on handle. Call before or after render
  makeSortable: (options) ->
    @sortable = true

    @$el.sortable({
      handle: options.handle
      forcePlaceholderSize: true
    }).bind('sortupdate', @reorder)

  createItemView: (index) =>
    # Create new element
    @itemViews[index] = @factory(@model, index)
    @itemModels[index] = @model[index]

    # Listen to change events
    @listenTo @itemViews[index], 'change', =>
      # Render list
      @render(true)

      # Render other sub-items
      for i in [0...@model.length]
        if i != index
          @itemViews[i].render()

      # Bubble up event
      @trigger 'change'

    # Return new view for convenience
    return @itemViews[index]

  render: (onlySelf = false) ->
    reloadSortNeeded = false

    # Save focus and scroll
    htmlPreserver.preserveFocus =>
      # Remove excess itemViews
      if @model.length < @itemViews.length
        # Remove item views
        for i in [@model.length...@itemViews.length]
          @itemViews[i].remove()

          # Remove holder element
          @$el.children("li").eq(i).remove()

        # Trim arrays
        excess = @itemViews.length - @model.length
        @itemViews.splice(@model.length, excess)
        @itemModels.splice(@model.length, excess)

      # Add new items as needed
      if @model.length > @itemViews.length
        reloadSortNeeded = true

        for i in [@itemViews.length...@model.length]
          # Create item element
          itemElem = $('<li data-index="'+i+'"></li>')
          if @itemClass
            itemElem.addClass(@itemClass)

          # Create item view
          @createItemView(i)

          # Add itemView to item
          itemElem.append(@itemViews[i].$el)

          # Add item element to list
          @$el.append(itemElem) 

      # For each model item
      for i in [0...@model.length]
        # Check if item model is same
        if @itemModels[i] == @model[i]
          # Render itemView unless only self
          if not onlySelf
            @itemViews[i].render()
        else
          reloadSortNeeded = true

          # Remove old view
          if @itemViews[i]?
            @itemViews[i].remove()

          # Recreate view
          @$el.children("li").eq(i).append(@createItemView(i).$el)

    # Save item models
    @itemModels = @model.slice(0)

    # Refresh sorting
    if @sortable and reloadSortNeeded
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
    for itemView in @itemViews
      if itemView
        itemView.remove()

    @itemViews.splice(0, @itemViews.length)
    @itemModels.splice(0, @itemModels.length)
    @$el.children("li").remove()

    @render()

    @trigger 'change'

  # Must be called when model is altered
  dirty: (action) =>
    if action?
      action()

    @render()
    @trigger 'change'

  remove: ->
    if @sortable
      @$el.sortable('destroy')

    for itemView in @itemViews
      if itemView
        itemView.remove()
    super()