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


NSString * const kJMSavedResources = @"SavedResources";
NSString * const kJMSavedResourcesDefaultOrganization = @"organization_1";
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

- (void)removeFromDB
{
    [JMFavorites removeFromFavorites:[self wrapperFromSavedReports]];
    [self.managedObjectContext deleteObject:self];
    [self.managedObjectContext save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMSavedResourcesDidChangedNotification object:nil];
}

- (void)removeReport
{
    NSString *pathToReport = [JMSavedResources pathToFolderForSavedReport:self];
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

+ (NSArray *)allSavedItems
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMSavedResources];
    NSArray *savedItems = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return savedItems;
}

+ (BOOL)moveSavedItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath
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

    NSError *moveContentError = [self moveResourceContentFromPath:currentFolderPath toPath:newFolderPath];
    NSError *removeCurrentFolderError = [self removeResourceAtPath:currentFolderPath];

    return !(moveContentError || removeCurrentFolderError);
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
    } else {
        [JMSavedResources createFolderAtPath:newFolderPath];
    }

    NSError *moveContentError = [JMSavedResources moveResourceContentFromPath:currentFolderPath toPath:newFolderPath];
    NSError *removeCurrentFolderError = [JMSavedResources removeResourceAtPath:currentFolderPath];

    if (!(moveContentError || removeCurrentFolderError)) {
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
    // Documents/
    NSString *pathToReportsFolder = [self pathToReportsFolder];
    // PathComponent/reports/reportName.format/reportName.format
    NSString *uri = savedReport.uri;
    // PathComponent/reports/reportName.format/
    NSString *pathToFolder = [uri stringByDeletingLastPathComponent];
    // Documents/PathComponent/reports/reportName.format/
    NSString *absolutePath = [pathToReportsFolder stringByAppendingPathComponent:pathToFolder];
    return absolutePath;
}

+ (NSString *)pathToTempFolderForSavedReport:(JMSavedResources *)savedReport
{
    // tmp/
    NSString *pathToTempReportsFolder = [self pathToTempReportsFolder];
    // PathComponent/reports/reportName.format/reportName.format
    NSString *uri = savedReport.uri;
    // PathComponent/reports/reportName.format/
    NSString *pathToTempFolder = [uri stringByDeletingLastPathComponent];
    // tmp/PathComponent/reports/reportName.format/
    NSString *absolutePath = [pathToTempReportsFolder stringByAppendingPathComponent:pathToTempFolder];
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

+ (NSString *)absoluteTempPathToSavedReport:(JMSavedResources *)savedReport
{
    // tmp/PathComponent/reports/reportName.format/
    NSString *pathToTempFolder = [self pathToTempFolderForSavedReport:savedReport];
    // reportName.format
    NSString *savedReportName = [self savedReportNameWithName:savedReport.label
                                                       format:savedReport.format];
    // Documents/TempPathComponent/reports/reportName.format/reportName.format
    NSString *absolutePath = [pathToTempFolder stringByAppendingPathComponent:savedReportName];
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
    // tmp/
    NSString *tempPath = [JMUtils applicationTempDirectory];
    // PathComponent
    //NSString *pathComponent = [self pathComponent];
    // tmp/PathComponent
    //NSString *result = [tempPath stringByAppendingPathComponent:pathComponent];
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
    NSString *path = [self createUniqueString];
    return path;
}

+ (NSString *)createUniqueString
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
    if ([wsType isEqualToString:kJS_WS_TYPE_REPORT_UNIT]) {
        return kJMSavedReportUnit;
    }
    return nil;
}

#pragma mark - File handlers
+ (NSError *)moveResourceContentFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSError *error;

    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fromPath error:&error];

    for (NSString *item in items) {
        NSString *newItem = item;
        if ([newItem isEqualToString:[fromPath lastPathComponent]] || [newItem.stringByDeletingPathExtension isEqualToString:kJMReportFilename]) {
            newItem = [toPath lastPathComponent];
        }
        NSString *itemFromPath = [fromPath stringByAppendingPathComponent:item];
        NSString *itemToPath = [toPath stringByAppendingPathComponent:newItem];
        [[NSFileManager defaultManager] moveItemAtPath:itemFromPath toPath:itemToPath error:&error];
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
    BOOL isExistInFS = [[NSFileManager defaultManager] fileExistsAtPath:path];
    return isExistInFS;
}

+ (BOOL)isExistsFolderAtPath:(NSString *)folderPath
{
    NSError *error;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    BOOL isExistsFolder = content.count > 0;
    return isExistsFolder;
}

#pragma mark - Updater
+ (NSString *)oldPathForSavedReport:(JMSavedResources *)savedResource
{
    NSString *oldPath = @"";
    NSString *documentFolderPath = [self pathToReportsFolder];
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
