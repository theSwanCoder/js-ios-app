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

@class JMServerProfile;


@interface JMFavorites : NSManagedObject

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSDate   * creationDate;
@property (nonatomic, strong) NSDate   * updateDate;
@property (nonatomic, strong) NSString * resourceDescription;
@property (nonatomic, strong) NSString * label;
@property (nonatomic, strong) NSString * uri;
@property (nonatomic, strong) NSString * wsType;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, strong) JMServerProfile *serverProfile;

@end
