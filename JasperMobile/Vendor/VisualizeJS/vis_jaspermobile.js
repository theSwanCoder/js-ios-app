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
            var callback = "http://jaspermobile.callback/json&&" + JSON.stringify(params);
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
        },
        updateViewPortInitialScale: function (scale) {
            var viewport = document.querySelector("meta[name=viewport]");
            viewport.setAttribute('content', 'initial-scale='+ scale + ', width=device-width, maximum-scale=2.0, user-scalable=yes');
        }
    }
};

// Callbacks
JasperMobile.Callback.Callbacks = {
    successCompleted: function(command, parameters) {
        JasperMobile.Callback.createCallback(
            {
                "command" : command,
                "parameters" : parameters
            }
        );
    },
    failedCompleted: function(command, parameters) {
        JasperMobile.Callback.createCallback(
            {
                "command" : command,
                "parameters" : parameters
            }
        );
    },
    successCallback: function(callback, parameters) {
        JasperMobile.Callback.createCallback(
            {
                "command" : callback,
                "parameters" : parameters
            }
        );
    },
    failedCallback: function(callback, parameters) {
        JasperMobile.Callback.createCallback(
            {
                "command" : callback,
                "parameters" : parameters
            }
        );
    }
};

// Report
JasperMobile.Report.API = {
    report: null,
    run: function(params) {
        visualize(function (v) {
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
                success: function() {
                    JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.run", {
                        "status" : status,
                        "pages" : report.data().totalPages
                    });
                },
                error: function(error) {
                    JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.run", {
                        "error" : JSON.stringify({
                            "code" : error.errorCode,
                            "message" : error.message
                        })
                    });
                },
                events: {
                    reportCompleted: function(status, error) {
                        JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Report.API.run.reportCompleted", {
                            "status" : status,
                            "pages" : report.data().totalPages,
                            "error" : error
                        });
                    },
                    changePagesState: function(page) {
                        JasperMobile.Callback.log("Event: changePagesState");
                        JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Report.API.run.changePagesState", {
                            "page" : page
                        });
                    }
                },
                linkOptions: {
                    events: {
                        click : function(event, link){
                            var type = link.type;

                            switch (type) {
                                case "ReportExecution": {
                                    var data = {
                                        resource: link.parameters._report,
                                        params: JasperMobile.Helper.collectReportParams(link)
                                    };
                                    var dataString = JSON.stringify(data);
                                    JasperMobile.Callback.log("Event: linkOption - ReportExecution");
                                    JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Report.API.run.linkOptions.events.ReportExecution", {
                                        "data" : dataString
                                    });
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
                                            JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Report.API.run.linkOptions.events.LocalPage", {
                                                "page" : link.pages
                                            });
                                        });
                                    break;
                                }
                                case "Reference": {
                                    var href = link.href;
                                    JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Report.API.run.linkOptions.events.Reference", {
                                        "location" : href
                                    });
                                    break;
                                }
                                default: {
                                    defaultHandler.call(this);
                                }
                            }
                        }}
                }
            });
            JasperMobile.Report.API.report = report;
        });
    },
    cancel: function() {
        if (JasperMobile.Report.API.report) {
            JasperMobile.Report.API.report.cancel()
                .done(function () {
                    JasperMobile.Callback.log("success cancel");
                })
                .fail(function (error) {
                    JasperMobile.Callback.log("failed cancel with error: " + error);
                });
        } else {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.cancel", {
                "error": JSON.stringify({
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.API.report == nil"
                })
            });
        }
    },
    refresh: function() {
        if (JasperMobile.Report.API.report) {
            JasperMobile.Report.API.report.refresh()
                .done( function() {
                        JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.refresh", {
                            "status": status,
                            "pages": JasperMobile.Report.API.report.data().totalPages
                        });
                }).fail( function(error) {
                    JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.refresh", {
                        "error": JSON.stringify({
                            "code" : error.errorCode,
                            "message" : error.message
                        })
                    });
                });
        } else {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.refresh", {
                "error": JSON.stringify({
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.API.report == nil"
                })
            });
        }
    },
    applyReportParams: function(params) {
        if (JasperMobile.Report.API.report) {
            JasperMobile.Report.API.report.params(params).run()
                .done(function (status, error) {
                    JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.applyReportParams", {
                        "status": status,
                        "pages": JasperMobile.Report.API.report.data().totalPages,
                        "error": error
                    });
                })
                .fail(function (error) {
                    JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.applyReportParams", {
                        "error": JSON.stringify({
                            "code" : error.errorCode,
                            "message" : error.message
                        })
                    });
                });
        } else {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.applyReportParams", {
                "error": JSON.stringify({
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.API.report == nil"
                })
            });
        }
    },
    selectPage: function(page) {
        if (JasperMobile.Report.API.report) {
            JasperMobile.Report.API.report.pages(page).run()
                .done(function (reportData) {
                    JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.selectPage", {
                        "page": parseInt(JasperMobile.Report.API.report.pages())
                    });
                })
                .fail(function (error) {
                    JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.selectPage", {
                        "error": JSON.stringify({
                            "code" : error.errorCode,
                            "message" : error.message
                        })
                    });
                });
        } else {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.selectPage", {
                "error": JSON.stringify({
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.API.report == nil"
                })
            });
        }
    },
    exportReport: function(format) {
        if (JasperMobile.Report.API.report) {
            JasperMobile.Report.API.report.export({
                outputFormat: format
            }).done(function (link) {
                JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.run", {
                    "link" : link.href
                });
            });
        } else {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.exportReport", {
                "error": JSON.stringify({
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.API.report == nil"
                })
            });
        }
    },
    destroyReport: function() {
        if (JasperMobile.Report.API.report) {
            JasperMobile.Report.API.report.destroy();
        } else {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.destroyReport", {
                "error": JSON.stringify({
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.API.report == nil"
                })
            });
        }
    }
};

