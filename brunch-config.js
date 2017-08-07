exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["web/static/css/app.css"] // concat app.css last
      }
    }
  },

  conventions: {
    assets: /^(web\/static\/assets)/,
    ignored: /^(web\/elm\/elm-stuff)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "web/elm"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      pattern: /^web\/static\/js\/app\.js$/
    },
    elmBrunch: {
      elmFolder: 'web/elm',
      mainModules: ['Main.elm'],
      outputFolder: '../static/js',
      makeParameters: ['--debug', '--warn']
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  sourceMaps: false,

  npm: {
    enabled: true
  },

  overrides: {
    production: {
      plugins: {
        elmBrunch: {
          makeParameters: []
        }
      }
    }
  }
};
