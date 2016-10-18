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
#import "JMRESTWebEnvironment.h"
#import "JMHTMLParser.h"
#import "JMHTMLScript.h"
#import "JMJavascriptRequest.h"

typedef void(^JMRestReportLoaderCompletion)(BOOL, NSError *);

@interface JSReportLoader (LoadHTML)
- (void)startLoadReportHTML;
@end

@interface JMRestReportLoader()
@property (nonatomic, weak) JMRESTWebEnvironment *webEnvironment;
@end

@implementation JMRestReportLoader

#pragma mark - Initializers
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithRestClient:(JSRESTBase *)restClient
{
    self = [super initWithRestClient:restClient];
    return self;
}

+ (instancetype)loaderWithReport:(JSReport *)report
                      restClient:(JSRESTBase *)restClient
{
    return [[self alloc] initWithRestClient:restClient];
}


- (id <JMReportLoaderProtocol>)initWithRestClient:(JSRESTBase *)restClient
                                   webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [self initWithRestClient:restClient];
    if (self) {
        _webEnvironment = (JMRESTWebEnvironment *) webEnvironment;
    }
    return self;
}

+ (id<JMReportLoaderProtocol>)loaderWithRestClient:(nonnull JSRESTBase *)restClient
                                    webEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithRestClient:restClient
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
    if (self.webEnvironment.state == JMWebEnvironmentStateEnvironmentReady) {
        if (self.webEnvironment.isReusable) {
            JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"API.injectContent"
                                                                                    inNamespace:JMJavascriptNamespaceRESTReport
                                                                                     parameters:@{
                                                                                             @"HTMLString" : @"",
                                                                                             @"transformationScale" : @"0.0"
                                                                                     }];
            [self.webEnvironment sendJavascriptRequest:injectContentRequest
                                            completion:^(NSDictionary *params, NSError *error) {
                                                JMLog(@"params: %@", params);
                                                JMLog(@"error: %@", error);
                                                if (error) {
                                                    [self.webEnvironment clean];
                                                }
                                            }];
        } else {
            [self.webEnvironment clean];
        }
    }
}

- (void)fitReportViewToScreen
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.fitReportViewToScreen"
                                                               inNamespace:JMJavascriptNamespaceRESTReport
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:nil];
}

#pragma mark - Private API
- (void)startLoadReportHTML
{
    [self renderReportWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [super startLoadReportHTML];
        } else {
            JMLog(@"error of rendering report: %@", error.localizedDescription);
            // TODO: extend errors handling
            [self loadHTMLWithOldFlow];
        }
    }];
}

- (void)loadHTMLWithOldFlow
{
    [self.webEnvironment loadHTML:self.report.HTMLString
                          baseURL:[NSURL URLWithString:self.report.baseURLString]
                       completion:^(BOOL isReady, NSError *error) {
                           JMJavascriptRequest *applyZoomRequest = [JMJavascriptRequest requestWithCommand:@"API.applyZoomForReport"
                                                                                               inNamespace:JMJavascriptNamespaceRESTReport
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


#pragma mark - Preparing

- (void)cacheDependencies:(NSArray <NSString *>*)dependencies completion:(void(^)(void))completion
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

    __block NSInteger dependenciesCount = dependencies.count;
    for (NSString *dependencyURLString in dependencies) {

        NSURL *url = [NSURL URLWithString:dependencyURLString];
        NSURLSessionDataTask *downloadTask = [session dataTaskWithURL:url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if (--dependenciesCount == 0) {
                                                            if (completion) {
                                                                completion();
                                                            }
                                                        }
                                                        if (data) {
                                                            // cache
                                                            NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response
                                                                                                                                              data:data];
                                                            [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse
                                                                                                  forRequest:[NSURLRequest requestWithURL:url]];
                                                        }
                                                    }];
        [downloadTask resume];
    }
}

#pragma mark - Render Report

- (void)renderReportWithCompletion:(JMRestReportLoaderCompletion __nonnull)completion
{
    if (!self.report) {
        return;
    }

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
                     scripts:(NSArray <JMHTMLScript *>*)scripts
                  completion:(JMRestReportLoaderCompletion __nonnull)completion
{
    void(^heapBlock)(BOOL, NSError *) = [completion copy];

    NSDictionary *params = @{
            @"HTMLString" : HTMLString,
            @"transformationScale" : [JMUtils isIphone] ? @"0.25" : @"0.5"
    };
    JMJavascriptRequest *injectContentRequest = [JMJavascriptRequest requestWithCommand:@"API.injectContent"
                                                                            inNamespace:JMJavascriptNamespaceRESTReport
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
                                            if (script.value) {
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
                                        }

                                        if (links.count == 0) { // report without chart scripts
                                            heapBlock(YES, nil);
                                        } else {
                                            NSMutableArray *dependencies = [NSMutableArray new];
                                            NSDictionary *renderScript = renderHighchartScripts.firstObject;
                                            if (renderScript) {
                                                NSDictionary *scriptParams = renderScript[@"scriptParams"];
                                                if (scriptParams) {
                                                    NSDictionary *requirejsConfig = scriptParams[@"requirejsConfig"];
                                                    if (requirejsConfig) {
                                                        NSDictionary *paths = requirejsConfig[@"paths"];
                                                        if (paths) {
                                                            for (NSString *serviceName in paths) {
                                                                [dependencies addObject:paths[serviceName]];
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            [dependencies addObjectsFromArray:links];
                                            __weak __typeof(self) weakSelf = strongSelf;
                                            [strongSelf cacheDependencies:dependencies completion:^{
                                                __typeof(self) strongSelf = weakSelf;

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
                                            }];
                                        }
                                    }];
}

- (void)loadDependenciesFromLinks:(NSArray *)links
                       completion:(JMRestReportLoaderCompletion __nonnull)completion
{
    JMJavascriptRequest *loadDependenciesRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScripts"
                                                                               inNamespace:JMJavascriptNamespaceDefault
                                                                                 parameters:@{
                                                                                         @"scriptURLs" : links,
                                                                                 }];
    [self.webEnvironment sendJavascriptRequest:loadDependenciesRequest
                                    completion:^(NSDictionary *params, NSError *error) {
                                        JMLog(@"JasperMobile.Helper.loadScripts");
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
    JMJavascriptRequest *chartRenderRequest = [JMJavascriptRequest requestWithCommand:@"API.renderHighcharts"
                                                                          inNamespace:JMJavascriptNamespaceRESTReport
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
    JMJavascriptRequest *chartRenderRequest = [JMJavascriptRequest requestWithCommand:@"API.executeScripts"
                                                                          inNamespace:JMJavascriptNamespaceRESTReport
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

//                    if ([self.delegate respondsToSelector:@selector(reportLoader:didReceiveOnClickEventForResourceLookup:withParameters:)]) {
//                        [self.delegate reportLoader:self didReceiveOnClickEventForResourceLookup:resourceLookup withParameters:[reportParameters copy]];
//                    }
                }
            }
        }];
    }
}

@end
