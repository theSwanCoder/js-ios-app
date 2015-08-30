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
static NSString *const kJMSavedResourcesTempIdentifier = @"Temp_";


@implementation JMSavedResources (Helpers)

+ (JMSavedResources *)savedReportsFromResourceLookup:(JSResourceLookup *)resource
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequestWithValuesAndFields:resource.uri, @"uri", nil];
    return [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
}

+ (JMSavedResources *)addReport:(JSResourceLookup *)resource withName:(NSString *)name format:(NSString *)format
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequestWithValuesAndFields:name, @"label", format, @"format", nil];
    JMSavedResources *savedReport = [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];

    if (!savedReport) {
//        JSProfile *sessionServerProfile = [JMSessionManager sharedManager].restClient.serverProfile;
        JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
        savedReport = [NSEntityDescription insertNewObjectForEntityForName:kJMSavedResources inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
        savedReport.label = name;
        savedReport.uri = [self uriForSavedReportWithName:name format:format];
        savedReport.resourceDescription = resource.resourceDescription;
        savedReport.format = format;
        savedReport.username = self.restClient.serverProfile.username;
        savedReport.wsType = [self wsTypeWithSourceWSType:resource.resourceType];
        savedReport.version = resource.version;
        [activeServerProfile addSavedResourcesObject:savedReport];
    }
    savedReport.creationDate = [NSDate date];
    savedReport.updateDate = [NSDate date];
    [[JMCoreDataManager sharedInstance] save:nil];

    return savedReport;
}

- (void)removeReport
{
    NSString *pathToReport = [JMSavedResources absolutePathToSavedReport:self];
    [[NSFileManager defaultManager] removeItemAtPath:pathToReport error:nil];
    
    [JMFavorites removeFromFavorites:[self wrapperFromSavedReports]];
    
    [self.managedObjectContext deleteObject:self];
    [self.managedObjectContext save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMSavedResourcesDidChangedNotification object:nil];
}

- (UIImage *)thumbnailImage
{
    NSString *reportDirectoryPath = [JMSavedResources pathToFolderForSavedReport:self];
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
    NSString *currentPath = [JMSavedResources absolutePathToSavedReport:self];
    NSString *newPath = [JMSavedResources renamedAbsolutePathToSavedReport:self newName:newName];

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

#pragma mark - Public API for Paths
+ (NSString *)pathToFolderForSavedReport:(JMSavedResources *)savedReport
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // Documents/
    NSString *pathToReportsFolder = [self pathToReportsFolder];
    // PathComponent/reports/reportName.format/reportName.format
    NSString *uri = savedReport.uri;
    // PathComponent/reports/reportName.format/
    NSString *pathToFolder = [uri stringByDeletingLastPathComponent];
    // Documents/PathComponent/reports/reportName.format/
    NSString *absolutePath = [pathToReportsFolder stringByAppendingPathComponent:pathToFolder];

    NSLog(@"absolutePath: %@", absolutePath);
    return absolutePath;
}

+ (NSString *)pathToTempFolderForSavedReport:(JMSavedResources *)savedReport
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // tmp/
    NSString *pathToTempReportsFolder = [self pathToTempReportsFolder];
    // PathComponent/reports/reportName.format/reportName.format
    NSString *uri = savedReport.uri;
    // PathComponent/reports/reportName.format/
    NSString *pathToTempFolder = [uri stringByDeletingLastPathComponent];
    // tmp/PathComponent/reports/reportName.format/
    NSString *absolutePath = [pathToTempReportsFolder stringByAppendingPathComponent:pathToTempFolder];

    NSLog(@"absolutePath: %@", absolutePath);
    return absolutePath;
}

