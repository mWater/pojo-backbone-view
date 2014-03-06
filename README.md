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

To use, add `template` function that returns string or function that will be called with `{model: <model>}`

To add sub-views, create empty div in template with sub view id (any string). Then call:

`addSubView(id, factory, modelFunc)`

id: id of subview 
factory: function which creates and returns subview (since we may have to re-create it if model object of subview changes) which is a Backbone view
modelFunc: optional function which returns the model object on which the subview is based. If not specified, subview will be recreated on each render.

When the view modifies the model object, it *must* call dirty() afterwards which triggers a smart re-render of the entire tree of views. Views whose model has not changed are left alone.

Override `scope` function which by default returns the model to determine which object is used for dirty checking.

### PojoListView

A view for Javascript arrays.

To use, add createItemView function:

createItemView(item, index) 

item: item of the array 
index: 0-based index of the array item

returns: new Backbone view

When the view modifies the model object, it *must* call dirty() afterwards which triggers a smart re-render of the entire tree of views. Views whose model has not changed are left alone.


## Samples

See `demo` folder
