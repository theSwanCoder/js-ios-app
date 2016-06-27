#import "JMResource.h"/*
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
//  JMAdhocViewerVC.h
//  TIBCO JasperMobile
//

#import "JMAdhocViewerVC.h"
#import "JMWebViewManager.h"
#import "JMVIZWebEnvironment.h"
#import "JMJavascriptRequest.h"

NSString *const kJMAdhocViewWebEnvironemntId = @"kJMAdhocViewWebEnvironemntId";

@interface JMAdhocViewerVC()
//@property (nonatomic, strong) JMResource *resource;
@end

@implementation JMAdhocViewerVC

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startResourceViewing
{
    [super setupSubviews];
    __weak __typeof(self) weakSelf = self;
    [((JMVIZWebEnvironment *)self.webEnvironment) prepareWithCompletion:^(BOOL isReady, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (isReady) {
            JMLog(@"ready");
            JMLog(@"resource uri: %@", strongSelf.resource.resourceLookup.uri);
            [strongSelf loadAdhocViewWithCompletion:^(BOOL success, NSError *error) {
                if (error) {
                    JMLog(@"error of loading adhoc view");
                } else {
                    JMLog(@"success of loading adhoc view");
                }
            }];
        } else {
            JMLog(@"not ready");
        }
    }];
}

#pragma mark - JMRefreshable
- (void)refresh
{

}

#pragma mark - Custom accessors
- (JMWebEnvironment *)currentWebEnvironment
{
    return [[JMWebViewManager sharedInstance] reusableWebEnvironmentWithId:[self currentWebEnvironmentIdentifier]];
}

- (NSString *)currentWebEnvironmentIdentifier
{
    NSString *webEnvironmentIdentifier = kJMAdhocViewWebEnvironemntId;
    return webEnvironmentIdentifier;
}

- (void)resetSubViews
{
//    [self.reportLoader destroy];
    [self.webEnvironment resetZoom];
    [self.webEnvironment.webView removeFromSuperview];

    self.webEnvironment = nil;
}

#pragma mark - Adhoc View Loader
- (void)loadAdhocViewWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    JSReportLoaderCompletionBlock heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.AdhocView.VIS.API.run"
                                                                parameters:@{
                                                                        @"uri" : self.resource.resourceLookup.uri
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:^(NSDictionary *parameters, NSError *error) {
                                        __typeof(self) strongSelf = weakSelf;

                                        if (error) {
                                            heapBlock(NO, error);
                                        } else {
                                            heapBlock(YES, nil);
                                        }
                                    }];
}

@end