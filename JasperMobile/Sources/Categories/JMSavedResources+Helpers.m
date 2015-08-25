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
    NSString *pathToReport = [JMSavedResources pathToReportDirectoryForReportWithName:self.label format:self.format];
    [[NSFileManager defaultManager] removeItemAtPath:pathToReport error:nil];
    
    [JMFavorites removeFromFavorites:[self wrapperFromSavedReports]];
    
    [self.managedObjectContext deleteObject:self];
    [self.managedObjectContext save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMSavedResourcesDidChangedNotification object:nil];
}

- (UIImage *)thumbnailImage
{
    NSString *reportDirectoryPath = [JMSavedResources pathToReportDirectoryForReportWithName:self.label format:self.format];
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
    NSString *currentPath = [JMSavedResources pathToReportDirectoryForReportWithName:self.label format:self.format];
    NSString *newPath = [JMSavedResources pathToReportDirectoryForReportWithName:newName format:self.format];

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

+ (NSString *)pathToReportsDirectory
{
    // PathComponent
    NSString *pathComponent = [self pathComponent];
    // Documents
    NSString *documentsPath = [JMUtils applicationDocumentsDirectory];
    // Documents/PathComponent
    NSString *pathToReport = [documentsPath stringByAppendingPathComponent:pathComponent];
    return pathToReport;
}

+ (NSString *)pathToTempReportsDirectory
{
    // TODO: move to /temp
    // TempPathComponent
    NSString *tempPathComponent = [self tempPathComponent];
    // Documents
    NSString *documentsPath = [JMUtils applicationDocumentsDirectory];
    // Documents/TempPathComponent
    NSString *pathToReport = [documentsPath stringByAppendingPathComponent:tempPathComponent];
    return pathToReport;
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
    return relativePath;
}

+ (NSString *)pathToTempReportDirectoryForReportWithName:(NSString *)reportName format:(NSString *)format
{
    // Documents/TempPathComponent/
    NSString *pathToTempReportsDirectory = [self pathToTempReportsDirectory];
    // reportName.format
    NSString *savedReportName = [self savedReportNameWithName:reportName format:format];
    // reports/reportName.format/
    NSString *relativePath = [kJMReportsDirectory stringByAppendingPathComponent:savedReportName];
    // Documents/TempPathComponent/reports/reportName.format/
    NSString *pathToTempReportDirectory = [pathToTempReportsDirectory stringByAppendingPathComponent:relativePath];
    return pathToTempReportDirectory;
}

+ (NSString *)pathToReportDirectoryForReportWithName:(NSString *)reportName format:(NSString *)format
{
    // Documents/PathComponent/
    NSString *pathToReportsDirectory = [self pathToReportsDirectory];
    // reportName.format
    NSString *savedReportName = [self savedReportNameWithName:reportName format:format];
    // reports/reportName.format/
    NSString *relativePath = [kJMReportsDirectory stringByAppendingPathComponent:savedReportName];
    // Documents/PathComponent/reports/reportName.format/
    NSString *pathToReportDirectory = [pathToReportsDirectory stringByAppendingPathComponent:relativePath];
    return pathToReportDirectory;
}

+ (NSString *)absoluteTempPathToReportWithName:(NSString *)reportName format:(NSString *)format
{
    // reports/reportName.format/reportName.format
    NSString *relativeReportPath = [self relativeReportPathWithName:reportName format:format];
    // Documents/TempPathComponent/
    NSString *pathToTempReportsDirectory = [self pathToTempReportsDirectory];
    // Documents/TempPathComponent/reports/reportName.format/reportName.format
    NSString *absolutePath = [pathToTempReportsDirectory stringByAppendingPathComponent:relativeReportPath];
    return absolutePath;
}

+ (NSString *)absolutePathToReportWithName:(NSString *)reportName format:(NSString *)format
{
    // reports/reportName.format/reportName.format
    NSString *relativeReportPath = [self relativeReportPathWithName:reportName format:format];
    // Documents/PathComponent/
    NSString *pathToDirectory = [self pathToReportsDirectory];
    // Documents/PathComponent/reports/reportName.format/reportName.format
    NSString *absolutePath = [pathToDirectory stringByAppendingPathComponent:relativeReportPath];
    return absolutePath;
}

+ (NSString *)pathComponent
{
    // TODO: replace with MD5 of (Alias + username)
    NSString *path = self.restClient.serverProfile.alias;
    return path;
}

+ (NSString *)tempPathComponent
{
    NSString *path = [self pathComponent];
    NSString *tempPath = [NSString stringWithFormat:@"%@%@", kJMSavedResourcesTempIdentifier, path];
    return tempPath;
}

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
