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
//  JMDashboard.h
//  TIBCO JasperMobile
//

#import "JMDashboard.h"

@interface JMDashboard()
// setters
@property (nonatomic, strong, readwrite) JSResourceLookup *resourceLookup;
@property (nonatomic, copy, readwrite) NSString *resourceURI;
@property (nonatomic, strong, readwrite) NSURLRequest *resourceRequest;
@end

@implementation JMDashboard

#pragma mark - LifyCycle
- (instancetype)initWithResource:(JSResourceLookup *)resourceLookup
{
    self = [super init];
    if (self) {
        _resourceLookup = resourceLookup;
        _resourceURI = resourceLookup.uri;
        _resourceRequest = [self createResourceRequest];
    }
    return self;
}

+ (instancetype)dashboardWithResource:(JSResourceLookup *)resourceLookup
{
    return [[self alloc] initWithResource:resourceLookup];
}

#pragma mark - Public API

#pragma mark - Private API

#pragma mark - Helpers
- (NSURLRequest *)createResourceRequest
{
    NSString *dashboardUrl = [NSString stringWithFormat:@"%@%@", @"flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=", _resourceURI];
    dashboardUrl = [dashboardUrl stringByAppendingString:@"&"];
    
    NSMutableURLRequest *dashboardRequest = [self.restClient.restKitObjectManager requestWithObject:nil
                                                                                             method:RKRequestMethodGET
                                                                                               path:dashboardUrl
                                                                                         parameters:nil];
    dashboardRequest.timeoutInterval = self.restClient.timeoutInterval;
    dashboardRequest.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    return dashboardRequest;
}

@end
