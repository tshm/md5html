lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet
mountFolder = (connect, dir) ->
  connect.static(require('path').resolve(dir))

module.exports = (grunt) ->
  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  # configurable paths
  yeomanConfig =
    app: 'app'
    dist: 'dist'

  try
    yeomanConfig.app = require('./component.json').appPath || yeomanConfig.app
  catch e

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      jade:
        files: ['<%= yeoman.app %>/*.jade']
        tasks: ['jade:html']
      coffee:
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee']
        tasks: ['coffee:dist']
      coffeeTest:
        files: ['test/spec/{,*/}*.coffee']
        tasks: ['coffee:test']
      compass:
        files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}']
        tasks: ['compass']
      livereload:
        files: [
          '{.tmp,<%= yeoman.app %>}/{,*/}*.html'
          '{.tmp,<%= yeoman.app %>}/styles/{,*/}*.css'
          '{.tmp,<%= yeoman.app %>}/scripts/{,*/}*.js'
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]
        tasks: ['livereload']
    connect:
      options:
        port: 9000
        # Change this to '0.0.0.0' to access the server from outside.
        hostname: 'localhost'
      livereload:
        options:
          middleware: (connect) ->
            return [
              lrSnippet
              mountFolder(connect, '.tmp')
              mountFolder(connect, yeomanConfig.app)
            ]
      test:
        options:
          middleware: (connect) ->
            return [
              mountFolder(connect, '.tmp')
              mountFolder(connect, 'test')
            ]
    open:
      server:
        url: 'http://localhost:<%= connect.options.port %>'
    clean:
      dist:
        files: [
          dot: true
          src: [
            '.tmp'
            '<%= yeoman.dist %>/*'
            '!<%= yeoman.dist %>/.git*'
          ]
        ]
      server: '.tmp'
    jshint:
      options:
        jshintrc: '.jshintrc'
      all: [
        'Gruntfile.js'
        '<%= yeoman.app %>/scripts/{,*/}*.js'
      ]
    karma:
      unit:
        configFile: 'karma.conf.js'
        singleRun: true
    coffee:
      dist:
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: '<%= yeoman.app %>/scripts'
          src: '{,*/}*.coffee'
          dest: '.tmp/scripts'
          ext: '.js'
        ]
      test:
        files: [
          expand: true
          cwd: 'test/spec'
          src: '{,*/}*.coffee'
          dest: '.tmp/spec'
          ext: '.js'
        ]
    compass:
      options:
        sassDir: '<%= yeoman.app %>/styles'
        cssDir: '.tmp/styles'
        imagesDir: '<%= yeoman.app %>/images'
        javascriptsDir: '<%= yeoman.app %>/scripts'
        fontsDir: '<%= yeoman.app %>/styles/fonts'
        importPath: '<%= yeoman.app %>/components'
        relativeAssets: true
      dist: {}
      server:
        options:
          debugInfo: true
    jade:
      html:
        options:
          pretty: true
          data: { debug: true }
        files: [
          expand: true
          cwd: '<%= yeoman.app %>'
          src: '*.jade'
          dest: '.tmp'
          ext: '.html'
        ]
      dist:
        options:
          pretty: true
          data: { debug: false }
        src: '<%= yeoman.app %>/index.jade'
        dest: '<%= yeoman.app %>/index.html'
    concat:
      dist:
        files:
          '<%= yeoman.dist %>/scripts/scripts.js': [
            '.tmp/scripts/{,*/}*.js'
            '<%= yeoman.app %>/scripts/{,*/}*.js'
          ]
    useminPrepare:
      html: '<%= yeoman.app %>/index.html'
      options:
        dest: '<%= yeoman.dist %>'
    usemin:
      html: ['<%= yeoman.dist %>/{,*/}*.html']
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css']
      options:
        dirs: ['<%= yeoman.dist %>']
    imagemin:
      dist:
        files: [{
          expand: true
          cwd: '<%= yeoman.app %>/images'
          src: '{,*/}*.{png,jpg,jpeg}'
          dest: '<%= yeoman.dist %>/images'
        }]
    cssmin:
      dist:
        files:
          '<%= yeoman.dist %>/styles/main.css': [
            '.tmp/styles/{,*/}*.css'
            '<%= yeoman.app %>/styles/{,*/}*.css'
          ]
    htmlmin:
      dist:
        options: {
          ###
          removeCommentsFromCDATA: true
          # https://github.com/yeoman/grunt-usemin/issues/44
          # collapseWhitespace: true
          collapseBooleanAttributes: true
          removeAttributeQuotes: true
          removeRedundantAttributes: true
          useShortDoctype: true
          removeEmptyAttributes: true
          removeOptionalTags: true
          ###
        }
        files: [{
          expand: true
          cwd: '<%= yeoman.app %>'
          src: ['*.html', 'views/*.html']
          dest: '<%= yeoman.dist %>'
        }]
    cdnify:
      dist:
        html: ['<%= yeoman.dist %>/*.html']
    ngmin:
      dist:
        files: [{
          expand: true
          cwd: '<%= yeoman.dist %>/scripts'
          src: '*.js'
          dest: '<%= yeoman.dist %>/scripts'
        }]
    uglify:
      dist:
        files:
          '<%= yeoman.dist %>/scripts/scripts.js': [
            '<%= yeoman.dist %>/scripts/scripts.js'
          ]
    rev:
      dist:
        files:
          src: [
            '<%= yeoman.dist %>/scripts/{,*/}*.js'
            '<%= yeoman.dist %>/styles/{,*/}*.css'
            '<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp}'
            '<%= yeoman.dist %>/styles/fonts/*'
          ]
    offline:
      options:
        dest: 'index_offline.html'
        source: 'index.html'
    copy:
      dist:
        files: [{
          expand: true
          dot: true
          cwd: '<%= yeoman.app %>'
          dest: '<%= yeoman.dist %>'
          src: [
            '*.{ico,txt}'
            '.htaccess'
            'components/**/*'
            'images/{,*/}*.{gif,webp}'
          ]
        }]

  grunt.renameTask('regarde', 'watch')

  grunt.registerTask('server', [
    'clean:server'
    'jade:html'
    'coffee:dist'
    #compass:server'
    'livereload-start'
    'connect:livereload'
    'open'
    'watch'
  ])

  grunt.registerTask('test', [
    'clean:server'
    'jade:html'
    'coffee'
    #compass'
    'connect:test'
    'karma'
  ])

  grunt.registerTask('build', [
    'clean:dist'
    'jade:dist:release'
    'jshint'
    #test'
    'coffee'
    #compass:dist'
    'useminPrepare'
    'imagemin'
    'cssmin'
    'htmlmin'
    'concat'
    'copy'
    'cdnify'
    'ngmin'
    'uglify'
    'rev'
    'usemin'
  ])

  grunt.registerTask 'default', ['build']

  # Alias the `test` task to run `karma` instead
  grunt.registerTask 'test', 'run the karma test driver', () ->
    done = this.async()
    require('child_process').exec 'karma start --single-run', (err, stdout) ->
      grunt.log.write(stdout)
      done(err)

  grunt.registerTask 'buildall', ['build', 'offline']

  grunt.registerTask 'offline', 'build offline page', () ->
    process.chdir('dist')
    options = this.options()
    pattern = new RegExp('<(script|link).*(src|href)="([^"]+)"[^>]*>(.*)', 'i')
    console.log( options )
    lines = grunt.file.read(options.source).split(/\n/).map (line) ->
      match = line.match(pattern)
      if not ( match and match[1] and match[3] )
        return line
      grunt.log.writeln(match)
      file = match[3]
      post = match[4]
      contents = grunt.file.read(file)
      return if match[1] is 'link'
        '<style>' + contents + '</style>' + post
      else
        '<script>' + contents + post
    grunt.file.write(options.dest, lines.join('\n'))
    grunt.log.writeln('offline build task complete.')

