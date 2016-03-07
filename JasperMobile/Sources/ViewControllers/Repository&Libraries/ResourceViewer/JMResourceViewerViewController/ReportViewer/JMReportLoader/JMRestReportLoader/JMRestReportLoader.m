/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMRestReportLoader.m
//  TIBCO JasperMobile
//

#import "JMRestReportLoader.h"
#import "NSObject+Additions.h"
#import "JMReportViewerVC.h"
#import "JMWebEnvironment.h"
#import "JMVisualizeManager.h"

typedef NS_ENUM(NSInteger, JMReportType) {
    JMReportTypeChart,
    JMReportTypeTable,
    JMReportTypeFusion,
    JMReportTypeMix,
};

@interface JSReportLoader (LoadHTML)
- (void)startLoadReportHTML;
@end

@interface JMRestReportLoader()
@property (nonatomic, weak) JMWebEnvironment *webEnvironment;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@end

@implementation JMRestReportLoader

#pragma mark - Initializers
- (id <JMReportLoaderProtocol>)initWithReport:(JSReport *)report restClient:(JSRESTBase *)restClient webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [super initWithReport:report
                      restClient:restClient];
    if (self) {
        _webEnvironment = webEnvironment;
    }
    return self;
}

+ (id <JMReportLoaderProtocol>)loaderWithReport:(JSReport *)report restClient:(JSRESTBase *)restClient webEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithReport:report
                             restClient:restClient
                         webEnvironment:webEnvironment];
}

#pragma mark - Public API
- (void)refreshReportWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    [self.webEnvironment clean];
    [super refreshReportWithCompletion: completion];
}

- (void)destroy
{
//    [self.webEnvironment clean];

    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest new];
    injectContentRequest.command = @"JasperMobile.Helper.injectContent";
    injectContentRequest.parametersAsString = @"\"\"";
    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);
                                    }];
}

#pragma mark - Private API
- (void)startLoadReportHTML
{
    [self verifyIsContentDivCreatedWithCompletion:^(BOOL isCreated, NSError *error) {
        NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"resource_viewer" ofType:@"html"];
        NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

        NSString *bodyHTMLString = [self extractBodyFromPage:self.report.HTMLString];

        // extract scripts
        NSArray *scripts = [self scriptsFromPage:bodyHTMLString];
        bodyHTMLString = [self removeScripts:scripts fromPage:bodyHTMLString];
//    JMLog(@"scripts: %@", scripts);

        NSString *scriptsString = @"";
        NSString *renderChartScript;
        for (NSString *script in scripts) {
            if ([script containsString:@"__renderHighcharts"]) {
                // get folder to render
                renderChartScript = script;
                continue;
            }
            scriptsString = [scriptsString stringByAppendingString:script];
        }

        if (isCreated) {
            [self fetchReportComponentsWithCompletion:^(NSDictionary *components, NSError *error) {

                if (components) {
                    JMReportType reportType = [self detectReportTypeFromComponents:components];

                    if (reportType == JMReportTypeChart) {
                        JMLog(@"renderChartScript: %@", renderChartScript);
                        NSString *componentId = components.allKeys.firstObject;
                        NSDictionary *component = components[componentId];
                        [self showChartReportWithComponent:component];
                    } else if (reportType == JMReportTypeFusion) {
                        [self showFusionReportWithComponents:components
                                                     content:bodyHTMLString];
                    } else if (reportType == JMReportTypeTable) {
                        [self showTableReportWithContent:bodyHTMLString];
                    } else if (reportType == JMReportTypeMix) {
                        [self showMixReportWithContent:bodyHTMLString
                                     renderChartScript:renderChartScript];
                    }

                    // TODO: add for table only
                } else {
                    // TODO: add error handling
                }
            }];
        } else {
            htmlString = [htmlString stringByReplacingOccurrencesOfString:@"SCRIPTS"
                                                               withString:scriptsString];

            [self.webEnvironment loadHTML:htmlString
                                  baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]
                               completion:^(BOOL isSuccess, NSError *error) {
                                   if (isSuccess) {

                                       [self fetchReportComponentsWithCompletion:^(NSDictionary *components, NSError *error) {

                                           if (components) {
                                               JMReportType reportType = [self detectReportTypeFromComponents:components];

                                               if (reportType == JMReportTypeChart) {
                                                   JMLog(@"renderChartScript: %@", renderChartScript);
                                                   NSString *componentId = components.allKeys.firstObject;
                                                   NSDictionary *component = components[componentId];
                                                   [self showChartReportWithComponent:component];
                                               } else if (reportType == JMReportTypeFusion) {
                                                   [self showFusionReportWithComponents:components
                                                                                content:bodyHTMLString];
                                               } else if (reportType == JMReportTypeTable) {
                                                   [self showTableReportWithContent:bodyHTMLString];
                                               } else if (reportType == JMReportTypeMix) {
                                                   [self showMixReportWithContent:bodyHTMLString
                                                                renderChartScript:renderChartScript];
                                               }

                                               // TODO: add for table only
                                           } else {
                                               // TODO: add error handling
                                           }
                                       }];

                                   } else {
                                       JMLog(@"error: %@", error);
                                   }
                               }];
        }

        [super startLoadReportHTML];
    }];
}

