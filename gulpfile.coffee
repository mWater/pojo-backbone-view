browserify = require 'browserify'
gulp = require 'gulp'
source = require 'vinyl-source-stream'
fs = require 'fs'
clean = require 'gulp-clean'
glob = require 'glob'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'

gulp.task 'default', ['prepublish']
gulp.task 'prepublish', ['coffee', 'copy']

# gulp.task 'watch', ->
#   return gulp.watch ['src/**/*', 'assets/**/*'], ['build']

gulp.task 'prepare-tests', ->
  files = glob.sync("./test/*Tests.coffee")
  bundler = browserify({ entries: files, extensions: [".js", ".coffee"] })
  return bundler.bundle()
    .on('error', gutil.log)
    .on('error', -> throw "Failed")
    .pipe(source('browserified.js'))
    .pipe(gulp.dest('./test'))

gulp.task "coffee", ->
  return gulp.src('./src/**/*.coffee')
    .pipe(coffee(bare: true).on("error", gutil.log))
    .pipe(gulp.dest('./lib'))

gulp.task 'copy', ->
  gulp.src(['./src/**/*.js', './src/**/*.css', './src/**/*.hbs'])
    .pipe(gulp.dest('./lib'))

