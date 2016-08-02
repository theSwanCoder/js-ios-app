
var JasperMobile = {
    VIS : {},
    REST : {},
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
                    var success = function() {
                        if (--callbacksCount == 0) {
                            JasperMobile.Callback.callback("JasperMobile.Helper.loadScripts", {});
                        }
                    };
                    var failed = function(error) {
                        JasperMobile.Callback.log("Error of loading script: " + JSON.stringify(error));
                    };
                    JasperMobile.Helper.addScript(scriptURL, success, failed);
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
        createDivElement: function(id, styles) {
            var divElement = document.createElement('div');
            divElement.id = id;
            document.body.appendChild(divElement);
            this.addStylesToElement(id, styles);
        },
        addStylesToElement: function(id, styles) {
            var style = document.createElement('style');
            style.type = 'text/css';
            var innerHTML = "#" + id + "{\n";
            for (var styleName in styles) {
                if (!styles.hasOwnProperty(styleName)) continue;
                innerHTML += styleName + ":" + styles[styleName]+ ";\n";
            }
            innerHTML += "}";

            style.innerHTML = innerHTML;
            document.getElementsByTagName('head')[0].appendChild(style);
        },
        removeDivElementWithID: function(id) {
            var divElement = document.getElementById(id);
            if (divElement == undefined) {
                return;
            }
            document.body.removeChild(divElement);
        },
        removeDivElementsWithClass: function(className) {
            var elements = document.getElementsByClassName(className);
            if (elements.length == 0) {
                return;
            }
            for (var i = 0; i < elements.length; ++i) {
                var element = elements[i];
                document.body.removeChild(element);
            }
        },
        existDivElement: function(name) {
            return document.getElementById(name) != undefined;
        }
    }
};

