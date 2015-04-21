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

//
//  JMCoreDataManager.m
//  TIBCO JasperMobile
//

#import "JMCoreDataManager.h"
#import "JMAppUpdater.h"

static NSString * const kJMProductName = @"JasperMobile";

@interface JMCoreDataManager ()

@property (nonatomic, readwrite, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation JMCoreDataManager

+ (instancetype)sharedInstance
{
    static JMCoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [JMCoreDataManager new];
    });
    return sharedInstance;
}


#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSString *momPath = [[NSBundle mainBundle] pathForResource:kJMProductName ofType:@"momd"];
        if (!momPath) {
            momPath = [[NSBundle mainBundle] pathForResource:kJMProductName ofType:@"mom"];
        }
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momPath]];
    }
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

        NSError *error = nil;
        NSDictionary *options = nil;
        if ([self isMigrationNeeded]) {
            [self migrate:&error];
            options = @{NSInferMappingModelAutomaticallyOption: @YES,
                        NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};
        } else {
            options = @{NSInferMappingModelAutomaticallyOption: @YES,
                        NSSQLitePragmasOption: @{@"journal_mode": @"WAL"}};
        }
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:[self sourceStoreType]
                                                       configuration:nil
                                                                 URL:[self sourceStoreURL]
                                                             options:options
                                                               error:&error]) {
            NSFileManager *fileManager = [NSFileManager new];
            [fileManager removeItemAtPath:[self sourceStoreURL].path error:nil];
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

- (BOOL)save:(NSError **)error
{
    return [self.managedObjectContext save:error];
}

- (void)resetPersistentStore
{
    NSArray *stores = [self.persistentStoreCoordinator persistentStores];
    for (NSPersistentStore *store in stores) {
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    self.persistentStoreCoordinator = nil;
}


# pragma mark -  Private Api

- (BOOL)isMigrationNeeded
{
    NSError *error = nil;
    BOOL isMigrationNeeded = NO;
    
    // Check if we need to migrate
    NSDictionary *sourceMetadata = [self sourceMetadata:&error];
    if (sourceMetadata != nil) {
        NSManagedObjectModel *destinationModel = [self managedObjectModel];
        // Migration is needed if destinationModel is NOT compatible
        isMigrationNeeded = ![destinationModel isConfiguration:nil
                                   compatibleWithStoreMetadata:sourceMetadata];
    }
    NSLog(@"isMigrationNeeded: %d", isMigrationNeeded);
    return isMigrationNeeded;
}

- (BOOL)migrate:(NSError *__autoreleasing *)error
{
    BOOL migratedSuccessfully = YES;
    for (NSString *mappingModelName in [self mappingModelNames]) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:mappingModelName withExtension:@"cdm"];
        
        NSMappingModel *mappingModel = [[NSMappingModel alloc] initWithContentsOfURL:fileURL];
        
        NSArray *bundlesForSourceModel = nil; /* an array of bundles, or nil for the main bundle */
        NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:bundlesForSourceModel
                                                                        forStoreMetadata:[self sourceMetadata:error]];
        if (sourceModel) {
            NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:[self managedObjectModel]];
            
            migratedSuccessfully &= [migrationManager migrateStoreFromURL:[self sourceStoreURL]
                                                                     type:[self sourceStoreType]
                                                                  options:nil
                                                         withMappingModel:mappingModel
                                                         toDestinationURL:[self destinationStoreURL]
                                                          destinationType:[self sourceStoreType]
                                                       destinationOptions:nil
                                                                    error:error];
        }
    }
    // Replace old database with new one
    NSError *fileManagerError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:[self sourceStoreURL] error:&fileManagerError];
    [[NSFileManager defaultManager] moveItemAtURL:[self destinationStoreURL] toURL:[self sourceStoreURL] error:&fileManagerError];
    
    return (migratedSuccessfully && !fileManagerError);
}

- (NSURL *)sourceStoreURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", kJMProductName]];
}

- (NSURL *)destinationStoreURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_New.sqlite", kJMProductName]];
}

- (NSString *)sourceStoreType
{
    return NSSQLiteStoreType;
}

- (NSDictionary *)sourceMetadata:(NSError **)error
{
    return [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:[self sourceStoreType]
                                                                      URL:[self sourceStoreURL]
                                                                    error:error];
}

- (NSArray *)mappingModelNames
{
    NSNumber *latestAppVersion = [JMAppUpdater latestAppVersion];
    NSNumber *currentAppVersion = [JMAppUpdater currentAppVersion];
    if (currentAppVersion != nil && [currentAppVersion compare:latestAppVersion] == NSOrderedSame) return nil;
    
    NSMutableDictionary *versionsToUpdate = [NSMutableDictionary dictionary];
    
    // Add update methods
    [versionsToUpdate setObject:@"Migration_v_1_9" forKey:@1.9];
    [versionsToUpdate setObject:@"Migration_v_2_0" forKey:@2.0];
#warning NEED CHECK SORTED ARRAY!!!!!!!!!!!!!!!!!!!!!!
    NSArray *versionsArray = [versionsToUpdate.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    
    NSLog(@"%@", versionsArray);
    NSMutableArray *mappingModels = [NSMutableArray array];
    
    for (NSNumber *version in versionsArray) {
        if (version.doubleValue <= currentAppVersion.doubleValue) continue;
        [mappingModels addObject:[versionsToUpdate objectForKey:version]];
    }
    return mappingModels;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jaspersoft.qwerty" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