+ (NSString *)absolutePathToSavedReport:(JMSavedResources *)savedReport
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // Documents/PathComponent/reports/reportName.format/
    NSString *pathToFolder = [self pathToFolderForSavedReport:savedReport];
    // reportName.format
    NSString *savedReportName = [self savedReportNameWithName:savedReport.label
                                                       format:savedReport.format];
    // Documents/PathComponent/reports/reportName.format/reportName.format
    NSString *absolutePath = [pathToFolder stringByAppendingPathComponent:savedReportName];

    NSLog(@"absolutePath: %@", absolutePath);
    return absolutePath;
}

+ (NSString *)renamedAbsolutePathToSavedReport:(JMSavedResources *)savedReport newName:(NSString *)newName
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // Documents/PathComponent/reports/reportName.format/
    NSString *pathToFolder = [self pathToFolderForSavedReport:savedReport];
    // Documents/PathComponent/reports/
    pathToFolder = [pathToFolder stringByDeletingLastPathComponent];
    // newName.format
    NSString *newSavedReportName = [self savedReportNameWithName:newName
                                                       format:savedReport.format];
    // Documents/PathComponent/reports/newName.format/
    pathToFolder = [pathToFolder stringByAppendingPathComponent:newSavedReportName];
    // Documents/PathComponent/reports/newName.format/newName.format
    NSString *absolutePath = [pathToFolder stringByAppendingPathComponent:newSavedReportName];

    NSLog(@"absolutePath: %@", absolutePath);
    return absolutePath;
}

+ (NSString *)absoluteTempPathToSavedReport:(JMSavedResources *)savedReport
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // tmp/PathComponent/reports/reportName.format/
    NSString *pathToTempFolder = [self pathToTempFolderForSavedReport:savedReport];
    // reportName.format
    NSString *savedReportName = [self savedReportNameWithName:savedReport.label
                                                       format:savedReport.format];
    // Documents/TempPathComponent/reports/reportName.format/reportName.format
    NSString *absolutePath = [pathToTempFolder stringByAppendingPathComponent:savedReportName];

    NSLog(@"absolutePath: %@", absolutePath);
    return absolutePath;
}

#pragma mark - Private API fo Paths
+ (NSString *)pathToReportsFolder
{
    // Documents
    NSString *documentsPath = [JMUtils applicationDocumentsDirectory];
    return documentsPath;
}

+ (NSString *)pathToTempReportsFolder
{
    // temp/
    NSString *tempPath = [JMUtils applicationTempDirectory];
    return tempPath;
}

+ (NSString *)savedReportNameWithName:(NSString *)reportName format:(NSString *)format
{
    NSString *savedReportName = [reportName stringByAppendingPathExtension:format];
    return savedReportName;
}

+ (NSString *)relativeReportPathWithName:(NSString *)reportName format:(NSString *)format
{
    // reportName.format
    NSString *savedReportName = [self savedReportNameWithName:reportName format:format];
    // reportName.format/reportName.format
    NSString *relativePath = [savedReportName stringByAppendingPathComponent:savedReportName];
    // reports/reportName.format/reportName.format
    relativePath = [kJMReportsDirectory stringByAppendingPathComponent:relativePath];
    // PathComponent
    NSString *pathComponent = [self pathComponent];
    // PathComponent/reports/reportName.format/reportName.format
    relativePath = [pathComponent stringByAppendingPathComponent:relativePath];
    return relativePath;
}

+ (NSString *)pathComponent
{
    // TODO: replace with MD5 of (Alias + username)
    NSString *path = [self createUniqueString];
    return path;
}

+ (NSString *)createUniqueString
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return uuid;
}

//+ (NSString *)tempPathComponent
//{
//    NSString *path = [self pathComponent];
//    NSString *tempPath = [NSString stringWithFormat:@"%@%@", kJMSavedResourcesTempIdentifier, path];
//    return tempPath;
//}

+ (NSString *)uriForSavedReportWithName:(NSString *)name format:(NSString *)format
{
    NSAssert(name != nil || format != nil, @"There aren't name and format of saved report");

    NSString *relativePath = [self relativeReportPathWithName:name format:format];
    return [NSString stringWithFormat:@"/%@", relativePath];
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
