
var JasperMobile = {
    Report : {},
    Dashboard : {},
    Callback: {},
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
        updateViewPortScale: function (params) {
            var scale = params["scale"];
            var viewPortContent = 'initial-scale='+ scale + ', width=device-width, maximum-scale=2.0, user-scalable=yes';
            var viewport = document.querySelector("meta[name=viewport]");
            if (!viewport) {
                viewport=document.createElement('meta');
                viewport.name = "viewport";
                viewport.content = viewPortContent;
                document.head.appendChild(viewport);
            } else {
                viewport.setAttribute('content', viewPortContent);
            }
        },
        addScript: function(scriptURL, success, error) {
            var nodes = document.head.querySelectorAll("[src='" + scriptURL + "']");
            if (nodes.length == 0) {
                var scriptTag = document.createElement('script');
                scriptTag.type = "text/javascript";
                scriptTag.src = scriptURL;
                scriptTag.async = true;
                scriptTag.onload = function() {
                    success();
                };
                var systemOnError = scriptTag.onError;
                scriptTag.onError = function (err) {
                    error(err);
                    systemOnError(err);
                };
                document.head.appendChild(scriptTag);
            } else {
                success();
            }
        },
        loadScripts: function(parameters) {
            var scriptURLs = parameters["scriptURLs"];
            var callbacksCount = scriptURLs.length;
            for (var i = 0; i < scriptURLs.length; i++) {
                var scriptURL = scriptURLs[i];
                (function(scriptURL) {
                    JasperMobile.Helper.addScript(scriptURL, function() {
                        if (--callbacksCount == 0) {
                            JasperMobile.Callback.callback("JasperMobile.Helper.loadScripts", {});
                        }
                    }, null);
                })(scriptURL);
            }
        },
        loadScript: function(parameters) {
            var scriptURL = parameters["scriptURL"];
            JasperMobile.Helper.addScript(scriptURL, function() {
                JasperMobile.Callback.callback("JasperMobile.Helper.loadScript", {
                    "params" : {
                        "script_path" : scriptURL
                    }
                });
            }, null);
        },
        cleanContent: function() {
            var elements = document.getElementsByClassName("_SmartLabel_Container");
            for(var i = 0; i < elements.length; i++) {
                var element = elements[i];
                document.body.removeChild(element);
            }
        },
        resetBodyTransformStyles: function() {
            var scale = "";
            var origin = "";
            JasperMobile.Helper.updateTransformStyles(document.body, scale, origin);
        },
        setBodyTransformStyles: function(scaleValue) {
            var scale = "scale(" + scaleValue + ")";
            var origin = "0% 0%";
            JasperMobile.Helper.updateTransformStyles(document.body, scale, origin);
        },
        updateBodyTransformStylesToFitWindow: function() {
            var body = document.body,
                html = document.documentElement;

            var width = Math.max( body.scrollWidth, body.offsetWidth,
                html.clientWidth, html.scrollWidth, html.offsetWidth );

            var scaleValue = window.innerWidth / width;
            JasperMobile.Helper.setBodyTransformStyles(scaleValue);
        },
        updateTransformStyles: function(element, scale, origin) {
            var navigator = window.navigator.appVersion;
            //ios 8.4 - 5.0 (iPhone; CPU iPhone OS 8_4 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12H141
            //ios 9.3 - 5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13E230
            var versionString = navigator.match(/(\d{3}\.\d+.\d+)/g)[0];

            if (versionString == "600.1.4") {
                element.style.webkitTransform = scale;
                element.style.webkitTransformOrigin = origin;
            } else {
                element.style.transform = scale;
                element.style.transformOrigin = origin;
            }
        },
        isContainerLoaded: function() {
            var container = document.getElementById("container");
            var isContainContainer = (container != null);
            console.log("isContainContainer: " + isContainContainer);
            JasperMobile.Callback.callback("JasperMobile.Helper.isContainerLoaded", {
                "isContainerLoaded" : isContainContainer ? "true" : "false"
            });
        }
    }
};

// Callbacks
JasperMobile.Callback = {
    createCallback: function(params) {
        window.webkit.messageHandlers.JMJavascriptNativeBridge.postMessage(params);
    },
    log : function(message) {
        //console.log("Log: " + message);
        this.createCallback(
            {
                "command" : "logging",
                "parameters" : {
                    "message" : message
                }
            }
        );
    },
    callback: function(command, parameters) {
        this.createCallback(
            {
                "type"       : "callback",
                "command"    : command,
                "parameters" : parameters
            }
        );
    },
    listener: function(command, parameters) {
        this.createCallback(
            {
                "type"       : "listener",
                "command"    : command,
                "parameters" : parameters
            }
        );
    }
};

JasperMobile.Report = {
    REST : {},
    VIS  : {}
};

