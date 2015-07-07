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


#import "JMSavedResources+Helpers.h"
#import "JMServerProfile+Helpers.h"
#import "JMFavorites+Helpers.h"
#import "JMSessionManager.h"


NSString * const kJMSavedResources = @"SavedResources";


@implementation JMSavedResources (Helpers)

+ (JMSavedResources *)savedReportsFromResourceLookup:(JSResourceLookup *)resource
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequestWithValuesAndFields:resource.uri, @"uri", nil];
    return [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
}

+ (void)addReport:(JSResourceLookup *)resource withName:(NSString *)name format:(NSString *)format
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequestWithValuesAndFields:name, @"label", format, @"format", nil];
    JMSavedResources *savedReport = [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    if (!savedReport) {
        JSProfile *sessionServerProfile = [JMSessionManager sharedManager].restClient.serverProfile;
        JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
        savedReport = [NSEntityDescription insertNewObjectForEntityForName:kJMSavedResources inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
        savedReport.label = name;
        savedReport.uri = [self uriForSavedReportWithName:name format:format];
        savedReport.resourceDescription = resource.resourceDescription;
        savedReport.format = format;
        savedReport.username = sessionServerProfile.username;
        savedReport.wsType = [self wsTypeWithSourceWSType:resource.resourceType];
        savedReport.version = resource.version;
        [activeServerProfile addSavedResourcesObject:savedReport];
    }
    savedReport.creationDate = [NSDate date];
    savedReport.updateDate = [NSDate date];
    [[JMCoreDataManager sharedInstance] save:nil];
}

- (void)removeReport
{
    NSString *pathToReport = [JMSavedResources pathToReportDirectoryWithName:self.label format:self.format];
    [[NSFileManager defaultManager] removeItemAtPath:pathToReport error:nil];
    
    [JMFavorites removeFromFavorites:[self wrapperFromSavedReports]];
    
    [self.managedObjectContext deleteObject:self];
    [self.managedObjectContext save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMSavedResourcesDidChangedNotification object:nil];
}

- (UIImage *)thumbnailImage
{
    NSString *reportDirectoryPath = [JMSavedResources pathToReportDirectoryWithName:self.label format:self.format];
    NSString *thumbnailImagePath = [reportDirectoryPath stringByAppendingPathComponent:kJMThumbnailImageFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailImagePath]) {
        NSData *imageData = [NSData dataWithContentsOfFile:thumbnailImagePath];
        if (imageData) {
            return [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        }
    }
    return nil;
}

+ (BOOL)isAvailableReportName:(NSString *)reportName format:(NSString *)reportFormat
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequestWithValuesAndFields:reportName, @"label", reportFormat, @"format", nil];
    JMSavedResources *savedReport = [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    
    return (!savedReport);
}

- (BOOL)renameReportTo:(NSString *)newName
{
    NSString *currentPath = [JMSavedResources pathToReportDirectoryWithName:self.label format:self.format];
    NSString *newPath = [JMSavedResources pathToReportDirectoryWithName:newName format:self.format];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:currentPath toPath:newPath error:&error];
    if (!error) {
        JMFavorites *favorites = [JMFavorites favoritesFromResourceLookup:[self wrapperFromSavedReports]];
        if (favorites) {
            favorites.label = newName;
            favorites.uri = [JMSavedResources uriForSavedReportWithName:newName format:self.format];
            [self.managedObjectContext save:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
        }
        
        self.label = newName;
        self.uri = [JMSavedResources uriForSavedReportWithName:newName format:self.format];
        self.updateDate = [NSDate date];
        [self.managedObjectContext save:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMSavedResourcesDidChangedNotification object:nil];
        return YES;
    } else {
        return NO;
    }
}

- (JSResourceLookup *)wrapperFromSavedReports
{
    JSResourceLookup *resource = [[JSResourceLookup alloc] init];
    resource.uri = self.uri;
    resource.label = self.label;
    resource.resourceType = self.wsType;
    resource.creationDate = self.creationDate;
    resource.updateDate = self.updateDate;
    resource.resourceDescription = self.resourceDescription;
    resource.version = self.version;
    return resource;
}

+ (NSString *)pathToReportDirectoryWithName:(NSString *)name format:(NSString *)format{

    NSString *fullReportName = [name stringByAppendingPathExtension:format];
    NSString *relativeReportPath = [kJMReportsDirectory stringByAppendingPathComponent:fullReportName];

    NSString *absolutePath = [self.restClient.serverProfile.alias stringByAppendingPathComponent:relativeReportPath];
    return [[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:absolutePath];
}

+ (NSString *)pathToReportWithName:(NSString *)name format:(NSString *)format
{
    NSString *savedItemURI = [self uriForSavedReportWithName:name format:format];

    NSString *absolutePath = [self.restClient.serverProfile.alias stringByAppendingPathComponent:savedItemURI];
    return [[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:absolutePath];
}

+ (NSString *)uriForSavedReportWithName:(NSString *)name format:(NSString *)format
{
    NSAssert(name != nil || format != nil, @"There aren't name and format of saved report");

    NSString *constantReportName = [kJMReportFilename stringByAppendingPathExtension:format];

    NSString *fullReportName = [name stringByAppendingPathExtension:format];
    NSString *relativeReportPath = [kJMReportsDirectory stringByAppendingPathComponent:fullReportName];

    NSString *savedItemURI = [relativeReportPath stringByAppendingPathComponent:constantReportName];
    return [NSString stringWithFormat:@"/%@",savedItemURI];
}

#pragma mark - Private

+ (NSFetchRequest *)savedReportsFetchRequestWithValuesAndFields:(id)firstValue, ... NS_REQUIRES_NIL_TERMINATION
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMSavedResources];
    NSMutableArray *predicates = [NSMutableArray arrayWithObject:[[JMSessionManager sharedManager] predicateForCurrentServerProfile]];

    va_list args;
    va_start(args, firstValue);
    for (NSString *value = firstValue; value != nil; value = va_arg(args, NSString*)) {
        NSString *queryFormat = [NSString stringWithFormat:@"%@ LIKE[cd] ", va_arg(args,NSString*)];
        [predicates addObject:[NSPredicate predicateWithFormat:[queryFormat stringByAppendingString:@"%@"], value]];
    }
    va_end(args);

    fetchRequest.predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    return fetchRequest;
}

+ (NSString *)wsTypeWithSourceWSType:(NSString *)wsType
{
    if ([wsType isEqualToString:[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT]) {
        return kJMSavedReportUnit;
    }
    return nil;
}
@end
