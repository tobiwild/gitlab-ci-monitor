exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["css/app.css"] // concat app.css last
      }
    }
  },

  conventions: {
    assets: /^(static)/,
    ignored: /^(elm\/elm-stuff)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "css",
      "elm",
      "js",
      "static",
      "vendor"
    ],

    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      pattern: /^js\/app\.js$/
    },
    elmBrunch: {
      elmFolder: 'elm',
      mainModules: ['Main.elm'],
      outputFolder: '../js',
      makeParameters: ['--debug', '--warn']
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
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