// REST Reports
JasperMobile.Report.REST.API = {
    elasticChart: null,
    transformationScale: 0.0,
    injectContent: function(contentObject, transformationScale) {
        JasperMobile.Report.REST.API.transformationScale = contentObject["transformationScale"];
        var content = contentObject["HTMLString"];
        var container = document.getElementById('container');
        //container.style.pointerEvents = "none"; // disable clicks under container

        if (container == null) {
            JasperMobile.Callback.callback("JasperMobile.Report.REST.API.injectContent", {
                "error" : {
                    "code"    : "internal.error", // TODO: need error codes?
                    "message" : "No container"
                }
            });
            return;
        }

        container.innerHTML = content;

        if (content == "") {
            // clean content
            JasperMobile.Helper.cleanContent();
            JasperMobile.Report.REST.API.elasticChart = null;
            container.style.zoom = "";
            JasperMobile.Callback.log("clear content");
            JasperMobile.Callback.callback("JasperMobile.Report.REST.API.injectContent", {});
        } else {
            container.style.zoom = 2;
            JasperMobile.Helper.resetBodyTransformStyles();
            JasperMobile.Helper.updateBodyTransformStylesToFitWindow();
            JasperMobile.Callback.callback("JasperMobile.Report.REST.API.injectContent", {});
        }
    },
    verifyEnvironmentIsReady: function() {
        JasperMobile.Callback.callback("JasperMobile.Report.REST.API.verifyEnvironmentIsReady", {
            "isReady" : document.getElementById("container") != null
        });
    },
    renderHighcharts: function(parameters) {
        var scripts = parameters["scripts"];
        var isElasticChart = parameters["isElasticChart"];

        JasperMobile.Report.REST.API.chartParams = parameters;

        var script;
        var functionName;
        var chartParams;

        JasperMobile.Report.REST.API.elasticChart = null;

        if (isElasticChart == "true") {
            var container = document.getElementById('container');

            JasperMobile.Helper.resetBodyTransformStyles();
            JasperMobile.Helper.setBodyTransformStyles(JasperMobile.Report.REST.API.transformationScale);

            script = scripts[0];
            functionName = script.scriptName.trim();
            chartParams = script.scriptParams;

            var containerWidth = container.offsetWidth / JasperMobile.Report.REST.API.transformationScale ;
            var containerHeight = container.offsetHeight /JasperMobile.Report.REST.API.transformationScale ;

            // Update chart size
            var chartDimensions = chartParams.chartDimensions;
            chartDimensions.width = containerWidth;
            chartDimensions.height = containerHeight;

            // set new chart size
            chartParams.chartDimensions = chartDimensions;

            JasperMobile.Report.REST.API.elasticChart = {
                "functionName" : functionName,
                "chartParams" : chartParams
            };

            // run script
            window[functionName](chartParams);

        } else {
            for(var i=0; i < scripts.length; i++) {
                script = scripts[i];
                functionName = script.scriptName.trim();
                chartParams = script.scriptParams;
                window[functionName](chartParams);
            }
        }
        JasperMobile.Callback.callback("JasperMobile.Report.REST.API.renderHighcharts", {});
    },
    executeScripts: function(parameters) {

        // intercept require js

        requirejs.onError = function (err) {
            if (err.requireType === 'timeout') {
                JasperMobile.Callback.log("require error: " + err);
            } else {
                throw err;
            }
        };

        requirejs.reallyLoad = requirejs.load;
        requirejs.load = function (context, moduleName, url) {

            // TODO: try load sources of scripts from native code
            // TODO: to eval the script
            // TODO: and to fire success here

            JasperMobile.Callback.log("require try load url: " + url);

            var node = document.createElement('script');
            node.type = 'text/javascript';
            node.charset = 'utf-8';
            node.async = true;

            node.setAttribute('data-requirecontext', context.contextName);
            node.setAttribute('data-requiremodule', moduleName);

            node.addEventListener('load', context.onScriptLoad, false);
            node.addEventListener('error', context.onScriptError, false);
            node.src = url;

            document.head.appendChild(node);
            return node;

            //requirejs.reallyLoad(context, moduleName, url);
        };

        // execute report's scripts

        var scripts = parameters["scripts"];
        for (var i = 0; i < scripts.length; i++) {
            var script = scripts[i];
            eval(script);
        }
        JasperMobile.Callback.callback("JasperMobile.Report.REST.API.executeScripts", {});
    },
    addHyperlinks: function(hyperlinks) {
        var allSpans = document.getElementsByTagName("span");
        for (var i = 0; i < hyperlinks.length; i++) {
            var hyperlink = hyperlinks[i];
            (function(hyperlink) {
                for (var j=0; j < allSpans.length; j++) {
                    var span = allSpans[j];
                    if (hyperlink.tooltip == span.title) {
                        // add click listener
                        span.addEventListener("click", function() {
                            JasperMobile.Callback.listener("JasperMobile.listener.hyperlink", {
                                "type" : hyperlink.type,
                                "params" : hyperlink.params
                            });
                        });
                    }
                }
            })(hyperlink);
        }
    },
    applyZoomForReport: function() {
        var tableNode = document.getElementsByClassName("jrPage")[0];
        if (tableNode.nodeName == "TABLE") {
            document.body.innerHTML = "<div id='containter'></div>";
            var container = document.getElementById("containter");
            container.appendChild(tableNode);
            var table = tableNode;
            var scale = "scale(" + innerWidth / parseInt(table.style.width) + ")";
            var origin = "50% 0%";
            JasperMobile.Helper.updateTransformStyles(table, scale, origin);
            JasperMobile.Callback.callback("JasperMobile.Report.REST.API.applyZoomForReport", {});
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.REST.API.applyZoomForReport", {
                "error" : {
                    "code"    : "internal.error", // TODO: need error codes?
                    "message" : "No table with class 'jrPage'."
                }
            });
        }
    },
    fitReportViewToScreen: function() {
        JasperMobile.Helper.resetBodyTransformStyles();
        if (JasperMobile.Report.REST.API.elasticChart != null) {
            JasperMobile.Helper.setBodyTransformStyles(JasperMobile.Report.REST.API.transformationScale );

            // run script
            var functionName = JasperMobile.Report.REST.API.elasticChart.functionName;
            var chartParams = JasperMobile.Report.REST.API.elasticChart.chartParams;

            var containerWidth = document.getElementById("container").offsetWidth / JasperMobile.Report.REST.API.transformationScale ;
            var containerHeight = document.getElementById("container").offsetHeight / JasperMobile.Report.REST.API.transformationScale ;

            var chartDimensions = chartParams.chartDimensions;
            chartDimensions.width = containerWidth;
            chartDimensions.height = containerHeight;

            chartParams.chartDimensions = chartDimensions;
            window[functionName](chartParams);
        } else {
            JasperMobile.Helper.updateBodyTransformStylesToFitWindow();
        }

        JasperMobile.Callback.callback("JasperMobile.Report.REST.API.fitReportViewToScreen", {});
    }
};

