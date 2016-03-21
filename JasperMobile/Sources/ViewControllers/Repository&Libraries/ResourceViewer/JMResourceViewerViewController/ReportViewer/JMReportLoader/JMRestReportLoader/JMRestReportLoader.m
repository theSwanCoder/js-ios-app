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
#import "JMHTMLParser.h"
#import "JMHTMLScript.h"

typedef void(^JMRestReportLoaderCompletion)(BOOL, NSError *);

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
//        if ([JMUtils isSupportNewRESTFlow]) {
//            self.needEmbeddableOutput = YES;
//        }
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
- (void)refreshReportWithCompletion:(JMRestReportLoaderCompletion)completion
{
    [self destroy];
    [super refreshReportWithCompletion: completion];
}

- (void)destroy
{
    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.injectContent"
                                                                             parameters:@{
                                                                                     @"HTMLString" : @""
                                                                             }];
    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);
                                    }];
}

#pragma mark - Private API
- (void)startLoadReportHTML
{
    [self prepareEnvironmentWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self renderReportWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    [super startLoadReportHTML];
                } else {
                    // TODO: extend errors handling
                    BOOL isParseError = YES;
                    if (isParseError) {
                        [self.webEnvironment loadHTML:self.report.HTMLString
                                              baseURL:[NSURL URLWithString:self.report.baseURLString]
                                           completion:nil];
                        [super startLoadReportHTML];
                    }
                }
            }];
        } else {
            // TODO: extend errors handling
            [self.webEnvironment loadHTML:self.report.HTMLString
                                  baseURL:[NSURL URLWithString:self.report.baseURLString]
                               completion:nil];
            [super startLoadReportHTML];
        }
    }];
}

#pragma mark - Prepear

- (void)prepareEnvironmentWithCompletion:(JMRestReportLoaderCompletion __nonnull)completion
{
    JMRestReportLoaderCompletion heapBlock = [completion copy];

    __weak __typeof(self) weakSelf = self;
    [self verifyIsContentDivCreatedWithCompletion:^(BOOL isCreated, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (isCreated) {
            heapBlock(YES, nil);
        } else {
            NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"resource_viewer" ofType:@"html"];
            NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

            __weak __typeof(self) weakSelf = self;
            [strongSelf.webEnvironment loadHTML:htmlString
                                        baseURL:[NSURL URLWithString:strongSelf.restClient.serverProfile.serverUrl]
                                     completion:^(BOOL isSuccess, NSError *error) {
                                         __typeof(self) strongSelf = weakSelf;
                                         if (isSuccess) {
                                             __weak __typeof(self) weakSelf = strongSelf;
                                             [strongSelf loadHighchartScriptsWithCompletion:^(BOOL success, NSError *error) {
                                                 __typeof(self) strongSelf = weakSelf;
                                                 if (success) {
                                                     [strongSelf loadFusionScriptsWithCompletion:^(BOOL i, NSError *error) {
                                                         if (success) {
                                                             heapBlock(YES, nil);
                                                         } else {
                                                             heapBlock(NO, error);
                                                         }
                                                     }];
                                                 } else {
                                                     heapBlock(NO, error);
                                                 }
                                             }];
                                         } else {
                                             heapBlock(NO, error);
                                         }
                                     }];
        }
    }];
}

- (void)verifyIsContentDivCreatedWithCompletion:(JMRestReportLoaderCompletion __nonnull)completion
{
    [self.webEnvironment verifyJasperMobileReadyWithCompletion:^(BOOL isWebViewLoaded) {
        completion(isWebViewLoaded, nil);
    }];
}

