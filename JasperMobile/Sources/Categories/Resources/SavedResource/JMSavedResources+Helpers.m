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


#import "JMSavedResources+Helpers.h"
#import "JMServerProfile+Helpers.h"
#import "JMFavorites+Helpers.h"
#import "JMSessionManager.h"
#import "JMResource.h"
#import "JMCoreDataManager.h"
#import "NSObject+Additions.h"
#import "JMConstants.h"
#import "JMUtils.h"

NSString * const kJMSavedResources = @"SavedResources";
NSString * const kJMSavedResourcesDefaultOrganization = @"organization_1";
static NSString *const kJMSavedResourcesTempIdentifier = @"Temp_";


@implementation JMSavedResources (Helpers)

+ (JMSavedResources *)savedReportsFromResource:(JMResource *)resource
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequestWithValuesAndFields:resource.resourceLookup.uri, @"uri", nil];
    NSArray *result = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return [result lastObject];
}

+ (JMSavedResources *)savedResourceWithReportName:(NSString *)reportName format:(NSString *)reportFormat;
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequestWithValuesAndFields:reportName, @"label", reportFormat, @"format", nil];
    NSArray <JMSavedResources*> *savedReports = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return [savedReports firstObject];
}

+ (JMSavedResources *)addReport:(JMResource *)resource withName:(NSString *)name format:(NSString *)format sourcesURL:(NSURL *)sourcesURL
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequestWithValuesAndFields:name, @"label", format, @"format", nil];
    JMSavedResources *savedReport = [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];

    if (!savedReport) {
        JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
        savedReport = [NSEntityDescription insertNewObjectForEntityForName:kJMSavedResources inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
        savedReport.label = name;
        savedReport.uri = [self uriForSavedReportWithName:name format:format];
        savedReport.resourceDescription = resource.resourceLookup.resourceDescription;
        savedReport.format = format;
        savedReport.username = self.restClient.serverProfile.username;
        savedReport.wsType = [self wsTypeWithSourceWSType:resource.resourceLookup.resourceType];
        savedReport.version = resource.resourceLookup.version;
        [activeServerProfile addSavedResourcesObject:savedReport];
    }
    savedReport.creationDate = [NSDate date];
    savedReport.updateDate = [NSDate date];
    
    NSError *error = [self moveResourceContentFromPath:[sourcesURL path] toPath:[JMSavedResources pathToFolderForSavedReport:savedReport]];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        [[JMCoreDataManager sharedInstance] resetPersistentStore];
        return nil;
    } else {
        [[JMCoreDataManager sharedInstance] save:nil];
        return savedReport;
    }
}

- (void)removeReport
{
    [JMFavorites removeFromFavorites:[self wrapperFromSavedReports]];

    NSString *pathToReport = [JMSavedResources pathToFolderForSavedReport:self];
    [[NSFileManager defaultManager] removeItemAtPath:pathToReport error:nil];
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
    return (![self savedResourceWithReportName:reportName format:reportFormat]);
}

+ (NSArray *)allSavedItems
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMSavedResources];
    NSArray *savedItems = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return savedItems;
}

+ (BOOL)migrateSavedItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSString *currentFolderPath = [fromPath stringByDeletingLastPathComponent];
    NSString *newFolderPath = [toPath stringByDeletingLastPathComponent];

    BOOL isFileExists = [self isExistItemAtPath:toPath];

    if (isFileExists) {
        NSString *newFileName = toPath.stringByDeletingPathExtension;
        NSString *newFileFormat = toPath.pathExtension;
        BOOL isEntryInDBExists = [JMSavedResources isAvailableReportName:newFileName format:newFileFormat];
        if (isEntryInDBExists) {
            return NO;
        } else {
            [self removeResourceAtPath:toPath];
        }
    } else {
        [self createFolderAtPath:newFolderPath];
    }

    NSError *error;

    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentFolderPath error:&error];

    for (NSString *item in items) {
        NSString *newItem = item;
        if ([newItem isEqualToString:[currentFolderPath lastPathComponent]] || [newItem.stringByDeletingPathExtension isEqualToString:kJMReportFilename]) {
            newItem = [newFolderPath lastPathComponent];
        }
        NSString *itemFromPath = [currentFolderPath stringByAppendingPathComponent:item];
        NSString *itemToPath = [newFolderPath stringByAppendingPathComponent:newItem];
        [[NSFileManager defaultManager] moveItemAtPath:itemFromPath toPath:itemToPath error:&error];
    }

    [self removeResourceAtPath:currentFolderPath];

    return !(error);
}

