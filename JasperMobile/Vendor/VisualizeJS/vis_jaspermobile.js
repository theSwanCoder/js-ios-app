var JasperMobile = {
    Report : {},
    Dashboard : {},
    Callback: {
        Queue : {
            queue : [],
            dispatchTimeInterval : null,
            startExecute : function() {
                if (!this.dispatchTimeInterval) {
                    this.dispatchTimeInterval = window.setInterval(JasperMobile.Callback.Queue.execute, 200);
                }
            },
            execute: function() {
                if(JasperMobile.Callback.Queue.queue.length > 0) {
                    var callback = JasperMobile.Callback.Queue.queue.shift();
                    callback();
                } else {
                    window.clearInterval(JasperMobile.Callback.Queue.dispatchTimeInterval);
                    JasperMobile.Callback.Queue.dispatchTimeInterval = null;
                }
            },
            add : function(callback) {
                this.queue.push(callback);
                this.startExecute();
            }
        },
        createCallback: function(params) {
            var callback = "http://jaspermobile.callback/json&" + JSON.stringify(params);
            this.Queue.add(function() {
                window.location.href = callback;
            })
        },
        onScriptLoaded : function() {
            this.createCallback(
                {
                    "command" : "DOMContentLoaded",
                    "parameters" : {}
                }
            );
        },
        log : function(message) {
            this.createCallback(
                {
                    "command" : "logging",
                    "parameters" : {
                        "message" : message
                    }
                }
            );
        }
    },
    Helper : {
        collectReportParams: function (link) {
            var isValueNotArray, key, params;
            params = {};
            for (key in link.parameters) {
                if (key !== '_report') {
                    isValueNotArray = Object.prototype.toString.call(link.parameters[key]) !== '[object Array]';
                    params[key] = isValueNotArray ? [link.parameters[key]] : link.parameters[key];
                }
            }
            return params;
        }
    }
};

// Callbacks
JasperMobile.Report.Callback = {
    onReportCompleted: function(status, pages, error) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "reportRunDidCompleted",
                "parameters" : {
                    "status" : status,
                    "pages" : pages,
                    "error" : error
                }
            }
        );
    },
    onPageChange: function(page) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "reportOnPageChange",
                "parameters" : {
                    "page" : page
                }
            }
        );
    },
    onLoadError: function(error) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "reportDidEndRenderFailured",
                "parameters" : {
                    "code" : error.errorCode,
                    "message" : error.message
                }
            }
        );
    },
    onPageLoadError: function(error) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "onPageLoadError",
                "parameters" : {
                    "message" : error
                }
            }
        );
    },
    onExportGetResourcePath: function(link) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "exportPath",
                "parameters" : {
                    "link" : link
                }
            }
        );
    },
    onReportExecution: function(data) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "runReport",
                "parameters" : {
                    "data" : data
                }
            }
        );
    },
    onReferenceClick: function(location) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "handleReferenceClick",
                "parameters" : {
                    "location" : location
                }
            }
        );
    }
};

JasperMobile.Dashboard.Callback = {
    onRunSuccess: function(data) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "onLoadDone",
                "parameters" : {
                    "components" : data.components,
                    "params" : data.parameters
                }
            }
        );
    },
    onRunFailed: function(error) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "onLoadError",
                "parameters" : {
                    "error" : error
                }
            }
        );
    },
    dashletWillMaximize: function(component) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "dashletWillMaximize",
                "parameters" : {
                    "component" : component
                }
            }
        );
    },
    dashletDidMaximize: function(component) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "dashletDidMaximize",
                "parameters" : {
                    "component" : component
                }
            }
        );
    },
    dashletFailedMaximize: function(component, error) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "dashletFailedMaximize",
                "parameters" : {
                    "error" : error
                }
            }
        );
    },
    onReportExecution: function(data) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "onReportExecution",
                "parameters" : data
            }
        );
    },
    onReferenceClick: function(location) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "onReferenceClick",
                "parameters" : {
                    "location" : location
                }
            }
        );
    },
    dashboardParameters: function (data) {
        JasperMobile.Callback.createCallback(
            {
                "command" : "dashboardParameters",
                "parameters" : {
                    "params" : data
                }
            }
        );
    }
};

