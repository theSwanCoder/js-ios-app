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
- (instancetype)initWithReport:(JSReport *)report
                    restClient:(JSRESTBase *)restClient
{
    self = [super initWithReport:report restClient:restClient];
    return self;
}

+ (instancetype)loaderWithReport:(JSReport *)report
                      restClient:(JSRESTBase *)restClient
{
    return [[self alloc] initWithReport:report restClient:restClient];
}


- (id <JMReportLoaderProtocol>)initWithReport:(JSReport *)report
                                   restClient:(JSRESTBase *)restClient
                               webEnvironment:(JMWebEnvironment *)webEnvironment
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
                                        if (error) {
                                            [self.webEnvironment clean];
                                        }
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
                    JMLog(@"error of rendering report: %@", error.localizedDescription);
                    // TODO: extend errors handling
                    [self loadHTMLWithOldFlow];
                }
            }];
        } else {
            // TODO: extend errors handling
            [self loadHTMLWithOldFlow];
        }
    }];
}

- (void)loadHTMLWithOldFlow
{
    [self.webEnvironment loadHTML:self.report.HTMLString
                          baseURL:[NSURL URLWithString:self.report.baseURLString]
                       completion:^(BOOL isSuccess, NSError *error) {
                           JMJavascriptRequest *applyZoomRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.applyZoomForReport"
                                                                                                parameters:nil];
                           [self.webEnvironment sendJavascriptRequest:applyZoomRequest
                                                           completion:^(NSDictionary *params, NSError *error) {
                                                               if (error) {
                                                                   JMLog(@"error of applying zoom: %@", error);
                                                               }
                                                               [super startLoadReportHTML];
                                                           }];
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

            [strongSelf.webEnvironment loadHTML:htmlString
                                        baseURL:[NSURL URLWithString:strongSelf.restClient.serverProfile.serverUrl]
                                     completion:^(BOOL isSuccess, NSError *error) {
                                         if (isSuccess) {
                                             heapBlock(YES, nil);
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
    void(^heapBlock)(BOOL, NSError *) = [completion copy];

    NSDictionary *params = @{
            @"HTMLString" : HTMLString
    };
    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Report.REST.API.injectContent"
                                                                             parameters:params];

    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;
                                        JMLog(@"JasperMobile.Report.REST.API.injectContent");
                                        JMLog(@"error: %@", error);

                                        // separate scripts
                                        NSMutableArray *links = [NSMutableArray new];
                                        NSMutableArray *renderHighchartScripts = [NSMutableArray new];
                                        NSMutableArray *otherSources = [NSMutableArray new];
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
                                                    [otherSources addObject:script.value];
                                                    break;
                                                }
                                                case JMHTMLScriptTypeOther: {
                                                    break;
                                                }
                                            }
                                        }

                                        if (links.count == 0) { // report without chart scripts
                                            heapBlock(YES, nil);
                                        } else {
                                            __weak __typeof(self) weakSelf = strongSelf;
                                            [strongSelf loadDependenciesFromLinks:links
                                                                 completion:^(BOOL success, NSError *error) {
                                                                     __typeof(self) strongSelf = weakSelf;
                                                                     if (success) {
                                                                         if (otherSources.count) {
                                                                             __weak __typeof(self) weakSelf = strongSelf;
                                                                             [strongSelf executeOtherScripts:otherSources
                                                                                            completion:^(BOOL success, NSError *error) {
                                                                                                __typeof(self) strongSelf = weakSelf;
                                                                                                if (success) {
                                                                                                    if (renderHighchartScripts.count) {
                                                                                                        [strongSelf renderHighchartsWithScripts:renderHighchartScripts
                                                                                                                           isElasticChart:strongSelf.report.isElasticChart
                                                                                                                               completion:heapBlock];
                                                                                                    } else {
                                                                                                        heapBlock(YES, nil);
                                                                                                    }
                                                                                                } else {
                                                                                                    heapBlock(NO, error);
                                                                                                }
                                                                                            }];
                                                                         } else if (renderHighchartScripts.count) {
                                                                             [strongSelf renderHighchartsWithScripts:renderHighchartScripts
                                                                                                isElasticChart:strongSelf.report.isElasticChart
                                                                                                    completion:heapBlock];
                                                                         } else {
                                                                             heapBlock(YES, nil);
                                                                         }
                                                                     } else {
                                                                         heapBlock(NO, error);
                                                                     }
                                                                 }];
                                        }
                                    }];
}

- (void)loadDependenciesFromLinks:(NSArray *)links
                       completion:(JMRestReportLoaderCompletion __nonnull)completion
{
    JMJavascriptRequest *loadDependenciesRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScripts"
                                                                                 parameters:@{
                                                                                         @"scriptURLs" : links,
                                                                                 }];
    [self.webEnvironment sendJavascriptRequest:loadDependenciesRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Report.REST.API.loadScript");
//                                        JMLog(@"params: %@", params);
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