// VIZ Reports
JasperMobile.Report.VIS.API = {
    report: null,
    isAmber: false,
    runReport: function(params) {
        JasperMobile.Report.VIS.API.isAmber = params["is_for_6_0"];
        var successFn = function(status) {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.runReport", {
                "status" : status,
                "pages" : JasperMobile.Report.VIS.API.report.data().totalPages
            });
        };
        var errorFn = function(error) {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.runReport", {
                "error" : {
                    "code" : error.errorCode,
                    "message" : error.message
                }
            });
        };
        var events = {
            reportCompleted: function(status, error) {
                JasperMobile.Callback.log("Event: reportCompleted");
                if (status == "ready") {
                    JasperMobile.Callback.listener("JasperMobile.Report.Event.reportCompleted", {
                        "status" : status,
                        "pages" : JasperMobile.Report.VIS.API.report.data().totalPages
                    });
                } else if (status == "failed") {
                    JasperMobile.Callback.log("Event: reportCompleted with error: " + JSON.stringify(error));
                }
            },
            changePagesState: function(page) {
                JasperMobile.Callback.log("Event: changePagesState");
                JasperMobile.Callback.listener("JasperMobile.Report.Event.changePagesState", {
                    "page" : page
                });
            },
            bookmarksReady : function (bookmarks) {
                JasperMobile.Callback.log("Event: bookmarksReady");
                JasperMobile.Callback.listener("JasperMobile.Report.Event.bookmarksReady", {
                    "bookmarks" : bookmarks
                });
            },
            reportPartsReady : function(parts) {
                JasperMobile.Callback.log("Event: reportPartsReady");
                JasperMobile.Callback.listener("JasperMobile.Report.Event.reportPartsReady", {
                    "parts" : parts
                });
            },
            pageFinal : function(html) {
                JasperMobile.Callback.log("Event: changePagesState");
            }
        };
        var linkOptionsEventsClick = function(event, link, defaultHandler){
            var type = link.type;

            switch (type) {
                case "ReportExecution": {
                    var data = {
                        resource: link.parameters._report,
                        params: JasperMobile.Helper.collectReportParams(link)
                    };
                    JasperMobile.Callback.log("Event: linkOption - ReportExecution");
                    JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.ReportExecution", {
                        "data" : data
                    });
                    break;
                }
                case "LocalAnchor": {
                    JasperMobile.Report.VIS.API.report
                        .pages({
                            anchor: link.anchor
                        })
                        .run()
                        .done(function(){
                            JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.LocalAnchor", {
                                "page" : link.pages
                            });
                        })
                        .fail(function(error) {
                            JasperMobile.Callback.log(error);
                        });
                    break;
                }
                case "LocalPage": {
                    JasperMobile.Report.VIS.API.report.pages(link.pages)
                        .run()
                        .fail(function(error) {
                            JasperMobile.Callback.log(error);
                        })
                        .done(function() {
                            JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.LocalPage", {
                                "page" : link.pages
                            });
                        });
                    break;
                }
                case "Reference": {
                    var href = link.href;
                    JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.Reference", {
                        "location" : href
                    });
                    break;
                }
                default: {
                    if (defaultHandler != null) {
                        defaultHandler.call(this);
                    }
                }
            }
        };

        var reportStruct = {
            resource: params["uri"],
            params: params["params"],
            pages: params["pages"],
            scale: "width",
            container: "#container",
            success: successFn,
            error: errorFn,
            events: events,
            linkOptions: {
                events: {
                    click : linkOptionsEventsClick
                }
            }
        };
        var auth = {};

        if (JasperMobile.Report.VIS.API.isAmber) {
            auth.auth = {
                loginFn: function(properties, request) {
                    return (new jQuery.Deferred()).resolve();
                }
            };
        } else {
            reportStruct.autoresize = false;
            reportStruct.chart = {
                animation : false,
                zoom : false
            };
        }

        var runFn = function (v) {
            // save link for reportObject
            JasperMobile.Report.VIS.API.report = v.report(reportStruct);
        };
        visualize(auth, runFn, errorFn);
    },
    cancel: function() {
        if (JasperMobile.Report.VIS.API.report) {
            JasperMobile.Report.VIS.API.report.cancel()
                .done(function () {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.cancel", {});
                })
                .fail(function (error) {
                    JasperMobile.Callback.log("failed cancel with error: " + error);
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.cancel", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.VIS.API.report == nil"
                }
            });
        }
    },
    refresh: function() {
        if (JasperMobile.Report.VIS.API.report) {
            JasperMobile.Report.VIS.API.report.refresh()
                .done( function(status) {
                        JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.refresh", {
                            "status": status,
                            "pages": JasperMobile.Report.VIS.API.report.data().totalPages
                        });
                }).fail( function(error) {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.refresh", {
                        "error": {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.refresh", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.VIS.API.report == nil"
                }
            });
        }
    },
    applyReportParams: function(params) {
        if (JasperMobile.Report.VIS.API.report) {
            JasperMobile.Report.VIS.API.report.params(params).run()
                .done(function (reportData) {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.applyReportParams", {
                        "pages": reportData.totalPages
                    });
                })
                .fail(function (error) {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.applyReportParams", {
                        "error": {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.applyReportParams", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.VIS.API.report == nil"
                }
            });
        }
    },
    selectPage: function(parameters) {
        var page = parameters["pageNumber"];
        if (JasperMobile.Report.VIS.API.report) {
            JasperMobile.Report.VIS.API.report.pages(page).run()
                .done(function (reportData) {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.selectPage", {
                        "page": parseInt(JasperMobile.Report.VIS.API.report.pages())
                    });
                })
                .fail(function (error) {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.selectPage", {
                        "error": {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.selectPage", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.VIS.API.report == nil"
                }
            });
        }
    },
    navigateToBookmark: function(parameters) {
        var bookmarkAnchor = parameters["anchor"];
        if (JasperMobile.Report.VIS.API.report) {
            JasperMobile.Report.VIS.API.report
                .pages({
                    anchor : bookmarkAnchor
                })
                .run()
                .done(function(reportData) {
                    JasperMobile.Callback.log("success of navigating to bookmark");
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.navigateToBookmark", {
                        "page": parseInt(JasperMobile.Report.VIS.API.report.pages())
                    });
                })
                .fail(function (error) {
                    JasperMobile.Callback.log("error of navigating to bookmark");
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.navigateToBookmark", {
                        "error": {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.navigateToBookmark", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.VIS.API.report == nil"
                }
            });
        }
    },
    navigateToPage: function(parameters) {
        var page = parameters["page"];
        if (JasperMobile.Report.VIS.API.report) {
            JasperMobile.Report.VIS.API.report
                .pages(page)
                .run()
                .done(function(reportData) {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.navigateToPage", {
                        "page": parseInt(JasperMobile.Report.VIS.API.report.pages())
                    });
                })
                .fail(function (error) {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.navigateToPage", {
                        "error": {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.navigateToPage", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.VIS.API.report == nil"
                }
            });
        }
    },
    exportReport: function(format) {
        if (JasperMobile.Report.VIS.API.report) {
            JasperMobile.Report.VIS.API.report.export({
                outputFormat: format
            }).done(function (link) {
                JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.run", {
                    "link" : link.href
                });
            });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.exportReport", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.VIS.API.report == nil"
                }
            });
        }
    },
    destroyReport: function() {
        if (JasperMobile.Report.VIS.API.report) {
            JasperMobile.Report.VIS.API.report.destroy()
                .done(function() {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.destroyReport", {});
                })
                .fail(function(error) {
                    JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.destroyReport", {
                        "error" : {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.destroyReport", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.VIS.API.report == nil"
                }
            });
        }
    },
    fitReportViewToScreen: function() {
        // var width = 500;
        // var height = 500;

        var body = document.body,
            html = document.documentElement;

        var height = Math.min( body.scrollHeight, body.offsetHeight,
            html.clientHeight, html.scrollHeight, html.offsetHeight );

        var width = Math.min( body.scrollWidth, body.offsetWidth,
            html.clientWidth, html.scrollWidth, html.offsetWidth );

        var container = document.getElementById("container");
        container.width = width;
        container.height = height;
        if (JasperMobile.Report.VIS.API.report != null && JasperMobile.Report.VIS.API.report.resize != undefined) {
            JasperMobile.Report.VIS.API.report.resize();
        }
        JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.fitReportViewToScreen", {
            size: {
                "width"  : width,
                "height" : height
            }
        });
    }
};

