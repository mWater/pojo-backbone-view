module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    browserify: {
      dist: {
        files: {
          'index.js': ['src/demo.coffee', 'src/lib/jquery.sortable.js']
        },
        options: {
          extensions: [ '.coffee', '.js' ],
          transform: ['coffeeify'],
          alias: [
            'lodash:underscore'
            ]
        }
      }
    },

  });

  grunt.loadNpmTasks('grunt-browserify');

  grunt.registerTask('default', ['browserify']);  

};