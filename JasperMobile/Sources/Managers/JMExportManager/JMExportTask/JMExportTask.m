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

@interface JMExportTask ()
@property (nonatomic, strong, readwrite) JMExportResource *exportResource;

@end

@implementation JMExportTask

#pragma mark - Life Cycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithResource:(JMResource *)resource name:(NSString *)name format:(NSString *)format
{
    self = [super init];
    if (self) {
        self.name = name;
        _exportResource = [self exportResourceFromResource:resource
                                                    format:format];
    }
    return self;
}

+ (instancetype)taskWithResource:(JMResource *)resource name:(NSString *)name format:(NSString *)format
{
    return [[self alloc] initWithResource:resource name:name format:format];
}

- (JMExportResource *)exportResourceFromResource:(JMResource *)resource format:(NSString *)format
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.label = self.name;
    resourceLookup.uri = [self resourceURIForResourceWithFormat:format];
    resourceLookup.resourceDescription = resource.resourceLookup.resourceDescription;
    resourceLookup.resourceType = [self resourceTypeForResource];
    resourceLookup.version = @1;
    resourceLookup.permissionMask = @(JSPermissionMask_Administration);
    resourceLookup.creationDate = [NSDate date];
    resourceLookup.updateDate = [NSDate date];

    JMExportResource *exportResource = [JMExportResource resourceWithResourceLookup:resourceLookup];
    exportResource.format = format;

    return exportResource;
}

- (NSString *)resourceTypeForResource
{
    NSString *messageString = [NSString stringWithFormat:@"You need to implement \"resourceTypeForResource:\" method in %@",NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:messageString userInfo:nil];
}

- (NSString *)resourceURIForResourceWithFormat:(NSString *)format
{
    NSString *messageString = [NSString stringWithFormat:@"You need to implement \"resourceURIForResourceWithFormat:\" method in %@",NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:messageString userInfo:nil];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: Export %@ in format %@>", [self class], self.name, self.exportResource.format];
}

@end
