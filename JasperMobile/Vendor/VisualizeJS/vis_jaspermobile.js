var JasperMobile = {};

// Callbacks
JasperMobile.Callback = {
    createCallback : function(params) {
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
    onReportCompleted: function(status, pages, error) {
        this.createCallback(
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
        this.createCallback(
            {
                "command" : "reportOnPageChange",
                "parameters" : {
                    "page" : page
                }
            }
        );
    },
    onLoadError: function(error) {
        this.createCallback(
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
        this.createCallback(
            {
                "command" : "onPageLoadError",
                "parameters" : {
                    "message" : error
                }
            }
        );
    },
    onExportGetResourcePath: function(link) {
        this.createCallback(
            {
                "command" : "exportPath",
                "parameters" : {
                    "link" : link
                }
            }
        );
    },
    onReportExecution: function(data) {
        JasperMobile.Callback.log("onReportExecution");
        this.createCallback(
            {
                "command" : "runReport",
                "parameters" : {
                    "data" : data
                }
            }
        );
    },
    onReferenceClick: function(location) {
        JasperMobile.Callback.log("onReportExecution");
        this.createCallback(
            {
                "command" : "handleReferenceClick",
                "parameters" : {
                    "location" : location
                }
            }
        );
    },
    log : function(params) {
        this.createCallback(
            {
                "command" : "logging",
                "parameters" : {
                    "message" : params
                }
            }
        );
    }
};

JasperMobile.Callback.Queue = {
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
};

JasperMobile.Helper = {
    collectReportParams: function(link) {
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
                    JasperMobile.Callback.onLoadError(error);
                },
                events: {
                    reportCompleted: function(status, error) {
                        JasperMobile.Callback.onReportCompleted(status, report.data().totalPages, error);
                    },
                    changePagesState: function(page) {
                        JasperMobile.Callback.onPageChange(page);
                    }
                },
                linkOptions: {
                    events: {
                        click : function(event, link){
                            JasperMobile.Callback.log("click to: " + link);
                            JasperMobile.Callback.log("link.parameters: " + link.parameters);
                            JasperMobile.Callback.log("link.parameters: " + JSON.stringify(link.parameters));
                            JasperMobile.Callback.log("link.parameters._report: " + link.parameters._report);
                            JasperMobile.Callback.log("JasperMobile.Helper.collectReportParams(link): " + JasperMobile.Helper.collectReportParams(link));
                            var type = link.type;
                            JasperMobile.Callback.log("link type: " + type);

                            switch (type) {
                                case "ReportExecution": {
                                    var data = {
                                        resource: link.parameters._report,
                                        params: JasperMobile.Helper.collectReportParams(link)
                                    };
                                    var dataString = JSON.stringify(data);
                                    JasperMobile.Callback.onReportExecution(dataString);
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
                                            JasperMobile.Callback.onPageChange(link.pages);
                                        });
                                    break;
                                }
                                case "Reference": {
                                    var href = link.href;
                                    JasperMobile.Callback.onReferenceClick(href);
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
                    JasperMobile.Callback.onReportCompleted(status, MobileReport.report.data().totalPages, error);
                },
                function(error) {
                    JasperMobile.Callback.onLoadError(error);
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
                    JasperMobile.Callback.onReportCompleted(status, MobileReport.report.data().totalPages, error);
                })
                .fail(function(error) {
                    JasperMobile.Callback.onLoadError(error);
                });
        }
    },
    selectPage: function(page) {
        if (this.report) {
            this.report
                .pages(page)
                .run()
                .done(function(page) {
                    JasperMobile.Callback.onPageChange(parseInt(MobileReport.report.pages()));
                })
                .fail(function(error) {
                    JasperMobile.Callback.onPageLoadError(error);
                });
        }
    },
    exportReport: function(format) {
        if (this.report) {
            this.report.export({
                outputFormat: format
            }).done(function(link) {
                JasperMobile.Callback.onExportGetResourcePath(link.href);
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

};

// Start Point
document.addEventListener("DOMContentLoaded", function(event) {
    JasperMobile.Callback.onScriptLoaded();
});