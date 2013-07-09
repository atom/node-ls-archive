module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      glob_to_multiple:
        expand: true
        cwd: 'src'
        src: ['*.coffee']
        dest: 'lib'
        ext: '.js'

    shell:
      test:
        command: 'jasmine-focused --coffee --captureExceptions spec'
        options:
          stdout: true
          stderr: true
          failOnError: true

    coffeelint:
      options:
        no_empty_param_list:
          level: 'error'
        max_line_length:
          level: 'ignore'
      src: ['src/**/*.coffee']
      test: ['spec/*.coffee']

  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-shell')
  grunt.registerTask 'clean', -> require('rimraf').sync('lib')
  grunt.registerTask('lint', ['coffeelint'])
  grunt.registerTask('default', ['clean', 'lint', 'coffee'])
  grunt.registerTask('test', ['default', 'shell:test'])
