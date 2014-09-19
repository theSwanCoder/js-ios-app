//
//  JMSavedResources.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/18/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JMServerProfile;

@interface JMSavedResources : NSManagedObject

@property (nonatomic, retain) NSString * creationDate;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * organization;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * wsType;
@property (nonatomic, retain) NSString * resourceDescription;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) JMServerProfile *serverProfile;

@end
