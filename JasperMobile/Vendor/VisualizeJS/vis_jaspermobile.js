
var JasperMobile = {
    Report : {},
    Dashboard : {},
    Callback: {},
    Helper : {
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
                scriptTag.onload = success;
                scriptTag.onError = error;
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
        removeItemsFromContainer: function() {
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
        },
        cleanEnvironment: function() {
            document.body.innerHTML = "<div id='container'></div>";
            this.removeScripts();
            visualize = undefined;
        },
        removeScripts: function() {
            var scriptTag = document.getElementsByTagName('script');
            //var src;

            for (var i = 0; i < scriptTag.length; i++) {
                //src = scriptTag[i].src;
                scriptTag[i].parentNode.removeChild(scriptTag[i]);
            }
        },
        sizeOfWindow: function() {
            var body = document.body,
                html = document.documentElement;

            var height = Math.min( body.scrollHeight, body.offsetHeight,
                html.clientHeight, html.scrollHeight, html.offsetHeight );

            var width = Math.min( body.scrollWidth, body.offsetWidth,
                html.clientWidth, html.scrollWidth, html.offsetWidth );
            return {
                width: width,
                height: height
            };
        },
        createDivElement: function(name, styles) {
            var divElement = document.createElement('div');
            divElement.id = name;
            for (var styleName in styles) {
                if (!styles.hasOwnProperty(styleName)) continue;
                divElement.style.styleName = styles[styleName];
            }
            document.body.appendChild(divElement);
        },
        removeDivElement: function(name) {
            var divElement = document.getElementById(name);
            document.body.removeChild(divElement);
        },
        existDivElement: function(name) {
            return document.getElementById(name) != undefined;
        }
    }
};

