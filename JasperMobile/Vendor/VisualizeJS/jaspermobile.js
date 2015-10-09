window.onerror = function myErrorHandler(errorMsg, url, lineNumber) {
    alert("Error occured: " + errorMsg);
    return false;
};
document.body.bgColor = "#f3f3f3";
var metaTag=document.createElement('meta');
metaTag.name = 'viewport';
metaTag.content = 'initial-scale=0.5, width=device-width, minimum-scale=0.5, maximum-scale=1';
document.getElementsByTagName('head')[0].appendChild(metaTag);
document.body.style.zoom = INITIAL_ZOOM;