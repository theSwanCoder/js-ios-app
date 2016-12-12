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
//  JMExportTask.m
//  TIBCO JasperMobile
//

#import "JMExportTask.h"
#import "JMSavedResources+Helpers.h"

@interface JMExportTask ()
@property (nonatomic, strong, readwrite) JMExportResource *exportResource;

@end

@implementation JMExportTask

#pragma mark - Life Cycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithResource:(JMExportResource *)resource
{
    self = [super init];
    if (self) {
        self.exportResource = resource;
    }
    return self;
}

+ (instancetype)taskWithResource:(JMExportResource *)resource
{
    return [[self alloc] initWithResource:resource];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: Export %@ in format %@>", [self class], self.name, self.exportResource.format];
}

@end