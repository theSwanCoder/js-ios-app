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
#import "JMDashboardParameter.h"
#import "JMResource.h"
#import "JMUtils.h"

@interface JMDashboard()
// setters
@property (nonatomic, strong, readwrite) JMResource *resource;
@property (nonatomic, copy, readwrite) NSString *resourceURI;
@end

@implementation JMDashboard

#pragma mark - LifyCycle
- (void)dealloc
{
    JMLog(@"%@ _ %@", self, NSStringFromSelector(_cmd));
}

- (instancetype)initWithResource:(JMResource *)resource
{
    self = [super init];
    if (self) {
        _resource = resource;
        _resourceURI = resource.resourceLookup.uri;
    }
    return self;
}

+ (instancetype)dashboardWithResource:(JMResource *)resourceLookup
{
    return [[self alloc] initWithResource:resourceLookup];
}

@end
