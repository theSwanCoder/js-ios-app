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
          return this.queue.shift().call(this);
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
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define('js.mobile.amber.ios.dashboard.callback', ['require','js.mobile.callback_dispatcher'],function(require) {
    var CallbackDispatcher, IosCallback;
    CallbackDispatcher = require('js.mobile.callback_dispatcher');
    return IosCallback = (function(superClass) {
      extend(IosCallback, superClass);

      function IosCallback() {
        this.onWindowResizeEnd = bind(this.onWindowResizeEnd, this);
        return IosCallback.__super__.constructor.apply(this, arguments);
      }

      IosCallback.prototype.onMaximizeStart = function(title) {
        this._makeCallback("didStartMaximazeDashlet&title=" + title);
      };

      IosCallback.prototype.onMaximizeEnd = function(title) {};

      IosCallback.prototype.onMinimizeStart = function() {};

      IosCallback.prototype.onMinimizeEnd = function() {};

      IosCallback.prototype.onScriptLoaded = function() {
        this._makeCallback("scriptDidLoad");
      };

      IosCallback.prototype.onLoadStart = function() {};

      IosCallback.prototype.onLoadDone = function() {
        this._makeCallback("onLoadDone");
      };

      IosCallback.prototype.onLoadError = function(error) {};

      IosCallback.prototype.onWindowResizeStart = function() {
        this._makeCallback("windowDidStartResize");
      };

      IosCallback.prototype.onWindowResizeEnd = function() {
        this._makeCallback("windowDidEndResize");
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

      function DashboardController(args) {
        this._overrideDashletTouches = bind(this._overrideDashletTouches, this);
        this._configureDashboard = bind(this._configureDashboard, this);
        this.callback = args.callback, this.viewport = args.viewport, this.scaler = args.scaler;
      }

      DashboardController.prototype.initialize = function() {
        this._injectViewport();
        this.callback.onLoadStart();
        return jQuery(document).ready((function(_this) {
          return function() {
            js_mobile.log("document ready");
            _this._attachDashletLoadListeners();
            return _this._removeRedundantArtifacts();
          };
        })(this));
      };

      DashboardController.prototype.minimizeDashlet = function() {
        js_mobile.log("minimize dashlet");
        js_mobile.log("Remove original scale");
        this._removeOriginalScale();
        this._disableDashlets();
        this._hideDashletChartTypeSelector();
        this._showDashlets();
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
        js_mobile.log("remove artifacts");
        customStyle = ".header, .dashletToolbar { display: none !important; } .show_chartTypeSelector_wrapper { display: none; } .column.decorated { margin: 0 !important; border: none !important; } .dashboardViewer.dashboardContainer>.content>.body, .column.decorated>.content>.body, .column>.content>.body { top: 0 !important; } #mainNavigation{ display: none !important; } .customOverlay { position: absolute; width: 100%; height: 100%; z-index: 1000; } .dashboardCanvas .dashlet > .dashletContent > .content { -webkit-overflow-scrolling : auto !important; } .component_show { display: block; }";
        return jQuery('<style id="custom_mobile"></style>').text(customStyle).appendTo('head');
      };

      DashboardController.prototype._hideDashletChartTypeSelector = function() {
        js_mobile.log("hide dashlet chart type selector");
        return jQuery('.show_chartTypeSelector_wrapper').removeClass('component_show');
      };

      DashboardController.prototype._showDashletChartTypeSelector = function() {
        js_mobile.log("show dashlet chart type selector");
        return jQuery('.show_chartTypeSelector_wrapper').addClass('component_show');
      };

      DashboardController.prototype._injectViewport = function() {
        js_mobile.log("inject custom viewport");
        return this.viewport.configure();
      };

      DashboardController.prototype._attachDashletLoadListeners = function() {
        var dashboardElInterval;
        js_mobile.log("attaching dashlet listener");
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
        })(this), 50);
      };

      DashboardController.prototype._configureDashboard = function() {
        js_mobile.log("_configureDashboard");
        this._createCustomOverlays();
        this._overrideDashletTouches();
        this._disableDashlets();
        this._setupResizeListener();
        return this.callback.onLoadDone();
      };

      DashboardController.prototype._scaleDashboard = function() {
        this.scaler.applyScale();
        js_mobile.log("_scaleDashboard " + (jQuery('.dashboardCanvas').length));
        return jQuery('.dashboardCanvas').addClass('scaledCanvas');
      };

      DashboardController.prototype._createCustomOverlays = function() {
        var dashletElements;
        js_mobile.log("_createCustomOverlays");
        dashletElements = jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent());
        js_mobile.log("dashletElements " + dashletElements.length);
        return jQuery.each(dashletElements, function(key, value) {
          var dashlet, overlay;
          dashlet = jQuery(value);
          overlay = jQuery("<div></div>");
          overlay.addClass("customOverlay");
          return dashlet.prepend(overlay);
        });
      };

      DashboardController.prototype._setupResizeListener = function() {
        js_mobile.log("set resizer listener");
        return jQuery(window).resize((function(_this) {
          return function() {
            js_mobile.log("inside resize callback");
            _this.callback.onWindowResizeStart();
            return DOMTreeObserver.lastModify(_this.callback.onWindowResizeEnd).wait();
          };
        })(this));
      };

      DashboardController.prototype._disableDashlets = function() {
        js_mobile.log("disable dashlet touches");
        return jQuery('.customOverlay').css('display', 'block');
      };

      DashboardController.prototype._enableDashlets = function() {
        js_mobile.log("enable dashlet touches");
        return jQuery('.customOverlay').css('display', 'none');
      };

      DashboardController.prototype._overrideDashletTouches = function() {
        var dashlets, self;
        js_mobile.log("override dashlet touches");
        dashlets = jQuery('.customOverlay');
        dashlets.unbind();
        self = this;
        return dashlets.click(function() {
          var dashlet, innerLabel, overlay, title;
          overlay = jQuery(this);
          dashlet = overlay.parent();
          innerLabel = dashlet.find('.innerLabel > p');
          if ((innerLabel != null) && (innerLabel.text != null)) {
            title = innerLabel.text();
            if ((title != null) && title.length > 0) {
              self._maximizeDashlet(dashlet, title);
              return self._hideDashlets(overlay);
            }
          }
        });
      };

      DashboardController.prototype._maximizeDashlet = function(dashlet, title) {
        var button, endListener;
        js_mobile.log("maximizing dashlet");
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
        js_mobile.log("Add original scale");
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

      DashboardController.prototype._showDashlets = function() {
        return jQuery('.customOverlay').parent().css("opacity", 1);
      };

      DashboardController.prototype._hideDashlets = function(overlay) {
        return jQuery('.customOverlay').not(overlay).parent().css("opacity", 0);
      };

      return DashboardController;

    })(Module);
  });

}).call(this);

