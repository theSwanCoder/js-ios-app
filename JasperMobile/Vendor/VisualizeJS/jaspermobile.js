var JasperMobile = {};

JasperMobile.htmlHandler = {
    changeClicker: function() {
        $(".body > div").click(function() {
                               var title = $(this).find(".innerLabel > p")[0].textContent;
                               
                               var button = $(this).find(".maximizeDashletButton")[0];
                               button.click();
                               
                               JasperMobile.makeCallback.run("command:maximize&title:"+title);
                               JasperMobile.htmlHandler.setSize("200%", "200%");
                               //JasperMobile.htmlHandler.setInterection(true);
                               });
    },
    minimizeDashlet: function() {
        $(".body > div").find(".minimizeDashlet")[0].click();
        JasperMobile.htmlHandler.setSize("450%", "450%");
        //JasperMobile.htmlHandler.setInterection(false);
    },
    setSize: function(widht, height) {
        $("#container").css("width", widht);
        $("#container").css("height", height);
    },
    setInterection: function(enable) {
        if (enable == true) {
            $(".dashlet").css("pointer-events", "auto");
        } else {
            $(".dashlet").css("pointer-events", "none");
        }
    }
};

JasperMobile.logger = {
    log : function (message) {
        //var xhr = new XMLHttpRequest();
        //xhr.open('GET', "http://debugger/" + encodeURIComponent(message));
        //xhr.send(null);
    }
};

JasperMobile.makeCallback = {
    run : function(data) {
        setTimeout(function() {
                   document.location.assign("http://jaspermobile.callback/" + data);
                   }, 100);
    }
};

