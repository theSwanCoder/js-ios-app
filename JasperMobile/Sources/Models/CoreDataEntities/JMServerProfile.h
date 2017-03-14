/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JMFavorites, JMSavedResources;


@interface JMServerProfile : NSManagedObject

@property (nonatomic, strong) NSString * alias;
@property (nonatomic, strong) NSNumber * askPassword;
@property (nonatomic, strong) NSNumber * keepSession;
@property (nonatomic, strong) NSNumber * useVisualize;
@property (nonatomic, strong) NSNumber * cacheReports;
@property (nonatomic, strong) NSString * organization;
@property (nonatomic, strong) NSString * serverUrl;
@property (nonatomic, strong) NSSet *favorites;
@property (nonatomic, strong) NSSet *savedResources;

@end

@interface JMServerProfile (CoreDataGeneratedAccessors)

- (void)addFavoritesObject:(JMFavorites *)value;
- (void)removeFavoritesObject:(JMFavorites *)value;
- (void)addFavorites:(NSSet *)values;
- (void)removeFavorites:(NSSet *)values;

- (void)addSavedResourcesObject:(JMSavedResources *)value;
- (void)removeSavedResourcesObject:(JMSavedResources *)value;
- (void)addSavedResources:(NSSet *)values;
- (void)removeSavedResources:(NSSet *)values;

@end