- (void)verifyIsContentDivCreatedWithCompletion:(void(^ __nonnull)(BOOL isCreated, NSError *error))completion
{
    [self.webEnvironment verifyJasperMobileReadyWithCompletion:^(BOOL isWebViewLoaded) {
        completion(isWebViewLoaded, nil);
    }];
//
//
//    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.verifyEnvironmentIsReady"
//                                                        parametersAsString:nil];
//
//    [self.webEnvironment sendJavascriptRequest:request
//                                    completion:^(NSDictionary *params, NSError *error) {
//                                        JMLog(@"JasperMobile.Report.REST.API.verifyEnvironmentIsReady");
//                                        JMLog(@"params: %@", params);
//                                        JMLog(@"error: %@", error);
//
//
//                                        completion(NO, error);
//                                    }];
}

- (NSString *)extractBodyFromPage:(NSString *)page
{
    NSRange pageRange = NSMakeRange(0, page.length);
    NSRange startBodyRange = [page rangeOfString:@"<body"];
    pageRange.location = startBodyRange.location;
    pageRange.length -= pageRange.location;
    NSRange startBodyCloseBracket = [page rangeOfString:@">"
                                                options:NSCaseInsensitiveSearch
                                                  range:pageRange];
    startBodyRange.length = startBodyCloseBracket.location + startBodyCloseBracket.length - startBodyRange.location;
    NSRange endBodyRange = [page rangeOfString:@"</body>"];

    NSUInteger bodyRangeLocation = startBodyRange.location + startBodyRange.length;
    NSUInteger bodyRangeLength = endBodyRange.location - bodyRangeLocation;
    NSRange bodyRange = NSMakeRange(bodyRangeLocation, bodyRangeLength);
    NSString *bodyString = [page substringWithRange:bodyRange];

    return bodyString;
}

- (NSArray *)scriptsFromPage:(NSString *)page
{
    NSMutableArray *scripts = [@[] mutableCopy];

    NSRange searchRange = NSMakeRange(0, page.length);

    NSUInteger startSearchLength = searchRange.length;
    while (searchRange.location <= startSearchLength) {
        NSRange startScriptRange = [page rangeOfString:@"<script"
                                          options:NSCaseInsensitiveSearch
                                            range:searchRange];

        if (startScriptRange.length == 0) {
            break;
        }

        NSRange endScriptRange = [page rangeOfString:@"</script>"
                                             options:NSCaseInsensitiveSearch
                                               range:searchRange];

        NSUInteger scriptRangeLocation = startScriptRange.location;
        NSUInteger scriptRangeLength = endScriptRange.location + endScriptRange.length - scriptRangeLocation;
        NSRange scriptRange = NSMakeRange(scriptRangeLocation, scriptRangeLength);
        NSString *script = [page substringWithRange:scriptRange];

        [scripts addObject:script];

        searchRange.location = endScriptRange.location + endScriptRange.length;
        searchRange.length = startSearchLength - searchRange.location;
    }

    return scripts;
}

- (NSString *)removeScripts:(NSArray *)scripts fromPage:(NSString *)page
{
    NSString *pageWithoutScripts = page;
    for (NSString *script in scripts) {
        pageWithoutScripts = [pageWithoutScripts stringByReplacingOccurrencesOfString:script withString:@""];
    }

    return pageWithoutScripts;
}

- (NSString *)removeSpecSymbolsFromSting:(NSString *)string
{
    NSString *cleanString = string;
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"   " withString:@" "];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"    " withString:@" "];
    return cleanString;
}

