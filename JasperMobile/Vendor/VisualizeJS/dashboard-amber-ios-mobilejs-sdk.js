(function() {
  define('js.mobile.ios.callbacks.IosCallback', ['require'],function(require) {
    var IosCallback;
    return IosCallback = (function() {
      function IosCallback() {}

      IosCallback.prototype.onMaximizeStart = function(title) {
        this._makeCallback("command:maximize&title:" + title);
      };

      IosCallback.prototype.onMaximizeEnd = function(title) {};

      IosCallback.prototype.onMinimizeStart = function() {};

      IosCallback.prototype.onMinimizeEnd = function() {};

      IosCallback.prototype.onScriptLoaded = function() {
        this._makeCallback("command:didScriptLoad");
      };

      IosCallback.prototype.onLoadStart = function() {};

      IosCallback.prototype.onLoadDone = function() {
        this._makeCallback("command:didEndLoading");
      };

      IosCallback.prototype.onLoadError = function(error) {};

      IosCallback.prototype.onWindowResizeStart = function() {
        this._makeCallback("command:didWindowResizeStart");
      };

      IosCallback.prototype.onWindowResizeEnd = function() {
        this._makeCallback("command:didWindowResizeEnd");
      };

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

      IosLogger.prototype.log = function(message) {
        return console.log(message);
      };

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
  define('js.mobile.dom_tree_observer', [],function() {
    var DOMTreeObserver;
    return DOMTreeObserver = (function() {
      function DOMTreeObserver() {}

      DOMTreeObserver._instance = null;

      DOMTreeObserver.lastModify = function(callback) {
        this._instance = new DOMTreeObserver;
        this._instance.callback = callback;
        return this._instance;
      };

      DOMTreeObserver.prototype.wait = function() {
        var timeout;
        timeout = null;
        jQuery("body").unbind();
        return jQuery("body").bind("DOMSubtreeModified", (function(_this) {
          return function() {
            if (timeout != null) {
              window.clearInterval(timeout);
            }
            return timeout = window.setTimeout(function() {
              window.clearInterval(timeout);
              jQuery("body").unbind();
              return _this.callback.call(_this);
            }, 2000);
          };
        })(this));
      };

      return DOMTreeObserver;

    })();
  });

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define('js.mobile.amber.dashboard.controller', ['require','js.mobile.amber.dashboard.view','js.mobile.dom_tree_observer'],function(require) {
    var DOMTreeObserver, DashboardController, View;
    View = require('js.mobile.amber.dashboard.view');
    DOMTreeObserver = require('js.mobile.dom_tree_observer');
    return DashboardController = (function() {
      function DashboardController(options) {
        this._overrideDashletTouches = bind(this._overrideDashletTouches, this);
        this._configureDashboard = bind(this._configureDashboard, this);
        this.context = options.context, this.viewport = options.viewport, this.scaler = options.scaler;
        this.logger = this.context.logger;
        this.callback = this.context.callback;
      }

      DashboardController.prototype.initialize = function() {
        this.callback.onLoadStart();
        return jQuery(document).ready((function(_this) {
          return function() {
            _this.logger.log("document ready");
            _this.scaler.initialize();
            _this._removeRedundantArtifacts();
            _this._injectViewport();
            _this._attachDashletLoadListeners();
            return _this._scaleDashboard();
          };
        })(this));
      };

      DashboardController.prototype.minimizeDashlet = function() {
        this.logger.log("minimize dashlet");
        this.logger.log("Remove original scale");
        this._removeOriginalScale();
        this._disableDashlets();
        this._hideDashletChartTypeSelector();
        this.callback.onMinimizeStart();
        DOMTreeObserver.lastModify((function(_this) {
          return function() {
            _this._hideDashletChartTypeSelector();
            return _this.callback.onMinimizeEnd();
          };
        })(this)).wait();
        return jQuery("div.dashboardCanvas > div.content > div.body > div").find(".minimizeDashlet")[0].click();
      };

      DashboardController.prototype._removeRedundantArtifacts = function() {
        var customStyle;
        this.logger.log("remove artifacts");
        customStyle = ".header, .dashletToolbar { display: none !important; } .show_chartTypeSelector_wrapper { display: none; } .column.decorated { margin: 0 !important; border: none !important; } .dashboardViewer.dashboardContainer>.content>.body, .column.decorated>.content>.body, .column>.content>.body { top: 0 !important; } #mainNavigation{ display: none !important; } .customOverlay { position: absolute; width: 100%; height: 100%; z-index: 1000; } .dashboardCanvas .dashlet > .dashletContent > .content { -webkit-overflow-scrolling : auto !important; } .component_show { display: block; }";
        return jQuery('<style id="custom_mobile"></style>').text(customStyle).appendTo('head');
      };

      DashboardController.prototype._hideDashletChartTypeSelector = function() {
        this.logger.log("hide dashlet chart type selector");
        return jQuery('.show_chartTypeSelector_wrapper').removeClass('component_show');
      };

      DashboardController.prototype._showDashletChartTypeSelector = function() {
        this.logger.log("show dashlet chart type selector");
        return jQuery('.show_chartTypeSelector_wrapper').addClass('component_show');
      };

      DashboardController.prototype._injectViewport = function() {
        this.logger.log("inject custom viewport");
        return this.viewport.configure();
      };

      DashboardController.prototype._attachDashletLoadListeners = function() {
        this.logger.log("attaching dashlet listener");
        return DOMTreeObserver.lastModify(this._configureDashboard).wait();
      };

      DashboardController.prototype._configureDashboard = function() {
        this.logger.log("_configureDashboard");
        this._createCustomOverlays();
        this._overrideDashletTouches();
        this._disableDashlets();
        this._setupResizeListener();
        return this.callback.onLoadDone();
      };

      DashboardController.prototype._scaleDashboard = function() {
        this.logger.log("_scaleDashboard");
        return jQuery('.dashboardCanvas').addClass('scaledCanvas');
      };

      DashboardController.prototype._createCustomOverlays = function() {
        var dashletElements;
        this.logger.log("_createCustomOverlays");
        dashletElements = jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent());
        return jQuery.each(dashletElements, function(key, value) {
          var dashlet, overlay;
          dashlet = jQuery(value);
          overlay = jQuery("<div></div>");
          overlay.addClass("customOverlay");
          return dashlet.prepend(overlay);
        });
      };

      DashboardController.prototype._setupResizeListener = function() {
        this.logger.log("set resizer listener");
        return jQuery(window).resize((function(_this) {
          return function() {
            _this.logger.log("inside resize callback");
            _this.callback.onWindowResizeStart();
            return DOMTreeObserver.lastModify(_this.callback.onWindowResizeEnd).wait();
          };
        })(this));
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
        var button, endListener;
        this.logger.log("maximizing dashlet");
        this._enableDashlets();
        this.callback.onMaximizeStart(title);
        endListener = (function(_this) {
          return function() {
            _this._showDashletChartTypeSelector();
            return _this.callback.onMaximizeEnd(title);
          };
        })(this);
        DOMTreeObserver.lastModify(endListener).wait();
        button = jQuery(jQuery(dashlet).find('div.dashletToolbar > div.content div.buttons > .maximizeDashletButton')[0]);
        button.click();
        this.logger.log("Add original scale");
        return this._addOriginalScale();
      };

      DashboardController.prototype._addOriginalScale = function() {
        return this._getOverlay().addClass("originalDashletInScaledCanvas");
      };

      DashboardController.prototype._removeOriginalScale = function() {
        return this._getOverlay().removeClass("originalDashletInScaledCanvas");
      };

      DashboardController.prototype._getOverlay = function() {
        return jQuery(".dashboardCanvas > .content > .body div.canvasOverlay");
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
        return this._generateStyles(factor);
      };

      Scaler.prototype._calculateFactor = function() {
        return this.diagonal / 10.1;
      };

      Scaler.prototype._generateStyles = function(factor) {
        var originalDashletInScaledCanvasCss, scaledCanvasCss;
        jQuery("#scale_style").remove();
        scaledCanvasCss = ".scaledCanvas { transform-origin: 0 0 0; -ms-transform-origin: 0 0 0; -webkit-transform-origin: 0 0 0; transform: scale( " + factor + " ); -ms-transform: scale( " + factor + " ); -webkit-transform: scale( " + factor + " ); width: " + (100 / factor) + "% !important; height: " + (100 / factor) + "% !important; }";
        originalDashletInScaledCanvasCss = ".dashboardCanvas > .content > .body div.canvasOverlay.originalDashletInScaledCanvas { transform-origin: 0 0 0; -ms-transform-origin: 0 0 0; -webkit-transform-origin: 0 0 0; transform: scale( " + (1 / factor) + " ); -ms-transform: scale( " + (1 / factor) + " ); -webkit-transform: scale( " + (1 / factor) + " ); width: " + (100 * factor) + "% !important; height: " + (100 * factor) + "% !important; }";
        jQuery('<style id="scale_style"></style>').text(scaledCanvasCss + originalDashletInScaledCanvasCss).appendTo('head');
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

      MobileDashboard.newInstance = function(context, viewport) {
        return this._instance || (this._instance = new MobileDashboard(context, viewport));
      };

      function MobileDashboard(context1, viewport1) {
        this.context = context1;
        this.viewport = viewport1;
        this.context.callback.onScriptLoaded();
      }

      MobileDashboard.configure = function(options) {
        this._instance.options = options;
        return this._instance;
      };

      MobileDashboard.run = function() {
        return this._instance.run();
      };

      MobileDashboard.prototype.run = function() {
        if (this.options == null) {
          return alert("Run was called without options");
        } else {
          return this._initController();
        }
      };

      MobileDashboard.minimizeDashlet = function() {
        return this._instance.minimizeDashlet();
      };

      MobileDashboard.prototype.minimizeDashlet = function() {
        if (this.dashboardController == null) {
          return alert("MobileDashboard not initialized");
        } else {
          return this.dashboardController.minimizeDashlet();
        }
      };

      MobileDashboard.prototype._initController = function() {
        var scaler;
        scaler = new Scaler(this.options);
        this.dashboardController = new DashboardController({
          context: this.context,
          viewport: this.viewport,
          scaler: scaler
        });
        return this.dashboardController.initialize();
      };

      return MobileDashboard;

    })();
    root = typeof window !== "undefined" && window !== null ? window : exports;
    return window.MobileDashboard = MobileDashboard;
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
        return viewPort.setAttribute('content', "width=device-width, minimum-scale=0.1, maximum-scale=3, user-scalable=yes");
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
        return MobileDashboard.newInstance(context, viewport);
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

