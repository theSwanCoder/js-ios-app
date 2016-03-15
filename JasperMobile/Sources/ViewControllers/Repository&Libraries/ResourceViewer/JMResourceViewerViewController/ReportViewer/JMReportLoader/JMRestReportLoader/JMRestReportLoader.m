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
#import "JMWebEnvironment.h"
#import "JSRestClient.h"


@interface JSReportLoader (LoadHTML)
- (void)startLoadReportHTML;
@end

@interface JMRestReportLoader()
@property (nonatomic, weak) JMWebEnvironment *webEnvironment;
@end

@implementation JMRestReportLoader

#pragma mark - Initializers
- (instancetype)initWithReport:(JSReport *)report restClient:(JSRESTBase *)restClient
{
    self = [super initWithReport:report restClient:restClient];
    return self;
}

+ (instancetype)loaderWithReport:(JSReport *)report restClient:(JSRESTBase *)restClient
{
    return [[self alloc] initWithReport:report restClient:restClient];
}


- (id <JMReportLoaderProtocol>)initWithReport:(JSReport *)report restClient:(JSRESTBase *)restClient webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [self initWithReport:report
                      restClient:restClient];
    if (self) {
        _webEnvironment = webEnvironment;
        if ([JMUtils isSupportNewRESTFlow]) {
            self.needEmbeddableOutput = YES;
        }
    }
    return self;
}

+ (id<JMReportLoaderProtocol>)loaderWithReport:(nonnull JSReport *)report
                                    restClient:(nonnull JSRESTBase *)restClient
                                webEnvironment:(JMWebEnvironment *)webEnvironment
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
    injectContentRequest.command = @"JasperMobile.Report.REST.API.injectContent";
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
    if ([JMUtils isSupportNewRESTFlow]) {
        [self verifyIsContentDivCreatedWithCompletion:^(BOOL isCreated, NSError *error) {
            NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"resource_viewer" ofType:@"html"];
            NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

            if (isCreated) {
                [self renderReportWithCompletion:^(BOOL success, NSError *error) {
                    if (success) {
                        [super startLoadReportHTML];
                    } else {
                        // TODO: add error handling
                    }
                }];
            } else {
                [self.webEnvironment loadHTML:htmlString
                                      baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]
                                   completion:^(BOOL isSuccess, NSError *error) {
                                       if (isSuccess) {
                                           [self renderReportWithCompletion:^(BOOL success, NSError *error) {
                                               if (success) {
                                                       [super startLoadReportHTML];
                                               } else {
                                                   // TODO: add error handling
                                               }
                                           }];
                                       } else {
                                           JMLog(@"error: %@", error);
                                       }
                                   }];
            }
        }];
    } else {
        // TODO: old flow
    }
}

- (void)verifyIsContentDivCreatedWithCompletion:(void(^ __nonnull)(BOOL isCreated, NSError *error))completion
{
    [self.webEnvironment verifyJasperMobileReadyWithCompletion:^(BOOL isWebViewLoaded) {
        completion(isWebViewLoaded, nil);
    }];
}

- (void)renderReportWithCompletion:(void(^)(BOOL, NSError *))completion
{
    NSString *bodyHTMLString = self.report.HTMLString;

    [self.restClient reportComponentForReportWithExecutionId:self.report.requestId
                                                  pageNumber:self.report.currentPage
                                                  completion:^(NSArray <JSReportComponent *>*components, NSError *error) {
                                                      if (components) {
                                                          self.report.reportComponents = components;

                                                          if (self.report.isElasticChart) {
                                                              JSReportComponent *component = self.report.reportComponents.firstObject;
                                                              NSDictionary *hcinstacedata = ((JSReportComponentChartStructure *)component.structure).hcinstancedata;
                                                              NSString *renderTo = hcinstacedata[@"renderto"];
                                                              NSString *HTMLString = [NSString stringWithFormat:@"\"<div id=\\\"%@\\\"></div>\"", renderTo];

                                                              [self renderReportWithHTML:HTMLString completion:completion];
                                                          } else {
                                                              [self renderReportWithHTML:[NSString stringWithFormat:@"\"%@\"", [self removeSpecSymbolsFromSting:bodyHTMLString]] completion:completion];
                                                          }
                                                      } else {
                                                          // TODO: add error handling
                                                      }
                                                  }];
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

- (void)renderReportWithHTML:(NSString *)HTMLString completion:(void(^ __nullable)(BOOL, NSError *))completion
{
    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.injectContent"
                                                                     parametersAsString:HTMLString];

    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.injectContent");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);

                                        NSMutableArray *highchartComponents = [NSMutableArray array];
                                        NSMutableArray *fusionComponents = [NSMutableArray array];
                                        for (JSReportComponent *component in self.report.reportComponents) {
                                            if (component.type == JSReportComponentTypeChart) {
                                                [highchartComponents addObject:component];
                                            } else if(component.type == JSReportComponentTypeFusion) {
                                                [fusionComponents addObject:component];
                                            }
                                        }

                                        if (fusionComponents.count) {
                                            [self loadFusionScriptsWithCompletion:^(BOOL success) {
                                                if (success) {
                                                    [self renderFusionWidgetsWithComponents:fusionComponents];
                                                    if (completion) {
                                                        completion(YES, nil);
                                                    }
                                                } else {
                                                    //TODO: handle errors
                                                }
                                            }];
                                        }

                                        if (highchartComponents.count) {
                                            [self loadHighchartScriptsWithCompletion:^(BOOL success) {
                                                if (success) {
                                                    if (self.report.isElasticChart) {
                                                        JSReportComponent *component = highchartComponents.firstObject;
                                                        [self renderAdhocHighchartWithComponent:component];
                                                    } else {
                                                        [self renderHighchartsWithComponents:highchartComponents];
                                                    }
                                                    if (completion) {
                                                        completion(YES, nil);
                                                    }
                                                } else {
                                                    //TODO: handle errors
                                                }
                                            }];
                                        }

                                        // report without chart scripts
                                        if (fusionComponents.count == 0 && highchartComponents.count == 0) {
                                            if (completion) {
                                                completion(YES, nil);
                                            }
                                        }
                                    }];
}

