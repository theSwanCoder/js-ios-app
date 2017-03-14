/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.0
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JMCoreDataManager : NSObject
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedInstance;

- (BOOL)save:(NSError **)error;

- (void)resetPersistentStore;

- (BOOL)isMigrationNeeded;

- (BOOL)migrate:(NSError *__autoreleasing *)error;

@end