// Dashboard
JasperMobile.Dashboard.API = {
    dashboardObject: {},
    refreshedDashboardObject: {},
    canceledDashboardObject: {},
    dashboardFunction: {},
    selectedDashlet: {}, // DOM element
    selectedComponent: {}, // Model element
    run: function (params) {
        JasperMobile.Callback.log("start run");
        visualize(function (v) {
            JasperMobile.Dashboard.API.dashboardFunction = v.dashboard;

            var dashboard = JasperMobile.Dashboard.API.dashboardFunction({
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
                        click: function(event, link, defaultHandler) {
                            var type = link.type;
                            JasperMobile.Callback.log("link type: " + type);

                            switch (type) {
                                case "ReportExecution": {
                                    var data = {
                                        resource: link.parameters._report,
                                        params: JasperMobile.Helper.collectReportParams(link)
                                    };
                                    var dataString = JSON.stringify(data);
                                    JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Dashboard.API.run.linkOptions.events.ReportExecution", {
                                        "data" : dataString
                                    });
                                    break;
                                }
                                case "LocalAnchor": {
                                    defaultHandler.call();
                                    break;
                                }
                                case "LocalPage": {
                                    defaultHandler.call();
                                    break;
                                }
                                case "Reference": {
                                    var href = link.href;
                                    JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Dashboard.API.run.linkOptions.events.Reference", {
                                        "location" : href
                                    });
                                    break;
                                }
                                case "AdHocExecution":
                                    defaultHandler.call();
                                    JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Dashboard.API.run.linkOptions.events.AdHocExecution", {});
                                    break;
                                default: {
                                    defaultHandler.call();
                                }
                            }
                        }
                    }
                },
                success: function() {
                    var data = JasperMobile.Dashboard.API.dashboardObject.data();
                    JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.run", {
                        "components" : data.components,
                        "params" : data.parameters
                    });
                    JasperMobile.Dashboard.API._configureComponents(data.components);
                    JasperMobile.Dashboard.API._defineComponentsClickEvent();
                    JasperMobile.Dashboard.API._setupFiltersApperance();
                },
                error: function(error) {
                    JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.run", {
                        "error" : JSON.stringify({
                            "code" : error.errorCode,
                            "message" : error.message
                        })
                    });
                }
            });
            JasperMobile.Dashboard.API.dashboardObject = dashboard;
        });
    },
    getDashboardParameters: function() {
        var data = JasperMobile.Dashboard.API.dashboardObject.data();
        JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.getDashboardParameters", {
            "components" : data.components,
            "params" : data.parameters
        });
    },
    minimizeDashlet: function(dashletId) {
        if (dashletId) {
            JasperMobile.Dashboard.API.dashboardObject.updateComponent(dashletId, {
                maximized: false,
                interactive: false
            }).done(function() {
                JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.minimizeDashlet", {
                    "component" : dashletId
                });
            }).fail(function(error) {
                JasperMobile.Callback.log("failed refresh with error: " + error);
                JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.minimizeDashlet", {
                    "error" : JSON.stringify({
                        "code" : error.errorCode,
                        "message" : error.message
                    })
                });
            });
        } else {
            // TODO: need this?
            //this._showDashlets();

            // stop showing buttons for changing chart type.
            var chartWrappers = document.querySelectorAll('.show_chartTypeSelector_wrapper');
            for (var i = 0; i < chartWrappers.length; ++i) {
                chartWrappers[i].style.display = 'none';
            }

            JasperMobile.Dashboard.API.selectedDashlet.classList.remove('originalDashletInScaledCanvas');

            JasperMobile.Dashboard.API.dashboardObject.updateComponent(JasperMobile.Dashboard.API.selectedComponent.id, {
                maximized: false,
                interactive: false
            }, function() {
                JasperMobile.Dashboard.API.selectedDashlet = {};
                JasperMobile.Dashboard.API.selectedComponent = {};
                // TODO: need add callbacks?
            }, function(error) {
                JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.minimizeDashlet", {
                    "error" : JSON.stringify({
                        "code" : error.errorCode,
                        "message" : error.message
                    })
                });
            });
        }
    },
    maximizeDashlet: function(dashletId) {
        if (dashletId) {
            JasperMobile.Dashboard.API.dashboardObject.updateComponent(dashletId, {
                maximized: true,
                interactive: true
            }).done(function() {
                JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.maximizeDashlet", {
                    "component" : dashletId
                });
            }).fail(function(error) {
                JasperMobile.Callback.log("failed refresh with error: " + error);
                JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.maximizeDashlet", {
                    "error" : JSON.stringify({
                        "code" : error.errorCode,
                        "message" : error.message
                    })
                });
            });
        } else {
            JasperMobile.Callback.log("Try maximize dashelt without 'id'");
        }
    },
    refresh: function() {
        JasperMobile.Callback.log("start refresh");
        JasperMobile.Callback.log("dashboard object: " + JasperMobile.Dashboard.API.dashboardObject);
        JasperMobile.Dashboard.API.refreshedDashboardObject = JasperMobile.Dashboard.API.dashboardObject.refresh()
            .done(function() {
                var data = JasperMobile.Dashboard.API.dashboardObject.data();
                JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.refresh", {
                    "components" : data.components,
                    "params" : data.parameters
                });
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed refresh with error: " + error);
                JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.refresh", {
                    "error" : JSON.stringify({
                        "code" : error.errorCode,
                        "message" : error.message
                    })
                });
            });
        setTimeout(function() {
            JasperMobile.Callback.log("state: " + JasperMobile.Dashboard.API.refreshedDashboardObject.state());
            if (JasperMobile.Dashboard.API.refreshedDashboardObject.state() === "pending") {
                JasperMobile.Dashboard.API.run({"uri" : JasperMobile.Dashboard.API.dashboardObject.properties().resource});
            }
        }, 20000);
    },
    cancel: function() {
        JasperMobile.Callback.log("start cancel");
        JasperMobile.Callback.log("dashboard object: " + JasperMobile.Dashboard.API.dashboardObject);
        JasperMobile.Dashboard.API.canceledDashboardObject = JasperMobile.Dashboard.API.dashboardObject.cancel()
            .done(function() {
                JasperMobile.Callback.log("success cancel");
                JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.cancel", {});
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed cancel with error: " + error);
                JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.cancel", {
                    "error" : JSON.stringify({
                        "code" : error.errorCode,
                        "message" : error.message
                    })
                });
            });
    },
    refreshDashlet: function() {
        JasperMobile.Callback.log("start refresh component");
        JasperMobile.Callback.log("dashboard object: " + JasperMobile.Dashboard.API.dashboardObject);
        JasperMobile.Dashboard.API.refreshedDashboardObject = JasperMobile.Dashboard.API.dashboardObject.refresh(JasperMobile.Dashboard.API.selectedComponent.id)
            .done(function() {
                JasperMobile.Callback.log("success refresh");
                var data = JasperMobile.Dashboard.API.dashboardObject.data();
                JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.refreshDashlet", {
                    "components" : data.components,
                    "params" : data.parameters
                });
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed refresh dashlet with error: " + error);
                JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.refreshDashlet", {
                    "error" : JSON.stringify({
                        "code" : error.errorCode,
                        "message" : error.message
                    })
                });
            });
        setTimeout(function() {
            JasperMobile.Callback.log("state: " + JasperMobile.Dashboard.API.refreshedDashboardObject.state());
            if (JasperMobile.Dashboard.API.refreshedDashboardObject.state() === "pending") {
                JasperMobile.Dashboard.API.run({"uri" : JasperMobile.Dashboard.API.dashboardObject.properties().resource});
            }
        }, 20000);
    },
    applyParams: function(parameters) {

        JasperMobile.Dashboard.API.dashboardObject.params(parameters).run()
            .done(function() {
                var data = JasperMobile.Dashboard.API.dashboardObject.data();
                JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.applyParams", {
                    "components" : data.components,
                    "params" : data.parameters
                });
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed apply");
                JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.applyParams", {
                    "error" : JSON.stringify({
                        "code" : error.errorCode,
                        "message" : error.message
                    })
                });
            });
    },
    destroy: function() {
        if (JasperMobile.Dashboard.API.dashboardObject) {
            JasperMobile.Dashboard.API.dashboardObject.destroy();
        }
    },
    _configureComponents: function(components) {
        components.forEach( function(component) {
            if (component.type !== 'inputControl') {
                JasperMobile.Dashboard.API.dashboardObject.updateComponent(component.id, {
                    interactive: false,
                    toolbar: false
                });
            }
        });
    },
    _defineComponentsClickEvent: function() {
        var dashboardId = JasperMobile.Dashboard.API.dashboardFunction.componentIdDomAttribute;
        var dashlets = JasperMobile.Dashboard.API._getDashlets(dashboardId); // DOM elements
        for (var i = 0; i < dashlets.length; ++i) {
            var parentElement = dashlets[i].parentElement;
            // set onClick listener for parent of dashlet
            parentElement.onclick = function(event) {
                JasperMobile.Dashboard.API.selectedDashlet = this;
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
                component = JasperMobile.Dashboard.API._getComponentById(id); // Model object

                // TODO: need this?
                //self._hideDashlets(dashboardId, dashlet);

                if (component && !component.maximized) {
                    JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Dashboard.API.events.dashlet.willMaximize", {
                        "component" : component
                    });
                    JasperMobile.Dashboard.API.selectedDashlet.className += "originalDashletInScaledCanvas";
                    JasperMobile.Dashboard.API.dashboardObject.updateComponent(id, {
                        maximized: true,
                        interactive: true
                    }, function() {
                        JasperMobile.Dashboard.API.selectedComponent = component;
                        JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Dashboard.API.events.dashlet.didMaximize", {
                            "component" : component
                        });
                    }, function(error) {
                        JasperMobile.Callback.Callbacks.failedCallback("JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed", {
                            "error" : JSON.stringify({
                                "code" : error.errorCode,
                                "message" : error.message
                            }),
                            "component" : component
                        });
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
        var components = JasperMobile.Dashboard.API.dashboardObject.data().components;
        for (var i = 0; components.length; ++i) {
            if (components[i].id === id) {
                return components[i];
            }
        }
    },
    _setupFiltersApperance: function() {
        var interval = window.setInterval(function() {
            window.clearInterval(interval);
            var div = document.querySelector(".msPlaceholder > div");
            if (div !== null) {
                var divHeight;
                divHeight = document.querySelector(".msPlaceholder > div").style.height;
                if (divHeight !== 'undefined') {
                    document.querySelector(".msPlaceholder > div").style.height = "";
                }
                document.querySelector(".filterRow > div > div").style.height = "";
            }
        }, 500);
    }
};

// Start Point
document.addEventListener("DOMContentLoaded", function(event) {
    JasperMobile.Callback.onScriptLoaded();
});

window.onerror = function myErrorHandler(message, source, lineno, colno, error) {
    JasperMobile.Callback.Callbacks.failedCallback("JasperMobile.Events.Window.OnError", {
        "error" : JSON.stringify({
            "code" : "window.onerror",
            "message" : message,
            "source" : source
        })
    });
    return false;
};