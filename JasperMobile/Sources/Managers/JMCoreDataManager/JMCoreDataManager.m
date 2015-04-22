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
#import "JMMigrationManager.h"
#import "JMAppUpdater.h"
#import "NSManagedObjectModel+JMAdditions.h"

static NSString * const kJMProductName = @"JasperMobile";

@interface JMCoreDataManager () <JMMigrationManagerDelegate>

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
            options = @{NSInferMappingModelAutomaticallyOption: @YES,
                        NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};
        } else {
            options = @{NSInferMappingModelAutomaticallyOption: @YES,
                        NSSQLitePragmasOption: @{@"journal_mode": @"WAL"}};
        }
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:[self sourceStoreURL]
                                                             options:options
                                                               error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [[NSNotificationCenter defaultCenter] postNotificationName:kJMResetApplicationNotification object:nil];
        }
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Public Api

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
    // Enable migrations to run even while user exits app
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

    JMMigrationManager *migrationManager = [JMMigrationManager new];
    migrationManager.delegate = self;
    
    BOOL migratedSuccessfully = [migrationManager progressivelyMigrateURL:[self sourceStoreURL]
                                                 ofType:NSSQLiteStoreType
                                                toModel:[self managedObjectModel]
                                                  error:error];
    if (migratedSuccessfully) {
        NSLog(@"migration complete");
    }
    
    // Mark it as invalid
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
    
    return (migratedSuccessfully);
}

# pragma mark -  Private Api

- (NSURL *)sourceStoreURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", kJMProductName]];
}

- (NSDictionary *)sourceMetadata:(NSError **)error
{
    return [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                      URL:[self sourceStoreURL]
                                                                    error:error];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jaspersoft.qwerty" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#pragma mark - JMMigrationManagerDelegate

- (void)migrationManager:(JMMigrationManager *)migrationManager migrationProgress:(float)migrationProgress
{
    NSLog(@"migration progress: %f", migrationProgress);
}

- (NSArray *)migrationManager:(JMMigrationManager *)migrationManager
  mappingModelsForSourceModel:(NSManagedObjectModel *)sourceModel
{
    NSMutableArray *mappingModels = [@[] mutableCopy];
//    NSString *modelName = [sourceModel jm_modelName];
//    if ([modelName isEqual:@"Model2"]) {
//        // Migrating to Model3
//        NSArray *urls = [[NSBundle bundleForClass:[self class]]
//                         URLsForResourcesWithExtension:@"cdm"
//                         subdirectory:nil];
//        for (NSURL *url in urls) {
//            if ([url.lastPathComponent rangeOfString:@"Model2_to_Model"].length != 0) {
//                NSMappingModel *mappingModel = [[NSMappingModel alloc] initWithContentsOfURL:url];
//                if ([url.lastPathComponent rangeOfString:@"User"].length != 0) {
//                    // User first so we create new relationship
//                    [mappingModels insertObject:mappingModel atIndex:0];
//                } else {
//                    [mappingModels addObject:mappingModel];
//                }
//            }
//        }
//    }
    return mappingModels;
}
@end
