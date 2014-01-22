/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMBaseRepositoryTableViewController+fetchInputControls.m
//  Jaspersoft Corporation
//

static NSString * const kJMShowReportOptionsSegue = @"ShowReportOptions";
static NSString * const kJMShowReportViewerSegue = @"ShowReportViewer";
static NSString * const kJMInputControls = @"inputControls";
static NSString * const kJMResourceLookup = @"resourceLookup";

#import <Objection-iOS/JSObjection.h>
#import "JMBaseRepositoryTableViewController+fetchInputControls.h"
#import "JMCancelRequestPopup.h"
#import "JMInputControlsHolder.h"
#import "JMRequestDelegate.h"
#import "JMReportOptionsUtil.h"
#import "JSRESTBase+updateServerInfo.h"

@implementation JMBaseRepositoryTableViewController (fetchInputControls)

- (void)fetchInputControlsForReport:(JSResourceLookup *)resourceLookup
{
    __weak JMBaseRepositoryTableViewController *weakSelf = self;
    
    JSObjectionInjector *objectionInjector = [JSObjection defaultInjector];
    JSRESTReport *report = [objectionInjector getObject:JSRESTReport.class];
    
    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:nil cancelBlock:^{
        [weakSelf.resourceClient cancelAllRequests];
        [report cancelAllRequests];
    }];
    
    [self.resourceClient updateServerInfo:[JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        // TODO: change server version to 5.2.0 instead of 5.5.0 (EMERALD_TWO)
        if (self.resourceClient.serverProfile.serverInfo.versionAsInteger >= weakSelf.constants.VERSION_CODE_EMERALD_TWO) {
            JMReportOptionsUtil *reportOptionsUtil = [objectionInjector getObject:JMReportOptionsUtil.class];
            NSArray *reportParameters = [reportOptionsUtil reportOptionsAsParametersForReport:resourceLookup.uri];
            [report inputControlsForReport:resourceLookup.uri ids:nil selectedValues:reportParameters delegate:[self reportDelegate:resourceLookup]];
        } else {
            [weakSelf.resourceClient resource:resourceLookup.uri delegate:[self resourceDelegate:resourceLookup]];
        }
    }]];
}

- (void)setResults:(id)sender toDestinationViewController:(id)viewController
{
    NSDictionary *data = sender;
    JSResourceLookup *resourceLookup = [data objectForKey:kJMResourceLookup];
    NSMutableArray *inputControls = [data objectForKey:kJMInputControls];
    
    [viewController setResourceLookup:resourceLookup];
    if (inputControls.count) {
        [viewController setInputControls:inputControls];
    }
}

- (BOOL)isReportSegue:(UIStoryboardSegue *)segue;
{
    NSString *identifier = segue.identifier;
    return [identifier isEqualToString:kJMShowReportViewerSegue] || [identifier isEqualToString:kJMShowReportOptionsSegue];
}

#pragma mark - Private -

- (void)performSegueWithReport:(JSResourceLookup *)resourceLookup andInputControls:(NSArray *)inputControls restVersion:(JSRESTVersion)restVersion
{
    NSDictionary *data = @{
        kJMResourceLookup : resourceLookup,
        kJMInputControls : inputControls
    };
    
    NSMutableArray *invisibleInputControls = [NSMutableArray array];
    for (id inputControl in inputControls) {
        BOOL isVisible = restVersion == JSRESTVersion_1 ? [inputControl isVisible] : [[inputControl visible] boolValue];
        if (!isVisible) {
            [invisibleInputControls addObject:inputControl];
        }
    }
    
    if (inputControls.count - invisibleInputControls.count == 0) {
        [self performSegueWithIdentifier:kJMShowReportViewerSegue sender:data];
    } else {
        [self performSegueWithIdentifier:kJMShowReportOptionsSegue sender:data];
    }
}

#pragma mark Rest v1

- (JMRequestDelegate *)resourceDelegate:(JSResourceLookup *)resourceLookup
{
    __weak JMBaseRepositoryTableViewController *weakSelf = self;
    
    return [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        [JMCancelRequestPopup dismiss];
        JSResourceDescriptor *descriptor = [result.objects objectAtIndex:0];
        NSMutableArray *inputControlWrappers = [NSMutableArray array];
        
        for (JSResourceDescriptor *childResourceDescriptor in descriptor.childResourceDescriptors) {
            if ([childResourceDescriptor.wsType isEqualToString:weakSelf.constants.WS_TYPE_INPUT_CONTROL]) {
                JSInputControlWrapper *inputControl = [[JSInputControlWrapper alloc] initWithResourceDescriptor:childResourceDescriptor];
                [inputControlWrappers addObject:inputControl];
            }
        }
        
        [self performSegueWithReport:resourceLookup andInputControls:inputControlWrappers restVersion:JSRESTVersion_1];
    }];
}

#pragma mark Rest v2

- (JMRequestDelegate *)reportDelegate:(JSResourceLookup *)resourceLookup
{
    __weak JMBaseRepositoryTableViewController *weakSelf = self;
    
    return [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        [JMCancelRequestPopup dismiss];
        [weakSelf performSegueWithReport:resourceLookup andInputControls:result.objects restVersion:JSRESTVersion_2];
    } viewControllerToDismiss:nil];
}

@end
