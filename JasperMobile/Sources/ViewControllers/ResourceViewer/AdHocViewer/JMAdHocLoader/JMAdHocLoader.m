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
//  JMAdHocLoader.m
//  TIBCO JasperMobile
//

#import "JMAdHocLoader.h"
#import "JMVIZWebEnvironment.h"
#import "JMResource.h"
#import "JMJavascriptRequest.h"
#import "JMJavascriptRequestExecutor.h"
#import "JMUtils.h"

@interface JMAdHocLoader()
@property (nonatomic, strong, readwrite) JMAdHoc *adHoc;
@property (nonatomic, weak) JMVIZWebEnvironment *webEnvironment;
@property (nonatomic, assign, readwrite) JMAdHocLoaderState state;
@property (nonatomic, copy, readwrite) JSRESTBase *restClient;
@end

@implementation JMAdHocLoader

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - Initializers
- (id<JMAdHocLoader> __nullable)initWithRESTClient:(JSRESTBase *)restClient
                                        webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment
{
    self = [super init];
    if (self) {
        NSAssert(restClient != nil, @"Parameter for rest client is nil");
        NSAssert([webEnvironment isKindOfClass:[JMVIZWebEnvironment class]], @"WebEnvironment isn't correct class");
        _webEnvironment = (JMVIZWebEnvironment *) webEnvironment;
        _state = JMAdHocLoaderState_Initial;
        _restClient = [restClient copy];
        [self addListenersForVisualizeEvents];
    }
    return self;
}

+ (id<JMAdHocLoader> __nullable)loaderWithRESTClient:(JSRESTBase *)restClient
                                          webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment
{
    return [[self alloc] initWithRESTClient:restClient
                             webEnvironment:webEnvironment];
}


#pragma mark - JMAdHocLoader required methods

- (void)runAdHoc:(JMAdHoc *)adHoc completion:(JMAdHocLoaderCompletion)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(adHoc != nil, @"AdHoc is nil");

    if (self.state == JMAdHocLoaderState_Cancel) {
        return;
    }

    self.adHoc = adHoc;
    self.state = JMAdHocLoaderState_Configured;
    if (self.state == JMAdHocLoaderState_Cancel) {
        return;
    }
    
    // run
    JMJavascriptRequest *runRequest = [JMJavascriptRequest requestWithCommand:@"API.run"
                                                                  inNamespace:JMJavascriptNamespaceVISAdHoc
                                                                   parameters:@{
                                                                                @"uri" : self.adHoc.resourceURI,
                                                                                }];
    self.state = JMAdHocLoaderState_Loading;
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:runRequest completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMAdHocLoaderState_Cancel) {
            return;
        }
        if (error) {
            completion(NO, error);
        } else {
            strongSelf.state = JMAdHocLoaderState_Ready;
            completion(YES, nil);
        }
    }];
}

- (void)reloadWithCompletion:(JMAdHocLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.adHoc != nil, @"AdHoc is nil");

    if (self.state == JMAdHocLoaderState_Cancel) {
        return;
    }

    JMAdHocLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.refresh"
                                                               inNamespace:JMJavascriptNamespaceVISAdHoc
                                                                parameters:nil];
    self.state = JMAdHocLoaderState_Loading;
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMAdHocLoaderState_Cancel) {
            return;
        }
        if (error) {
            strongSelf.state = JMAdHocLoaderState_Failed;
            heapBlock(NO, error);
        } else {
            strongSelf.state = JMAdHocLoaderState_Ready;
            heapBlock(YES, nil);
        }
    }];
}

- (void)destroy
{
    NSAssert(self.adHoc != nil, @"AdHoc is nil");

    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self removeListenersForVisualizeEvents];
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.destroy"
                                                               inNamespace:JMJavascriptNamespaceVISAdHoc
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        // Need capture self to wait until this request finishes
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
        }
    }];

    
    self.state = JMAdHocLoaderState_Destroy;
}

- (void)cancel
{
    NSAssert(self.adHoc != nil, @"AdHoc is nil");

    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self removeListenersForVisualizeEvents];
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.cancel"
                                                               inNamespace:JMJavascriptNamespaceVISAdHoc
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
        }
    }];
    
    self.state = JMAdHocLoaderState_Cancel;
}

#pragma mark - Helpers
- (void)addListenersForVisualizeEvents
{
    __weak __typeof(self) weakSelf = self;
    NSString *adHocExecutionLinkOptionListenerId = @"JasperMobile.VIS.Event.Link.AdHocExecution";
    [self.webEnvironment addListener:self forEventId:adHocExecutionLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(adHocExecutionLinkOptionListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                if (error) {
                                    JMLog(@"error: %@", error);
                                } else {
                                    [strongSelf handleOnAdHocExecution:params];
                                }
                            }];
}

- (void)removeListenersForVisualizeEvents
{
    [self.webEnvironment removeListener:self];
}

#pragma mark - Handle JS callbacks
- (void)handleOnAdHocExecution:(NSDictionary *)parameters
{
    JMLog(@"parameters: %@", parameters);
}

@end