// Callbacks
JasperMobile.Callback = {
    createCallback: function(params) {
        window.webkit.messageHandlers.JMJavascriptNativeBridge.postMessage(params);
    },
    log : function(message) {
        console.log("Log: " + message);
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
            JasperMobile.Helper.removeItemsFromContainer();
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
            document.body.innerHTML = "<div id='container'></div>";
            var container = document.getElementById("container");
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
JasperMobile.Report.VIS = {
    activeReport: undefined,
    manager: {
        reports: {},
        containerManager: {
            activeContainer: undefined,
            defaultContainer: {
                name : "container",
                isActive : true
            },
            nextIndexToFree : 0,
            containers : undefined,
            setContainers: function(parameters) {
                this.containers = parameters["containers"];
                for (var i = 0; i < this.containers.length; ++i) {
                    var container = this.containers[i];
                    JasperMobile.Helper.createDivElement(container.name, {
                        "width" : "100%",
                        "height" : "100%",
                        "margin" : "0 auto"
                    });
                }
            },
            chooseDefaultContainer: function() {
                if (!JasperMobile.Helper.existDivElement(this.defaultContainer.name)) {
                    this.createDefaultContainer();
                }
                this.activeContainer = this.defaultContainer;
            },
            createDefaultContainer: function() {
                var containerName = JasperMobile.Report.VIS.manager.containerManager.defaultContainer;
                JasperMobile.Helper.createDivElement(containerName.name, {
                    "width" : "100%",
                    "height" : "100%",
                    "margin" : "0 auto"
                });
            },
            removeDefaultContainer: function() {
                JasperMobile.Helper.removeDivElement(this.defaultContainer.name);
            },
            changeActiveContainer: function() {
                if (this.activeContainer == undefined) {
                    this.activeContainer = this.containers[0];
                } else {
                    var nextContainer = this.nextContainer();
                    this.hideContainer(this.activeContainer);
                    this.showContainer(nextContainer);
                    this.activeContainer = nextContainer;
                }
                this.activeContainer.isActive = true;
            },
            nextContainer: function() {
                var currentIndex = this.containers.indexOf(this.activeContainer);
                var nextContainer = this.findInactiveContainer();

                // there isn't any free spot,
                if (nextContainer == undefined) {
                    var containerToFree = this.containers[this.nextIndexToFree];
                    JasperMobile.Report.VIS.manager.removeReportInContainer(containerToFree, function() {
                        JasperMobile.Callback.log("report was removed");
                    });

                    // chage next index
                    if (++this.nextIndexToFree == this.containers.length) {
                        this.nextIndexToFree = 0;
                    }
                    nextContainer = containerToFree;
                }
                return nextContainer;
            },
            findInactiveContainer: function() {
                var inActiveContainer = undefined;
                var container = undefined;
                for (var i = 0; i < this.containers.length; i++) {
                    container = this.containers[i];
                    if (container.isActive) {
                        continue;
                    } else {
                        inActiveContainer = container;
                        break;
                    }
                }
                return inActiveContainer;
            },
            hideContainer: function(container) {
                var element = document.getElementById(container.name);
                element.style.display = "none";
            },
            showContainer: function(container) {
                var element = document.getElementById(container.name);
                element.style.display = "block";
            },
            clearContainer: function(container) {
                var containerElement = document.getElementById(container.name);
                containerElement.innerHTML = "";
            },
            reset: function() {
                if (this.containers == undefined) {
                    return;
                }
                for(var i = 0; i < this.containers.length; ++i) {
                    var container = this.containers[i];
                    container.isActive = false;
                }
                this.nextIndexToFree = 0;
            }
        },
        addReport:function(object) {
            var report = this.createReport(object);
            report.container = this.containerManager.activeContainer;
            var uri = report.object.resource();
            report.uri = uri;
            JasperMobile.Report.VIS.activeReport = report;
            this.reports[uri] = report;
        },
        removeReportInContainer: function(container, success) {
            var report = this.findReportInContainer(container);
            if (report != undefined) {
                delete this.reports[report.uri];
                report.destroy(success);
            } else {
                // TODO: show error
                JasperMobile.Callback.log("error of finding report in container");
            }
        },
        findReportInContainer: function(container) {
            var reportInContainer = undefined;
            for (var reportURI in this.reports) {
                if (!this.reports.hasOwnProperty(reportURI)) continue;

                var report = this.reports[reportURI];
                if (report.container.name == container.name) {
                    reportInContainer = report;
                    break;
                }
            }
            return reportInContainer;
        },
        removeAllReports: function() {
            for (var reportURI in this.reports) {
                if (!this.reports.hasOwnProperty(reportURI)) continue;

                var report = this.reports[reportURI];
                (function(self, report){
                    report.destroy(
                        function () {
                            JasperMobile.Callback.log("report was destroyed at: " + report.uri);
                        },
                        function(error){
                            self.containerManager.clearContainer(report.container);
                            JasperMobile.Callback.log("error while destroying report: " + report.uri);
                            JasperMobile.Callback.log("error: " + JSON.stringify(error));
                        })
                })(this, report);
            }
            this.reports = {};
        },
        createReport: function(object) {
            return {
                object: object,
                container: undefined,
                uri: undefined,
                totalPages: function() {
                    return this.object.data().totalPages;
                },
                pages: function() {
                    return this.object.pages();
                },
                bookmarks: function() {
                    return this.object.data().bookmarks;
                },
                parts: function() {
                    return this.object.data().reportParts;
                },
                destroy: function(success, fail) {
                    JasperMobile.Report.VIS.privateAPI.executeOperation(
                        this,
                        "destroy",
                        null,
                        success,
                        fail
                    );
                }
            };
        },
        containsReport: function(uri) {
            return (this.reports[uri] != undefined);
        },
        setActiveReport: function(uri) {
            JasperMobile.Report.VIS.activeReport = this.reports[uri];
            this.containerManager.showContainer(JasperMobile.Report.VIS.activeReport.container);
        }
    },
    API: {},
    privateAPI: {},
    Helpers : {},
    Handlers: {
        Hyperlinks : {}
    },
    reset: function() {
        this.activeReport = undefined;
        this.manager.containerManager.reset();
        this.manager.removeAllReports();
    }
};
JasperMobile.Report.VIS.Helpers = {
    isAmber: false,
    initReportStructWithParameters: function(parameters) {
        JasperMobile.Report.VIS.Helpers.isAmber = parameters["is_for_6_0"]; // TODO: replace with switch
        var report;
        if (this.isAmber) {
            report = this.baseStructFn(parameters);
        } else {
            report = this.structFn(parameters);
        }
        return report;
    },
    runFn: function(params) {
        var self = this;
        return function(v) {
            // TODO: where to get container? manager?
            //params["container"] = "container";
            var reportObject = v.report(self.initReportStructWithParameters(params));
            if (JasperMobile.Report.VIS.manager.containerManager.containers != undefined &&
                JasperMobile.Report.VIS.manager.containerManager.containers.length > 0) {
                // save report object
                JasperMobile.Report.VIS.manager.addReport(reportObject);
            } else {
                var report = JasperMobile.Report.VIS.manager.createReport(reportObject);
                report.container = JasperMobile.Report.VIS.manager.containerManager.activeContainer;
                JasperMobile.Report.VIS.activeReport = report;
            }
        };
    },
    structFn: function(parameters) {
        var struct = this.baseStructFn(parameters);
        struct.autoresize = false;
        struct.chart = {
            animation : false,
            zoom : false
        };
        return struct;
    },
    baseStructFn: function(parameters) {
        var self = this;
        var container = JasperMobile.Report.VIS.manager.containerManager.activeContainer.name;
        return {
            resource: parameters["uri"],
            params: parameters["params"],
            pages: parameters["pages"],
            scale: "width",
            container: "#" + container,
            success: self.success,
            error: self.failed,
            events: self.events,
            linkOptions: {
                events: {
                    "click" : self.linkOptionsEventsClick
                }
            }
        };
    },
    success: function(reportData) {
        var status = "undefined";
        if (JasperMobile.Report.VIS.activeReport.totalPages() == undefined) {
            status = "inProgress";
        } else {
            status = "ready";
        }
        JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.run", {
            "status"      : status,
            "pages"       : JasperMobile.Report.VIS.activeReport.pages(),
            "totalPages"  : JasperMobile.Report.VIS.activeReport.totalPages(),
            "bookmarks"   : JasperMobile.Report.VIS.activeReport.bookmarks(),
            "parts"       : JasperMobile.Report.VIS.activeReport.parts()
        });
    },
    failed: function(error) {
        JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.run", {
            "error" : {
                "code"    : error.errorCode,
                "message" : error.message
            }
        });
    },
    events: {
        reportCompleted: function(status, error) {
            JasperMobile.Callback.log("Event: reportCompleted");
            if (status == "ready") {
                JasperMobile.Callback.listener("JasperMobile.Report.Event.reportCompleted", {
                    "status" : status,
                    "pages" : JasperMobile.Report.VIS.activeReport.totalPages()
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
            JasperMobile.Callback.log("Event: pageFinal");
        }
    },
    linkOptionsEventsClick: function(event, link) {
        var type = link.type;
        switch (type) {
            case "ReportExecution": {
                JasperMobile.Report.VIS.Handlers.Hyperlinks.handleReportExecution(link);
                break;
            }
            case "LocalAnchor": {
                JasperMobile.Report.VIS.Handlers.Hyperlinks.handleLocalAnchor(link);
                break;
            }
            case "LocalPage": {
                JasperMobile.Report.VIS.Handlers.Hyperlinks.handleLocalPage(link);
                break;
            }
            case "Reference": {
                JasperMobile.Report.VIS.Handlers.Hyperlinks.handleReference(link);
                break;
            }
            case "RemoteAnchor": {
                JasperMobile.Report.VIS.Handlers.Hyperlinks.handleRemoteAnchor(link);
                break;
            }
            case "RemotePage": {
                JasperMobile.Report.VIS.Handlers.Hyperlinks.handleRemotePage(link);
                break;
            }
            default: {
                JasperMobile.Callback.log("unknown hyperlink : " + JSON.stringify(link));
            }
        }
    },
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
    authFn: function() {
        if (this.isAmber) {
            return this.authForAmber;
        } else {
            return this.baseAuth;
        }
    },
    baseAuth: {},
    authForAmber: {
        auth : {
            loginFn: function(properties, request) {
                return (new jQuery.Deferred()).resolve();
            }
        }
    }
};
JasperMobile.Report.VIS.Handlers.Hyperlinks = {
    handleReportExecution: function(link) {
        var data = {
            resource: link.parameters._report,
            params: JasperMobile.Report.VIS.Helpers.collectReportParams(link)
        };
        JasperMobile.Callback.log("Event: linkOption - ReportExecution");
        JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.ReportExecution", {
            "data" : data
        });
    },
    handleLocalAnchor: function(link) {
        var parameters = {
            "destination":{
                anchor:link.anchor
            }
        };
        JasperMobile.Report.VIS.privateAPI.executeOperation(undefined, "navigateTo", parameters,
            function(data) {
                JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.LocalAnchor", {
                    "destination" : link.pages
                });
            },
            function(error) {
                JasperMobile.Callback.log(error);
            });
    },
    handleLocalPage: function(link) {
        var parameters = {
            "destination": link.pages
        };
        JasperMobile.Report.VIS.privateAPI.executeOperation(undefined, "navigateTo", parameters,
            function(data) {
                JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.LocalPage", {
                    "destination" : link.pages
                });
            },
            function(error) {
                JasperMobile.Callback.log(error);
            });
    },
    handleReference: function(link) {
        var href = link.href;
        JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.Reference", {
            "destination" : href
        });
    },
    handleRemoteAnchor: function(link) {
        JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.RemoteAnchor", {
            "link" : link
        });
    },
    handleRemotePage: function (link) {
        JasperMobile.Callback.listener("JasperMobile.Report.VIS.API.Event.Link.RemotePage", {
            "link" : link
        });
    }
};
JasperMobile.Report.VIS.privateAPI = {
    executeOperation: function(report, operation, parameters, success, fail) {
        if (report == undefined) {
            report = JasperMobile.Report.VIS.activeReport
        }
        var request = "JasperMobile.Report.VIS.API." + operation;
        if (fail == undefined) {
            fail = function(error) {
                JasperMobile.Callback.callback(request, {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            }
        }
        if (report) {
            if( typeof(this[operation]) == "function" ) {
                this[operation](
                    report,
                    parameters,
                    success,
                    fail
                );
            } else {
                JasperMobile.Callback.log("Wrong operation: " + JSON.stringify(operation));
            }
        } else {
            JasperMobile.Callback.callback(request, {
                "error": {
                    "code" : "visualize.error",
                    "message" : "Report object is not exist!"
                }
            });
        }
    },
    cancel : function(report, parameters, success, fail) {
        report.object.cancel()
            .done(success)
            .fail(fail);
    },
    refresh: function(report, parameters, success, fail) {
        report.object.refresh()
            .done(success)
            .fail(fail);
    },
    navigateTo: function (report, parameters, success, fail) {
        report.object.pages(parameters.destination).run()
            .done(success)
            .fail(fail);
    },
    updateReportWithParameters: function(report, parameters, success, fail) {
        report.object.params(parameters).run()
            .done(success)
            .fail(fail);
    },
    destroy: function(report, parameters, success, fail) {
        report.object.destroy()
            .done(success)
            .fail(fail);
    },
    fitReportViewToScreen: function(report, parameters, success, fail) {
        var container = document.getElementById(report.container.name);
        container.width = JasperMobile.Helper.sizeOfWindow().width;
        container.height = JasperMobile.Helper.sizeOfWindow().height;
        if (report.object != undefined && typeof(report.object.resize) == "function") {
            report.object.resize();
            success({
                "width"  : container.width,
                "height" : container.height
            });
        } else {
            fail({
                "code" : "undefined",
                "message" : "Report Object isn't exist or 'resize' doesn't available"
            });
        }
    }
};
JasperMobile.Report.VIS.API = {
    run: function(params) {
        if (JasperMobile.Report.VIS.manager.containsReport(params["uri"])) {
            JasperMobile.Report.VIS.manager.setActiveReport(params["uri"]);
            if (JasperMobile.Report.VIS.activeReport.pages() == 1) {
                JasperMobile.Report.VIS.Helpers.success(JasperMobile.Report.VIS.activeReport.object.data());
            } else {
                this.navigateTo(
                    {"destination" : 1},
                    JasperMobile.Report.VIS.Helpers.success
                );
            }
        } else {
            if (JasperMobile.Report.VIS.manager.containerManager.containers != undefined &&
                JasperMobile.Report.VIS.manager.containerManager.containers.length > 0) {
                // Choose other container
                JasperMobile.Report.VIS.manager.containerManager.changeActiveContainer();
            } else {
                JasperMobile.Report.VIS.manager.containerManager.chooseDefaultContainer();
            }
            visualize(
                JasperMobile.Report.VIS.Helpers.authFn(),
                JasperMobile.Report.VIS.Helpers.runFn(params),
                JasperMobile.Report.VIS.Helpers.failed
            );
        }
    },
    refresh: function(success) {
        if (typeof(success) != "function") {
            success = function(status) {
                JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.refresh", {
                    "status": status,
                    "totalPages": JasperMobile.Report.VIS.activeReport.totalPages()
                });
            };
        }
        JasperMobile.Report.VIS.privateAPI.executeOperation(
            undefined,
            "refresh",
            undefined,
            success
        );
    },
    applyReportParams: function(parameters, success) {
        if (typeof(success) != "function") {
            success = function(reportData) {
                JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.applyReportParams", {
                    "pages": reportData.totalPages
                });
            };
        }
        JasperMobile.Report.VIS.privateAPI.executeOperation(
            undefined,
            "updateReportWithParameters",
            parameters,
            success
        );
    },
    navigateTo: function(parameters, success) {
        if (typeof(success) != "function") {
            success = function(data) {
                JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.navigateTo", {
                    "destination": JasperMobile.Report.VIS.activeReport.pages()
                });
            };
        }
        JasperMobile.Report.VIS.privateAPI.executeOperation(
            undefined,
            "navigateTo",
            parameters,
            success
        );
    },
    cancel: function(success) {
        if (typeof(success) != "function") {
            success = function() {
                JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.cancel", {});
            };
        }
        JasperMobile.Report.VIS.privateAPI.executeOperation(
            undefined,
            "cancel",
            undefined,
            success
        );
    },
    destroy: function() {
        if (JasperMobile.Report.VIS.manager.containerManager.containers != undefined &&
            JasperMobile.Report.VIS.manager.containerManager.containers.length > 0) {
            JasperMobile.Report.VIS.manager.containerManager.hideContainer(JasperMobile.Report.VIS.activeReport.container);
            JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.destroy", {});
        } else {
            JasperMobile.Report.VIS.activeReport.destroy(function() {
                JasperMobile.Report.VIS.manager.containerManager.activeContainer = undefined;
                JasperMobile.Report.VIS.activeReport = undefined;
                JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.destroy", {});
            });
        }
    },
    fitReportViewToScreen: function(success) {
        if (typeof(success) != "function") {
            success = function(size) {
                JasperMobile.Callback.callback("JasperMobile.Report.VIS.API.fitReportViewToScreen", {
                    "size" : size
                });
            };
        }
        JasperMobile.Report.VIS.privateAPI.executeOperation(
            undefined,
            "fitReportViewToScreen",
            null,
            success
        );
    }
};

