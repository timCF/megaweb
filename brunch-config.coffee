exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  conventions:
    ignored: /^(vendor.*\.less|vendor.*\.jade|.+node_modules.+|.+_.+\..+)$/
  modules:
    definition: 'commonjs'
    wrapper: 'commonjs'
  sourceMaps: false
  paths:
    public: 'public/'
  files:
    javascripts:
      joinTo:
        #'js/app.js': /^app/
        #'js/vendor.js': /^vendor/
        'js/app.js': /^(app|vendor)/
      order:
        before: [
          'node_modules/jquery/dist/jquery.js'
        ]

    stylesheets:
      joinTo:
        'css/app.css' : /^(app|vendor)/

    templates:
      joinTo:
        'js/templates.js': /^app.*\.jade$/
        'js/app.js': /^app.*\.jreact$/

  plugins:
    jade:
      options:
        pretty: false # Adds pretty-indentation whitespaces to output (false by default)
      noRuntime: true

    less:
      dumpLineNumbers: 'comments'
      
    bower:
      extend:
        #"bootstrap" : 'vendor/bootstrap/docs/assets/js/bootstrap.js'
        "angular-mocks": []
        "styles": []
      asserts:
        "img" : /bootstrap(\\|\/)img/
        "font": /font-awesome(\\|\/)font/