- (void)loadHighchartScriptsWithCompletion:(JMRestReportLoaderCompletion __nonnull)completion
{
    completion(YES, nil);

//    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    JMRestReportLoaderCompletion heapBlock = [completion copy];
//
//    NSString *serverURLString = self.restClient.serverProfile.serverUrl;
//    NSString *requireJSURLString = [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/render/scripts/require/require-2.1.6.src.js"];
//    NSDictionary *params = @{
//            @"scriptURL" : requireJSURLString,
//    };
//    JMJavascriptRequest *requireJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScript"
//                                                                             parameters:params];
//    [self.webEnvironment sendJavascriptRequest:requireJSLoadRequest
//                                    completion:^(NSDictionary *params, NSError *error) {
//                                        JMLog(@"JasperMobile.Helper.loadScript");
//                                        JMLog(@"params: %@", params);
//                                        JMLog(@"error: %@", error);
//                                        if (params) {
//
//                                            NSString *renderChartJSURLString = [NSString stringWithFormat:@"%@/%@", serverURLString, @"reportresource?resource=com/jaspersoft/jasperreports/highcharts/charts/resources/highcharts.chart.producer.js"];
//                                            params = @{
//                                                    @"scriptURL" : renderChartJSURLString,
//                                            };
//                                            JMJavascriptRequest *renderChartJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScript"
//                                                                                                                         parameters:params];
//
//                                            [self.webEnvironment sendJavascriptRequest:renderChartJSLoadRequest
//                                                                            completion:^(NSDictionary *params, NSError *error) {
//                                                                                JMLog(@"JasperMobile.Helper.loadScript");
//                                                                                JMLog(@"params: %@", params);
//                                                                                JMLog(@"error: %@", error);
//                                                                                if (params) {
//                                                                                    heapBlock(YES, nil);
//                                                                                } else {
//                                                                                    heapBlock(NO, error);
//                                                                                }
//                                                                            }];
//                                        } else {
//                                            heapBlock(NO, error);
//                                        }
//                                    }];
}

- (void)loadFusionScriptsWithCompletion:(JMRestReportLoaderCompletion __nonnull)completion
{
    completion(YES, nil);
//    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//
//    JMRestReportLoaderCompletion heapBlock = [completion copy];
//
//    NSString *serverURLString = self.restClient.serverProfile.serverUrl;
//    NSString *requireJSURLString = [NSString stringWithFormat:@"%@//%@", serverURLString, @"fusion/maps/FusionCharts.js"];
//    NSDictionary *params = @{
//            @"scriptURL" : requireJSURLString,
//    };
//    JMJavascriptRequest *fusionJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScript"
//                                                                            parameters:params];
//    [self.webEnvironment sendJavascriptRequest:fusionJSLoadRequest
//                                    completion:^(NSDictionary *params, NSError *error) {
//                                        JMLog(@"JasperMobile.Helper.loadScript");
//                                        JMLog(@"params: %@", params);
//                                        JMLog(@"error: %@", error);
//
//                                        if (params) {
//                                            heapBlock(YES, nil);
//                                        } else {
//                                            heapBlock(NO, error);
//                                        }
//                                    }];
}

#pragma mark - Render Report

- (void)renderReportWithCompletion:(JMRestReportLoaderCompletion __nonnull)completion
{
    void(^heapBlock)(BOOL, NSError *) = [completion copy];

    [self.restClient reportComponentForReportWithExecutionId:self.report.requestId
                                                  pageNumber:self.report.currentPage
                                                  completion:^(NSArray <JSReportComponent *>*components, NSError *error) {
                                                      if (components) {
                                                          self.report.reportComponents = components;

                                                          JMHTMLParser *parser = [JMHTMLParser parserWithHTMLString:self.report.HTMLString];
                                                          [parser parse];
                                                          NSString *bodyHTMLString = [parser content];
                                                          NSArray *scripts = parser.scripts;

                                                          if (!bodyHTMLString) {
                                                              // TODO: add error codes
                                                              NSError *error = [NSError errorWithDomain:@"Parse HTML Error"
                                                                                                   code:0
                                                                                               userInfo:@{
                                                                                                       NSLocalizedDescriptionKey: @"Parse HTML Error"
                                                                                               }];
                                                              heapBlock(NO, error);
                                                          } else {
                                                              if (self.report.isElasticChart) {
                                                                  JSReportComponent *component = self.report.reportComponents.firstObject;
                                                                  NSDictionary *hcinstacedata = ((JSReportComponentChartStructure *)component.structure).hcinstancedata;
                                                                  NSString *renderTo = hcinstacedata[@"renderto"];
                                                                  bodyHTMLString = [NSString stringWithFormat:@"<div id='%@'></div>", renderTo];
                                                              }

                                                              [self renderReportWithHTML:bodyHTMLString
                                                                                 scripts:scripts
                                                                              completion:heapBlock];
                                                          }

                                                      } else {
                                                          heapBlock(NO, error);
                                                      }
                                                  }];
}

