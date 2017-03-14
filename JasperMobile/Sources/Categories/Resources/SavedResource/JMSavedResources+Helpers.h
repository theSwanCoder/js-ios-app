/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

@import UIKit;
#import "JMSavedResources.h"
#import "JMExportResource.h"


extern NSString * const kJMSavedResources;

@interface JMSavedResources (Helpers)
    // Returns saved resource from JMResource
+ (JMSavedResources *)savedResourceFromResource:(JMResource *)resource;
    
+ (JMSavedResources *)savedResourceWithResourceName:(NSString *)resourceName format:(NSString *)format resourceType:(JMResourceType)resourceType;
    
    // Adds saved resource with path to CoreData
+ (JMSavedResources *)addResource:(JMExportResource *)resource sourcesURL:(NSURL *)sourcesURL;
    
    // Returns YES if resource with name resourceName with format format is absent
+ (BOOL)isAvailableResourceName:(NSString *)resourceName format:(NSString *)format resourceType:(JMResourceType)resourceType;
    
+ (NSArray *)allSavedItems;
    
+ (BOOL)migrateSavedItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
    
    // Rename saved resource
- (BOOL)renameResourceTo:(NSString *)newName;
    
    // Removes saved resource
- (void)removeResource;
    
    // Returns thumbnail image for saved resource
- (UIImage *)thumbnailImage;
    
    // Returns wrapper from SavedResources. Wrapper is a JMResource
- (JMResource *)wrapperFromSavedResources;
    
    // paths
+ (NSString *)uriForSavedResourceWithName:(NSString *)name format:(NSString *)format resourceType:(JMResourceType)resourceType;
    
+ (NSString *)pathToFolderForSavedResource:(JMSavedResources *)savedResource;
+ (NSString *)absolutePathToSavedResource:(JMSavedResources *)savedResource;
    
+ (NSString *)oldPathForSavedResource:(JMSavedResources *)savedResource;
+ (NSString *)newURIForSavedResource:(JMSavedResources *)savedResource;

@end