// VIZ Dashboards
JasperMobile.Dashboard.API = {
    dashboardObject: {},
    refreshedDashboardObject: {},
    canceledDashboardObject: {},
    dashboardFunction: {},
    selectedDashlet: {}, // DOM element
    selectedComponent: {}, // Model element
    isAmber: false,
    activeLinks: [],
    runDashboard: function(params) {
        var success = params["success"];
        var failed = params["failed"];
        JasperMobile.Dashboard.API.isAmber = params["is_for_6_0"];
        var successFn = function() {

            setTimeout(function(){
                var data = JasperMobile.Dashboard.API.dashboardObject.data();
                if (data.components) {
                    JasperMobile.Dashboard.API._configureComponents(data.components);
                }
                if (JasperMobile.Dashboard.API.isAmber) {
                    JasperMobile.Dashboard.API._defineComponentsClickEventAmber();
                } else {
                    JasperMobile.Dashboard.API._defineComponentsClickEvent();
                }

                JasperMobile.Callback.callback("JasperMobile.Dashboard.API.runDashboard", {
                    "components" : data.components ? data.components : {},
                    "params" : data.parameters
                });

                if (success != "null") {
                    success({
                        "components" : data.components ? data.components : {},
                        "params" : data.parameters
                    });
                }
            }, 6000);

            // hide input controls dashlet if it exists
            var filterGroupNodes = document.querySelectorAll('[data-componentid="Filter_Group"]');
            if (filterGroupNodes.length > 0) {
                var filterGroup = filterGroupNodes[0];
                filterGroup.style.display = "none";
            }
        };
        var errorFn = function(error) {
            JasperMobile.Callback.callback("JasperMobile.Dashboard.API.runDashboard", {
                "error" : {
                    "code" : error.errorCode,
                    "message" : error.message
                }
            });
            if (failed != "null") {
                failed(error);
            }
        };
        var dashboardStruct = {
            resource: params["uri"],
            container: "#container",
            linkOptions: {
                events: {
                    click: function(event, link, defaultHandler) {
                        var type = link.type;
                        JasperMobile.Callback.log("link type: " + type);
                        JasperMobile.Dashboard.API.defaultHandler = defaultHandler;
                        if (JasperMobile.Dashboard.API.isAmber) {
                            // There are cases when the same event goes several times
                            // It looks like a vis bug.
                            var contains = false;
                            for (var i = 0; i < JasperMobile.Dashboard.API.activeLinks.length; ++i) {
                                var currentLink = JasperMobile.Dashboard.API.activeLinks[i];
                                if (currentLink.id == link.id) {
                                    contains = true;
                                    break;
                                }
                            }
                            if (contains) {
                                return;
                            }
                            // save the link temporary to prevent handling it several times
                            JasperMobile.Dashboard.API.activeLinks.push(link);
                            // remove all links after some timeout
                            setTimeout(function() {
                                JasperMobile.Dashboard.API.activeLinks = [];
                            },3000);
                        }
                        switch (type) {
                            case "ReportExecution": {
                                var data = {
                                    resource: link.parameters._report,
                                    params: JasperMobile.Helper.collectReportParams(link)
                                };
                                JasperMobile.Callback.listener("JasperMobile.Dashboard.API.run.linkOptions.events.ReportExecution", {
                                    "data" : data
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
                                JasperMobile.Callback.listener("JasperMobile.Dashboard.API.run.linkOptions.events.Reference", {
                                    "location" : href
                                });
                                break;
                            }
                            case "AdHocExecution": {
                                if (defaultHandler == undefined) {
                                    JasperMobile.Callback.listener("JasperMobile.Dashboard.API.run.linkOptions.events.AdHocExecution", {
                                        "link" : link
                                    });
                                } else {
                                    defaultHandler.call();
                                }
                                break;
                            }
                            default: {
                                defaultHandler.call();
                            }
                        }
                    }
                }
            },
            success: successFn,
            error: errorFn
        };
        var auth = {};

        if (JasperMobile.Dashboard.API.isAmber) {
            auth.auth = {
                loginFn: function(properties, request) {
                    return (new jQuery.Deferred()).resolve();
                }
            };
        } else {
            dashboardStruct.report =  {
                chart: {
                    animation: false,
                        zoom: false
                }
            };
        }

        var dashboardFn = function (v) {
            // save link for dashboardObject
            JasperMobile.Dashboard.API.dashboardFunction = v.dashboard;
            JasperMobile.Dashboard.API.dashboardObject = JasperMobile.Dashboard.API.dashboardFunction(dashboardStruct);
        };

        visualize(auth, dashboardFn, errorFn);
    },
    getDashboardParameters: function() {
        var data = JasperMobile.Dashboard.API.dashboardObject.data();
        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.getDashboardParameters", {
            "components" : data.components,
            "params" : data.parameters
        });
    },
    minimizeDashlet: function(parameters) {
        var dashletId = parameters["identifier"];
        if (dashletId != "null") {
            if (JasperMobile.Dashboard.API.isAmber) {
                JasperMobile.Dashboard.API.minimizeDashletForAmber();
            } else {
                JasperMobile.Dashboard.API.dashboardObject.updateComponent(dashletId, {
                    maximized: false,
                    interactive: false
                }).done(function() {
                    setTimeout(function(){
                        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.minimizeDashlet", {
                            "component" : dashletId
                        });
                    }, 3000);
                }).fail(function(error) {
                    JasperMobile.Callback.log("failed refresh with error: " + error);
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.minimizeDashlet", {
                        "error" : {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
            }
        } else {
            if (JasperMobile.Dashboard.API.isAmber) {
                JasperMobile.Dashboard.API.minimizeDashletForAmber();
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
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.minimizeDashlet", {
                        "error" : {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
            }
        }
    },
    minimizeDashletForAmber: function() {
        var canvasOverlay = document.getElementsByClassName("canvasOverlay")[0];
        if (canvasOverlay != null && canvasOverlay.nodeName == "DIV") {
            var minimizeButton = canvasOverlay.getElementsByClassName("minimizeDashlet")[0];
            if (minimizeButton != null && minimizeButton.nodeName == "BUTTON") {
                minimizeButton.click();
                JasperMobile.Dashboard.API._enableClicks();
                setTimeout(function(){
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.minimizeDashlet", {});
                }, 3000);
            } else {
                JasperMobile.Callback.callback("JasperMobile.Dashboard.API.minimizeDashlet", {
                    "error" : {
                        "code" : "maximize.button.error",
                        "message" : "Component is not ready"
                    }
                });
            }
        } else {
            JasperMobile.Callback.callback("JasperMobile.Dashboard.API.minimizeDashlet", {
                "error" : {
                    "code" : "maximize.button.error",
                    "message" : "Component is not ready"
                }
            });
        }
    },
    maximizeDashlet: function(parameters) {
        var dashletId = parameters["identifier"];
        if (dashletId) {
            if (JasperMobile.Dashboard.API.isAmber) {
                JasperMobile.Dashboard.API.maximizeDashletForAmber(dashletId);
            } else {
                JasperMobile.Dashboard.API.dashboardObject.updateComponent(dashletId, {
                    maximized: true,
                    interactive: true
                }).done(function() {
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.maximizeDashlet", {
                        "component" : dashletId
                    });
                }).fail(function(error) {
                    JasperMobile.Callback.log("failed refresh with error: " + error);
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.maximizeDashlet", {
                        "error" : {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
            }
        } else {
            JasperMobile.Callback.log("Trying maximize dashelt without 'id'");
        }
    },
    maximizeDashletForAmber: function(dashletId) {
        var maximizeButton = JasperMobile.Dashboard.API._findDashletMaximizeButtonWithDashletId(dashletId);
        if (maximizeButton != null) {
            if (maximizeButton.disabled) {
                JasperMobile.Callback.callback("JasperMobile.Dashboard.API.events.dashlet.didEndMaximize", {
                    "error" : {
                        "code" : "maximize.button.error",
                        "message" : "Component is not ready"
                    }
                });
            } else {
                JasperMobile.Callback.listener("JasperMobile.Dashboard.API.events.dashlet.didStartMaximize", {
                    "component" : dashletId
                });
                maximizeButton.click();
                setTimeout(function(){
                    JasperMobile.Callback.listener("JasperMobile.Dashboard.API.events.dashlet.didEndMaximize", {
                        "component" : dashletId
                    });
                }, 3000);
            }
        } else {
            JasperMobile.Callback.log("There is not maximize button");
        }
    },
    _findDashletMaximizeButtonWithDashletId: function(dashletId) {
        console.log("dashletId: " + dashletId);
        var allNodes = document.querySelector(".dashboardCanvas > div > div").childNodes;
        var maximizeButton = null;
        for (var i = 0; i < allNodes.length; i++) {
            var nodeElement = allNodes[i];
            console.log("nodeElement: " + nodeElement);
            var componentId = nodeElement.attributes["data-componentid"].value;
            console.log("componentId: " + componentId);
            if (componentId == dashletId) {
                console.log("found node: " + nodeElement);
                maximizeButton = nodeElement.getElementsByClassName("maximizeDashletButton")[0];
                break;
            }
        }
        return maximizeButton;
    },
    refresh: function() {
        JasperMobile.Callback.log("start refresh");
        JasperMobile.Callback.log("dashboard object: " + JasperMobile.Dashboard.API.dashboardObject);
        JasperMobile.Dashboard.API.refreshedDashboardObject = JasperMobile.Dashboard.API.dashboardObject.refresh()
            .done(function() {
                JasperMobile.Callback.log("done refresh");
                var data = JasperMobile.Dashboard.API.dashboardObject.data();
                setTimeout(function() {
                    JasperMobile.Callback.log("state: " + JasperMobile.Dashboard.API.refreshedDashboardObject.state());
                    if (JasperMobile.Dashboard.API.refreshedDashboardObject.state() === "rejected") {
                        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refresh", {
                            "error" : {
                                "code" : "dashboard.refresh.rejected",
                                "message" : "Refresh was rejected"
                            }
                        });
                    } else if (JasperMobile.Dashboard.API.refreshedDashboardObject.state() === "pending") {
                        // TODO: update handling this case
                        var uri = JasperMobile.Dashboard.API.dashboardObject.properties().resource;
                        JasperMobile.Dashboard.API.dashboardObject.destroy();
                        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refresh", {
                            "error" : {
                                "code" : "dashboard.refresh.pending",
                                "message" : "Refresh was pended"
                            }
                        });
                    } else if (JasperMobile.Dashboard.API.refreshedDashboardObject.state() === "resolved") {
                        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refresh", {
                            "components" : data.components,
                            "params" : data.parameters
                        });
                    } else {
                        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refresh", {
                            "error" : {
                                "code" : "dashboard.refresh.undefined",
                                "message" : "Refresh failed with 'undefied' error"
                            }
                        });
                    }
                }, 3000);
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed refresh with error: " + error);
                if (error.errorCode == "authentication.error") {
                    JasperMobile.Dashboard.API.dashboardObject.destroy();
                    setTimeout(function () {
                        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refresh", {
                            "error" : {
                                "code" : error.errorCode,
                                "message" : error.message
                            }
                        });
                    }, 3000);
                } else {
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refresh", {
                        "error" : {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                }
            });
    },
    cancel: function() {
        JasperMobile.Callback.log("start cancel");
        JasperMobile.Callback.log("dashboard object: " + JasperMobile.Dashboard.API.dashboardObject);
        JasperMobile.Dashboard.API.canceledDashboardObject = JasperMobile.Dashboard.API.dashboardObject.cancel()
            .done(function() {
                JasperMobile.Callback.log("success cancel");
                JasperMobile.Callback.callback("JasperMobile.Dashboard.API.cancel", {});
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed cancel with error: " + error);
                JasperMobile.Callback.callback("JasperMobile.Dashboard.API.cancel", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
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
                JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refreshDashlet", {
                    "components" : data.components,
                    "params" : data.parameters,
                    "isFullReload" : "false"
                });
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed refresh dashlet with error: " + error);
                JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refreshDashlet", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            });
        setTimeout(function() {
            JasperMobile.Callback.log("state: " + JasperMobile.Dashboard.API.refreshedDashboardObject.state());
            if (JasperMobile.Dashboard.API.refreshedDashboardObject.state() === "pending") {
                var uri = JasperMobile.Dashboard.API.dashboardObject.properties().resource;
                JasperMobile.Dashboard.API.dashboardObject.cancel();
                JasperMobile.Dashboard.API.runDashboard({
                    "uri" : uri,
                    success: function() {
                        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.refreshDashlet", {
                            "isFullReload": "true"
                        });
                    },
                    failed: function(error) {
                        if (error.errorCode == "authentication.error") {
                            JasperMobile.Callback.listener("JasperMobile.Dashboard.API.unauthorized", {});
                        } else {
                            // TODO: handle this.
                        }
                    }
                });
            }
        }, 6000);
    },
    applyParams: function(parameters) {
        JasperMobile.Dashboard.API.dashboardObject.params(parameters).run()
            .done(function() {
                setTimeout(function(){
                    var data = JasperMobile.Dashboard.API.dashboardObject.data();
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.applyParams", {
                        "components" : data.components,
                        "params" : data.parameters
                    });
                }, 3000);
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed apply");
                JasperMobile.Callback.callback("JasperMobile.Dashboard.API.applyParams", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            });
    },
    destroy: function() {
        if (JasperMobile.Dashboard.API.dashboardObject) {
            JasperMobile.Dashboard.API.dashboardObject.destroy()
                .done(function() {
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.destroy", {});
                })
                .fail(function(error) {
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.destroy", {
                        "error" : {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Dashboard.API.destroy", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Dashboard.API.dashboardObject == nil"
                }
            });
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
                    JasperMobile.Callback.listener("JasperMobile.Dashboard.API.events.dashlet.didStartMaximize", {
                        "component" : component
                    });
                    JasperMobile.Dashboard.API.selectedDashlet.className += "originalDashletInScaledCanvas";
                    JasperMobile.Dashboard.API.dashboardObject.updateComponent(id, {
                        maximized: true,
                        interactive: true
                    }, function() {
                        JasperMobile.Dashboard.API.selectedComponent = component;
                        setTimeout(function(){
                            JasperMobile.Callback.listener("JasperMobile.Dashboard.API.events.dashlet.didEndMaximize", {
                                "component" : component
                            });
                        }, 3000);
                    }, function(error) {
                        JasperMobile.Callback.callback("JasperMobile.Dashboard.API.events.dashlet.didEndMaximize", {
                            "error" : {
                                "code" : error.errorCode,
                                "message" : error.message
                            },
                            "component" : component
                        });
                    });
                }
            };
        }
    },
    _defineComponentsClickEventAmber: function() {
        var allNodes = document.querySelector(".dashboardCanvas > div > div").childNodes;
        for (var i = 0; i < allNodes.length; i++) {
            var nodeElement = allNodes[i];
            var componentId = nodeElement.attributes["data-componentid"].value;
            if (componentId == "Filter_Group") {
                // JasperMobile.Callback.log("Filter_Group");
            } else if (componentId == "Text") {
                // JasperMobile.Callback.log("Text");
            } else {
                // JasperMobile.Callback.log("componentId: " + componentId);
                (function(nodeElement, componentId) {
                    JasperMobile.Dashboard.API._configureDashletForAmber(nodeElement, componentId);
                })(nodeElement, componentId);
            }
        }
    },
    _configureDashletForAmber: function(dashletWrapper, componentId) {
        var dashletContent = dashletWrapper.getElementsByClassName("dashletContent")[0];
        if (dashletContent.nodeName == "DIV") {
            // create overlay
            var overlay = document.createElement("div");
            overlay.style.opacity = 1;
            overlay.style.zIndex = "1000";
            overlay.style.position = "absolute";
            overlay.style.height = "100%";
            overlay.style.width = "100%";
            overlay.className = "dashletOverlay";
            dashletContent.insertBefore(overlay, dashletContent.childNodes[0]);

            // hide dashlet toolbar
            // var dashletToolbarNodes = dashletContent.getElementsByClassName("dashletToolbar");
            // if (dashletToolbarNodes.length > 0) {
            //     var dashletToolbar = dashletToolbarNodes[0];
            //     dashletToolbar.style.display = "none";
            // }

            // add click listener
            overlay.addEventListener("click", function(event) {
                var maximizeButton = dashletWrapper.getElementsByClassName("maximizeDashletButton")[0];
                if (maximizeButton != undefined &&  maximizeButton.nodeName == "BUTTON" && !maximizeButton.disabled) {
                    JasperMobile.Callback.listener("JasperMobile.Dashboard.API.events.dashlet.didStartMaximize", {});
                    maximizeButton.click();
                    JasperMobile.Dashboard.API._disableClicks();
                    setTimeout(function(){
                        JasperMobile.Callback.listener("JasperMobile.Dashboard.API.events.dashlet.didEndMaximize", {
                            "componentId" : componentId
                        });
                    }, 3000);
                } else {
                    JasperMobile.Callback.callback("JasperMobile.Dashboard.API.events.dashlet.didEndMaximize", {
                        "error" : {
                            "code" : "maximize.button.error",
                            "message" : "Component is not ready"
                        }
                    });
                }
            });
        } else {
            JasperMobile.Callback.callback("JasperMobile.Dashboard.API.events.dashlet.didEndMaximize", {
                "error" : {
                    "code" : "maximize.button.error",
                    "message" : "Component is not ready"
                }
            });
        }
    },
    _disableClicks: function() {
        var overlays = document.getElementsByClassName("dashletOverlay");
        if (overlays != undefined) {
            for (var i = 0; i < overlays.length; i++) {
                var overlay = overlays[i];
                overlay.style.pointerEvents = "none";
            }
        }
    },
    _enableClicks: function() {
        var overlays = document.getElementsByClassName("dashletOverlay");
        if (overlays != undefined) {
            for (var i = 0; i < overlays.length; i++) {
                var overlay = overlays[i];
                overlay.style.pointerEvents = "auto";
            }
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
    }
};

// Start Point
document.addEventListener("DOMContentLoaded", function(event) {
    JasperMobile.Callback.listener("DOMContentLoaded", null);

    // intercepting network calls
    XMLHttpRequest.prototype.reallySend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.send = function(body) {
        JasperMobile.Callback.log("send body: " + body);
        this.reallySend(body);
    };
});

window.onerror = function myErrorHandler(message, source, lineno, colno, error) {
    JasperMobile.Callback.listener("JasperMobile.Events.Window.OnError", {
        "error" : {
            "code" : "window.onerror",
            "message" : message + " " + source + " " + lineno + " " + colno + " " + error,
            "source" : source
        }
    });
    // run default handler
    return false;
};