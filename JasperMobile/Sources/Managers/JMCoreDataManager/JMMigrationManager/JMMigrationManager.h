/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.0
 */

@import Foundation;
@import CoreData;


@class JMMigrationManager;

@protocol JMMigrationManagerDelegate <NSObject>

@optional
- (void)migrationManager:(JMMigrationManager *)migrationManager migrationProgress:(float)migrationProgress;
- (NSArray *)migrationManager:(JMMigrationManager *)migrationManager mappingModelsForSourceModel:(NSManagedObjectModel *)sourceModel;

@end

@interface JMMigrationManager : NSObject

- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                          error:(NSError **)error;

@property (nonatomic, weak) id<JMMigrationManagerDelegate> delegate;

@end