// Callbacks
JasperMobile.Callback = {
    logEnable: true, // For now could be changed by hands
    createCallback: function(params) {
        window.webkit.messageHandlers.JMJavascriptRequestExecutor.postMessage(params);
    },
    log : function(message) {
        if (!this.logEnable) {
            return;
        }
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
    logJSON: function(message, json) {
        if (!this.logEnable) {
            return;
        }
        var jsonString = JSON.stringify(json);
        console.log("Log: " + message + "; json: " + jsonString);
        this.createCallback(
            {
                "command" : "logging",
                "parameters" : {
                    "message": message,
                    "object" : JSON.parse(jsonString)
                }
            }
        );
    },
    logObject: function(message, object) {
        if (!this.logEnable) {
            return;
        }
        this.logJSON(message, this.jsonFromObject(object));
    },
    jsonFromObject: function(object) {
        var listOfProperties = Object.getOwnPropertyNames(object);
        var objectJSON = {};
        for(var propertyIndex in listOfProperties) {
            var propertyName = listOfProperties[propertyIndex];
            var property = object[propertyName];
            var propertyType = typeof property;
            // construct structure
            var structure = {
                "type" : propertyType
            };
            if (propertyType === 'object') {
                structure["object"] = this.jsonFromObject(property);
            } else {
                structure["value"] = property;
            }
            objectJSON[propertyName] = structure;
        }
        return objectJSON;
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

JasperMobile.containerManager = {
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
    removeAllContainers: function() {
        if (this.containers == undefined) {
            JasperMobile.Helper.removeDivElementWithID(this.defaultContainer.name);
        } else {
            for (var i = 0; i < this.containers.length; ++i) {
                var container = this.containers[i];
                JasperMobile.Helper.removeDivElementWithID(container.name);
            }
            this.containers = undefined;
        }
    },
    chooseDefaultContainer: function() {
        if (!JasperMobile.Helper.existDivElement(this.defaultContainer.name)) {
            this.createDefaultContainer();
        }
        this.activeContainer = this.defaultContainer;
    },
    createDefaultContainer: function() {
        var containerName = this.defaultContainer;
        JasperMobile.Helper.createDivElement(containerName.name, {
            "width" : "100%",
            "height" : "100%",
            "margin" : "0 auto"
        });
    },
    removeDefaultContainer: function() {
        JasperMobile.Helper.removeDivElementWithID(this.defaultContainer.name);
    },
    changeActiveContainer: function(freeContainerFromReport) {
        if (this.activeContainer == undefined) {
            this.activeContainer = this.containers[0];
        } else {
            var nextContainer = this.nextContainer();
            freeContainerFromReport(nextContainer);
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
            this.clearContainer(container);
            container.isActive = false;
        }
        this.nextIndexToFree = 0;
        // remove
        // m-Dialog
        // jive_dropdown_menu
        // TODO: invesigate all cases
        JasperMobile.Helper.removeDivElementsWithClass("m-Dialog");
        JasperMobile.Helper.removeDivElementsWithClass("m-jive_dropdown_menu");
    },
    shouldReuseContainers: function() {
        return JasperMobile.containerManager.containers != undefined && JasperMobile.containerManager.containers.length > 0;
    }
};

// REST flow
JasperMobile.REST = {
    Report: {},
    Dashboard: {}
};

// REST Reports
JasperMobile.REST.Report.API = {
    elasticChart: null,
    transformationScale: 0.0,
    injectContent: function(contentObject, transformationScale) {
        if (!JasperMobile.containerManager.shouldReuseContainers()) {
            JasperMobile.containerManager.chooseDefaultContainer();
        }

        JasperMobile.REST.Report.API.transformationScale = contentObject["transformationScale"];
        var content = contentObject["HTMLString"];
        var container = document.getElementById('container');
        //container.style.pointerEvents = "none"; // disable clicks under container

        if (container == null) {
            JasperMobile.Callback.callback("JasperMobile.REST.Report.API.injectContent", {
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
            JasperMobile.REST.Report.API.elasticChart = null;
            container.style.zoom = "";
            JasperMobile.Callback.log("clear content");
            JasperMobile.Callback.callback("JasperMobile.REST.Report.API.injectContent", {});
        } else {
            container.style.zoom = 2;
            JasperMobile.Helper.resetBodyTransformStyles();
            JasperMobile.Helper.updateBodyTransformStylesToFitWindow();
            JasperMobile.Callback.callback("JasperMobile.REST.Report.API.injectContent", {});
        }
    },
    verifyEnvironmentIsReady: function() {
        JasperMobile.Callback.callback("JasperMobile.REST.Report.API.verifyEnvironmentIsReady", {
            "isReady" : document.getElementById("container") != null
        });
    },
    renderHighcharts: function(parameters) {
        var scripts = parameters["scripts"];
        var isElasticChart = parameters["isElasticChart"];

        JasperMobile.REST.Report.API.chartParams = parameters;

        var script;
        var functionName;
        var chartParams;

        JasperMobile.REST.Report.API.elasticChart = null;

        if (isElasticChart == "true") {
            var container = document.getElementById('container');

            JasperMobile.Helper.resetBodyTransformStyles();
            JasperMobile.Helper.setBodyTransformStyles(JasperMobile.REST.Report.API.transformationScale);

            script = scripts[0];
            functionName = script.scriptName.trim();
            chartParams = script.scriptParams;

            var containerWidth = container.offsetWidth / JasperMobile.REST.Report.API.transformationScale ;
            var containerHeight = container.offsetHeight / JasperMobile.REST.Report.API.transformationScale ;

            // Update chart size
            var chartDimensions = chartParams.chartDimensions;
            chartDimensions.width = containerWidth;
            chartDimensions.height = containerHeight;

            // set new chart size
            chartParams.chartDimensions = chartDimensions;

            JasperMobile.REST.Report.API.elasticChart = {
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
        JasperMobile.Callback.callback("JasperMobile.REST.Report.API.renderHighcharts", {});
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
        JasperMobile.Callback.callback("JasperMobile.REST.Report.API.executeScripts", {});
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
            JasperMobile.Callback.callback("JasperMobile.REST.Report.API.applyZoomForReport", {});
        } else {
            JasperMobile.Callback.callback("JasperMobile.REST.Report.API.applyZoomForReport", {
                "error" : {
                    "code"    : "internal.error", // TODO: need error codes?
                    "message" : "No table with class 'jrPage'."
                }
            });
        }
    },
    fitReportViewToScreen: function() {
        JasperMobile.Helper.resetBodyTransformStyles();
        if (JasperMobile.REST.Report.API.elasticChart != null) {
            JasperMobile.Helper.setBodyTransformStyles(JasperMobile.REST.Report.API.transformationScale );

            // run script
            var functionName = JasperMobile.REST.Report.API.elasticChart.functionName;
            var chartParams = JasperMobile.REST.Report.API.elasticChart.chartParams;

            var containerWidth = document.getElementById("container").offsetWidth / JasperMobile.REST.Report.API.transformationScale ;
            var containerHeight = document.getElementById("container").offsetHeight / JasperMobile.REST.Report.API.transformationScale ;

            var chartDimensions = chartParams.chartDimensions;
            chartDimensions.width = containerWidth;
            chartDimensions.height = containerHeight;

            chartParams.chartDimensions = chartDimensions;
            window[functionName](chartParams);
        } else {
            JasperMobile.Helper.updateBodyTransformStylesToFitWindow();
        }

        JasperMobile.Callback.callback("JasperMobile.REST.Report.API.fitReportViewToScreen", {});
    }
};

// Legacy Dashboard
JasperMobile.REST.Dashboard.API = {
    dashboardFlowURI: "flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=",
    runDashboard: function(parameters) {
        if (!JasperMobile.containerManager.shouldReuseContainers()) {
            JasperMobile.containerManager.chooseDefaultContainer();
        }

        var baseURL = parameters["baseURL"];
        var resourceURI = parameters["resourceURI"];
        var url = baseURL + JasperMobile.REST.Dashboard.API.dashboardFlowURI + resourceURI;
        JasperMobile.REST.Dashboard.API.loadDashboard(
            url,
            function() {
                JasperMobile.Callback.callback("JasperMobile.REST.Dashboard.API.runDashboard", {});
            },
            function(error) {
                JasperMobile.Callback.callback("JasperMobile.REST.Dashboard.API.runDashboard", {
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
            }
        };
        xmlhttp.onload = function(e) {
            if (xmlhttp.readyState === 4) {
                if (xmlhttp.status === 200 || xmlhttp.status === 0) {
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
        xmlhttp.onerror = function(e) {
            JasperMobile.Callback.log("error: " + JSON.stringify(e));
            JasperMobile.Callback.log('onerror statustext: ' + xmlhttp.statusText + ',status: ' + xmlhttp.status);
        };
        xmlhttp.open("GET", URL, true);
        xmlhttp.send();
    }
};

// VIZ flow
JasperMobile.VIS = {
    Helpers: {
        authFn: function(isForAmber) {
            if (isForAmber) {
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
    },
    Report: {},
    Dashboard: {}
};

// VIZ Reports
JasperMobile.VIS.Report = {
    state: {
        reportFunction : undefined,
        activeReport: undefined
    },
    manager: {
        reports: {},
        addReport:function(object) {
            var report = this.createReport(object);
            report.container = JasperMobile.containerManager.activeContainer;
            var uri = report.object.resource();
            report.uri = uri;
            JasperMobile.VIS.Report.state.activeReport = report;
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
            var reportStruct = {
                object: object,
                container: undefined,
                uri: undefined,
                hasChartComponents : function() {
                    var hasChartComponents = false;
                    var components = object.data().components;
                    for (var componentIndex in components) {
                        if (!components.hasOwnProperty(componentIndex)) continue;
                        var component = components[componentIndex];
                        var componentType = component.componentType;
                        if (componentType === "chart" ) {
                            hasChartComponents = true;
                            break;
                        }
                    }
                    return hasChartComponents;
                },
                chartComponents: function() {
                    var chartComponents = [];
                    var components = object.data().components;
                    for (var componentIndex in components) {
                        if (!components.hasOwnProperty(componentIndex)) continue;
                        var component = components[componentIndex];
                        var componentType = component.componentType;
                        // set this properties because our mapper (JMReportComponent)
                        component["type"] = componentType;
                        component["charttype"] = component.chartType;
                        if (componentType === "chart" ) {
                            chartComponents.push(component);
                        }
                    }
                    return chartComponents;
                },
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
                    JasperMobile.Callback.log("Start destroying of a report");
                    try {
                        JasperMobile.VIS.Report.privateAPI.executeOperation(
                            this,
                            "destroy",
                            null,
                            success,
                            fail
                        );
                    } catch(error) {
                        JasperMobile.Callback.log("error of destroying of a report: " + error);
                    }
                }
            };
            return reportStruct;
        },
        containsReport: function(uri) {
            return (this.reports[uri] != undefined);
        },
        setActiveReport: function(uri) {
            JasperMobile.VIS.Report.state.activeReport = this.reports[uri];
            JasperMobile.containerManager.showContainer(JasperMobile.VIS.Report.state.activeReport.container);
        }
    },
    API: {},
    privateAPI: {},
    Helpers : {},
    Handlers: {
        Hyperlinks : {}
    },
    reset: function() {
        this.state.activeReport = undefined;
        JasperMobile.containerManager.reset();
        this.manager.removeAllReports();
    }
};
JasperMobile.VIS.Report.Helpers = {
    isAmber: false,
    initReportStructWithParameters: function(parameters) {
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
            JasperMobile.VIS.Report.state.reportFunction = v.report;
            var reportObject = v.report(self.initReportStructWithParameters(params));
            if (JasperMobile.containerManager.shouldReuseContainers()) {
                // save report object
                JasperMobile.VIS.Report.manager.addReport(reportObject);
            } else {
                try {
                    var report = JasperMobile.VIS.Report.manager.createReport(reportObject);
                    report.container = JasperMobile.containerManager.activeContainer;
                    JasperMobile.VIS.Report.state.activeReport = report;
                } catch (error) {
                    JasperMobile.Callback.log("error of creating of report object: " + error);
                    JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.run", {
                        "error" : {
                            "code"    : error.errorCode,
                            "message" : error.message
                        }
                    });
                }
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
        var container = JasperMobile.containerManager.activeContainer.name;
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
        JasperMobile.Callback.log("success of running report");
        var status = "undefined";
        if (JasperMobile.VIS.Report.state.activeReport == undefined) {
            JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.run", {
                "error" : {
                    "code"    : "Visualize Error",
                    "message" : "An error of creating a report object"
                }
            });
            return;
        }
        if (JasperMobile.VIS.Report.state.activeReport.totalPages() == undefined) {
            status = "inProgress";
            JasperMobile.VIS.Report.Helpers.detectMutlipageReport(function(isMultipageReport) {
                if (isMultipageReport) {
                    JasperMobile.Callback.listener("JasperMobile.Report.Event.MultipageReport", null);
                }
            });
        } else {
            status = "ready";
        }
        JasperMobile.Callback.logObject("active report", JasperMobile.VIS.Report.state.activeReport);
        JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.run", {
            "status"      : status,
            "pages"       : JasperMobile.VIS.Report.state.activeReport.pages(),
            "totalPages"  : JasperMobile.VIS.Report.state.activeReport.totalPages(),
            "bookmarks"   : JasperMobile.VIS.Report.state.activeReport.bookmarks(),
            "parts"       : JasperMobile.VIS.Report.state.activeReport.parts()
        });
    },
    failed: function(error) {
        JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.run", {
            "error" : {
                "code"    : error.errorCode,
                "message" : error.message
            }
        });
    },
    events: {
        reportCompleted: function(status, error) {
            JasperMobile.Callback.log("Event: reportCompleted, status:(" + status + ")");
            if (status === "ready") {
                try {
                    var hasChartComponents = JasperMobile.VIS.Report.state.activeReport.hasChartComponents();
                    if (hasChartComponents) {
                        var components = JasperMobile.VIS.Report.state.activeReport.chartComponents();
                        JasperMobile.Callback.listener("JasperMobile.Report.Event.reportCompleted", {
                            "status": status,
                            "components": components
                        });
                    } else {
                        JasperMobile.Callback.listener("JasperMobile.Report.Event.reportCompleted", {
                            "status": status
                        });
                    }
                } catch(error) {
                    JasperMobile.Callback.log("error of detecting of has report charts: " + error);
                    JasperMobile.Callback.listener("JasperMobile.Report.Event.reportCompleted", {
                        "status": status
                    });
                }
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
            JasperMobile.Callback.log("Total Pages:" + JasperMobile.VIS.Report.state.activeReport.totalPages());
        },
        changeTotalPages: function(totalPages) {
            JasperMobile.Callback.log("Event: changeTotalPages: " + totalPages);
            JasperMobile.Callback.listener("JasperMobile.Report.Event.changeTotalPages", {
                "pages" : totalPages
            });
        }
    },
    linkOptionsEventsClick: function(event, link) {
        JasperMobile.Callback.log("link: " + JSON.stringify(link));
        var type = link.type;
        switch (type) {
            case "ReportExecution": {
                JasperMobile.VIS.Report.Handlers.Hyperlinks.handleReportExecution(link);
                break;
            }
            case "LocalAnchor": {
                JasperMobile.VIS.Report.Handlers.Hyperlinks.handleLocalAnchor(link);
                break;
            }
            case "LocalPage": {
                JasperMobile.VIS.Report.Handlers.Hyperlinks.handleLocalPage(link);
                break;
            }
            case "Reference": {
                JasperMobile.VIS.Report.Handlers.Hyperlinks.handleReference(link);
                break;
            }
            case "RemoteAnchor": {
                JasperMobile.VIS.Report.Handlers.Hyperlinks.handleRemoteAnchor(link);
                break;
            }
            case "RemotePage": {
                JasperMobile.VIS.Report.Handlers.Hyperlinks.handleRemotePage(link);
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
    detectMutlipageReport: function(completion) {
        var exportParameters = {
            outputFormat: "html",
            pages : 2
        };
        JasperMobile.VIS.Report.privateAPI.executeOperation(
            undefined,
            "export",
            exportParameters,
            function(data) {
                //JasperMobile.Callback.log("data: " + JSON.stringify(data));
                var href = data.href;
                if (href) {
                    completion(true);
                }
            },
            function(error) {
                completion(false);
                //JasperMobile.Callback.log("error: " + JSON.stringify(error));
            }
        );
    }
};
JasperMobile.VIS.Report.Handlers.Hyperlinks = {
    handleReportExecution: function(link) {
        JasperMobile.Callback.log("handleReportExecution");
        var data = {};
        if (link.parameters) {
            data = {
                resource: link.parameters._report,
                params: JasperMobile.VIS.Report.Helpers.collectReportParams(link)
            };
            JasperMobile.Callback.log("Event: linkOption - ReportExecution");
            JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.ReportExecution", {
                "data" : data
            });
        } else {
            JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.ReportExecution", {
                "error" : {
                    "code" : "hyperlink.not.support.error",
                    "message" : "Hyperlink doesn't support"
                }
            });
        }
    },
    handleLocalAnchor: function(link) {
        if (link.anchor == undefined) {
            JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.LocalAnchor", {
                "error" : {
                    "code" : "hyperlink.not.support.error",
                    "message" : "Hyperlink doesn't support"
                }
            });
        } else {
            var parameters = {
                "destination":{
                    anchor:link.anchor
                }
            };
            JasperMobile.VIS.Report.privateAPI.executeOperation(undefined, "navigateTo", parameters,
                function(data) {
                    JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.LocalAnchor", {
                        "destination" : link.pages
                    });
                },
                function(error) {
                    JasperMobile.Callback.log(error);
                });
        }
    },
    handleLocalPage: function(link) {
        if (link.pages == undefined) {
            JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.LocalPage", {
                "error" : {
                    "code" : "hyperlink.not.support.error",
                    "message" : "Hyperlink doesn't support"
                }
            });
        } else {
            var parameters = {
                "destination": link.pages
            };
            JasperMobile.VIS.Report.privateAPI.executeOperation(undefined, "navigateTo", parameters,
                function(data) {
                    JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.LocalPage", {
                        "destination" : link.pages
                    });
                },
                function(error) {
                    JasperMobile.Callback.log(error);
                });
        }
    },
    handleReference: function(link) {
        var href = link.href;
        JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.Reference", {
            "destination" : href
        });
    },
    handleRemoteAnchor: function(link) {
        if (JasperMobile.VIS.Report.Helpers.isAmber) {
            JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.RemoteAnchor", {
                "error" : {
                    "code" : "hyperlink.not.support.error",
                    "message" : "Hyperlink doesn't support"
                }
            });
        } else {
            JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.RemoteAnchor", {
                "location": link.href
            });
        }
    },
    handleRemotePage: function (link) {
        if (JasperMobile.VIS.Report.Helpers.isAmber) {
            JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.RemotePage", {
                "error" : {
                    "code" : "hyperlink.not.support.error",
                    "message" : "Hyperlink doesn't support"
                }
            });
        } else {
            JasperMobile.Callback.listener("JasperMobile.VIS.Report.Event.Link.RemotePage", {
                "location" : link.href
            });
        }
    }
};
JasperMobile.VIS.Report.privateAPI = {
    executeOperation: function(report, operation, parameters, success, fail) {
        if (report == undefined) {
            report = JasperMobile.VIS.Report.state.activeReport
        }
        var request = "JasperMobile.VIS.Report.API." + operation;
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
    export: function(report, parameters, success, fail) {
        report.object.export(parameters)
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
    },
    updateChartType: function(report, parameters, success, fail) {
        report.object.updateComponent(parameters.componentId, parameters.chart)
            .done(success)
            .fail(fail);
    }
};
JasperMobile.VIS.Report.API = {
    run: function(params) {
        JasperMobile.Callback.log("run report");
        JasperMobile.VIS.Report.Helpers.isAmber = params["is_for_6_0"]; // TODO: replace with switch
        var shouldUseCache = params["shouldUseCache"];
        if (shouldUseCache && JasperMobile.containerManager.containers == undefined) {
            JasperMobile.containerManager.setContainers(
                {
                    "containers" : [
                        {
                            "name" : "container",
                            "isActive" : false
                        }
                        ]
                });
        } else if (!shouldUseCache && JasperMobile.containerManager.containers != undefined) {
            JasperMobile.containerManager.removeAllContainers();
            JasperMobile.VIS.Report.manager.removeAllReports();
        }

        if (JasperMobile.VIS.Report.manager.containsReport(params["uri"])) {
            JasperMobile.Callback.log("from cache");
            JasperMobile.VIS.Report.manager.setActiveReport(params["uri"]);
            if (JasperMobile.VIS.Report.state.activeReport.pages() == 1) {
                JasperMobile.VIS.Report.Helpers.success(JasperMobile.VIS.Report.state.activeReport.object.data());
            } else {
                this.navigateTo(
                    {"destination" : 1},
                    JasperMobile.VIS.Report.Helpers.success
                );
            }
        } else {
            JasperMobile.Callback.log("fresh run");
            if (JasperMobile.containerManager.shouldReuseContainers()) {
                JasperMobile.Callback.log("save into cache");
                // Choose other container
                JasperMobile.containerManager.changeActiveContainer(function(container) {
                    if (container != undefined) {
                        JasperMobile.VIS.Report.manager.removeReportInContainer(container, function() {
                            JasperMobile.Callback.log("report was removed");
                        });
                    }
                });
            } else {
                JasperMobile.Callback.log("without cache");
                JasperMobile.containerManager.chooseDefaultContainer();
            }
            visualize(
                JasperMobile.VIS.Helpers.authFn(JasperMobile.VIS.Report.Helpers.isAmber),
                JasperMobile.VIS.Report.Helpers.runFn(params),
                JasperMobile.VIS.Report.Helpers.failed
            );
        }
    },
    refresh: function(success) {
        if (typeof(success) != "function") {
            success = function(data) {
                JasperMobile.Callback.log("success of refresh: " + JSON.stringify(data));
                JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.refresh", {
                    "status": status,
                    "totalPages": data.totalPages
                });
            };
        }
        JasperMobile.VIS.Report.privateAPI.executeOperation(
            undefined,
            "refresh",
            undefined,
            success
        );
    },
    applyReportParams: function(parameters, success) {
        if (typeof(success) != "function") {
            success = function(reportData) {
                JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.applyReportParams", {
                    "pages": reportData.totalPages
                });
            };
        }
        JasperMobile.VIS.Report.privateAPI.executeOperation(
            undefined,
            "updateReportWithParameters",
            parameters,
            success
        );
    },
    navigateTo: function(parameters, success) {
        if (typeof(success) != "function") {
            success = function(data) {
                JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.navigateTo", {
                    "destination": JasperMobile.VIS.Report.state.activeReport.pages()
                });
            };
        }
        JasperMobile.VIS.Report.privateAPI.executeOperation(
            undefined,
            "navigateTo",
            parameters,
            success
        );
    },
    cancel: function(success) {
        if (typeof(success) != "function") {
            success = function() {
                JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.cancel", {});
            };
        }
        JasperMobile.VIS.Report.privateAPI.executeOperation(
            undefined,
            "cancel",
            undefined,
            success
        );
    },
    destroy: function() {
        if (JasperMobile.containerManager.shouldReuseContainers()) {
            JasperMobile.containerManager.hideContainer(JasperMobile.VIS.Report.state.activeReport.container);
            JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.destroy", {});
        } else {
            JasperMobile.VIS.Report.state.activeReport.destroy(function() {
                JasperMobile.Callback.log("finish of destroying of a report");
                JasperMobile.containerManager.activeContainer = undefined;
                JasperMobile.VIS.Report.state.activeReport = undefined;
                JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.destroy", {});
            });
        }
    },
    fitReportViewToScreen: function(success) {
        if (typeof(success) != "function") {
            success = function(size) {
                JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.fitReportViewToScreen", {
                    "size" : size
                });
            };
        }
        JasperMobile.VIS.Report.privateAPI.executeOperation(
            undefined,
            "fitReportViewToScreen",
            null,
            success
        );
    },
    availableChartTypes: function() {
        JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.availableChartTypes", {
            "chart" : JasperMobile.VIS.Report.state.reportFunction.chart.types
        });
    },
    updateChartType: function(params, success) {
        if (typeof(success) != "function") {
            success = function(data) {
                JasperMobile.Callback.callback("JasperMobile.VIS.Report.API.updateChartType", {
                    "data" : data
                });
            };
        }
        JasperMobile.VIS.Report.privateAPI.executeOperation(
            undefined,
            "updateChartType",
            params,
            success
        );
    }
};

