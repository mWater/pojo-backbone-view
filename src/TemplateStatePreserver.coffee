# Saves state when templates are applied by copying input controls
# from previous rendering. If not done, focus and typing problems occur
# when the template is re-rendered
$ = require 'jquery'

module.exports = class TemplateStatePreserver

  # Apply saved state to new template element 
  apply: (element, html) ->
    savedElems = {}

    focusables = "input[type='text'],input[type='number'],select,button,a"

    # Find focusables in old html and detach
    for input in $(element).find(focusables)
      # Only those with id can be preserved
      # Select2 must be handled separately
      if input.id and not $(input).hasClass("select2-offscreen")
        # Find matching input in old element
        savedElems[input.id] = $(input).detach()

    # Apply template
    $(element).html(html)

    # Find inputs in new html
    for input in $(element).find(focusables)
      # Only those with id can be preserved
      if input.id and savedElems[input.id]?
        oldInput = savedElems[input.id]

        # Get new attributes
        attrs = input.attributes

        # Replace old attributes with new (except value, which must be done manually)
        for attr in attrs
          if attr.name isnt "value"
            $(oldInput).attr(attr.name, attr.value)

        # Copy value across
        $(oldInput).val($(input).val())

        # Copy contents across for buttons and links
        if input.tagName == "BUTTON" or input.tagName == "A"
          $(oldInput).html($(input).html())        

        # Replace new control with old
        $(input).replaceWith(oldInput)