// Report
MobileReport = {
    report: null,
    run: function(params) {
        visualize({}, function (v) {

            var report = v.report({
                resource: params["uri"],
                params: params["params"],
                pages: params["pages"],
                scale: "width",
                container: "#container",
                chart: {
                    animation : false,
                    zoom : false
                },
                error: function(error) {
                    JasperMobile.Report.Callback.onLoadError(error);
                },
                events: {
                    reportCompleted: function(status, error) {
                        JasperMobile.Report.Callback.onReportCompleted(status, report.data().totalPages, error);
                    },
                    changePagesState: function(page) {
                        JasperMobile.Report.Callback.onPageChange(page);
                    }
                },
                linkOptions: {
                    events: {
                        click : function(event, link){
                            //JasperMobile.Callback.log("click to: " + link);
                            //JasperMobile.Callback.log("link.parameters: " + link.parameters);
                            //JasperMobile.Callback.log("link.parameters: " + JSON.stringify(link.parameters));
                            //JasperMobile.Callback.log("link.parameters._report: " + link.parameters._report);
                            //JasperMobile.Callback.log("JasperMobile.Helper.collectReportParams(link): " + JasperMobile.Helper.collectReportParams(link));
                            var type = link.type;
                            //JasperMobile.Callback.log("link type: " + type);

                            switch (type) {
                                case "ReportExecution": {
                                    var data = {
                                        resource: link.parameters._report,
                                        params: JasperMobile.Helper.collectReportParams(link)
                                    };
                                    var dataString = JSON.stringify(data);
                                    JasperMobile.Report.Callback.onReportExecution(dataString);
                                    break;
                                }
                                case "LocalAnchor": {
                                    report
                                        .pages({
                                            anchor: link.anchor
                                        })
                                        .run()
                                        .fail(function(error) {
                                            JasperMobile.Callback.log(error);
                                        });
                                    break;
                                }
                                case "LocalPage": {
                                    report.pages(link.pages)
                                        .run()
                                        .fail(function(error) {
                                            JasperMobile.Callback.log(error);
                                        })
                                        .done(function() {
                                            JasperMobile.Report.Callback.onPageChange(link.pages);
                                        });
                                    break;
                                }
                                case "Reference": {
                                    var href = link.href;
                                    JasperMobile.Report.Callback.onReferenceClick(href);
                                    break;
                                }
                                default: {
                                    defaultHandler.call(this);
                                }
                            }
                        }}
                }
            });
            MobileReport.report = report;
        });
    },
    refresh: function() {
        if (this.report) {
            this.report.refresh(
                function(status, error) {
                    JasperMobile.Report.Callback.onReportCompleted(status, MobileReport.report.data().totalPages, error);
                },
                function(error) {
                    JasperMobile.Report.Callback.onLoadError(error);
                }
            );
        }
    },
    applyReportParams: function(params) {
        if (this.report) {
            this.report
                .params(params)
                .run()
                .done(function(status, error) {
                    JasperMobile.Report.Callback.onReportCompleted(status, MobileReport.report.data().totalPages, error);
                })
                .fail(function(error) {
                    JasperMobile.Report.Callback.onLoadError(error);
                });
        }
    },
    selectPage: function(page) {
        if (this.report) {
            this.report
                .pages(page)
                .run()
                .done(function(page) {
                    JasperMobile.Report.Callback.onPageChange(parseInt(MobileReport.report.pages()));
                })
                .fail(function(error) {
                    JasperMobile.Report.Callback.onPageLoadError(error);
                });
        }
    },
    exportReport: function(format) {
        if (this.report) {
            this.report.export({
                outputFormat: format
            }).done(function(link) {
                JasperMobile.Report.Callback.onExportGetResourcePath(link.href);
            });
        }
    },
    destroyReport: function() {
        if (this.report) {
            this.report.destroy();
        }
    }
};

