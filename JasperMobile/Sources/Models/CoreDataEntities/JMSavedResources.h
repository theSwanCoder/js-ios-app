/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JMServerProfile;

@interface JMSavedResources : NSManagedObject

@property (nonatomic, retain) NSDate   * creationDate;
@property (nonatomic, strong) NSDate   * updateDate;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * wsType;
@property (nonatomic, retain) NSString * resourceDescription;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) JMServerProfile *serverProfile;

@end
