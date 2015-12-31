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

- (instancetype)initWithResource:(JSResourceLookup *)resource name:(NSString *)name format:(NSString *)format
{
    self = [super init];
    if (self) {
        self.name = name;
        _exportResource = [self exportResourceLookupForResource:resource format:format];
    }
    return self;
}

+ (instancetype)taskWithResource:(JSResourceLookup *)resource name:(NSString *)name format:(NSString *)format
{
    return [[self alloc] initWithResource:resource name:name format:format];
}

- (JMExportResource *)exportResourceLookupForResource:(JSResourceLookup *)resource format:(NSString *)format
{
    JMExportResource *exportResource = [JMExportResource new];
    
    exportResource.label = self.name;
    exportResource.uri = [self resourceURIForResourceWithFormat:format];
    exportResource.resourceDescription = resource.resourceDescription;
    exportResource.resourceType = [self resourceTypeForResource];
    exportResource.version = [NSNumber numberWithInteger:1];
    exportResource.permissionMask = [NSNumber numberWithInteger:JSPermissionMask_Administration];
    exportResource.creationDate = [NSDate date];
    exportResource.updateDate = [NSDate date];
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