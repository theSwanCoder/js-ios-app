!function(global){function isArray(arr){return"[object Array]"===Object.prototype.toString.call(arr)}function foreach(arr,handler){if(isArray(arr))for(var i=0;i<arr.length;i++)handler(arr[i]);else handler(arr)}function D(fn){var status="pending",doneFuncs=[],failFuncs=[],progressFuncs=[],resultArgs=null,promise={done:function(){for(var i=0;i<arguments.length;i++)if(arguments[i])if(isArray(arguments[i]))for(var arr=arguments[i],j=0;j<arr.length;j++)"resolved"===status&&arr[j].apply(this,resultArgs),doneFuncs.push(arr[j]);else"resolved"===status&&arguments[i].apply(this,resultArgs),doneFuncs.push(arguments[i]);return this},fail:function(){for(var i=0;i<arguments.length;i++)if(arguments[i])if(isArray(arguments[i]))for(var arr=arguments[i],j=0;j<arr.length;j++)"rejected"===status&&arr[j].apply(this,resultArgs),failFuncs.push(arr[j]);else"rejected"===status&&arguments[i].apply(this,resultArgs),failFuncs.push(arguments[i]);return this},always:function(){return this.done.apply(this,arguments).fail.apply(this,arguments)},progress:function(){for(var i=0;i<arguments.length;i++)if(arguments[i])if(isArray(arguments[i]))for(var arr=arguments[i],j=0;j<arr.length;j++)"pending"===status&&progressFuncs.push(arr[j]);else"pending"===status&&progressFuncs.push(arguments[i]);return this},then:function(){arguments.length>1&&arguments[1]&&this.fail(arguments[1]),arguments.length>0&&arguments[0]&&this.done(arguments[0]),arguments.length>2&&arguments[2]&&this.progress(arguments[2])},promise:function(obj){if(null==obj)return promise;for(var i in promise)obj[i]=promise[i];return obj},state:function(){return status},debug:function(){console.log("[debug]",doneFuncs,failFuncs,status)},isRejected:function(){return"rejected"===status},isResolved:function(){return"resolved"===status},pipe:function(done,fail){return D(function(def){foreach(done,function(func){"function"==typeof func?deferred.done(function(){var returnval=func.apply(this,arguments);returnval&&"function"==typeof returnval?returnval.promise().then(def.resolve,def.reject,def.notify):def.resolve(returnval)}):deferred.done(def.resolve)}),foreach(fail,function(func){"function"==typeof func?deferred.fail(function(){var returnval=func.apply(this,arguments);returnval&&"function"==typeof returnval?returnval.promise().then(def.resolve,def.reject,def.notify):def.reject(returnval)}):deferred.fail(def.reject)})}).promise()}},deferred={resolveWith:function(context){if("pending"===status){status="resolved";for(var args=resultArgs=arguments.length>1?arguments[1]:[],i=0;i<doneFuncs.length;i++)doneFuncs[i].apply(context,args)}return this},rejectWith:function(context){if("pending"===status){status="rejected";for(var args=resultArgs=arguments.length>1?arguments[1]:[],i=0;i<failFuncs.length;i++)failFuncs[i].apply(context,args)}return this},notifyWith:function(context){if("pending"===status)for(var args=resultArgs=arguments.length>1?arguments[1]:[],i=0;i<progressFuncs.length;i++)progressFuncs[i].apply(context,args);return this},resolve:function(){return this.resolveWith(this,arguments)},reject:function(){return this.rejectWith(this,arguments)},notify:function(){return this.notifyWith(this,arguments)}},obj=promise.promise(deferred);return fn&&fn.apply(obj,[obj]),obj}D.when=function(){if(arguments.length<2){var obj=arguments.length?arguments[0]:void 0;return obj&&"function"==typeof obj.isResolved&&"function"==typeof obj.isRejected?obj.promise():D().resolve(obj).promise()}return function(args){for(var df=D(),size=args.length,done=0,rp=new Array(size),i=0;i<args.length;i++)!function(j){var obj=null;args[j].done?args[j].done(function(){rp[j]=arguments.length<2?arguments[0]:arguments,++done==size&&df.resolve.apply(df,rp)}).fail(function(){df.reject(arguments)}):(obj=args[j],args[j]=new Deferred,args[j].done(function(){rp[j]=arguments.length<2?arguments[0]:arguments,++done==size&&df.resolve.apply(df,rp)}).fail(function(){df.reject(arguments)}).resolve(obj))}(i);return df.promise()}(arguments)},global.Deferred=D}(window);

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
            if (viewport != null) {
                viewport.setAttribute('content', 'initial-scale='+ scale + ', width=device-width, maximum-scale=2.0, user-scalable=yes');
            } else {
                var viewPortTag=document.createElement('meta');
                viewPortTag.id="viewport";
                viewPortTag.name = "viewport";
                viewPortTag.content = "initial-scale="+ scale +"; width=device-width, maximum-scale=2.0, user-scalable=yes";
                var head = document.getElementsByTagName('head')[0];
                head.appendChild(viewPortTag);
            }
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
    runReport: function(params) {
        var successFn = function() {
            JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.runReport", {
                "status" : status,
                "pages" : JasperMobile.Report.API.report.data().totalPages
            });
        };
        var errorFn = function(error) {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.runReport", {
                "error" : JSON.stringify({
                    "code" : error.errorCode,
                    "message" : error.message
                })
            });
        };
        var events = {
            reportCompleted: function(status) {
                JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Report.API.run.reportCompleted", {
                    "status" : status,
                    "pages" : JasperMobile.Report.API.report.data().totalPages,
                });
            },
            changePagesState: function(page) {
                JasperMobile.Callback.log("Event: changePagesState");
                JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Report.API.run.changePagesState", {
                    "page" : page
                });
            }
        };
        var linkOptionsEventsClick = function(event, link){
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
        };

        var reportStruct = {
            resource: params["uri"],
            params: params["params"],
            pages: params["pages"],
            scale: "width",
            container: "#container",
            autoresize: false,
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

        if (params["is_for_6_0"]) {
            auth = {
                auth: {
                    loginFn: function(properties, request) {
                        return (new Deferred()).resolve();
                    }
                }
            };
        } else {
            reportStruct.chart = {
                animation : false,
                zoom : false
            };
        }

        var runFn = function (v) {
            // save link for reportObject
            JasperMobile.Report.API.report = v.report(reportStruct);
        };
        visualize(auth, runFn, errorFn);
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
                .done(function (reportData) {
                    JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.applyReportParams", {
                        "pages": reportData.totalPages,
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
            JasperMobile.Report.API.report.destroy()
                .done(function() {
                    JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.destroyReport", {});
                })
                .fail(function(error) {
                    JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.destroyReport", {
                        "error" : JSON.stringify({
                            "code" : error.errorCode,
                            "message" : error.message
                        })
                    });
                });
        } else {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Report.API.destroyReport", {
                "error": JSON.stringify({
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Report.API.report == nil"
                })
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
        JasperMobile.Report.API.report.resize();
        JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Report.API.fitReportViewToScreen", {
            size: JSON.stringify({
                "width"  : width,
                "height" : height
            })
        });
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
    isAmber: false,
    runDashboard: function(params) {
        JasperMobile.Dashboard.API.isAmber = params["is_for_6_0"];
        var successFn = function() {

            setTimeout(function(){
                var data = JasperMobile.Dashboard.API.dashboardObject.data();
                if (data.components) {
                    JasperMobile.Dashboard.API._configureComponents(data.components);
                }
                JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.runDashboard", {
                    "components" : data.components ? data.components : {},
                    "params" : data.parameters
                });

                if (JasperMobile.Dashboard.API.isAmber) {
                    JasperMobile.Dashboard.API._defineComponentsClickEventAmber();
                } else {
                    JasperMobile.Dashboard.API._defineComponentsClickEvent();
                }
                JasperMobile.Dashboard.API._setupFiltersApperance();
            }, 6000);

        };
        var errorFn = function(error) {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.runDashboard", {
                "error" : JSON.stringify({
                    "code" : error.errorCode,
                    "message" : error.message
                })
            });
        };
        var dashboardStruct = {
            resource: params["uri"],
            container: "#container",
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
                            case "AdHocExecution": {
                                // defaultHandler.call();
                                JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Dashboard.API.run.linkOptions.events.AdHocExecution", {
                                    "link" : link
                                });
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
            auth = {
                auth: {
                    loginFn: function(properties, request) {
                        return (new Deferred()).resolve();
                    }
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
        JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.getDashboardParameters", {
            "components" : data.components,
            "params" : data.parameters
        });
    },
    minimizeDashlet: function(dashletId) {
        if (dashletId) {
            if (JasperMobile.Dashboard.API.isAmber) {
                JasperMobile.Dashboard.API.minimizeDashletForAmber();
            } else {
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
                    JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.minimizeDashlet", {
                        "error" : JSON.stringify({
                            "code" : error.errorCode,
                            "message" : error.message
                        })
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
                // TODO: need add callbacks?
            } else {
                JasperMobile.Callback.Callbacks.failedCallback("JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed", {
                    "error" : JSON.stringify({
                        "code" : "maximize.button.error",
                        "message" : "Component is not ready"
                    })
                });
            }
        } else {
            JasperMobile.Callback.Callbacks.failedCallback("JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed", {
                "error" : JSON.stringify({
                    "code" : "maximize.button.error",
                    "message" : "Component is not ready"
                })
            });
        }
    },
    maximizeDashlet: function(dashletId) {
        if (dashletId) {
            if (JasperMobile.Dashboard.API.isAmber) {
                JasperMobile.Dashboard.API.maximizeDashletForAmber(dashletId);
            } else {
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
            }
        } else {
            JasperMobile.Callback.log("Trying maximize dashelt without 'id'");
        }
    },
    maximizeDashletForAmber: function(dashletId) {
        var maximizeButton = JasperMobile.Dashboard.API._findDashletMaximizeButtonWithDashletId(dashletId);
        if (maximizeButton != null) {
            if (maximizeButton.disabled) {
                JasperMobile.Callback.Callbacks.failedCallback("JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed", {
                    "error" : JSON.stringify({
                        "code" : "maximize.button.error",
                        "message" : "Component is not ready"
                    })
                });
            } else {
                maximizeButton.click();
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
            JasperMobile.Dashboard.API.dashboardObject.destroy()
                .done(function() {
                    JasperMobile.Callback.Callbacks.successCompleted("JasperMobile.Dashboard.API.destroy", {});
                })
                .fail(function(error) {
                    JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.destroy", {
                        "error" : JSON.stringify({
                            "code" : error.errorCode,
                            "message" : error.message
                        })
                    });
                });
        } else {
            JasperMobile.Callback.Callbacks.failedCompleted("JasperMobile.Dashboard.API.destroy", {
                "error": JSON.stringify({
                    "code" : "visualize.error",
                    "message" : "JasperMobile.Dashboard.API.dashboardObject == nil"
                })
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
    _defineComponentsClickEventAmber: function() {
        var allNodes = document.querySelector(".dashboardCanvas > div > div").childNodes;
        var allDashlets = [];
        for (var i = 0; i < allNodes.length; i++) {
            var nodeElement = allNodes[i];
            var componentId = nodeElement.attributes["data-componentid"].value;
            if (componentId == "Filter_Group") {
                // JasperMobile.Callback.log("Filter_Group");
            } else if (componentId == "Text") {
                // JasperMobile.Callback.log("Text");
            } else {
                // JasperMobile.Callback.log("Isn't Filter");
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
            dashletContent.insertBefore(overlay, dashletContent.childNodes[0]);

            // add click listener
            overlay.addEventListener("click", function() {
                var maximizeButton = dashletWrapper.getElementsByClassName("maximizeDashletButton")[0];
                if (maximizeButton.nodeName == "BUTTON" && !maximizeButton.disabled) {
                    maximizeButton.click();
                    JasperMobile.Callback.Callbacks.successCallback("JasperMobile.Dashboard.API.events.dashlet.didMaximize", {
                        "componentId" : componentId
                    });
                } else {
                    JasperMobile.Callback.Callbacks.failedCallback("JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed", {
                        "error" : JSON.stringify({
                            "code" : "maximize.button.error",
                            "message" : "Component is not ready"
                        })
                    });
                }
            });
        } else {
            JasperMobile.Callback.Callbacks.failedCallback("JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed", {
                "error" : JSON.stringify({
                    "code" : "maximize.button.error",
                    "message" : "Component is not ready"
                })
            });
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