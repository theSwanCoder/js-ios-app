(function() {
  define('js.mobile.ios.callbacks.IosCallback', ['require'],function(require) {
    var IosCallback;
    return IosCallback = (function() {
      function IosCallback() {}

      IosCallback.prototype.onMaximizeStart = function(title) {
        this._makeCallback("command:maximize&title:" + title);
      };

      IosCallback.prototype.onMinimizeStart = function() {};

      IosCallback.prototype.onScriptLoaded = function() {
        this._makeCallback("command:didScriptLoad");
      };

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
  define('js.mobile.ios.loggers.logger', [],function() {
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
  define('js.mobile.amber.dashboard.controller', ['require','js.mobile.amber.dashboard.view'],function(require) {
    var DashboardController, View;
    View = require('js.mobile.amber.dashboard.view');
    return DashboardController = (function() {
      function DashboardController(options) {
        this.context = options.context, this.viewport = options.viewport, this.scaler = options.scaler;
        this.logger = this.context.logger;
        this.callback = this.context.callback;
      }

      DashboardController.prototype.initialize = function() {
        this.callback.onLoadStart();
        this.scaler.initialize();
        this._removeRedundantArtifacts();
        this._injectViewport();
        return this._attachDashletLoadListeners();
      };

      DashboardController.prototype.minimizeDashlet = function() {
        this.logger.log("minimize dashlet");
        this.logger.log("Remove original scale");
        this.scaler.removeOriginalScale();
        jQuery("div.dashboardCanvas > div.content > div.body > div").find(".minimizeDashlet")[0].click();
        this._disableDashlets();
        return this.callback.onMinimizeStart();
      };

      DashboardController.prototype._injectViewport = function() {
        return this.viewport.configure();
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
        this._createCustomOverlays();
        this._scaleDashboard();
        this._overrideDashletTouches();
        this._disableDashlets();
        return this.callback.onLoadDone();
      };

      DashboardController.prototype._removeRedundantArtifacts = function() {
        var customStyle;
        this.logger.log("remove artifacts");
        customStyle = ".header, .dashletToolbar, .show_chartTypeSelector_wrapper { display: none !important; } .column.decorated { margin: 0 !important; border: none !important; } .dashboardViewer.dashboardContainer>.content>.body, .column.decorated>.content>.body, .column>.content>.body { top: 0 !important; } #mainNavigation{ display: none !important; } .customOverlay { position: absolute; width: 100%; height: 100%; z-index: 1000; }";
        return jQuery('<style id="custom_mobile"></style').text(customStyle).appendTo('head');
      };

      DashboardController.prototype._createCustomOverlays = function() {
        var dashletElements;
        dashletElements = jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent());
        return jQuery.each(dashletElements, function(key, value) {
          var dashlet, overlay;
          dashlet = jQuery(value);
          overlay = jQuery("<div></div>");
          overlay.addClass("customOverlay");
          return dashlet.prepend(overlay);
        });
      };

      DashboardController.prototype._disableDashlets = function() {
        this.logger.log("disable dashlet touches");
        return jQuery('.customOverlay').css('display', 'block');
      };

      DashboardController.prototype._enableDashlets = function() {
        this.logger.log("enable dashlet touches");
        return jQuery('.customOverlay').css('display', 'none');
      };

      DashboardController.prototype._overrideDashletTouches = function() {
        var dashlets, self;
        this.logger.log("override dashlet touches");
        dashlets = jQuery('.customOverlay');
        dashlets.unbind();
        self = this;
        return dashlets.click(function() {
          var dashlet, innerLabel, title;
          dashlet = jQuery(this).parent();
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
        var button;
        this.logger.log("maximizing dashlet");
        this._enableDashlets();
        this.callback.onMaximizeStart(title);
        button = jQuery(jQuery(dashlet).find('div.dashletToolbar > div.content div.buttons > .maximizeDashletButton')[0]);
        button.click();
        this.logger.log("Add original scale");
        return this.scaler.addOriginalScale();
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
  define('js.mobile.scaler', [],function() {
    var Scaler;
    return Scaler = (function() {
      function Scaler(options) {
        this.diagonal = options.diagonal;
      }

      Scaler.prototype.initialize = function() {
        var factor;
        factor = this._calculateFactor();
        this._generateStyles(factor);
        return this._applyScaleToDOM();
      };

      Scaler.prototype.addOriginalScale = function() {
        return this._getOverlay().addClass("originalDashletInScaledCanvas");
      };

      Scaler.prototype.removeOriginalScale = function() {
        return this._getOverlay().removeClass("originalDashletInScaledCanvas");
      };

      Scaler.prototype._getOverlay = function() {
        return jQuery(".dashboardCanvas > .content > .body div.canvasOverlay");
      };

      Scaler.prototype._calculateFactor = function() {
        var factor;
        factor = this.diagonal / 10.1;
        console.log(factor);
        return factor;
      };

      Scaler.prototype._generateStyles = function(factor) {
        var originalDashletInScaledCanvasCss, scaledCanvasCss;
        jQuery("#scale_style").remove();
        scaledCanvasCss = ".scaledCanvas { transform-origin: 0 0 0; -ms-transform-origin: 0 0 0; -webkit-transform-origin: 0 0 0; transform: scale( " + factor + " ); -ms-transform: scale( " + factor + " ); -webkit-transform: scale( " + factor + " ); width: " + (100 / factor) + "% !important; height: " + (100 / factor) + "% !important; }";
        originalDashletInScaledCanvasCss = ".dashboardCanvas > .content > .body div.canvasOverlay.originalDashletInScaledCanvas { transform-origin: 0 0 0; -ms-transform-origin: 0 0 0; -webkit-transform-origin: 0 0 0; transform: scale( " + (1 / factor) + " ); -ms-transform: scale( " + (1 / factor) + " ); -webkit-transform: scale( " + (1 / factor) + " ); width: " + (100 * factor) + "% !important; height: " + (100 * factor) + "% !important; }";
        jQuery('<style id="scale_style"></style').text(scaledCanvasCss + originalDashletInScaledCanvasCss).appendTo('head');
      };

      Scaler.prototype._applyScaleToDOM = function() {
        return jQuery('.dashboardCanvas').addClass('scaledCanvas');
      };

      return Scaler;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.amber.dashboard', ['require','js.mobile.amber.dashboard.controller','js.mobile.amber.dashboard.window','js.mobile.scaler'],function(require) {
    var DashboardController, DashboardWindow, MobileDashboard, Scaler, root;
    DashboardController = require('js.mobile.amber.dashboard.controller');
    DashboardWindow = require('js.mobile.amber.dashboard.window');
    Scaler = require('js.mobile.scaler');
    MobileDashboard = (function() {
      MobileDashboard._instance = null;

      MobileDashboard.getInstance = function(context, viewport) {
        return this._instance || (this._instance = new MobileDashboard(context, viewport));
      };

      MobileDashboard.configure = function(options) {
        this._instance.options = options;
        return this._instance;
      };

      MobileDashboard.run = function() {
        return this._instance.run();
      };

      MobileDashboard.minimizeDashlet = function() {
        return this._instance.minimizeDashlet();
      };

      function MobileDashboard(context1, viewport1) {
        this.context = context1;
        this.viewport = viewport1;
        this.context.callback.onScriptLoaded();
      }

      MobileDashboard.prototype.run = function() {
        var scaler;
        scaler = new Scaler(this.options);
        this.dashboardController = new DashboardController({
          context: this.context,
          viewport: this.viewport,
          scaler: scaler
        });
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
  define('js.mobile.ios.viewport.dashboard.amber', [],function() {
    var Viewport;
    return Viewport = (function() {
      function Viewport() {}

      Viewport.prototype.configure = function() {
        var viewPort;
        viewPort = document.querySelector('meta[name=viewport]');
        return viewPort.setAttribute('content', "width=device-width, minimum-scale=0.1, maximum-scale=1, user-scalable=yes");
      };

      return Viewport;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.amber.ios.dashboard.client', ['require','js.mobile.ios.callbacks.IosCallback','js.mobile.ios.loggers.logger','js.mobile.context','js.mobile.amber.dashboard','js.mobile.ios.viewport.dashboard.amber'],function(require) {
    var Context, IosCallback, IosClient, IosLogger, MobileDashboard, Viewport;
    IosCallback = require('js.mobile.ios.callbacks.IosCallback');
    IosLogger = require('js.mobile.ios.loggers.logger');
    Context = require('js.mobile.context');
    MobileDashboard = require('js.mobile.amber.dashboard');
    Viewport = require('js.mobile.ios.viewport.dashboard.amber');
    return IosClient = (function() {
      function IosClient() {}

      IosClient.prototype.run = function() {
        var context, viewport;
        context = new Context({
          callback: new IosCallback(),
          logger: new IosLogger()
        });
        viewport = new Viewport();
        return MobileDashboard.getInstance(context, viewport);
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

