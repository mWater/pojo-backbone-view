# Saves state when elements have HTML replaced by copying input controls
# from previous rendering. If not done, focus and typing problems occur
# when the template is re-rendered
$ = require 'jquery'
_ = require 'underscore'

# Preserves focus and scroll when an action is preformed
# In action function, call replaceHtml 
exports.preserveFocus = (action) ->
  # Save focused element
  focused = document.activeElement

  # Turn off transitions on focused element
  if focused?
    $(focused).css("transition", "none")
    $(focused).css("-webkit-transition", "none")

  # Save scroll position
  oldScrollTop = $(window).scrollTop()

  # Perform action
  action()

  # Restore scroll position
  $(window).scrollTop(oldScrollTop)

  # Restore focus
  if focused?
    # Set focus back
    $(focused).focus()

    # Turn back on transitions on focused element
    $(focused).css("transition", "")
    $(focused).css("-webkit-transition", "")

# Replace element contents with html, preserving inputs
exports.replaceHtml = (element, html) ->
  savedElems = {}

  focusables = "input[type='text'],input[type='number'],select,button,a,textarea"

  # Find focusables in old html and detach
  for input in $(element).find(focusables)
    # Only those with id can be preserved
    # Select2 must be handled separately
    # If multiple with same id, ignore
    if input.id and not $(input).hasClass("select2-offscreen") and not $(input).hasClass("select2-input") and $(element).find("#" + input.id).length == 1
      # Find matching input in old element
      savedElems[input.id] = $(input).detach()

  # Apply template
  $(element).html(html)

  # Find inputs in new html
  for input in $(element).find(focusables)
    # Only those with id can be preserved
    if input.id and savedElems[input.id]?
      oldInput = savedElems[input.id][0]

      # Get list of all attributes of new and old
      attrNames = _.union(_.pluck(input.attributes, "name"), _.pluck(oldInput.attributes, "name"))

      # Replace old attributes with new
      for attr in attrNames
        if $(oldInput).prop(attr) != $(input).prop(attr)
          $(oldInput).prop(attr, $(input).prop(attr))

      # Copy contents across for buttons and links and selects
      if input.tagName == "BUTTON" or input.tagName == "A" or input.tagName == "SELECT"
        $(oldInput).html($(input).html())        

      # Copy value across if different (since value might not be explicitly set as attribute)
      newValue = $(input).val()
      oldValue = $(oldInput).val()
      if oldValue != newValue
        $(oldInput).val(newValue)

      # Replace new control with old
      $(input).replaceWith(oldInput)
