(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define('js.mobile.callback_dispatcher', [],function() {
    var CallbackDispatcher;
    return CallbackDispatcher = (function() {
      function CallbackDispatcher() {
        this._processQueue = bind(this._processQueue, this);
        this.queue = [];
        this.paused = false;
      }

      CallbackDispatcher.prototype.dispatch = function(task) {
        if (!this.paused) {
          this.queue.push(task);
          return this._processEventLoop();
        } else {
          return this.queue.push(task);
        }
      };

      CallbackDispatcher.prototype.firePendingTasks = function() {
        var results;
        if (!this.paused) {
          results = [];
          while (this.queue.length > 0) {
            results.push(this.queue.pop().call(this));
          }
          return results;
        }
      };

      CallbackDispatcher.prototype.pause = function() {
        return this.paused = true;
      };

      CallbackDispatcher.prototype.resume = function() {
        return this.paused = false;
      };

      CallbackDispatcher.prototype._processEventLoop = function() {
        if (this.dispatchTimeInterval == null) {
          return this._createInterval(this._processQueue);
        }
      };

      CallbackDispatcher.prototype._processQueue = function() {
        if (this.queue.length === 0) {
          return this._removeInterval();
        } else {
          return this.queue.pop().call(this);
        }
      };

      CallbackDispatcher.prototype._createInterval = function(eventLoop) {
        return this.dispatchTimeInterval = window.setInterval(eventLoop, 200);
      };

      CallbackDispatcher.prototype._removeInterval = function() {
        window.clearInterval(this.dispatchTimeInterval);
        return this.dispatchTimeInterval = null;
      };

      return CallbackDispatcher;

    })();
  });

}).call(this);

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define('js.mobile.ios.callbacks.IosCallback', ['require','js.mobile.callback_dispatcher'],function(require) {
    var CallbackDispatcher, IosCallback;
    CallbackDispatcher = require('js.mobile.callback_dispatcher');
    return IosCallback = (function(superClass) {
      extend(IosCallback, superClass);

      function IosCallback() {
        return IosCallback.__super__.constructor.apply(this, arguments);
      }

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
        return this.dispatch(function() {
          return window.location.href = "http://jaspermobile.callback/" + command;
        });
      };

      return IosCallback;

    })(CallbackDispatcher);
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
  define('js.mobile.lifecycle', [],function() {
    var lifecycle;
    lifecycle = {
      dashboardController: {
        instanceMethods: {
          pause: function() {
            return this.callback.pause();
          },
          resume: function() {
            this.callback.resume();
            return this.callback.firePendingTasks();
          }
        }
      },
      dashboard: {
        staticMethods: {
          pause: function() {
            return this._instance._pause();
          },
          resume: function() {
            return this._instance._resume();
          }
        },
        instanceMethods: {
          _pause: function() {
            return this._controller.pause();
          },
          _resume: function() {
            return this._controller.resume();
          }
        }
      }
    };
    lifecycle['report'] = lifecycle['dashboard'];
    lifecycle['reportController'] = lifecycle['dashboardController'];
    return lifecycle;
  });

}).call(this);

(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define('js.mobile.module', [],function() {
    var Module, moduleKeywords;
    moduleKeywords = ['extended', 'included'];
    return Module = (function() {
      function Module() {}

      Module.extend = function(obj) {
        var key, ref, value;
        for (key in obj) {
          value = obj[key];
          if (indexOf.call(moduleKeywords, key) < 0) {
            this[key] = value;
          }
        }
        if ((ref = obj.extended) != null) {
          ref.apply(this);
        }
        return this;
      };

      Module.include = function(obj) {
        var key, ref, value;
        for (key in obj) {
          value = obj[key];
          if (indexOf.call(moduleKeywords, key) < 0) {
            this.prototype[key] = value;
          }
        }
        if ((ref = obj.included) != null) {
          ref.apply(this);
        }
        return this;
      };

      return Module;

    })();
  });

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define('js.mobile.amber.dashboard.controller', ['require','js.mobile.dom_tree_observer','js.mobile.lifecycle','js.mobile.module'],function(require) {
    var DOMTreeObserver, DashboardController, Module, lifecycle;
    DOMTreeObserver = require('js.mobile.dom_tree_observer');
    lifecycle = require('js.mobile.lifecycle');
    Module = require('js.mobile.module');
    return DashboardController = (function(superClass) {
      extend(DashboardController, superClass);

      DashboardController.include(lifecycle.dashboardController.instanceMethods);

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
            return _this._attachDashletLoadListeners();
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
        var dashboardElInterval;
        this.logger.log("attaching dashlet listener");
        return dashboardElInterval = window.setInterval((function(_this) {
          return function() {
            var dashboardContainer;
            dashboardContainer = jQuery('.dashboardCanvas');
            if (dashboardContainer.length > 0) {
              window.clearInterval(dashboardElInterval);
              DOMTreeObserver.lastModify(_this._configureDashboard).wait();
              return _this._scaleDashboard();
            }
          };
        })(this), 500);
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
        this.logger.log("_scaleDashboard " + (jQuery('.dashboardCanvas').length));
        return jQuery('.dashboardCanvas').addClass('scaledCanvas');
      };

      DashboardController.prototype._createCustomOverlays = function() {
        var dashletElements;
        this.logger.log("_createCustomOverlays");
        dashletElements = jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent());
        this.logger.log("dashletElements " + dashletElements.length);
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

    })(Module);
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
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define('js.mobile.amber.dashboard', ['require','js.mobile.amber.dashboard.controller','js.mobile.scaler','js.mobile.lifecycle','js.mobile.module'],function(require) {
    var DashboardController, MobileDashboard, Module, Scaler, lifecycle;
    DashboardController = require('js.mobile.amber.dashboard.controller');
    Scaler = require('js.mobile.scaler');
    lifecycle = require('js.mobile.lifecycle');
    Module = require('js.mobile.module');
    MobileDashboard = (function(superClass) {
      extend(MobileDashboard, superClass);

      MobileDashboard.include(lifecycle.dashboard.instanceMethods);

      MobileDashboard.extend(lifecycle.dashboard.staticMethods);

      MobileDashboard._instance = null;

      MobileDashboard.newInstance = function(context, viewport) {
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
        return this._instance._minimizeDashlet();
      };

      function MobileDashboard(context1, viewport1) {
        this.context = context1;
        this.viewport = viewport1;
        this.context.callback.onScriptLoaded();
      }

      MobileDashboard.prototype.run = function() {
        if (this.options == null) {
          return alert("Run was called without options");
        } else {
          return this._initController();
        }
      };

      MobileDashboard.prototype._minimizeDashlet = function() {
        if (this._controller == null) {
          return alert("MobileDashboard not initialized");
        } else {
          return this._controller.minimizeDashlet();
        }
      };

      MobileDashboard.prototype._initController = function() {
        var scaler;
        scaler = new Scaler(this.options);
        this._controller = new DashboardController({
          context: this.context,
          viewport: this.viewport,
          scaler: scaler
        });
        return this._controller.initialize();
      };

      return MobileDashboard;

    })(Module);
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