(function() {
  define('js.mobile.scale.calculator', [],function() {
    var ScaleCalculator;
    return ScaleCalculator = (function() {
      function ScaleCalculator(diagonal) {
        this.diagonal = diagonal;
        this.diagonal || (this.diagonal = 10.1);
      }

      ScaleCalculator.prototype.calculateFactor = function() {
        return this.diagonal / 10.1;
      };

      return ScaleCalculator;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.scale.style.report', [],function() {
    var ScaleStyleReport;
    return ScaleStyleReport = (function() {
      function ScaleStyleReport() {}

      ScaleStyleReport.prototype.applyFor = function(factor) {
        var scaledCanvasCss;
        jQuery("#scale_style").remove();
        scaledCanvasCss = "#container { transform-origin: 0 0 0; -ms-transform-origin: 0 0 0; -webkit-transform-origin: 0 0 0; transform: scale( " + factor + " ); -ms-transform: scale( " + factor + " ); -webkit-transform: scale( " + factor + " ); width: " + (100 / factor) + "% !important; height: " + (100 / factor) + "% !important; }";
        jQuery('<style id="scale_style"></style>').text(scaledCanvasCss).appendTo('head');
      };

      return ScaleStyleReport;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.scale.style.dashboard', [],function() {
    var ScaleStyleDashboard;
    return ScaleStyleDashboard = (function() {
      function ScaleStyleDashboard() {}

      ScaleStyleDashboard.prototype.applyFor = function(factor) {
        var originalDashletInScaledCanvasCss, scaledCanvasCss;
        jQuery("#scale_style").remove();
        scaledCanvasCss = ".scaledCanvas { transform-origin: 0 0 0; -ms-transform-origin: 0 0 0; -webkit-transform-origin: 0 0 0; transform: scale( " + factor + " ); -ms-transform: scale( " + factor + " ); -webkit-transform: scale( " + factor + " ); width: " + (100 / factor) + "% !important; height: " + (100 / factor) + "% !important; }";
        originalDashletInScaledCanvasCss = ".dashboardCanvas > .content > .body div.canvasOverlay.originalDashletInScaledCanvas { transform-origin: 0 0 0; -ms-transform-origin: 0 0 0; -webkit-transform-origin: 0 0 0; transform: scale( " + (1 / factor) + " ); -ms-transform: scale( " + (1 / factor) + " ); -webkit-transform: scale( " + (1 / factor) + " ); width: " + (100 * factor) + "% !important; height: " + (100 * factor) + "% !important; }";
        jQuery('<style id="scale_style"></style>').text(scaledCanvasCss + originalDashletInScaledCanvasCss).appendTo('head');
      };

      return ScaleStyleDashboard;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.scale.manager', ['require','js.mobile.scale.calculator','js.mobile.scale.style.report','js.mobile.scale.style.dashboard'],function(require) {
    var ScaleCalculator, ScaleManager, ScaleStyleDashboard, ScaleStyleReport;
    ScaleCalculator = require('js.mobile.scale.calculator');
    ScaleStyleReport = require('js.mobile.scale.style.report');
    ScaleStyleDashboard = require('js.mobile.scale.style.dashboard');
    return ScaleManager = (function() {
      ScaleManager.getReportManager = function(diagonal) {
        return new ScaleManager(diagonal, new ScaleStyleReport());
      };

      ScaleManager.getDashboardManager = function(diagonal) {
        return new ScaleManager(diagonal, new ScaleStyleDashboard());
      };

      function ScaleManager(diagonal, scaleStyle) {
        this.scaleStyle = scaleStyle;
        this.calculator = new ScaleCalculator(diagonal);
      }

      ScaleManager.prototype.applyScale = function() {
        var factor;
        factor = this.calculator.calculateFactor();
        return this.scaleStyle.applyFor(factor);
      };

      return ScaleManager;

    })();
  });

}).call(this);

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define('js.mobile.amber.dashboard', ['require','js.mobile.amber.dashboard.controller','js.mobile.scale.manager','js.mobile.lifecycle','js.mobile.module'],function(require) {
    var DashboardController, MobileDashboard, Module, ScaleManager, lifecycle;
    DashboardController = require('js.mobile.amber.dashboard.controller');
    ScaleManager = require('js.mobile.scale.manager');
    lifecycle = require('js.mobile.lifecycle');
    Module = require('js.mobile.module');
    MobileDashboard = (function(superClass) {
      extend(MobileDashboard, superClass);

      MobileDashboard.include(lifecycle.dashboard.instanceMethods);

      MobileDashboard.extend(lifecycle.dashboard.staticMethods);

      MobileDashboard._instance = null;

      MobileDashboard.newInstance = function(args) {
        return this._instance || (this._instance = new MobileDashboard(args));
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

      function MobileDashboard(args1) {
        this.args = args1;
        this.args.callback.onScriptLoaded();
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
        this.args.scaler = ScaleManager.getDashboardManager(this.options.diagonal);
        this._controller = new DashboardController(this.args);
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
        return viewPort.setAttribute('content', "initial-scale=1, width=device-width, minimum-scale=0.1, maximum-scale=3, user-scalable=yes");
      };

      return Viewport;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.amber.ios.dashboard.client', ['require','js.mobile.amber.ios.dashboard.callback','js.mobile.amber.dashboard','js.mobile.ios.viewport.dashboard.amber'],function(require) {
    var IosCallback, IosClient, MobileDashboard, Viewport;
    IosCallback = require('js.mobile.amber.ios.dashboard.callback');
    MobileDashboard = require('js.mobile.amber.dashboard');
    Viewport = require('js.mobile.ios.viewport.dashboard.amber');
    return IosClient = (function() {
      function IosClient() {}

      IosClient.prototype.run = function() {
        return MobileDashboard.newInstance({
          callback: new IosCallback(),
          viewport: new Viewport()
        });
      };

      return IosClient;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.debug_log', [],function() {
    var Log;
    return Log = (function() {
      function Log() {}

      Log.configure = function() {
        window.js_mobile = {};
        return window.js_mobile.log = console.log.bind(console);
      };

      return Log;

    })();
  });

}).call(this);

(function() {
  require(['js.mobile.amber.ios.dashboard.client', 'js.mobile.debug_log'], function(IosClient, Log) {
    return (function($) {
      Log.configure();
      return new IosClient().run();
    })(jQuery);
  });

}).call(this);

define("ios/dashboard/amber/debug_main.js", function(){});