// Dashboards
JasperMobile.Dashboard = {
    Legacy : {},
    // Move to this from JasperMobile.Dashboard.API
    VIS  : {}
};

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

JasperMobile.Dashboard.Legacy.API = {
    dashboardFlowURI: "flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=",
    runDashboard: function(parameters) {
        var baseURL = parameters["baseURL"];
        var resourceURI = parameters["resourceURI"];
        var url = baseURL + JasperMobile.Dashboard.Legacy.API.dashboardFlowURI + resourceURI;
        JasperMobile.Dashboard.Legacy.API.loadDashboard(
            url,
            function() {
                JasperMobile.Callback.callback("JasperMobile.Dashboard.Legacy.API.runDashboard", {});
            },
            function(error) {
                JasperMobile.Callback.callback("JasperMobile.Dashboard.Legacy.API.runDashboard", {
                    "error" : error
                });
            }
        );
    },
    refresh: function(parameters) {
        var baseURL = parameters["baseURL"];
        var resourceURI = parameters["resourceURI"];
        var url = baseURL + JasperMobile.Dashboard.Legacy.API.dashboardFlowURI + resourceURI;
        JasperMobile.Dashboard.Legacy.API.loadDashboard(
            url,
            function() {
                JasperMobile.Callback.callback("JasperMobile.Dashboard.Legacy.API.refresh", {});
            },
            function(error) {
                JasperMobile.Callback.callback("JasperMobile.Dashboard.Legacy.API.refresh", {
                    "error" : error
                });
            }
        );
    },
    loadDashboard: function(URL, success, failure) {
        JasperMobile.Callback.log("loadDashboard with URL: " + URL);
        JasperMobile.Callback.log("container: " + document.getElementById("container"));
        // There could be more than 1 time events on login.html
        var authErrorWasSent = false;
        var windowWidth = window.innerWidth;

        var xmlhttp = new XMLHttpRequest();

        xmlhttp.onreadystatechange = function() {
            var responseURL = xmlhttp.responseURL;
            JasperMobile.Callback.log("responseURL: " + responseURL);
            if (responseURL.indexOf("login.html") > -1 && !authErrorWasSent) {
                authErrorWasSent = true;
                xmlhttp.abort();
                failure({
                    "code" : "authentication.error",
                    "message" : "Authentication error"
                });
                return;
            }

            if (xmlhttp.readyState == XMLHttpRequest.DONE) {
                if (xmlhttp.status == 200) {
                    JasperMobile.Callback.log("done of loading html");
                    var bodyWidth = document.width;
                    var container = jQuery(document.body);
                    container.attr('id', 'dashboardViewer');
                    container.html(xmlhttp.responseText).promise().done(function(){
                        JasperMobile.Callback.log("html was added to container");
                    });
                    setTimeout(function() {
                        var scale = "scale(" + parseInt(windowWidth) / parseInt(document.width) + ")";
                        var origin = "0% 0%";
                        JasperMobile.Helper.updateTransformStyles(document.body, scale, origin);
                        success();
                    }, 3000);
                } else {
                    JasperMobile.Callback.log("xmlhttp.status: " + xmlhttp.status);
                }
            }
        };
        xmlhttp.open("GET", URL, true);
        xmlhttp.send();
    },
    cancel: function() {

    },
    destroy: function() {
        JasperMobile.Dashboard.Legacy.API.destroyDashboard(function() {
            JasperMobile.Callback.callback("JasperMobile.Dashboard.Legacy.API.destroy", {});
        });
    },
    destroyDashboard: function(completion) {
        document.body.innerHTML = "";
        document.body.id = "";
        JasperMobile.Helper.resetBodyTransformStyles();
        setTimeout(function() {
            completion();
        }, 500);
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
}, false);

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