- (void)fetchReportComponentsWithCompletion:(void(^)(NSDictionary *components, NSError *error))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    self.sessionDataTask = [session dataTaskWithRequest:[self requestForGettingReportComponents]
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          NSError *serializationError;
                                          NSDictionary *components = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingMutableContainers
                                                                                                       error:&serializationError];
                                          if (components) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (completion) {
                                                      completion(components, nil);
                                                  } else {
                                                      completion(nil, error);
                                                  }
                                              });
                                          } else {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  completion(nil, serializationError);
                                              });
                                          }
                                      }];
    [self.sessionDataTask resume];
}

- (NSURLRequest *)requestForGettingReportComponents
{
    NSString *getComponentsURLString = [NSString stringWithFormat:@"%@/getReportComponents.html", self.restClient.serverProfile.serverUrl];
    NSURL *getComponentsURL = [NSURL URLWithString:getComponentsURLString];
    NSString *method = @"POST";

    NSMutableURLRequest *getComponentsRequest = [NSMutableURLRequest requestWithURL:getComponentsURL];
    getComponentsRequest.HTTPMethod = method;
    [getComponentsRequest setValue:@"application/x-www-form-urlencoded"
                forHTTPHeaderField:@"Content-Type"];
    [getComponentsRequest setValue:@"application/json"
                forHTTPHeaderField:@"Accept"];

    NSString *parameters = [NSString stringWithFormat:@"jasperPrintName=%@&pageIndex=0", self.report.requestId];
    NSData *paramsData = [parameters dataUsingEncoding:NSASCIIStringEncoding];
    getComponentsRequest.HTTPBody = paramsData;

    return getComponentsRequest;
}

- (JMReportType)detectReportTypeFromComponents:(NSDictionary *)components
{
    __block BOOL isContainChart = NO;
    __block BOOL isContainTable = NO;
    __block BOOL isContainFusion = NO;
    [components enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        NSString *type = obj[@"type"];
        if ([type isEqualToString:@"chart"]) {
            isContainChart = YES;
        } else if ([type isEqualToString:@"fusionWidget"]) {
            JMLog(@"fusion widget");
            isContainFusion = YES;
        } else if ([type isEqualToString:@"hyperlinks"]) {
            JMLog(@"hyperlinks");
        } else if ([type isEqualToString:@"table"]) {
            isContainTable = YES;
        }
    }];

    JMReportType reportType = JMReportTypeMix;
    if (isContainChart && !isContainTable && !isContainFusion) {
        reportType = JMReportTypeChart;
    } else if (isContainTable && !isContainChart && !isContainFusion) {
        reportType = JMReportTypeTable;
    } else if (isContainFusion && !isContainChart && !isContainTable) {
        reportType = JMReportTypeFusion;
    }

    return reportType;
}

