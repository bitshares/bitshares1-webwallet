/* Exports a function which returns an object that overrides the default &
 *   plugin file patterns (used widely through the app configuration)
 *
 * To see the default definitions for Lineman's file paths and globs, see:
 *
 *   - https://github.com/linemanjs/lineman/blob/master/config/files.coffee
 */
module.exports = function(lineman) {
  //Override file patterns here
  return {
    js: {
      vendor: [
        "vendor/js/jquery.js",
        "vendor/js/jquery.growl.js",
        // "vendor/js/ark.js",
        "vendor/js/stacktrace.js",
        "vendor/js/angular.js",
        "vendor/js/angular-resource.js",
        "vendor/js/angular-ui-router.js",
        "vendor/js/ui-bootstrap-tpls.js",
	 	    "vendor/js/ui-grid.js",
        "vendor/js/angular-idle.js",
        "vendor/js/validate.js",
        "vendor/js/xeditable.js",
        "vendor/js/angular-translate.min.js",
        "vendor/js/angular-translate-loader-static-files.min.js",
        "vendor/js/jsonpath.js",
        "vendor/js/angular-pageslide-directive.js",
        "vendor/js/highstock.src.js"
      ],
      app: [
        "app/js/app.js",
        "app/js/**/*.js"
      ]
    },

//    less: {
//      compile: {
//        options: {
//          paths: ["vendor/css/normalize.css", "vendor/css/**/*.css", "app/css/**/*.less"]
//        }
//      }
//    },

    css: {
      vendor: [
        "vendor/css/jquery.growl.css",
        "vendor/css/bootstrap.css",
        "vendor/css/font-awesome.css",
        "vendor/css/ark.css",
        "vendor/css/xeditable.css",
        "vendor/css/ui-grid.css"
      ],
      app: [
        "app/css/bootstrap_overrides.css",
        "app/css/main.css",
        "app/css/forms.css",
        "app/css/layout.css",
        "app/css/my-ng-grid.css",
        "app/css/toolbar.css",
        "app/css/footer.css",
        "app/css/market.css",
        "app/css/spinner.css",
        "app/css/help.css",
        "app/css/splashpage.css"
      ]
    }

  };
};


