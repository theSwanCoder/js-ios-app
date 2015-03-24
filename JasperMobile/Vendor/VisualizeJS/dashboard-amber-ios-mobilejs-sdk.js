(function() {
  define('js.mobile.ios.dashboard.callback', ['require'],function(require) {
    var IosCallback;
    return IosCallback = (function() {
      function IosCallback() {}

      IosCallback.prototype.onMaximize = function(title) {
        this._makeCallback("command:maximize&title:" + title);
      };

      IosCallback.prototype.onMinimize = function() {};

      IosCallback.prototype.onScriptLoaded = function() {};

      IosCallback.prototype.onLoadStart = function() {};

      IosCallback.prototype.onLoadDone = function() {
        this._makeCallback("command:didEndLoading");
      };

      IosCallback.prototype.onLoadError = function(error) {};

      IosCallback.prototype._makeCallback = function(command) {
        return window.location.href = "http://jaspermobile.callback/" + command;
      };

      return IosCallback;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.ios.logger', [],function() {
    var IosLogger;
    return IosLogger = (function() {
      function IosLogger() {}

      IosLogger.prototype.log = function(message) {};

      return IosLogger;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.context', [],function() {
    var Context;
    return Context = (function() {
      function Context(options) {
        this.logger = options.logger, this.callback = options.callback;
      }

      Context.prototype.setWindow = function(window) {
        this.window = window;
      };

      return Context;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.amber.dashboard.view', [],function() {
    var View;
    return View = (function() {
      function View(options) {
        this.context = options.context, this.el = options.el;
        this.logger = this.context.logger;
      }

      View.prototype.scaleView = function() {
        var windowHeight, windowWidth;
        windowWidth = this.context.window.width;
        windowHeight = this.context.window.height;
        return this.setSize(windowWidth, windowHeight);
      };

      View.prototype.setSize = function(width, height) {
        this.logger.log("Set size. Width: " + width + ". Height: " + height);
        this.el.css('width', width);
        return this.el.css('height', height);
      };

      View.prototype.disable = function() {
        return this._setInteractive(false);
      };

      View.prototype.enable = function() {
        return this._setInteractive(true);
      };

      View.prototype._setInteractive = function(enable) {
        var pointerMode;
        pointerMode = enable ? "auto" : "none";
        this.logger.log("Toggle interaction: " + pointerMode);
        return this.el.css("pointer-events", pointerMode);
      };

      return View;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.scaler', [],function() {
    var Scaler;
    return Scaler = (function() {
      function Scaler() {}

      Scaler.prototype.scale = function(factor) {
        jQuery("meta[name=viewport]").attr('content', 'width=device-width; minimum-scale=0.1; maximum-scale=1; user-scalable=yes');
        jQuery("#frame").css("width", "50%");
        jQuery("#frame").css("height", "50%");
      };

      return Scaler;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.amber.dashboard.controller', ['require','js.mobile.amber.dashboard.view','js.mobile.scaler'],function(require) {
    var DashboardController, Scaler, View;
    View = require('js.mobile.amber.dashboard.view');
    Scaler = require('js.mobile.scaler');
    return DashboardController = (function() {
      function DashboardController(context) {
        this.context = context;
        this.logger = this.context.logger;
        this.callback = this.context.callback;
        this.container = new View({
          el: jQuery('#frame'),
          context: this.context
        });
        this.scaler = new Scaler;
      }

      DashboardController.prototype.initialize = function() {
        this.callback.onLoadStart();
        this.scaler.scale(0.5);
        this._removeRedundantArtifacts();
        this._injectViewport();
        return this._attachDashletLoadListeners();
      };

      DashboardController.prototype.minimizeDashlet = function() {
        this.logger.log("minimize dashlet");
        this.logger.log("Remove original scale");
        jQuery(".dashboardCanvas > .content > .body div.canvasOverlay").removeClass("originalDashletInScaledCanvas");
        jQuery("div.dashboardCanvas > div.content > div.body > div").find(".minimizeDashlet")[0].click();
        this._disableDashlets();
        return this.callback.onMinimize();
      };

      DashboardController.prototype._injectViewport = function() {
        var viewPort;
        viewPort = document.querySelector('meta[name=viewport]');
        return viewPort.setAttribute('content', "width=device-width, height=device-height, user-scalable=yes");
      };

      DashboardController.prototype._scaleDashboard = function() {
        return jQuery('.dashboardCanvas').addClass('scaledCanvas');
      };

      DashboardController.prototype._attachDashletLoadListeners = function() {
        var timeInterval;
        return timeInterval = window.setInterval((function(_this) {
          return function() {
            var timeIntervalDashletContent;
            window.clearInterval(timeInterval);
            return timeIntervalDashletContent = window.setInterval(function() {
              var dashletContent, dashlets;
              dashlets = jQuery('.dashlet');
              if (dashlets.length > 0) {
                dashletContent = jQuery('.dashletContent > div.content');
                if (dashletContent.length === dashlets.length) {
                  _this._configureDashboard();
                  return window.clearInterval(timeIntervalDashletContent);
                }
              }
            }, 100);
          };
        })(this), 100);
      };

      DashboardController.prototype._configureDashboard = function() {
        this._scaleDashboard();
        this._overrideDashletTouches();
        this._disableDashlets();
        return this.callback.onLoadDone();
      };

      DashboardController.prototype._removeRedundantArtifacts = function() {
        var customStyle;
        this.logger.log("remove artifacts");
        customStyle = ".header, .dashletToolbar, .show_chartTypeSelector_wrapper { display: none !important; } .column.decorated { margin: 0 !important; border: none !important; } .dashboardViewer.dashboardContainer>.content>.body, .column.decorated>.content>.body, .column>.content>.body { top: 0 !important; } #mainNavigation{ display: none !important; }";
        return jQuery('<style id="custom_mobile"></style').text(customStyle).appendTo('head');
      };

      DashboardController.prototype._disableDashlets = function() {
        var dashletElements, dashlets;
        this.logger.log("disable dashlet touches");
        dashletElements = jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent());
        dashlets = new View({
          el: dashletElements,
          context: this.context
        });
        return dashlets.disable();
      };

      DashboardController.prototype._overrideDashletTouches = function() {
        var dashlets, self;
        this.logger.log("override dashlet touches");
        dashlets = jQuery('div.dashboardCanvas > div.content > div.body > div');
        dashlets.unbind();
        self = this;
        return dashlets.click(function() {
          var dashlet, innerLabel, title;
          dashlet = jQuery(this);
          innerLabel = dashlet.find('.innerLabel > p');
          if ((innerLabel != null) && (innerLabel.text != null)) {
            title = innerLabel.text();
            if ((title != null) && title.length > 0) {
              return self._maximizeDashlet(dashlet, title);
            }
          }
        });
      };

      DashboardController.prototype._maximizeDashlet = function(dashlet, title) {
        var button, dashletElements, dashlets;
        this.logger.log("maximizing dashlet");
        dashletElements = jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent());
        dashlets = new View({
          el: dashletElements,
          context: this.context
        });
        dashlets.enable();
        this.callback.onMaximize(title);
        button = jQuery(jQuery(dashlet).find('div.dashletToolbar > div.content div.buttons > .maximizeDashletButton')[0]);
        button.click();
        this.logger.log("Add original scale");
        return jQuery(".dashboardCanvas > .content > .body div.canvasOverlay").addClass("originalDashletInScaledCanvas");
      };

      return DashboardController;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.amber.dashboard.window', [],function() {
    var DashboardWindow;
    return DashboardWindow = (function() {
      function DashboardWindow(width, height) {
        this.width = width;
        this.height = height;
      }

      return DashboardWindow;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.amber.dashboard', ['require','js.mobile.amber.dashboard.controller','js.mobile.amber.dashboard.window'],function(require) {
    var DashboardController, DashboardWindow, MobileDashboard, root;
    DashboardController = require('js.mobile.amber.dashboard.controller');
    DashboardWindow = require('js.mobile.amber.dashboard.window');
    MobileDashboard = (function() {
      MobileDashboard._instance = null;

      MobileDashboard.getInstance = function(context) {
        return this._instance || (this._instance = new MobileDashboard(context));
      };

      MobileDashboard.run = function() {
        return this._instance.run();
      };

      MobileDashboard.minimizeDashlet = function() {
        return this._instance.minimizeDashlet();
      };

      function MobileDashboard(context1) {
        this.context = context1;
        this.context.callback.onScriptLoaded();
      }

      MobileDashboard.prototype.run = function() {
        var window;
        window = new DashboardWindow('100%', '100%');
        this.context.setWindow(window);
        this.dashboardController = new DashboardController(this.context);
        return this.dashboardController.initialize();
      };

      MobileDashboard.prototype.minimizeDashlet = function() {
        return this.dashboardController.minimizeDashlet();
      };

      return MobileDashboard;

    })();
    root = typeof window !== "undefined" && window !== null ? window : exports;
    return root.MobileDashboard = MobileDashboard;
  });

}).call(this);

(function() {
  define('js.mobile.amber.ios.dashboard.client', ['require','js.mobile.ios.dashboard.callback','js.mobile.ios.logger','js.mobile.context','js.mobile.amber.dashboard'],function(require) {
    var Context, IosCallback, IosClient, IosLogger, MobileDashboard;
    IosCallback = require('js.mobile.ios.dashboard.callback');
    IosLogger = require('js.mobile.ios.logger');
    Context = require('js.mobile.context');
    MobileDashboard = require('js.mobile.amber.dashboard');
    return IosClient = (function() {
      function IosClient() {}

      IosClient.prototype.run = function() {
        var context;
        context = new Context({
          callback: new IosCallback(),
          logger: new IosLogger()
        });
        MobileDashboard.getInstance(context);
        return MobileDashboard.run();
      };

      return IosClient;

    })();
  });

}).call(this);

(function() {
  require(['js.mobile.amber.ios.dashboard.client'], function(IosClient) {
    return (function($) {
      return new IosClient().run();
    })(jQuery);
  });

}).call(this);

define("ios/amber/dashboard/main.js", function(){});