// VIZ Dashboards
JasperMobile.VIS.Dashboard = {
    state: {
        dashboardObject         : undefined,
        refreshedDashboardObject: undefined,
        canceledDashboardObject : undefined,
        dashboardFunction       : undefined,
        selectedDashlet         : undefined, // DOM element
        selectedComponent       : undefined, // Model element
        isAmber                 : false,
        activeLinks             : []
    },
    manager: {},
    Setup: {},
    Helpers: {},
    PrivateAPI : {},
    Handlers: {
        Hyperlinks: {}
    },
    API: {}
};
JasperMobile.VIS.Dashboard.Handlers.Hyperlinks = {
    adhocExectionWasClicked: false,
    handleReportExecution: function(link) {
        var data = {
            resource: link.parameters._report,
            params: JasperMobile.VIS.Report.Helpers.collectReportParams(link)
        };
        JasperMobile.Callback.listener("JasperMobile.VIS.Event.Link.ReportExecution", {
            "data" : data
        });
    },
    handleReference: function (link) {
        var href = link.href;
        JasperMobile.Callback.listener("JasperMobile.VIS.Event.Link.Reference", {
            "location" : href
        });
    },
    handleAdhocExecution: function(link) {
        JasperMobile.Callback.listener("JasperMobile.VIS.Event.Link.AdHocExecution", {
            "linkObject" : link
        });
    },
    handleRemotePage: function(link) {
        var href = link.href;
        JasperMobile.Callback.listener("JasperMobile.VIS.Event.Link.RemotePage", {
            "location" : href
        });
    },
    handleRemoteAnchor: function(link) {
        var href = link.href;
        JasperMobile.Callback.listener("JasperMobile.VIS.Event.Link.RemoteAnchor", {
            "location" : href
        });
    }
};
JasperMobile.VIS.Dashboard.Setup = {
    initStructWithParameters: function(parameters) {
        var struct;
        if (JasperMobile.VIS.Dashboard.state.isAmber) {
            struct = this.baseStructFn(parameters);
        } else {
            struct = this.structFn(parameters);
        }
        return struct;
    },
    runFn : function(parameters) {
        var self = this;
        return function (v) {
            JasperMobile.VIS.Dashboard.state.dashboardFunction = v.dashboard;
            JasperMobile.VIS.Dashboard.state.dashboardObject = v.dashboard(self.initStructWithParameters(parameters));
        };
    },
    baseStructFn: function(parameters) {
        var self = this;
        var container = JasperMobile.containerManager.activeContainer.name;
        return {
            resource: parameters["uri"],
            container: "#" + container,
            linkOptions: {
                events: {
                    "click" : self.linkOptionsEventsClick
                }
            },
            success: self.success,
            error: self.failed
        };
    },
    structFn: function(parameters) {
        var struct = this.baseStructFn(parameters);
        struct.report =  {
            chart: {
                animation: false,
                zoom     : false
            }
        };
        return struct;
    },
    success: function() {
        setTimeout(function(){
            var data = JasperMobile.VIS.Dashboard.state.dashboardObject.data();
            if (data.components) {
                JasperMobile.VIS.Dashboard.Helpers._configureComponents(data.components);
            }
            if (JasperMobile.VIS.Dashboard.state.isAmber) {
                JasperMobile.VIS.Dashboard.Helpers._defineComponentsClickEventAmber();
            } else {
                JasperMobile.VIS.Dashboard.Helpers._defineComponentsClickEvent();
            }

            JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.run", {
                "components" : data.components ? data.components : {},
                "params" : data.parameters
            });

            // TODO: Redo. This was used after failing refresh
            // if (success != "null") {
            //     success({
            //         "components" : data.components ? data.components : {},
            //         "params" : data.parameters
            //     });
            // }
        }, 6000);

        // hide input controls dashlet if it exists
        var filterGroupNodes = document.querySelectorAll('[data-componentid="Filter_Group"]');
        if (filterGroupNodes.length > 0) {
            var filterGroup = filterGroupNodes[0];
            filterGroup.style.display = "none";
        }
    },
    failed: function(error) {
        JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.run", {
            "error" : {
                "code" : error.errorCode,
                "message" : error.message
            }
        });
        // TODO: Redo. This was used after failing refresh
        // if (failed != "null") {
        //     failed(error);
        // }
    },
    linkOptionsEventsClick : function(event, link, defaultHandler) {
        var type = link.type;
        JasperMobile.Callback.log("link: " + JSON.stringify(link));
        if (JasperMobile.VIS.Dashboard.state.isAmber) {
            // There are cases when the same event goes several times
            // It looks like a vis bug.
            var contains = false;
            for (var i = 0; i < JasperMobile.VIS.Dashboard.state.activeLinks.length; ++i) {
                var currentLink = JasperMobile.VIS.Dashboard.state.activeLinks[i];
                if (currentLink.id == link.id) {
                    contains = true;
                    break;
                }
            }
            if (contains) {
                return;
            }
            // save the link temporary to prevent handling it several times
            JasperMobile.VIS.Dashboard.state.activeLinks.push(link);
            // remove all links after some timeout
            setTimeout(function() {
                JasperMobile.VIS.Dashboard.state.activeLinks = [];
            },3000);
        }
        switch (type) {
            case "ReportExecution": {
                JasperMobile.VIS.Dashboard.Handlers.Hyperlinks.handleReportExecution(link);
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
            case "RemotePage": {
                JasperMobile.VIS.Dashboard.Handlers.Hyperlinks.handleRemotePage(link);
                break;
            }
            case "RemoteAnchor": {
                JasperMobile.VIS.Dashboard.Handlers.Hyperlinks.handleRemoteAnchor(link);
                break;
            }
            case "Reference": {
                JasperMobile.VIS.Dashboard.Handlers.Hyperlinks.handleReference(link);
                break;
            }
            case "AdHocExecution": {
                if (typeof(defaultHandler) != "function") {
                    JasperMobile.VIS.Dashboard.Handlers.Hyperlinks.handleAdhocExecution(link);
                } else {
                    JasperMobile.VIS.Dashboard.Handlers.Hyperlinks.adhocExectionWasClicked = true;
                    defaultHandler.call();
                }
                break;
            }
            default: {
                defaultHandler.call();
            }
        }
    }
};
JasperMobile.VIS.Dashboard.Helpers = {
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
    _configureComponents: function(components) {
        components.forEach( function(component) {
            if (component.type !== 'inputControl') {
                JasperMobile.VIS.Dashboard.state.dashboardObject.updateComponent(component.id, {
                    interactive: false,
                    toolbar: false
                });
            }
        });
    },
    _defineComponentsClickEvent: function() {
        var dashboardId = JasperMobile.VIS.Dashboard.state.dashboardFunction.componentIdDomAttribute;
        var dashlets = this._getDashlets(dashboardId); // DOM elements
        for (var i = 0; i < dashlets.length; ++i) {
            var parentElement = dashlets[i].parentElement;
            // set onClick listener for parent of dashlet

            (function(self) {
                parentElement.onclick = function(event) {
                    JasperMobile.VIS.Dashboard.state.selectedDashlet = this;
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
                    component = self._getComponentById(id); // Model object

                    // TODO: need this?
                    //self._hideDashlets(dashboardId, dashlet);

                    if (component && !component.maximized) {
                        JasperMobile.Callback.listener("JasperMobile.VIS.Dashboard.API.events.dashlet.didStartMaximize", {
                            "component" : component
                        });
                        JasperMobile.VIS.Dashboard.state.selectedDashlet.className += "originalDashletInScaledCanvas";
                        JasperMobile.VIS.Dashboard.state.dashboardObject.updateComponent(id, {
                            maximized: true,
                            interactive: true
                        }, function() {
                            JasperMobile.VIS.Dashboard.state.selectedComponent = component;
                            setTimeout(function(){
                                JasperMobile.Callback.listener("JasperMobile.VIS.Dashboard.API.events.dashlet.didEndMaximize", {
                                    "component" : component
                                });
                            }, 3000);
                        }, function(error) {
                            JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.events.dashlet.didEndMaximize", {
                                "error" : {
                                    "code" : error.errorCode,
                                    "message" : error.message
                                },
                                "component" : component
                            });
                        });
                    }
                };
            })(this);
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
                (function(nodeElement, componentId, self) {
                    self._configureDashletForAmber(nodeElement, componentId);
                })(nodeElement, componentId, this);
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
                    JasperMobile.Callback.listener("JasperMobile.VIS.Dashboard.API.events.dashlet.didStartMaximize", {});
                    maximizeButton.click();
                    JasperMobile.VIS.Dashboard.Helpers._disableClicks();
                    setTimeout(function(){
                        JasperMobile.Callback.listener("JasperMobile.VIS.Dashboard.API.events.dashlet.didEndMaximize", {
                            "componentId" : componentId
                        });
                    }, 3000);
                } else {
                    JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.events.dashlet.didEndMaximize", {
                        "error" : {
                            "code" : "maximize.button.error",
                            "message" : "Component is not ready"
                        }
                    });
                }
            });
        } else {
            JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.events.dashlet.didEndMaximize", {
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
        var components = JasperMobile.VIS.Dashboard.state.dashboardObject.data().components;
        for (var i = 0; components.length; ++i) {
            if (components[i].id === id) {
                return components[i];
            }
        }
    }
};
JasperMobile.VIS.Dashboard.PrivateAPI = {
    minimizeDashlet: function(parameters) {
        var dashletId = parameters["identifier"];
        if (dashletId == "null") {
            // TODO: need this?
            //this._showDashlets();

            // stop showing buttons for changing chart type.
            var chartWrappers = document.querySelectorAll('.show_chartTypeSelector_wrapper');
            for (var i = 0; i < chartWrappers.length; ++i) {
                chartWrappers[i].style.display = 'none';
            }

            JasperMobile.VIS.Dashboard.state.selectedDashlet.classList.remove('originalDashletInScaledCanvas');

            JasperMobile.VIS.Dashboard.state.dashboardObject.updateComponent(JasperMobile.VIS.Dashboard.state.selectedComponent.id, {
                maximized: false,
                interactive: false
            }, function() {
                JasperMobile.VIS.Dashboard.state.selectedDashlet = {};
                JasperMobile.VIS.Dashboard.state.selectedComponent = {};
                // TODO: need add callbacks?
            }, function(error) {
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.minimizeDashlet", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            });
        } else {
            JasperMobile.VIS.Dashboard.state.dashboardObject.updateComponent(dashletId, {
                maximized: false,
                interactive: false
            }).done(function() {
                setTimeout(function(){
                    JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.minimizeDashlet", {
                        "component" : dashletId
                    });
                }, 3000);
            }).fail(function(error) {
                JasperMobile.Callback.log("failed refresh with error: " + error);
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.minimizeDashlet", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            });
        }
    },
    minimizeDashletForAmber: function(parameters) {
        var canvasOverlay = document.getElementsByClassName("canvasOverlay")[0];
        if (canvasOverlay != null && canvasOverlay.nodeName == "DIV") {
            var minimizeButton = canvasOverlay.getElementsByClassName("minimizeDashlet")[0];
            if (minimizeButton != null && minimizeButton.nodeName == "BUTTON") {
                minimizeButton.click();
                JasperMobile.VIS.Dashboard.Helpers._enableClicks();
                setTimeout(function(){
                    JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.minimizeDashlet", {});
                }, 3000);
            } else {
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.minimizeDashlet", {
                    "error" : {
                        "code" : "maximize.button.error",
                        "message" : "Component is not ready"
                    }
                });
            }
        } else {
            JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.minimizeDashlet", {
                "error" : {
                    "code" : "maximize.button.error",
                    "message" : "Component is not ready"
                }
            });
        }
    },
    maximizeDashlet: function (parameters) {
        var dashletId = parameters["identifier"];
        if (dashletId) {
            JasperMobile.VIS.Dashboard.state.dashboardObject.updateComponent(dashletId, {
                maximized: true,
                interactive: true
            }).done(function() {
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.maximizeDashlet", {
                    "component" : dashletId
                });
            }).fail(function(error) {
                JasperMobile.Callback.log("failed refresh with error: " + error);
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.maximizeDashlet", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            });
        } else {
            JasperMobile.Callback.log("Trying maximize dashelt without 'id'");
        }
    },
    maximizeDashletForAmber: function (parameters) {
        var dashletId = parameters["identifier"];
        var maximizeButton = JasperMobile.VIS.Dashboard.Helpers._findDashletMaximizeButtonWithDashletId(dashletId);
        if (maximizeButton != null) {
            if (maximizeButton.disabled) {
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.events.dashlet.didEndMaximize", {
                    "error" : {
                        "code" : "maximize.button.error",
                        "message" : "Component is not ready"
                    }
                });
            } else {
                JasperMobile.Callback.listener("JasperMobile.VIS.Dashboard.API.events.dashlet.didStartMaximize", {
                    "component" : dashletId
                });
                maximizeButton.click();
                setTimeout(function(){
                    JasperMobile.Callback.listener("JasperMobile.VIS.Dashboard.API.events.dashlet.didEndMaximize", {
                        "component" : dashletId
                    });
                }, 3000);
            }
        } else {
            JasperMobile.Callback.log("There is not maximize button");
        }
    }
};
JasperMobile.VIS.Dashboard.API = {
    run: function(params) {
        JasperMobile.VIS.Dashboard.state.isAmber = params["is_for_6_0"];
        JasperMobile.containerManager.chooseDefaultContainer();
        visualize(
            JasperMobile.VIS.Helpers.authFn(JasperMobile.VIS.Dashboard.state.isAmber),
            JasperMobile.VIS.Dashboard.Setup.runFn(params),
            JasperMobile.VIS.Dashboard.Setup.failed
        );
    },
    minimizeDashlet: function(parameters) {
        if (JasperMobile.VIS.Dashboard.state.isAmber) {
            JasperMobile.VIS.Dashboard.PrivateAPI.minimizeDashletForAmber(parameters);
        } else {
            JasperMobile.VIS.Dashboard.PrivateAPI.minimizeDashlet(parameters);
        }
    },
    maximizeDashlet: function(parameters) {
        if (JasperMobile.VIS.Dashboard.state.isAmber) {
            JasperMobile.VIS.Dashboard.PrivateAPI.maximizeDashletForAmber(parameters);
        } else {
            JasperMobile.VIS.Dashboard.PrivateAPI.maximizeDashlet(parameters);
        }
    },
    refresh: function() {
        JasperMobile.Callback.log("start refresh");
        JasperMobile.Callback.log("dashboard object: " + JasperMobile.VIS.Dashboard.state.dashboardObject);
        JasperMobile.VIS.Dashboard.state.refreshedDashboardObject = JasperMobile.VIS.Dashboard.state.dashboardObject.refresh()
            .done(function() {
                JasperMobile.Callback.log("done refresh");
                var data = JasperMobile.VIS.Dashboard.state.dashboardObject.data();
                setTimeout(function() {
                    JasperMobile.Callback.log("state: " + JasperMobile.VIS.Dashboard.state.refreshedDashboardObject.state());
                    if (JasperMobile.VIS.Dashboard.state.refreshedDashboardObject.state() === "rejected") {
                        JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refresh", {
                            "error" : {
                                "code" : "dashboard.refresh.rejected",
                                "message" : "Refresh was rejected"
                            }
                        });
                    } else if (JasperMobile.VIS.Dashboard.state.refreshedDashboardObject.state() === "pending") {
                        // TODO: update handling this case
                        var uri = JasperMobile.VIS.Dashboard.state.dashboardObject.properties().resource;
                        JasperMobile.VIS.Dashboard.state.dashboardObject.destroy();
                        JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refresh", {
                            "error" : {
                                "code" : "dashboard.refresh.pending",
                                "message" : "Refresh was pended"
                            }
                        });
                    } else if (JasperMobile.VIS.Dashboard.state.refreshedDashboardObject.state() === "resolved") {
                        JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refresh", {
                            "components" : data.components,
                            "params" : data.parameters
                        });
                    } else {
                        JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refresh", {
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
                    JasperMobile.VIS.Dashboard.state.dashboardObject.destroy();
                    setTimeout(function () {
                        JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refresh", {
                            "error" : {
                                "code" : error.errorCode,
                                "message" : error.message
                            }
                        });
                    }, 3000);
                } else {
                    JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refresh", {
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
        JasperMobile.Callback.log("dashboard object: " + JasperMobile.VIS.Dashboard.state.dashboardObject);
        JasperMobile.VIS.Dashboard.state.canceledDashboardObject = JasperMobile.VIS.Dashboard.state.dashboardObject.cancel()
            .done(function() {
                JasperMobile.Callback.log("success cancel");
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.cancel", {});
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed cancel with error: " + error);
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.cancel", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            });
    },
    refreshDashlet: function(params) {
        // TODO: use params["identifier"];
        JasperMobile.Callback.log("start refresh component");
        JasperMobile.Callback.log("dashboard object: " + JasperMobile.VIS.Dashboard.state.dashboardObject);
        JasperMobile.VIS.Dashboard.state.refreshedDashboardObject = JasperMobile.VIS.Dashboard.state.dashboardObject.refresh(JasperMobile.VIS.Dashboard.state.selectedComponent.id)
            .done(function() {
                JasperMobile.Callback.log("success refresh");
                var data = JasperMobile.VIS.Dashboard.state.dashboardObject.data();
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refreshDashlet", {
                    "components" : data.components,
                    "params" : data.parameters,
                    "isFullReload" : "false"
                });
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed refresh dashlet with error: " + error);
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refreshDashlet", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            });
        setTimeout(function() {
            JasperMobile.Callback.log("state: " + JasperMobile.VIS.Dashboard.state.refreshedDashboardObject.state());
            if (JasperMobile.VIS.Dashboard.state.refreshedDashboardObject.state() === "pending") {
                var uri = JasperMobile.VIS.Dashboard.state.dashboardObject.properties().resource;
                JasperMobile.VIS.Dashboard.state.dashboardObject.cancel();
                // TODO: redo this
                // JasperMobile.VIS.Dashboard.API.run({
                //     "uri" : uri,
                //     success: function() {
                //         JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.refreshDashlet", {
                //             "isFullReload": "true"
                //         });
                //     },
                //     failed: function(error) {
                //         if (error.errorCode == "authentication.error") {
                //             JasperMobile.Callback.listener("JasperMobile.VIS.Dashboard.API.unauthorized", {});
                //         } else {
                //             // TODO: handle this.
                //         }
                //     }
                // });
            }
        }, 6000);
    },
    applyParams: function(parameters) {
        JasperMobile.VIS.Dashboard.state.dashboardObject.params(parameters).run()
            .done(function() {
                setTimeout(function(){
                    var data = JasperMobile.VIS.Dashboard.state.dashboardObject.data();
                    JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.applyParams", {
                        "components" : data.components,
                        "params" : data.parameters
                    });
                }, 3000);
            })
            .fail(function(error) {
                JasperMobile.Callback.log("failed apply");
                JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.applyParams", {
                    "error" : {
                        "code" : error.errorCode,
                        "message" : error.message
                    }
                });
            });
    },
    getDashboardParameters: function() {
        var data = JasperMobile.VIS.Dashboard.state.dashboardObject.data();
        JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.getDashboardParameters", {
            "components" : data.components,
            "params" : data.parameters
        });
    },
    destroy: function() {
        if (JasperMobile.VIS.Dashboard.state.dashboardObject) {
            JasperMobile.VIS.Dashboard.state.dashboardObject.destroy()
                .done(function() {
                    JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.destroy", {});
                })
                .fail(function(error) {
                    JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.destroy", {
                        "error" : {
                            "code" : error.errorCode,
                            "message" : error.message
                        }
                    });
                });
        } else {
            JasperMobile.Callback.callback("JasperMobile.VIS.Dashboard.API.destroy", {
                "error": {
                    "code" : "visualize.error",
                    "message" : "JasperMobile.VIS.Dashboard.state.dashboardObject == nil"
                }
            });
        }
    }
};

// Start Point
document.addEventListener("DOMContentLoaded", function(event) {
    // intercepting network calls
    XMLHttpRequest.prototype.reallySend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.send = function(body) {
        JasperMobile.Callback.log("send body: " + body);
        this.reallySend(body);
    };
}, false);

var validWindowOpen = window.open;
window.open = function(URL, name, specs, replace) {
    if (JasperMobile.VIS.Dashboard.Handlers.Hyperlinks.adhocExectionWasClicked) {
        JasperMobile.VIS.Dashboard.Handlers.Hyperlinks.adhocExectionWasClicked = false;
        JasperMobile.Callback.listener("JasperMobile.VIS.Event.Link.AdHocExecution", {
            "linkObject" : {
                "URL" : URL
            }
        });
    } else {
        validWindowOpen(URL, name, specs, replace);
    }
};

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