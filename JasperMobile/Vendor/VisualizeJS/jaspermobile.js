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

JasperMobile.auth = {
    name: "",
    password: "",
    organization: "",
    setCredentials : function(name, password, organization) {
        console.log("set credentials: name - " + name + " password - " + password + " organization - " + organization);
        JasperMobile.logger.log("set credentials" + " " + name + " " + password);
        this.name = name;
        this.password = password;
        this.organization = organization;
    }
};

    // Reports
    JasperMobile.report = {
        run: function(resourcePath, reportParameters) {
            visualize({
                        auth: {
                            name: JasperMobile.auth.name,
                            password: JasperMobile.auth.password,
                            organization: JasperMobile.auth.organization
                        }
                    }, function (v) {
                        console.log("run report for path: " + resourcePath + " and parameters: " + reportParameters);
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
        destroy: function() {
            console.log("destroy");
          JasperMobile.report.loader.destroy();
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

    var domLoadedListener = function() {
        JasperMobile.makeCallback.run("DOMContentLoaded");
    };
    document.addEventListener("DOMContentLoaded", domLoadedListener);

    //jQuery(document).ready(domLoadedListener);