// start load VISUALIZE.JS
try {
    JasperMobile.visualize = visualize;
}
catch(err) {
    JasperMobile.logger.log(err);
    JasperMobile.makeCallback.run("error=visualizeError&message=" + err);
}

    JasperMobile.auth = {
    name: "",
    password: "",
    organization: "",
        setCredentials : function(name, password, organization) {
            JasperMobile.logger.log("set credentials" + " " + name + " " + password);
            this.name = name;
            this.password = password;
            this.organization = organization;
        }
    };

    // Dashboards
    JasperMobile.dashboard = {
        run: function(resourcePath) {
            visualize({
                      auth: {
                      name: JasperMobile.auth.name,
                      password: JasperMobile.auth.password
                      }
                      }, function (v) {
                      v("#container").dashboard({
                                                resource: resourcePath,
                                                success: function() {
                                                JasperMobile.logger.log("end loading");
                                                JasperMobile.makeCallback.run("command:didEndLoading");
                                                JasperMobile.htmlHandler.changeClicker();
                                                },
                                                error: function(err) {
                                                JasperMobile.logger.log(err);
                                                }
                                                });
                      });
        }
    };

    // Reports
    JasperMobile.report = {
        run: function(resourcePath, reportParameters) {
            JasperMobile.visualize({
                        auth: {
                            name: JasperMobile.auth.name,
                            password: JasperMobile.auth.password,
                            organization: JasperMobile.auth.organization
                        }
                    }, function (v) {

                        //render report from provided resource
                        JasperMobile.makeCallback.run("reportDidBeginRender");
                      
                        JasperMobile.report.loader = v.report({
                            //server: "http://build-master.jaspersoft.com:5980/jrs-pro-trunk",
                            resource: resourcePath,
                            container: "#container",
                            scale: "width",
                            params: reportParameters,
                            linkOptions: {
                                events: {
                                    "click"  : function(evt, link){
                                          console.log(link);
                                          console.log(evt);
                                                              
                                          var type = link.type;
                                          JasperMobile.logger.log(type);
                                          if (type == "ReportExecution") {
                                              var parameters = link.parameters;
                                              var _report = parameters._report;
                                              var _vals = jQuery.map(parameters, function(val) { return val; });
                                              var _keys = Object.keys(parameters);
                                              
                                              var paramString = "";
                                              for (var i=1; i < _keys.length; i++) {
                                                  var key = _keys[i];
                                                  var value = _vals[i];
                                                              if (key == "reportTitle") {
                                                              continue;
                                                              }
                                                  paramString += "&" + key + "=" + value;
                                              }
                                                              
                                              var command = decodeURI("type=runReport&reportPath=" + _report + paramString);
                                              JasperMobile.makeCallback.run(command);
                                          } else if (type == "LocalAnchor") {
                                              var parameters = link.parameters;
                                              var href = link.href
                                              var target = link.target
                                              if (target == "Self" && href == "#title") {
                                                  JasperMobile.report.loader
                                                  .pages(1)
                                                  .run()
                                                  .fail(function(err) { alert(err); })
                                                  .done( function() {
                                                      JasperMobile.makeCallback.run("reportDidChangePage&currentPage=" + JasperMobile.report.loader.pages());
                                                           });
                                              } else if (target == "Self" && href == "#summary") {
                                                  JasperMobile.report.loader
                                                  .pages(JasperMobile.report.totalPages)
                                                  .run()
                                                  .fail(function(err) { alert(err); })
                                                  .done( function() {
                                                    JasperMobile.makeCallback.run("reportDidChangePage&currentPage=" + JasperMobile.report.loader.pages());
                                                           });
                                              } else {
                                                var href = link.href;
                                                window.location.hash = href;
                                              }
                                          } else if (type == "LocalPage") {
                                              var href = link.href;
                                              var numberPattern = /\d+/g;
                                              var pageNumber = href.match(numberPattern).join("");
                                                JasperMobile.report.loader
                                                    .pages(Number(pageNumber))
                                                    .run()
                                                    .fail(function(err) { alert(err); })
                                                    .done( function() {
                                                      JasperMobile.makeCallback.run("reportDidChangePage&currentPage=" + JasperMobile.report.loader.pages());
                                                             });
                                          } else if (type == "Reference") {
                                              var href = link.href;
                                              JasperMobile.makeCallback.run("linkOptions&linkType=" + type + "&href=" + href);
                                          } else if (type == "RemoteAnchor") {
                                              console.log(link);
                                              console.log(evt);
                                          }
                                    }
                                }
                            },
                            error: function (err){
                                JasperMobile.makeCallback.run("reportDidEndRenderFailured");
                            },
                            events: {
                                changeTotalPages: function(totalPages) {
                                    JasperMobile.report.totalPages = totalPages;
                                    JasperMobile.makeCallback.run("changeTotalPages&totalPage=" + totalPages);
                                }
                            },
                            success: function(parameters) {
                              console.log(parameters);
                              JasperMobile.makeCallback.run("reportDidEndRenderSuccessful");
                            }
                        });
            });
        },
        nextPage: function() {
            var currentPage = JasperMobile.report.loader.pages() || 1;
            
            JasperMobile.report.loader
                .pages(++currentPage)
                .run()
                .done(function() {
                      // doesn't call
                      alert("loaded page");
                })
                .fail(function(err) {
                      alert(err);
                });
        },
        prevPage: function() {
            var currentPage = JasperMobile.report.loader.pages() || 1;
            
            JasperMobile.report.loader
                .pages(--currentPage)
                .run()
                .fail(function(err) {
                      alert(err);
                });
        },
        setPage: function(pageNumber) {
            JasperMobile.report.loader
                .pages(pageNumber)
                .run()
                .fail(function(err) {
                  alert(err);
                });
        },
        getInputControls: function(resourcePath) {
            visualize({
                    auth: {
                        name: JasperMobile.auth.name,
                        password: JasperMobile.auth.password,
                        organization: JasperMobile.auth.organization
                    }
                },function(v){
                    var ic = v.inputControls({
                    resource: resourcePath,
                    success: function(data) {
                        console.log(data); // [{ "id":"Cascading_name_single_select" "options": [{ .
                        var i = 0;
                        var callback = "inputControls&";
                        data.forEach(buildControl);                        
                        
                        function buildControl(control) {
//                             JasperMobile.makeCallback.run("inputControl" + (i++) + JSON.stringify(control));
                             callback += "control#" + (i++) + JSON.stringify(control);
                                             //JasperMobile.logger.log(JSON.stringify(control));
                        }
                        JasperMobile.makeCallback.run(callback);
                    },
                    error: function(err) {
                        alert(err.message);
                    }
                });
            });
        }
    };

    var reportPath = REPORT_PATH;
    var reportParameters = REPORT_PARAMETERS;
    var authName = AUTH_NAME;
    var authPassword = AUTH_PASSWORD;
    var authOrganisation = AUTH_ORGANISATION;
    JasperMobile.isDomLoaded = false;

    var domLoadedListener = function() {
        document.removeEventListener("DOMContentLoaded", domLoadedListener);
        // UIWebView issue (
        JasperMobile.logger.log(JasperMobile.isDomLoaded);
        if (!JasperMobile.isDomLoaded) {
            JasperMobile.isDomLoaded = true;
            
            JasperMobile.logger.log("DOM did loaded");
            // TODO: need better approach
            JasperMobile.auth.setCredentials(authName, authPassword, authOrganisation);
            JasperMobile.report.run(reportPath, reportParameters);
        }
    };
    document.addEventListener("DOMContentLoaded", domLoadedListener);

    //jQuery(document).ready(domLoadedListener);

