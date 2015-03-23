(function() {
  define('js.mobile.ios.report.callback', ['require'],function(require) {
    var ReportCallback;
    return ReportCallback = (function() {
      function ReportCallback() {}

      ReportCallback.prototype.onScriptLoaded = function() {
        this._makeCallback("DOMContentLoaded");
      };

      ReportCallback.prototype.onLoadStart = function() {
        console.log("onLoadStart");
      };

      ReportCallback.prototype.onLoadDone = function(parameters) {
        this._makeCallback("reportDidEndRenderSuccessful");
      };

      ReportCallback.prototype.onLoadError = function(error) {
        this._makeCallback("reportDidEndRenderFailured&error=" + error);
      };

      ReportCallback.prototype.onTotalPagesLoaded = function(pages) {
        this._makeCallback("changeTotalPages&totalPage=" + pages);
      };

      ReportCallback.prototype.onPageChange = function(page) {
        console.log("onPageChange");
      };

      ReportCallback.prototype.onReferenceClick = function(location) {
        console.log("onReferenceClick");
      };

      ReportCallback.prototype.onReportExecutionClick = function(reportUri, params) {
        this._makeCallback("runReport&params=" + params);
      };

      ReportCallback.prototype._makeCallback = function(command) {
        return window.location.href = "http://jaspermobile.callback/" + command;
      };

      return ReportCallback;

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
  define('js.mobile.session', [],function() {
    var Session;
    return Session = (function() {
      function Session(options) {
        this.username = options.username, this.password = options.password, this.organization = options.organization;
      }

      Session.prototype.authOptions = function() {
        return {
          auth: {
            name: this.username,
            password: this.password,
            organization: this.organization
          }
        };
      };

      return Session;

    })();
  });

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define('js.mobile.report.controller', [],function() {
    var ReportController;
    return ReportController = (function() {
      function ReportController(options) {
        this._notifyPageChange = bind(this._notifyPageChange, this);
        this._openRemoteLink = bind(this._openRemoteLink, this);
        this._navigateToPage = bind(this._navigateToPage, this);
        this._navigateToAnchor = bind(this._navigateToAnchor, this);
        this._startReportExecution = bind(this._startReportExecution, this);
        this._processLinkClicks = bind(this._processLinkClicks, this);
        this._processErrors = bind(this._processErrors, this);
        this._processSuccess = bind(this._processSuccess, this);
        this._processChangeTotalPages = bind(this._processChangeTotalPages, this);
        this._executeReport = bind(this._executeReport, this);
        this.context = options.context, this.session = options.session, this.uri = options.uri, this.params = options.params;
        this.callback = this.context.callback;
        this.logger = this.context.logger;
        this.logger.log(this.uri);
        this.params || (this.params = {});
        this.totalPages = 0;
      }

      ReportController.prototype.selectPage = function(page) {
        if (this.loader != null) {
          return this.loader.pages(page).run().done(this._processSuccess).fail(this._processErrors);
        }
      };

      ReportController.prototype.runReport = function() {
        this.callback.onLoadStart();
        return visualize(this.session.authOptions(), this._executeReport);
      };

      ReportController.prototype.destroyReport = function() {
        return this.loader.destroy();
      };

      ReportController.prototype._executeReport = function(visualize) {
        return this.loader = visualize.report({
          resource: this.uri,
          params: this.params,
          container: "#container",
          scale: "width",
          linkOptions: {
            events: {
              click: this._processLinkClicks
            }
          },
          error: this._processErrors,
          events: {
            changeTotalPages: this._processChangeTotalPages
          },
          success: this._processSuccess
        });
      };

      ReportController.prototype._processChangeTotalPages = function(totalPages) {
        this.totalPages = totalPages;
        return this.callback.onTotalPagesLoaded(this.totalPages);
      };

      ReportController.prototype._processSuccess = function(parameters) {
        return this.callback.onLoadDone(parameters);
      };

      ReportController.prototype._processErrors = function(error) {
        this.logger.log(error);
        return this.callback.onLoadError(error);
      };

      ReportController.prototype._processLinkClicks = function(event, link) {
        var type;
        type = link.type;
        switch (type) {
          case "ReportExecution":
            return this._startReportExecution(link);
          case "LocalAnchor":
            return this._navigateToAnchor(link);
          case "LocalPage":
            return this._navigateToPage(link);
          case "Reference":
            return this._openRemoteLink(link);
        }
      };

      ReportController.prototype._startReportExecution = function(link) {
        var params, paramsAsString, reportUri;
        params = link.parameters;
        reportUri = params._report;
        paramsAsString = JSON.stringify(params, null, 2);
        return this.callback.onReportExecutionClick(reportUri, paramsAsString);
      };

      ReportController.prototype._navigateToAnchor = function(link) {
        return window.location.hash = link.href;
      };

      ReportController.prototype._navigateToPage = function(link) {
        var href, matches, numberPattern, pageNumber;
        href = link.href;
        numberPattern = /\d+/g;
        matches = href.match(numberPattern);
        if (matches != null) {
          pageNumber = matches.join("");
          return this._loadPage(pageNumber);
        }
      };

      ReportController.prototype._openRemoteLink = function(link) {
        var href;
        href = link.href;
        return this.callback.onReferenceClick(href);
      };

      ReportController.prototype._loadPage = function(page) {
        return this.loader.pages(page).run().fail(this._processErrors).done(this._notifyPageChange);
      };

      ReportController.prototype._notifyPageChange = function() {
        return this.callback.onPageChange(this.loader.pages());
      };

      return ReportController;

    })();
  });

}).call(this);

(function() {
  define('js.mobile.report', ['require','js.mobile.session','js.mobile.report.controller'],function(require) {
    var MobileReport, ReportController, Session, root;
    Session = require('js.mobile.session');
    ReportController = require('js.mobile.report.controller');
    MobileReport = (function() {
      MobileReport._instance = null;

      MobileReport.getInstance = function(context) {
        return this._instance || (this._instance = new MobileReport(context));
      };

      MobileReport.setCredentials = function(options) {
        return this._instance.setCredentials(options);
      };

      MobileReport.destroy = function() {
        return this._instance.destroyReport();
      };

      MobileReport.run = function(options) {
        return this._instance.run(options);
      };

      MobileReport.selectPage = function(page) {
        return this._instance.selectPage(page);
      };

      function MobileReport(context1) {
        this.context = context1;
        this.context.callback.onScriptLoaded();
      }

      MobileReport.prototype.setCredentials = function(options) {
        return this.session = new Session(options);
      };

      MobileReport.prototype.selectPage = function(page) {
        if (this.reportController) {
          return this.reportController.selectPage(page);
        }
      };

      MobileReport.prototype.run = function(options) {
        options.session = this.session;
        options.context = this.context;
        this.reportController = new ReportController(options);
        return this.reportController.runReport();
      };

      MobileReport.prototype.destroyReport = function() {
        return this.reportController.destroyReport();
      };

      return MobileReport;

    })();
    root = typeof window !== "undefined" && window !== null ? window : exports;
    return root.MobileReport = MobileReport;
  });

}).call(this);

(function() {
  define('js.mobile.ios.report.client', ['require','js.mobile.ios.report.callback','js.mobile.ios.logger','js.mobile.context','js.mobile.report'],function(require) {
    var AndroidLogger, Context, MobileReport, ReportCallback, ReportClient;
    ReportCallback = require('js.mobile.ios.report.callback');
    AndroidLogger = require('js.mobile.ios.logger');
    Context = require('js.mobile.context');
    MobileReport = require('js.mobile.report');
    return ReportClient = (function() {
      function ReportClient() {}

      ReportClient.prototype.run = function() {
        var callbackImplementor, context, logger;
        callbackImplementor = new ReportCallback();
        logger = new AndroidLogger();
        context = new Context({
          callback: callbackImplementor,
          logger: logger
        });
        MobileReport.getInstance(context);
        return callbackImplementor.onScriptLoaded();
      };

      return ReportClient;

    })();
  });

}).call(this);

(function() {
  require(['js.mobile.ios.report.client'], function(ReportClient) {
    return new ReportClient().run();
  });

}).call(this);

define("ios/report/main.js", function(){});

