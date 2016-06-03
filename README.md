TIBCO JasperMobile for iOS
==========================
[![Build Status](https://travis-ci.org/Jaspersoft/js-ios-app.svg?branch=develop)](https://travis-ci.org/Jaspersoft/js-ios-app/builds)

TIBCO JasperMobile for iOS is a native application which allows you to browse your JasperReports Server repository and view reports/dashboards in several formats.

It is built using the Jaspersoft Mobile SDK for iOS, and it is compatible with JasperReports Server 6.0 or higher, Community or Commercial editions.  

The source code of TIBCO JasperMobile for iOS is freely available and can be used as a good example of how to integrate reporting and analysis services of JasperReports Server with your own native applications.


General Information
--------------------

Please see the TIBCO JasperMobile for iOS Community project page:
http://community.jaspersoft.com/project/jaspermobile-ios

Installation
------------

The recommended approach for installing JaspersoftSDK for building application is via the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation. For best results, it is recommended that you install via **CocoaPods >= 0.19.1g Git >= 1.8.0** installed via Homebrew.

### via CocoaPods

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your TIBCO JasperMobile project, and Install pods into your project:

``` bash
$ pod install
```

Open your TIBCO JasperMobile project in Xcode from the .xcworkspace file (not the usual project file)

``` bash
$ open TIBCO JasperMobile.xcworkspace
```

License
-------

TIBCO JasperMobile app is licensed under the terms of the [GNU LESSER GENERAL PUBLIC LICENSE, version 3.0](http://www.gnu.org/licenses/lgpl). Please see the [LICENSE](LICENSE) file for full details.