- (void)renderReportWithHTML:(NSString *)HTMLString
                     scripts:(NSArray <NSString *>*)scripts
                  completion:(JMRestReportLoaderCompletion __nonnull)completion
{
    NSDictionary *params = @{
            @"HTMLString" : HTMLString
    };
    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.injectContent"
                                                                             parameters:params];

    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.injectContent");
//                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);

                                        NSMutableArray *links = [NSMutableArray new];
                                        NSMutableArray *renderHighchartScripts = [NSMutableArray new];
                                        NSMutableArray *sources = [NSMutableArray new];
                                        for (JMHTMLScript *script in scripts) {
                                            switch(script.type) {
                                                case JMHTMLScriptTypeLink: {
                                                    [links addObject:script.value];
                                                    break;
                                                }
                                                case JMHTMLScriptTypeRenderHighchart: {
                                                    [renderHighchartScripts addObject:script.value];
                                                    break;
                                                }
                                                case JMHTMLScriptTypeSource: {
                                                    [sources addObject:script.value];
                                                    break;
                                                }
                                                case JMHTMLScriptTypeOther: {
                                                    break;
                                                }
                                            }
                                        }

                                        [self loadScriptsFromLinks:links
                                                        completion:^(BOOL success, NSError *error) {
                                                            if (success) {

                                                                if (sources.count) {
                                                                    [self executeOtherScripts:sources
                                                                                   completion:completion];
                                                                }

                                                                if (renderHighchartScripts.count) {
                                                                    [self renderHighchartsWithScripts:renderHighchartScripts
                                                                                       isElasticChart:self.report.isElasticChart
                                                                                           completion:completion];
                                                                }
                                                            } else {
                                                                completion(NO, error);
                                                            }
                                                        }];

                                        // report without chart scripts
                                        if (links.count == 0) {
                                            if (completion) {
                                                completion(YES, nil);
                                            }
                                        }
                                    }];
}

- (void)loadScriptsFromLinks:(NSArray *)links
                  completion:(JMRestReportLoaderCompletion __nonnull)completion
{
    JMJavascriptRequest *loadDependenciesRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScripts"
                                                                                 parameters:@{
                                                                                         @"scriptURLs" : links,
                                                                                 }];
    [self.webEnvironment sendJavascriptRequest:loadDependenciesRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.loadScript");
                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);
                                        if (params) {
                                            completion(YES, nil);
                                        } else {
                                            completion(NO, error);
                                        }
                                    }];
}

- (void)renderHighchartsWithScripts:(NSArray *)scripts
                     isElasticChart:(BOOL)isElasticChart
                         completion:(JMRestReportLoaderCompletion __nonnull)completion
{
    JMJavascriptRequest *chartRenderRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.renderHighcharts"
                                                                           parameters:@{
                                                                                   @"scripts"         : scripts,
                                                                                   @"isElasticChart"  : isElasticChart ? @"true" : @"false"
                                                                           }];
    [self.webEnvironment sendJavascriptRequest:chartRenderRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.renderHighcharts");
//                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);

                                        if (params) {
                                            completion(YES, nil);
                                        } else {
                                            completion(NO, error);
                                        }
                                    }];
}

- (void)executeOtherScripts:(NSArray *)scripts
                 completion:(JMRestReportLoaderCompletion __nonnull)completion
{
    JMJavascriptRequest *chartRenderRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.executeScripts"
                                                                           parameters:@{
                                                                                   @"scripts" : scripts,
                                                                           }];
    [self.webEnvironment sendJavascriptRequest:chartRenderRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.executeScripts");
//                                        JMLog(@"params: %@", params);
                                        JMLog(@"error: %@", error);

                                        if (params) {
                                            completion(YES, nil);
                                        } else {
                                            completion(NO, error);
                                        }
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