- (BOOL)renameReportTo:(NSString *)newName
{
    NSString *currentPath = [JMSavedResources absolutePathToSavedReport:self];
    NSString *newPath = [JMSavedResources renamedAbsolutePathToSavedReport:self newName:newName];
    
    NSString *currentFolderPath = [currentPath stringByDeletingLastPathComponent];
    NSString *newFolderPath = [newPath stringByDeletingLastPathComponent];
    
    BOOL isFileExists = [JMSavedResources isExistItemAtPath:newPath];
    
    if (isFileExists) {
        BOOL isEntryInDBExists = [JMSavedResources isAvailableReportName:newName format:self.format];
        if (isEntryInDBExists) {
            return NO;
        } else {
            [JMSavedResources removeResourceAtPath:newPath];
        }
    }
    
    // Move folder and it content
    NSError *moveContentError = [JMSavedResources moveResourceContentFromPath:currentFolderPath toPath:newFolderPath];
    
    if (!moveContentError) {
        // Rename report file
        NSString *temporaryReportName = [newFolderPath stringByAppendingPathComponent:[currentPath lastPathComponent]];
        [[NSFileManager defaultManager] moveItemAtPath:temporaryReportName toPath:newPath error:&moveContentError];
        if (!moveContentError) {
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
        }
    }
    return NO;
}

- (JMResource *)wrapperFromSavedReports
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.uri = self.uri;
    resourceLookup.label = self.label;
    resourceLookup.resourceType = self.wsType;
    resourceLookup.creationDate = self.creationDate;
    resourceLookup.updateDate = self.updateDate;
    resourceLookup.resourceDescription = self.resourceDescription;
    resourceLookup.version = self.version;
    return [JMResource resourceWithResourceLookup:resourceLookup];
}

#pragma mark - Public API for Paths
+ (NSString *)pathToFolderForSavedReport:(JMSavedResources *)savedReport
{
    // Documents/
    NSString *pathToDocumentsFolder = [JMUtils applicationDocumentsDirectory];
    // PathComponent/reports/reportName.format/reportName.format
    NSString *uri = savedReport.uri;
    // PathComponent/reports/reportName.format/
    NSString *pathToReportsFolder = [uri stringByDeletingLastPathComponent];
    // Documents/PathComponent/reports/reportName.format/
    NSString *absolutePath = [pathToDocumentsFolder stringByAppendingPathComponent:pathToReportsFolder];
    return absolutePath;
}

+ (NSString *)absolutePathToSavedReport:(JMSavedResources *)savedReport
{
    // Documents/PathComponent/reports/reportName.format/
    NSString *pathToFolder = [self pathToFolderForSavedReport:savedReport];
    // reportName.format
    NSString *savedReportName = [self savedReportNameWithName:savedReport.label
                                                       format:savedReport.format];
    // Documents/PathComponent/reports/reportName.format/reportName.format
    NSString *absolutePath = [pathToFolder stringByAppendingPathComponent:savedReportName];
    return absolutePath;
}

+ (NSString *)renamedAbsolutePathToSavedReport:(JMSavedResources *)savedReport newName:(NSString *)newName
{
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
    return absolutePath;
}

#pragma mark - Private API fo Paths

+ (NSString *)savedReportNameWithName:(NSString *)reportName format:(NSString *)format
{
    NSString *savedReportName = [reportName stringByAppendingPathExtension:format];
    return savedReportName;
}

+ (NSString *)pathComponent
{
    NSString *userName = self.restClient.serverProfile.username;
    NSString *organization = self.restClient.serverProfile.organization;
    if (!organization) {
        organization = kJMSavedResourcesDefaultOrganization;
    }
    NSString *serverURL = self.restClient.serverProfile.serverUrl;
    NSString *alias = self.restClient.serverProfile.alias;

    NSString *uniqueString = [self createUniqueStringWithUserName:userName
                                                     organization:organization
                                                         severURL:serverURL
                                                            alias:alias];
    return uniqueString;
}

