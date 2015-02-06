/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  UIViewController+fetchInputControls.m
//  TIBCO JasperMobile
//

NSString * const kJMShowReportOptionsSegue = @"ShowReportOptions";
NSString * const kJMShowMultiPageReportSegue = @"ShowMultiPageReport";
NSString * const kJMShowDashboardViewerSegue = @"ShowDashboardViewer";
NSString * const kJMShowSavedRecourcesViewerSegue = @"ShowSavedRecourcesViewer";

#import "UIViewController+fetchInputControls.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"
#import "JMConstants.h"

@implementation UIViewController (FetchInputControls)

@dynamic resourceClient;

- (void)fetchInputControlsForReport:(JSResourceLookup *)resourceLookup
{
    JSObjectionInjector *objectionInjector = [JSObjection defaultInjector];
    JSRESTReport *report = [objectionInjector getObject:JSRESTReport.class];
    
    [JMUtils showNetworkActivityIndicator];
    [JMCancelRequestPopup presentWithMessage:@"status.loading" restClient:nil cancelBlock:^{
        [report cancelAllRequests];
    }];
    
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
        
        [JMUtils hideNetworkActivityIndicator];
        [JMCancelRequestPopup dismiss];
        
        NSMutableArray *invisibleInputControls = [NSMutableArray array];
        for (JSInputControlDescriptor *inputControl in result.objects) {
            if (!inputControl.visible.boolValue) {
                [invisibleInputControls addObject:inputControl];
            }
        }
        
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setObject:resourceLookup forKey:kJMResourceLookup];
        
        if (result.objects.count - invisibleInputControls.count == 0) {
            [self performSegueWithIdentifier:kJMShowMultiPageReportSegue sender:data];
        } else {
            if (invisibleInputControls.count) {
                NSMutableArray *inputControls = [result.objects mutableCopy];
                [inputControls removeObjectsInArray:invisibleInputControls];
                [data setObject:inputControls forKey:kJMInputControls];
            } else {
                [data setObject:result.objects forKey:kJMInputControls];
            }
            
            [self performSegueWithIdentifier:kJMShowReportOptionsSegue sender:data];
        }
    } @weakselfend
    viewControllerToDismiss:nil];
    
    [report inputControlsForReport:[resourceLookup.uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                               ids:nil
                    selectedValues:nil
                          delegate:delegate];
}

- (BOOL)isResourceSegue:(UIStoryboardSegue *)segue;
{
    NSString *identifier = segue.identifier;
    return ([identifier isEqualToString:kJMShowMultiPageReportSegue] ||
            [identifier isEqualToString:kJMShowReportOptionsSegue] ||
            [identifier isEqualToString:kJMShowDashboardViewerSegue] ||
            [identifier isEqualToString:kJMShowSavedRecourcesViewerSegue]);
}

@end