- (void)showChartReportWithComponent:(NSDictionary *)componentJSON
{
    // create div for chart
    NSDictionary *hcinstacedata = componentJSON[@"hcinstancedata"];
    NSDictionary *globalOptions = componentJSON[@"globalOptions"];
    NSString *renderTo = hcinstacedata[@"renderto"];
    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.injectContent"
                                                                     parametersAsString:[NSString stringWithFormat:@"\"<div id=\\\"%@\\\"></div>\"", renderTo]];

    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Helper.injectContent");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);

                                        // render chart
                                        NSDictionary *servicesJSON = @{
                                                @"services" : hcinstacedata[@"services"]
                                        };
                                        NSDictionary *chartDimensionsJSON = @{
                                                @"chartDimensions" : @{
                                                        @"width" : hcinstacedata[@"width"],
                                                        @"height" : hcinstacedata[@"height"],
                                                }
                                        };
                                        NSDictionary *requirejsConfigJSON = @{
                                                @"requirejsConfig" : @{
                                                        @"baseUrl" : @"",
                                                        @"paths" : @{
                                                                @"jquery" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/jquery-1.10.2.min.js",
                                                                @"highcharts" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/highcharts-4.1.8.src.js",
                                                                @"highcharts-more" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/highcharts-more-4.1.8.src.js",
                                                                @"heatmap" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/highcharts-heatmap-4.1.8.src.js",
                                                                @"treemap" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/highcharts-treemap-4.1.8.src.js",
                                                                @"adhocHighchartsSettingService" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/reportresource?resource=com/jaspersoft/ji/adhoc/jr/require/adhocHighchartsSettingService.js",
                                                                @"underscore" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/lodash.custom/dist/lodash.custom.js",
                                                                @"xssUtil" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/js-sdk/src/common/util/xssUtil.js",
                                                                @"grouped-categories" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/highcharts-pack/highcharts/grouped-categories.js",
                                                                @"adhoc/chart/ext/multiplePieTitlesExt" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/bi-report/src/adhoc/chart/ext/multiplePieTitlesExt.js",
                                                                @"adhoc/chart/palette/defaultPalette" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/bi-report/src/adhoc/chart/palette/defaultPalette.js",
                                                                @"adhoc/chart/enum/dateTimeFormats" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/bi-report/src/adhoc/chart/enum/dateTimeFormats.js",
                                                                @"adhoc/chart/enum/adhocToHighchartsTypes" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/bi-report/src/adhoc/chart/enum/adhocToHighchartsTypes.js",
                                                                @"adhoc/chart/adhocDataProcessor" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/bi-report/src/adhoc/chart/adhocDataProcessor.js",
                                                                @"adhoc/chart/highchartsDataMapper" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/bi-report/src/adhoc/chart/highchartsDataMapper.js",
                                                                @"adhoc/highcharts.api" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/bi-report/src/adhoc/chart/adhocToHighchartsAdapter.js",
                                                                @"adhoc/chart/Highcharts" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/bi-report/src/adhoc/chart/Highcharts.js",
                                                                @"json3" : @"http://mobiledemo2.jaspersoft.com/jasperserver-pro/scripts/bower_components/json3/lib/json3.js"
                                                        },
                                                        @"shim" : @{
                                                                @"highcharts" : @{
                                                                        @"exports" : @"Highcharts",
                                                                        @"deps" : @[
                                                                                @"jquery"
                                                                        ]
                                                                },
                                                                @"highcharts-more" : @{
                                                                        @"exports" : @"Highcharts",
                                                                        @"deps" : @[
                                                                                @"highcharts",
                                                                                @"heatmap",
                                                                                @"treemap"
                                                                        ]
                                                                },
                                                                @"heatmap" : @{
                                                                        @"exports" : @"Highcharts",
                                                                        @"deps" : @[
                                                                                @"highcharts"
                                                                        ]
                                                                },
                                                                @"treemap" : @{
                                                                        @"exports" : @"Highcharts",
                                                                        @"deps" : @[
                                                                                @"heatmap",
                                                                        ]
                                                                },
                                                                @"grouped-categories" : @{
                                                                        @"exports" : @"Highcharts",
                                                                        @"deps" : @[
                                                                                @"underscore",
                                                                        ]
                                                                }
                                                        }

                                                }
                                        };
                                        NSDictionary *renderToJSON = @{
                                                @"renderTo" : renderTo
                                        };
                                        NSDictionary *globalOptionsJSON = @{
                                                @"globalOptions" : globalOptions
                                        };

                                        NSDictionary *parameters = @{
                                                @"services"        : servicesJSON[@"services"],
                                                @"chartDimensions" : chartDimensionsJSON[@"chartDimensions"],
                                                @"requirejsConfig" : requirejsConfigJSON[@"requirejsConfig"],
                                                @"renderTo"        : renderToJSON[@"renderTo"],
                                                @"globalOptions"   : globalOptionsJSON[@"globalOptions"],
                                        };
                                        NSError *serializeError;
                                        NSData *componentData = [NSJSONSerialization dataWithJSONObject:parameters
                                                                                                options:NSJSONWritingPrettyPrinted
                                                                                                  error:&serializeError];

                                        NSString *componentDataAsString = [[NSString alloc] initWithData:componentData encoding:NSUTF8StringEncoding];

                                        NSString *renderFullScreen = @"true";
                                        NSString *parametersAsString = [NSString stringWithFormat:@"%@, %@, %@", @"__renderHighcharts", componentDataAsString, renderFullScreen];
                                        JMJavascriptRequest *chartRenderRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.renderChart"
                                                                                                       parametersAsString:parametersAsString];
                                        [self.webEnvironment sendJavascriptRequest:chartRenderRequest
                                                                        completion:^(NSDictionary *params, NSError *error) {
                                                                            JMLog(@"JasperMobile.Report.REST.API.renderChart");
                                                                            JMLog(@"params: %@", params);
                                                                            JMLog(@"error: %@", error);
                                                                        }];
                                    }];
}