+ (NSString *)createUniqueStringWithUserName:(NSString *)userName
                                organization:(NSString *)organization
                                    severURL:(NSString *)serverURL
                                       alias:(NSString *)alias
{
    NSString *combinedString = [NSString stringWithFormat:@"%@+%@+%@+%@", userName, organization, serverURL, alias];
    NSData *combinedStringData = [combinedString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *result = [combinedStringData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    result = [result uppercaseString];
    return result;
}

+ (NSString *)uriForSavedReportWithName:(NSString *)reportName format:(NSString *)format
{
    NSAssert(reportName != nil || format != nil, @"There aren't name and format of saved report");

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

    return [NSString stringWithFormat:@"/%@", relativePath];
}

#pragma mark - Private

+ (NSFetchRequest *)savedReportsFetchRequestWithValuesAndFields:(id)firstValue, ... NS_REQUIRES_NIL_TERMINATION
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMSavedResources];
    NSMutableArray *predicates = [@[[[JMSessionManager sharedManager] predicateForCurrentServerProfile]] mutableCopy];

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
    if ([wsType isEqualToString:kJS_WS_TYPE_REPORT_UNIT] || [wsType isEqualToString:kJMTempExportedReportUnit]) {
        return kJMSavedReportUnit;
    }
    return nil;
}

#pragma mark - File handlers
+ (NSError *)moveResourceContentFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSError *error = [self copyResourceContentFromPath:fromPath toPath:toPath];
    if (error) {
        if ([self isExistItemAtPath:toPath]) {
            error = [self removeResourceAtPath:toPath];
        }
    } else {
        error = [self removeResourceAtPath:fromPath];
    }
    return error;



//    NSError *error;
//
//    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fromPath error:&error];
//
//    for (NSString *item in items) {
//        NSString *newItem = item;
//        if ([newItem isEqualToString:[fromPath lastPathComponent]] || [newItem.stringByDeletingPathExtension isEqualToString:kJMReportFilename]) {
//            newItem = [toPath lastPathComponent];
//        }
//        NSString *itemFromPath = [fromPath stringByAppendingPathComponent:item];
//        NSString *itemToPath = [toPath stringByAppendingPathComponent:newItem];
//        [[NSFileManager defaultManager] moveItemAtPath:itemFromPath toPath:itemToPath error:&error];
//    }
//
//    return error;
}

+ (NSError *)copyResourceContentFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSError *error;
    if ([self isExistsFolderAtPath:toPath]) {
        error = [self removeResourceAtPath:toPath];
    }
    
    if (!error) {
        // Check existing or create new reports folder
        NSString *pathToDocumentsFolder = [JMUtils applicationDocumentsDirectory];
        NSString *relativeReportsPath = [[self pathComponent] stringByAppendingPathComponent:kJMReportsDirectory];
        NSString *reportsFolder = [pathToDocumentsFolder stringByAppendingPathComponent:relativeReportsPath];
        
        if (![self isExistsFolderAtPath:reportsFolder]) {
            error = [self createFolderAtPath:reportsFolder];
        }
        
        // Copy content
        if (!error) {
            [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:&error];
        }
    }
    return error;
}

+ (NSError *)removeResourceAtPath:(NSString *)path
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    return error;
}

+ (NSError *)createFolderAtPath:(NSString *)path
{
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    return error;
}

+ (BOOL)isExistItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)isExistsFolderAtPath:(NSString *)folderPath
{
    BOOL isDirectory;
    return ([[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDirectory] && isDirectory);
}

#pragma mark - Updater
+ (NSString *)oldPathForSavedReport:(JMSavedResources *)savedResource
{
    NSString *oldPath = @"";
    NSString *documentFolderPath = [JMUtils applicationDocumentsDirectory];
    NSString *uri = savedResource.uri;
    NSString *oldReportsFolder = [documentFolderPath stringByAppendingPathComponent:savedResource.serverProfile.alias];
    BOOL isExistFolder = [self isExistsFolderAtPath:oldReportsFolder];
    if (isExistFolder) {
        oldPath = oldReportsFolder;
    } else {
        oldPath = documentFolderPath;
    }
    oldPath = [oldPath stringByAppendingPathComponent:uri];

    return oldPath;
}

+ (NSString *)newURIForSavedReport:(JMSavedResources *)savedResource
{
    NSString *uri = savedResource.uri;
    NSString *newUri = [uri stringByDeletingLastPathComponent];
    NSString *newName = [newUri lastPathComponent];
    newUri = [newUri stringByAppendingPathComponent:newName];

    NSString *userName = savedResource.username;
    NSString *organization = savedResource.serverProfile.organization;
    if (!organization) {
        organization = kJMDemoServerOrganization;
    }
    NSString *serverURL = savedResource.serverProfile.serverUrl;
    NSString *alias = savedResource.serverProfile.alias;

    NSString *pathComponent = [JMSavedResources createUniqueStringWithUserName:userName
                                                                  organization:organization
                                                                      severURL:serverURL
                                                                         alias:alias];
    newUri = [pathComponent stringByAppendingPathComponent:newUri];

    return newUri;
}

@end
