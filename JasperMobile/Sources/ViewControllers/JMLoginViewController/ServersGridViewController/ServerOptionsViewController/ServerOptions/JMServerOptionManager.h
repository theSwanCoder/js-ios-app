/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <Foundation/Foundation.h>
#import "JMServerProfile.h"
#import "JMServerOption.h"

typedef NS_ENUM(NSInteger, JMServerOptionType) {
    JMServerOptionTypeAlias,
    JMServerOptionTypeURL,
    JMServerOptionTypeOrganization,
    JMServerOptionTypeAskPassword,
    JMServerOptionTypeKeepSession,
    JMServerOptionTypeUseVisualize,
    JMServerOptionTypeCacheReports,
};

extern NSString *const JMCacheReportsOptionDidChangeNotification;

@interface JMServerOptionManager : NSObject
@property (nonatomic, strong) JMServerProfile *serverProfile;
@property (nonatomic, readonly) NSDictionary <NSNumber *, JMServerOption *>*availableOptions;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL isExistingServerProfile;

- (id)initWithServerProfile:(JMServerProfile *)serverProfile;

- (BOOL)isValidData;
- (NSString *)urlSchemeForServerProfile;
- (void) saveChanges;
- (void) discardChanges;

@end