- (void)showFusionReportWithComponents:(NSDictionary *)components content:(NSString *)content
{
    [self.webEnvironment addListenerWithId:@"JasperMobile.listener.hyperlink"
                                  callback:^(NSDictionary *params, NSError *error) {
                                      JMLog(@"JasperMobile.listener.hyperlink");
                                      JMLog(@"params: %@", params);
                                      JMLog(@"error: %@", error);
                                      [self handleRunReportWithParameters:params];
                                  }];

    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.injectContent"
                                                                     parametersAsString:[NSString stringWithFormat:@"\"%@\"", [self removeSpecSymbolsFromSting:content]]];
    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Helper.injectContent");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);


                                        __block NSDictionary *hyperlinks;
                                        [components enumerateKeysAndObjectsUsingBlock:^(NSString *componentId, NSDictionary *component, BOOL *stop) {
                                            NSString *componentType = component[@"type"];
                                            if ([componentType isEqualToString:@"hyperlinks"]) {
                                                hyperlinks = component[@"hyperlinks"];
                                                *stop = YES;
                                            }
                                        }];

                                        if (hyperlinks) {
                                            NSError *error;
                                            NSData *hyperlinksData = [NSJSONSerialization dataWithJSONObject:hyperlinks
                                                                                                    options:NSJSONWritingPrettyPrinted
                                                                                                      error:&error];
                                            NSString *hyperlinksAsString = [[NSString alloc] initWithData:hyperlinksData encoding:NSUTF8StringEncoding];
                                            JMJavascriptRequest *addHyperlinksRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.addHyperlinks"
                                                                                                           parametersAsString:hyperlinksAsString];
                                            [self.webEnvironment sendJavascriptRequest:addHyperlinksRequest
                                                                            completion:^(NSDictionary *params, NSError *error) {
                                                                                JMLog(@"JasperMobile.Report.REST.API.hyperlinks");
                                                                                JMLog(@"params: %@", params);
                                                                                JMLog(@"error: %@", error);
                                                                            }];
                                        }
                                    }];
}

- (void)showTableReportWithContent:(NSString *)bodyHTMLString
{
    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.injectContent"
                                                                     parametersAsString:[NSString stringWithFormat:@"\"%@\"", [self removeSpecSymbolsFromSting:bodyHTMLString]]];
    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Helper.injectContent");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);
                                    }];
}

- (void)showMixReportWithContent:(NSString *)bodyHTMLString renderChartScript:(NSString *)renderChartScript
{
    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.injectContent"
                                                                     parametersAsString:[NSString stringWithFormat:@"\"%@\"", [self removeSpecSymbolsFromSting:bodyHTMLString]]];
    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Helper.injectContent");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);

                                        if (!renderChartScript) {
                                            JMLog(@"there isn't chart script");
                                            return;
                                        }
                                        JMJavascriptRequest *renderScriptRequest = [JMJavascriptRequest requestWithScript:renderChartScript];
                                        if (!renderScriptRequest) {
                                            return;
                                        }
                                        [self.webEnvironment sendJavascriptRequest:renderScriptRequest
                                                                        completion:^(NSDictionary *params, NSError *error) {
                                                                            JMLog(@"renderChartScript");
                                                                            JMLog(@"params: %@", params);
                                                                            JMLog(@"error: %@", error);
                                                                        }];
                                    }];
}

#pragma mark - Handle Hyperlinks
- (void)handleRunReportWithParameters:(NSDictionary *)parameters
{
    NSDictionary *params = parameters[@"params"];
    NSString *reportPath = params[@"_report"];
    if (reportPath) {
        [self.restClient resourceLookupForURI:reportPath resourceType:kJS_WS_TYPE_REPORT_UNIT
                                   modelClass:[JSResourceLookup class]
                              completionBlock:^(JSOperationResult *result) {
            NSError *error = result.error;
            if (error) {
                NSString *errorString = error.localizedDescription;
                JSReportLoaderErrorType errorType = JSReportLoaderErrorTypeUndefined;
                if (errorString && [errorString rangeOfString:@"unauthorized"].length) {
                    errorType = JSReportLoaderErrorTypeAuthentification;
                }
                JMLog(@"error: %@", error);
            } else {
                JSResourceLookup *resourceLookup = [result.objects firstObject];
                if (resourceLookup) {
                    resourceLookup.resourceType = kJS_WS_TYPE_REPORT_UNIT;

                    NSMutableArray *reportParameters = [NSMutableArray array];

                    JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:@"customerId"
                                                                                           value:@[params[@"customerId"]]];
                    [reportParameters addObject:reportParameter];

                    if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForResourceLookup:withParameters:)]) {
                        [self.delegate reportLoader:self didReceiveOnClickEventForResourceLookup:resourceLookup withParameters:[reportParameters copy]];
                    }
                }
            }
        }];
    }
}

@end
