# POJO Backbone View

Backbone Views that use Plain Old Javascript Objects and dirty checking

## Rationale

Backbone Models are painful when manipulating complex and deeply nested Javascript objects. If you want to create Meteor-style views that use templates and properly preserve inputs with all the handiness of Angular.JS dirty checking, then POJO Backbone View is the thing for you.

## Dependencies

Depends on backbone and lodash (for deep cloning). Is Bootstrap friendly.

## Usage

POJO Backbone View is designed to be used with browserify.

There are two classes: PojoView and PojoListView.

### PojoView

A view with optional nested sub-views. Subviews are re-rendered properly and are themselves nestable.

To use, add `template` function that returns a handlebars template (compiled). It will be called with the results of the `data` function.

`data` function should produce an object which is passed to the template

Any post-render work can be done in `postTemplate` function which is passed results of `data` function

To add sub-views, create empty div in template with sub view id (any string). Then call:

`addSubView(options)`

Options
id: the DOM id where the subview will be inserted
factory: function which produces a view. It is called with result of scope function if scope is present
scope: is a function which produces the object used to determine if the subview should be recreated.
If not specified, subview will always be recreated on render. scope object is tested for === equality, not deep equal

When the view modifies the model object, it *must* call dirty() afterwards which triggers a smart re-render of the entire tree of views. Views whose model has not changed are left alone.

Override `scope` function which by default returns the model to determine which object is used for dirty checking.

### PojoListView

A view for Javascript arrays.

To use, add factory function:

`factory(item, index) `

`item:` item of the array 
`index`: 0-based index of the array item

returns: new Backbone view

When the view modifies the model object, it *must* call dirty() afterwards which triggers a smart re-render of the entire tree of views. Views whose model has not changed are left alone.


## Samples

See `demo` folder