- (void)renderAdhocHighchartWithComponent:(JSReportComponent *)component
{
    NSDictionary *chartParams = [self highChartParametersFromComponenents:component];

    NSError *serializeError;
    NSData *componentData = [NSJSONSerialization dataWithJSONObject:chartParams
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&serializeError];

    NSString *componentDataAsString = [[NSString alloc] initWithData:componentData
                                                            encoding:NSUTF8StringEncoding];

    //renderAdHocHighchart
    NSString *parametersAsString = [NSString stringWithFormat:@"%@, %@", @"__renderHighcharts", componentDataAsString];
    JMJavascriptRequest *chartRenderRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.renderAdHocHighchart"
                                                                   parametersAsString:parametersAsString];

    [self.webEnvironment sendJavascriptRequest:chartRenderRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.renderAdHocHighchart");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);
                                    }];
}

- (void)renderHighchartsWithComponents:(NSArray <JSReportComponent *>*)components
{
    NSMutableArray *paramsForAllCharts = [@[] mutableCopy];
    for (JSReportComponent *component in components) {
        NSDictionary *chartParams = [self highChartParametersFromComponenents:component];
        [paramsForAllCharts addObject:chartParams];
    }

    NSError *serializeError;
    NSData *componentData = [NSJSONSerialization dataWithJSONObject:paramsForAllCharts
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&serializeError];

    NSString *componentDataAsString = [[NSString alloc] initWithData:componentData
                                                            encoding:NSUTF8StringEncoding];

    NSString *parametersAsString = [NSString stringWithFormat:@"%@, %@", @"__renderHighcharts", componentDataAsString];
    JMJavascriptRequest *chartRenderRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.renderHighcharts"
                                                                   parametersAsString:parametersAsString];

    [self.webEnvironment sendJavascriptRequest:chartRenderRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.renderHighcharts");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);
                                    }];
}

- (void)renderFusionWidgetsWithComponents:(NSArray <JSReportComponent *>*)components
{
    NSMutableArray *paramsForAllCharts = [@[] mutableCopy];
    for (JSReportComponent *component in components) {
        id chartParams = ((JSReportComponentFusionStructure *)component.structure).instanceData;
        [paramsForAllCharts addObject:chartParams];
    }

    NSError *serializeError;
    NSData *componentData = [NSJSONSerialization dataWithJSONObject:paramsForAllCharts
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&serializeError];

    NSString *componentDataAsString = [[NSString alloc] initWithData:componentData
                                                            encoding:NSUTF8StringEncoding];// paramsArray, jrsDomain


    NSString *parametersAsString = [NSString stringWithFormat:@"%@, %@", componentDataAsString, @"\"http://mobiledemo2.jaspersoft.com\""];
    JMJavascriptRequest *chartRenderRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.renderFusionWidgets"
                                                                   parametersAsString:parametersAsString];
    [self.webEnvironment sendJavascriptRequest:chartRenderRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.renderChart");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);
                                    }];
}

- (void)loadHighchartScriptsWithCompletion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    void(^heapBlock)(BOOL) = [completion copy];

    NSString *serverURLString = self.restClient.serverProfile.serverUrl;
    NSString *requireJSURLString = [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/require/require-2.1.6.src.js"];
    JMJavascriptRequest *requireJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScript"
                                                                   parametersAsString:[NSString stringWithFormat:@"\"%@\"", requireJSURLString]];
    [self.webEnvironment sendJavascriptRequest:requireJSLoadRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Helper.loadScript");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);
                                        if (params) {

                                            NSString *renderChartJSURLString = [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/resources/highcharts.chart.producer.js"];
                                            JMJavascriptRequest *renderChartJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScript"
                                                                                                             parametersAsString:[NSString stringWithFormat:@"\"%@\"", renderChartJSURLString]];

                                            [self.webEnvironment sendJavascriptRequest:renderChartJSLoadRequest
                                                                            completion:^(NSDictionary *params, NSError *error) {
                                                                                JMLog(@"JasperMobile.Helper.loadScript");
                                                                                JMLog(@"params: %@", params);
                                                                                JMLog(@"error: %@", error);
                                                                                if (params) {
                                                                                    heapBlock(YES);
                                                                                } else {
                                                                                    heapBlock(NO);
                                                                                }
                                                                            }];
                                        } else {
                                            heapBlock(NO);
                                        }
                                    }];
}