//var JasperMobile = {};
//JasperMobile.htmlHandler = {
//  changeClicker: function() {
//    var elems = jQuery("div.dashboardCanvas > div.content > div.body > div");
//    elems.unbind();
//    elems.click(function() {
//      var title = jQuery(this).find(".innerLabel > p")[0].textContent;
//
//      JasperMobile.makeCallback.run("command:maximize&title:"+title);
//      //JasperMobile.htmlHandler.setSize("#frame", "200%", "200%");
//      jQuery('.dashlet').css("pointer-events", "auto");
//
//      var button = jQuery(jQuery(this).find('div.dashletToolbar > div.content div.buttons > .maximizeDashletButton')[0]);
//      button.click();
//    });
//  },
//  minimizeDashlet: function() {
//    JasperMobile.logger.log("minimize dashlet");
//    jQuery("div.dashboardCanvas > div.content > div.body > div").find(".minimizeDashlet")[0].click();
//    JasperMobile.htmlHandler.setSize("#frame", "300%", "300%");
//    jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent()).css("pointer-events", "none");
//  },
//  setSize: function(el, widht, height) {
//    JasperMobile.logger.log("set size " + jQuery(el).toString());
//    jQuery(el).css("width", widht);
//    jQuery(el).css("height", height);
//  },
//  setInterection: function(el, enable) {
//    JasperMobile.logger.log("set interection " + jQuery(el).toString());
//    if (enable == true) {
//      jQuery(el).css("pointer-events", "auto");
//    } else {
//      jQuery(el).css("pointer-events", "none");
//    }
//  }
//};
//
//JasperMobile.logger = {
//  log : function (message) {
//    var xhr = new XMLHttpRequest();
//    xhr.open('GET', "http://debugger/" + encodeURIComponent(message));
//    xhr.send(null);
//  }
//};
//
//JasperMobile.auth = {
//  name: "",
//  password: "",
//  setCredentials : function(name, password) {
//    JasperMobile.logger.log("set credentials" + " " + name + " " + password);
//    this.name = name;
//    this.password = password;
//  }
//};
//
//JasperMobile.makeCallback = {
//  run : function(data) {
//    window.location.href = "http://jaspermobile.callback/" + data;
//  }
//};
//
//JasperMobile.dashboard = {
//  run: function(resourcePath) {
//    visualize({
//      auth: {
//        name: JasperMobile.auth.name,
//        password: JasperMobile.auth.password
//      }
//    }, function (v) {
//      v("#container").dashboard({
//        resource: resourcePath,
//        success: function() {
//          JasperMobile.logger.log("end loading");
//          JasperMobile.makeCallback.run("command:didEndLoading");
//          JasperMobile.htmlHandler.changeClicker();
//        },
//        error: function(err) {
//          JasperMobile.logger.log(err);
//        }
//      });
//    });
//  }
//};
//
//// start point
//var domLoadedListener = function() {
//  var viewPort = document.querySelector("meta[name=viewport]");
//  viewPort.setAttribute('content', 'width=device-width; minimum-scale=0.1; maximum-scale=1; user-scalable=yes');
//
//  JasperMobile.htmlHandler.setSize("#frame", "300%", "300%");
//
//  var timeInterval = setInterval(function () {
//    var dashlets = jQuery('.dashlet');
//    if (dashlets.length > 0) {
//      JasperMobile.makeCallback.run("command:didEndLoading");
//      jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent()).css("pointer-events", "none");
//
//      window.clearInterval(timeInterval);
//
//      var timeIntervalDashletContent = setInterval(function() {
//        var dashletContent = jQuery('.dashletContent > div.content');
//
//        //var dashboardContentLength = jQuery.trim( dashletContent.html() ).length;
//
//        if (dashletContent.length === dashlets.length) {
//          JasperMobile.htmlHandler.changeClicker();
//          window.clearInterval(timeIntervalDashletContent);
//        }
//      }, 100);
//    }
//  }, 100);
//
//};
//
//jQuery(document).ready(domLoadedListener);