// Dashboard
MobileDashboard = {
    dashboardObject: {},
    refreshedDashboardObject: {},
    canceledDashboardObject: {},
    dashboardFunction: {},
    selectedDashlet: {}, // DOM element
    selectedComponent: {}, // Model element
    run: function (params) {
        JasperMobile.Callback.log("start run");
        visualize({}, function (v) {
            MobileDashboard.dashboardFunction = v.dashboard;

            var dashboard = MobileDashboard.dashboardFunction({
                resource: params["uri"],
                container: "#container",
                report: {
                    chart: {
                        animation: false,
                        zoom: false
                    }
                },
                linkOptions: {
                    events: {
                        click: function(event, link) {
                            var type = link.type;
                            JasperMobile.Callback.log("link type: " + type);

                            switch (type) {
                                case "ReportExecution": {
                                    var data = {
                                        resource: link.parameters._report,
                                        params: JasperMobile.Helper.collectReportParams(link)
                                    };
                                    var dataString = JSON.stringify(data);
                                    JasperMobile.Dashboard.Callback.onReportExecution(data);
                                    break;
                                }
                                case "LocalAnchor": {
                                    defaultHandler.call(this);
                                    break;
                                }
                                case "LocalPage": {
                                    defaultHandler.call(this);
                                    break;
                                }
                                case "Reference": {
                                    var href = link.href;
                                    JasperMobile.Dashboard.Callback.onReferenceClick(href);
                                    break;
                                }
                                case "AdHocExecution":
                                    defaultHandler.call(this);
                                    break;
                                default: {
                                    defaultHandler.call(this);
                                }
                            }
                        }
                    }
                },
                success: function() {
                    //// Hack to get parameters' values
                    setTimeout(function(){
                        var data = MobileDashboard.dashboardObject.data();
                        JasperMobile.Dashboard.Callback.onRunSuccess(data);
                    }, 6000);
                    MobileDashboard._configureComponents(data.components);
                    MobileDashboard._defineComponentsClickEvent();
                },
                error: function(error) {
                    JasperMobile.Dashboard.Callback.onRunFailed(error);
                }
            });
            MobileDashboard.dashboardObject = dashboard;
        });
    },
    getDashboardParameters: function() {
        var data = MobileDashboard.dashboardObject.data();
        JasperMobile.Dashboard.Callback.dashboardParameters(data.parameters);
    },
    minimizeDashlet: function(dashletId) {
        if (dashletId) {
            MobileDashboard.dashboardObject.updateComponent(dashletId, {
                maximized: false,
                interactive: false
            });
        } else {
            // TODO: need this?
            //this._showDashlets();

            // stop showing buttons for changing chart type.
            var chartWrappers = document.querySelectorAll('.show_chartTypeSelector_wrapper');
            for (var i = 0; i < chartWrappers.length; ++i) {
                chartWrappers[i].style.display = 'none';
            }

            MobileDashboard.selectedDashlet.classList.remove('originalDashletInScaledCanvas');

            MobileDashboard.dashboardObject.updateComponent(MobileDashboard.selectedComponent.id, {
                maximized: false,
                interactive: false
            }, function() {
                MobileDashboard.selectedDashlet = {};
                MobileDashboard.selectedComponent = {};
                // TODO: need add callbacks?
            }, function(error) {
                // TODO: need add callbacks?
            });
        }
    },
    maximizeDashlet: function(dashletId) {
        if (dashletId) {
            MobileDashboard.dashboardObject.updateComponent(dashletId, {
                maximized: true,
                interactive: true
            });
        } else {
            JasperMobile.Callback.log("Try maximize dashelt without 'id'");
        }
    },
    refresh: function() {
        JasperMobile.Callback.log("start refresh");
        JasperMobile.Callback.log("dashboard object: " + MobileDashboard.dashboardObject);
        MobileDashboard.refreshedDashboardObject = MobileDashboard.dashboardObject.refresh()
            .done(function() {
                JasperMobile.Callback.log("success refresh");
                var data = MobileDashboard.dashboardObject.data();
                JasperMobile.Dashboard.Callback.onRunSuccess(data.components);
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed refresh with error: " + error);
            });
        setTimeout(function() {
            JasperMobile.Callback.log("state: " + MobileDashboard.refreshedDashboardObject.state());
            if (MobileDashboard.refreshedDashboardObject.state() === "pending") {
                MobileDashboard.run({"uri" : MobileDashboard.dashboardObject.properties().resource});
            }
        }, 20000);
    },
    cancel: function() {
        JasperMobile.Callback.log("start cancel");
        JasperMobile.Callback.log("dashboard object: " + MobileDashboard.dashboardObject);
        MobileDashboard.canceledDashboardObject = MobileDashboard.dashboardObject.cancel()
            .done(function() {
                JasperMobile.Callback.log("success cancel");
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed cancel");
            });
    },
    refreshDashlet: function() {
        JasperMobile.Callback.log("start refresh component");
        JasperMobile.Callback.log("dashboard object: " + MobileDashboard.dashboardObject);
        MobileDashboard.dashboardObject.refresh(MobileDashboard.selectedComponent.id)
            .done(function() {
                JasperMobile.Callback.log("success refresh");
                var data = MobileDashboard.dashboardObject.data();
                JasperMobile.Dashboard.Callback.onRunSuccess(data.components);
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed refresh");
            });
    },
    applyParams: function(parameters) {

        MobileDashboard.dashboardObject.params(parameters).run()
            .done(function() {
                JasperMobile.Callback.log("success apply");
            })
            .fail(function() {
                JasperMobile.Callback.log("failed apply");
            });
    },
    destroy: function() {
        if (MobileDashboard.dashboardObject) {
            MobileDashboard.dashboardObject.destroy();
        }
    },
    _configureComponents: function(components) {
        components.forEach( function(component) {
            if (component.type !== 'inputControl') {
                MobileDashboard.dashboardObject.updateComponent(component.id, {
                    interactive: false,
                    toolbar: false
                });
            }
        });
    },
    _defineComponentsClickEvent: function() {
        var dashboardId = MobileDashboard.dashboardFunction.componentIdDomAttribute;
        var dashlets = MobileDashboard._getDashlets(dashboardId); // DOM elements
        for (var i = 0; i < dashlets.length; ++i) {
            var parentElement = dashlets[i].parentElement;
            // set onClick listener for parent of dashlet
            parentElement.onclick = function(event) {
                MobileDashboard.selectedDashlet = this;
                var targetClass = event.target.className;
                if (targetClass !== 'overlay') {
                    return;
                }

                // start showing buttons for changing chart type.
                var chartWrappers = document.querySelectorAll('.show_chartTypeSelector_wrapper');
                for (var i = 0; i < chartWrappers.length; ++i) {
                    chartWrappers[i].style.display = 'block';
                }

                var component, id;
                id = this.getAttribute(dashboardId);
                component = MobileDashboard._getComponentById(id); // Model object

                // TODO: need this?
                //self._hideDashlets(dashboardId, dashlet);

                if (component && !component.maximized) {
                    JasperMobile.Dashboard.Callback.dashletWillMaximize(component);
                    MobileDashboard.selectedDashlet.className += "originalDashletInScaledCanvas";
                    MobileDashboard.dashboardObject.updateComponent(id, {
                        maximized: true,
                        interactive: true
                    }, function() {
                        MobileDashboard.selectedComponent = component;
                        JasperMobile.Dashboard.Callback.dashletDidMaximize(component);
                    }, function(error) {
                        JasperMobile.Dashboard.Callback.dashletFailedMaximize(component, error);
                    });
                }
            };
        }
    },
    _getDashlets: function(dashboardId) {
        var dashlets;
        var query = ".dashlet";
        if (dashboardId != null) {
            query = "[" + dashboardId + "] > .dashlet";
        }
        dashlets = document.querySelectorAll(query);
        return dashlets;
    },
    _getComponentById: function(id) {
        var components = MobileDashboard.dashboardObject.data().components;
        for (var i = 0; components.length; ++i) {
            if (components[i].id === id) {
                return components[i];
            }
        }
    }
};

// Start Point
document.addEventListener("DOMContentLoaded", function(event) {
    JasperMobile.Callback.onScriptLoaded();
});