- (void)loadFusionScriptsWithCompletion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));

    void(^heapBlock)(BOOL) = [completion copy];
    NSString *serverURLString = self.restClient.serverProfile.serverUrl;
    NSString *requireJSURLString = [NSString stringWithFormat:@"%@//%@", serverURLString, @"fusion/maps/FusionCharts.js"];
    JMJavascriptRequest *fusionJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScript"
                                                                     parametersAsString:[NSString stringWithFormat:@"\"%@\"", requireJSURLString]];
    [self.webEnvironment sendJavascriptRequest:fusionJSLoadRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Helper.loadScript");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);

                                        if (params) {
                                            heapBlock(YES);
                                        } else {
                                            heapBlock(NO);
                                        }
                                    }];
}

- (NSDictionary *)highChartParametersFromComponenents:(JSReportComponent *)component
{
    NSDictionary *hcinstacedata = ((JSReportComponentChartStructure *)component.structure).hcinstancedata;
    NSString *renderTo = hcinstacedata[@"renderto"];

    // render chart
    NSDictionary *chartDimensionsJSON = @{
            @"width" : hcinstacedata[@"width"],
            @"height" : hcinstacedata[@"height"],
    };

    NSDictionary *globalOptions = ((JSReportComponentChartStructure *)component.structure).globalOptions;

    NSDictionary *parameters;
    if (globalOptions) {
        parameters = @{
                @"services"        : hcinstacedata[@"services"],
                @"chartDimensions" : chartDimensionsJSON,
                @"requirejsConfig" : [self requirejsConfigJSON],
                @"renderTo"        : renderTo,
                @"globalOptions"   : globalOptions,
        };
    } else {
        parameters = @{
                @"services"        : hcinstacedata[@"services"],
                @"chartDimensions" : chartDimensionsJSON,
                @"requirejsConfig" : [self requirejsConfigJSON],
                @"renderTo"        : renderTo,
        };
    }

    return parameters;
}

- (NSDictionary *)requirejsConfigJSON
{
    NSString *serverURLString = self.restClient.serverProfile.serverUrl;
    NSDictionary *paths = @{
            @"jquery"                                  : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/jquery-1.10.2.min.js"],
            @"highcharts"                              : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/highcharts-4.1.8.src.js"],
            @"highcharts-more"                         : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/highcharts-more-4.1.8.src.js"],
            @"heatmap"                                 : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/highcharts-heatmap-4.1.8.src.js"],
            @"treemap"                                 : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/highcharts-treemap-4.1.8.src.js"],
            @"dataSettingService"                      : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/services/require/data.service.js"],
            @"defaultSettingService"                   : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/services/require/default.service.js"],
            @"yAxisSettingService"                     : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/services/require/y.axis.service.js"],
            @"itemHyperlinkSettingService"             : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/services/require/item.hyperlink.service.js"],
            @"adhocHighchartsSettingService"           : [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/ji/adhoc/jr/require/adhocHighchartsSettingService.js"],
            @"adhoc/chart/ext/multiplePieTitlesExt"    : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/bi-report/src/adhoc/chart/ext/multiplePieTitlesExt.js"],
            @"adhoc/chart/palette/defaultPalette"      : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/bi-report/src/adhoc/chart/palette/defaultPalette.js"],
            @"adhoc/chart/enum/dateTimeFormats"        : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/bi-report/src/adhoc/chart/enum/dateTimeFormats.js"],
            @"adhoc/chart/enum/adhocToHighchartsTypes" : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/bi-report/src/adhoc/chart/enum/adhocToHighchartsTypes.js"],
            @"adhoc/chart/adhocDataProcessor"          : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/bi-report/src/adhoc/chart/adhocDataProcessor.js"],
            @"adhoc/chart/highchartsDataMapper"        : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/bi-report/src/adhoc/chart/highchartsDataMapper.js"],
            @"adhoc/highcharts.api"                    : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/bi-report/src/adhoc/chart/adhocToHighchartsAdapter.js"],
            @"adhoc/chart/Highcharts"                  : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/bi-report/src/adhoc/chart/Highcharts.js"],
            @"grouped-categories"                      : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/highcharts-pack/highcharts/grouped-categories.js"],
            @"underscore"                              : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/lodash.custom/dist/lodash.custom.js"],
            @"xssUtil"                                 : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/js-sdk/src/common/util/xssUtil.js"],
            @"json3"                                   : [NSString stringWithFormat:@"%@/%@", serverURLString, @"scripts/bower_components/json3/lib/json3.js"],
    };

    NSDictionary *requirejsConfigJSON = @{
            @"baseUrl" : @"",
            @"paths" : paths,
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

    };
    return requirejsConfigJSON;
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
