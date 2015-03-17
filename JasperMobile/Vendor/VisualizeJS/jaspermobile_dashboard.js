var containerSize = {
    width : CONTAINER_SIZE_WIDTH,
    height : CONTAINER_SIZE_HEIGHT
};

var JasperMobile = {};
JasperMobile.htmlHandler = {
  changeClicker: function() {
    var elems = jQuery("div.dashboardCanvas > div.content > div.body > div");
    elems.unbind();
    elems.click(function() {
      var title = jQuery(this).find(".innerLabel > p")[0].textContent;

      JasperMobile.makeCallback.run("command:maximize&title:"+title);
      //JasperMobile.htmlHandler.setSize("#frame", "200%", "200%");
      jQuery('.dashlet').css("pointer-events", "auto");

      var button = jQuery(jQuery(this).find('div.dashletToolbar > div.content div.buttons > .maximizeDashletButton')[0]);
      button.click();
    });
  },
  minimizeDashlet: function() {
    JasperMobile.logger.log("minimize dashlet");
    jQuery("div.dashboardCanvas > div.content > div.body > div").find(".minimizeDashlet")[0].click();
    JasperMobile.htmlHandler.setSize("#frame", containerSize.width, containerSize.height);
    jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent()).css("pointer-events", "none");
  },
  setSize: function(el, widht, height) {
    JasperMobile.logger.log("set size " + jQuery(el).toString());
    jQuery(el).css("width", widht);
    jQuery(el).css("height", height);
  },
  setInterection: function(el, enable) {
    JasperMobile.logger.log("set interection " + jQuery(el).toString());
    if (enable == true) {
      jQuery(el).css("pointer-events", "auto");
    } else {
      jQuery(el).css("pointer-events", "none");
    }
  },
    disableTitles: function() {        
        jQuery('.header').hide();
        jQuery('.dashletToolbar').hide();
        jQuery('.show_chartTypeSelector_wrapper').hide();
        jQuery('.column.decorated').css( 'margin', '0px');
        jQuery('.column.decorated').css( 'border', 'none');
        jQuery('.dashboardViewer .dashboardContainer > .content > .body').css( 'top', '0px');
        jQuery('.column.decorated > .content > .body').css( 'top', '0px');
        jQuery('.column > .content > .body').css( 'top', '0px');
        jQuery('body').css( '-webkit-transform', 'translateZ(0) !important');
        jQuery('body').css( '-webkit-backface-visibility', 'hidden !important');
    }
};

JasperMobile.logger = {
  log : function (message) {
    //var xhr = new XMLHttpRequest();
    //xhr.open('GET', "http://debugger/" + encodeURIComponent(message));
    //xhr.send(null);
  }
};

JasperMobile.auth = {
  name: "",
  password: "",
  setCredentials : function(name, password) {
    JasperMobile.logger.log("set credentials" + " " + name + " " + password);
    this.name = name;
    this.password = password;
  }
};

JasperMobile.makeCallback = {
  run : function(data) {
    window.location.href = "http://jaspermobile.callback/" + data;
  }
};

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

// start point
var domLoadedListener = function() {
  var viewPort = document.querySelector("meta[name=viewport]");
  viewPort.setAttribute('content', 'width=device-width; minimum-scale=0.1; maximum-scale=1; user-scalable=yes');
  JasperMobile.htmlHandler.setSize("#frame", containerSize.width, containerSize.height);
  var timeInterval = setInterval(function () {
    var dashlets = jQuery('.dashlet');
    if (dashlets.length > 0) {
      JasperMobile.makeCallback.run("command:didEndLoading");
      jQuery('.dashlet').not(jQuery('.inputControlWrapper').parentsUntil('.dashlet').parent()).css("pointer-events", "none");

      window.clearInterval(timeInterval);

      var timeIntervalDashletContent = setInterval(function() {
        var dashletContent = jQuery('.dashletContent > div.content');

        //var dashboardContentLength = jQuery.trim( dashletContent.html() ).length;

        if (dashletContent.length === dashlets.length) {
          JasperMobile.htmlHandler.changeClicker();
           JasperMobile.htmlHandler.disableTitles();
          window.clearInterval(timeIntervalDashletContent);
        }
      }, 100);
    }
  }, 100);

};

jQuery(document).ready(domLoadedListener);
